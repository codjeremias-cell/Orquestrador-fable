---
name: springboot-repository-service
description: Cria o repositório Spring Data JPA e a camada de serviço (caso de uso) de uma entidade no track Java Web/Spring Boot (Gradup e afins) — queries com join fetch para evitar N+1, serviço com injeção por construtor, @Transactional por leitura/escrita, e o serviço nunca devolve a entidade JPA (sempre mapeia para record de leitura). Acione quando o usuário disser coisas como "cria o repositório de Curso", "preciso do serviço que cadastra Categoria", "monta a query com filtro de Curso", "tira essa regra do controller", em projeto Spring Boot. NÃO acione para a entidade/migração (use springboot-entity) nem para o controller/tela (use springboot-controller-thymeleaf).
---

# Spring Boot — Repositório + Serviço (caso de uso)

## Objetivo

Implementar o acesso a dados (Spring Data JPA) e a regra de negócio (serviço/caso de uso) de uma
entidade, no padrão real validado no Gradup (`CourseRepository`, `CourseAuthoringService`): queries
explícitas com `join fetch`, serviço fino que nunca vaza a entidade JPA para fora do módulo.

## Entradas obrigatórias

1. Entidade alvo (já criada pela `springboot-entity`, ou o arquivo dela).
2. Operações desejadas (buscas com filtro, criar, editar, listar por dono/empresa, etc.).
3. O(s) DTO/record de leitura que o serviço deve devolver (ou autorização para propor um).

## Entradas opcionais

- Regras de negócio explícitas e mensagens de erro para violação de invariante.
- Se alguma operação precisa de projeção (leitura em lote enxuta, sem carregar a entidade inteira).

## Trava obrigatória

- Não gerar sem a entidade real e suas colunas confirmadas (RO-01).
- Serviço que devolveria a entidade JPA direto para fora do módulo → parar e propor o record de
  leitura em vez disso (RO-SB4 — a view nunca recebe entidade JPA).

## Leituras obrigatórias (RO-01)

1. A entidade alvo (`springboot-entity`) — campos, tipos, relacionamentos reais.
2. Um repositório já existente do módulo/projeto para copiar o estilo de `@Query`/projeção.
3. Um serviço já existente para copiar o padrão de injeção, transação e exceção de negócio.

## Convenções obrigatórias (Track Java Web/Spring Boot)

**Repositório:**
- Interface `extends JpaRepository<Entidade, Long>` em `com.<app>.<modulo>.infrastructure`.
- Query customizada com `@Query` em **text block** (`"""..."""`) + `@Param`; usar **`join fetch`**
  sempre que a query for devolver a entidade e acessar um `@ManyToOne` dela (evita N+1).
- Métodos derivados simples (`existsBySlug`, `countByPublishedTrue`) quando bastam — só usar
  `@Query` quando o derivado não expressa a regra.
- **Projeção de interface** (ex.: `interface CourseAdminProjection { ... }`) para leituras em lote
  que não precisam da entidade completa.

**Serviço (`com.<app>.<modulo>.application`):**
- `@Service`, **injeção por construtor** (campos `private final`, sem `@Autowired` em campo, sem
  Lombok `@RequiredArgsConstructor`).
- **`@Transactional(readOnly = true)`** em métodos de leitura; **`@Transactional`** simples em
  métodos de escrita (RO-SB3 — operação multi-passo é atômica).
- Violação de invariante de negócio: `.orElseThrow(() -> new IllegalArgumentException("mensagem
  clara"))` — sem hierarquia de exceção customizada a menos que o projeto já tenha uma.
- **Nunca devolve a entidade JPA.** Todo retorno público é um **record** de leitura, montado dentro
  do próprio método de serviço (`.map(this::toCard)` ou `new Record(...)` direto) — RO-SB4.
- Record de leitura já traz campos "prontos para a view" (rótulo/classe CSS calculados no serviço,
  não deixados para o template decidir).

## Fluxo

1. Confirmar entidade, operações e o(s) record(s) de leitura.
2. Ler a entidade, um repositório e um serviço de referência (RO-01).
3. Escrever o repositório: métodos derivados simples primeiro; `@Query` + `join fetch` para o
   resto; projeção quando a leitura for em lote e enxuta.
4. Escrever o serviço: construtor com as dependências, métodos de leitura (`readOnly`) e escrita
   (transacional), validação de invariante, mapeamento para record antes de devolver.
5. Escrever teste do serviço no padrão do projeto: `@SpringBootTest` +
   `@EnabledIfEnvironmentVariable(named = "DB_URL", matches = ".+")` contra o Postgres real
   (RO-SB8) — o teste roda só quando a variável está definida, então `mvn test` sem banco não
   quebra.
6. Rodar `mvn test` (com e sem `DB_URL`, se possível) e reportar arquivos e suposições.

## Regras de implementação

- Repositório não tem regra de negócio; serviço não tem SQL direto (delega ao repositório).
- Serviço não conhece `Model`, `HttpServletRequest` nem nada da camada `web` — recebe parâmetros
  primitivos/record e devolve record.
- Módulo só acessa outro módulo pela interface pública (serviço/fachada) dele, nunca pela tabela ou
  classe interna alheia (regra de dependência do track: aponta para dentro).

## Guardrails

- Nunca devolver `List<Entidade>`/`Entidade` de um método público do serviço — sempre record.
- Nunca `@OneToMany` "resolvido" via `getX().size()` no lugar de uma query própria no repositório.
- Não inventar assinatura de repositório/entidade não confirmada (RO-01).
- Não deixar operação multi-passo sem `@Transactional`.

## Saída esperada

- Repositório em `infrastructure`, serviço em `application`, record(s) de leitura.
- Teste do serviço gated por `DB_URL` seguindo RO-SB8.
- `mvn test` executado como evidência (declarar se `DB_URL` não estava setada e o teste foi pulado
  — SKIP declarado, não sucesso simulado).

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: paginar uma listagem que hoje devolve tudo; adicionar índice para
uma query de filtro frequente; extrair uma projeção nova se a tela só precisar de 2-3 campos).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (limite entre `application`/`infrastructure`) · `dev-senior` (query e transação corretas).
- **Vem antes:** `springboot-entity` (a entidade que este repositório/serviço usa).
- **Vem depois:** `springboot-controller-thymeleaf` (a tela chama o serviço, nunca o repositório direto).
- **Não confundir com:** `java-jdbc-dao`/`java-service-usecase` (mesmo papel, mas no track desktop JavaFX/JDBC puro).
