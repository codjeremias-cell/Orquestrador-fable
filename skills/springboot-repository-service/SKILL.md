---
name: springboot-repository-service
description: "Camada de dados e regra de negócio de um CRUD Spring, a segunda das três: cria o repositório Spring Data JPA e a camada de serviço (caso de uso) de uma entidade no track Java Web/Spring Boot. Acione com \"cria o repositório de Curso\", \"preciso do serviço que cadastra Categoria\", \"monta a query com filtro de Curso\", \"tira essa regra do controller\", \"faz o serviço de X\". NÃO acione fora disso — para a entidade/migração, use springboot-entity; para o controller/tela, use springboot-controller-thymeleaf."
---

# Spring Boot — Repositório + Serviço (caso de uso)

**Camada no CRUD:** dados + regra de negócio. É a 2ª das três camadas — `springboot-entity` (domínio) →
**esta** (repositório + serviço) → `springboot-controller-thymeleaf` (tela). O serviço é a fronteira
pública do módulo: a tela fala com ele, não com o repositório.

## Objetivo

Implementar o acesso a dados (Spring Data JPA) e a regra de negócio (serviço/caso de uso) de uma
entidade, no padrão real validado no Gradup (`CourseRepository`, `CourseAuthoringService`): queries
explícitas com `join fetch`, serviço fino que nunca vaza a entidade JPA para fora do módulo (RO-SB4).

## Princípio: espelhar o projeto-alvo (Gradup = a casa validada)

As convenções abaixo são o padrão real do Gradup — se o projeto-alvo é o Gradup ou segue a mesma
casa, siga-as: é acerto, não escolha. Se for um Spring Boot de **outra casa** (ex.: usa Lombok, outra
estrutura de pacotes, outra política de exceção), leia um artefato existente do projeto e espelhe o
padrão dele, declarando onde diverge do Gradup (RI-04). Separe sempre o que é **invariante**
(segurança/correção — não varia porque quebrá-lo introduz bug de performance, transação ou
vazamento) do que é **estilo da casa** (varia — espelhe o que o projeto já usa).

- **Invariante (não varia):** `join fetch` quando a query acessa `@ManyToOne` (sem ele, cada linha
  dispara uma query extra — o N+1); `@Transactional(readOnly=true)` em leitura e transação atômica em
  escrita multi-passo (senão uma falha no meio deixa dado inconsistente); serviço não vaza entidade
  JPA para fora do módulo (evita lazy-loading fora de transação e acoplamento ao domínio).
- **Estilo da casa (espelhe):** injeção por construtor × `@RequiredArgsConstructor`, política de
  exceção (`IllegalArgumentException` × exceção customizada), forma do record — o Gradup usa
  construtor puro + `IllegalArgumentException`.

## Entradas obrigatórias

1. Entidade alvo (já criada pela `springboot-entity`, ou o arquivo dela).
2. Operações desejadas (buscas com filtro, criar, editar, listar por dono/empresa, etc.).
3. O(s) DTO/record de leitura que o serviço deve devolver (ou autorização para propor um).

## Entradas opcionais

- Regras de negócio explícitas e mensagens de erro para violação de invariante.
- Se alguma operação precisa de projeção (leitura em lote enxuta, sem carregar a entidade inteira).

## Trava obrigatória

- Não gerar sem a entidade real e suas colunas confirmadas (RO-01).
- Serviço devolvendo a entidade JPA para fora do módulo → parar e propor o record de leitura (RO-SB4
  — ver Convenções).

## Leituras obrigatórias (RO-01)

1. A entidade alvo (`springboot-entity`) — campos, tipos, relacionamentos reais.
2. Um repositório já existente do módulo/projeto para copiar o estilo de `@Query`/projeção.
3. Um serviço já existente para copiar o padrão de injeção, transação e exceção de negócio.

## Convenções obrigatórias (Track Java Web/Spring Boot)

**Repositório:**
- Interface `extends JpaRepository<Entidade, Long>` em `com.<app>.<modulo>.infrastructure`.
- Query customizada com `@Query` em **text block** (`"""..."""`) + `@Param`; use **`join fetch`**
  sempre que a query devolver a entidade e acessar um `@ManyToOne` dela (sem ele vem o N+1).
- Métodos derivados simples (`existsBySlug`, `countByPublishedTrue`) quando bastam — só parta para
  `@Query` quando o derivado não expressa a regra.
- **Projeção de interface** (ex.: `interface CourseAdminProjection { ... }`) para leituras em lote
  que não precisam da entidade completa (carrega só as colunas usadas).
- **Índice: decisão DOCUMENTADA com gatilho, nunca índice criado por reflexo.** O javadoc da query de
  listagem registra o inventário de índices atual, **por que NÃO criar agora** (com a tabela pequena o
  planner tende ao seq scan — índice seria otimização prematura) e o **GATILHO explícito** de quando
  criar ("quando passar de ~alguns milhares de linhas, ou a latência do GET incomodar").

**Serviço (`com.<app>.<modulo>.application`):**
- `@Service`, **injeção por construtor** (campos `private final`, sem `@Autowired` em campo — o
  construtor deixa as dependências explícitas e o objeto imutável/testável). O Gradup não usa Lombok
  `@RequiredArgsConstructor`, mas isso é estilo-da-casa: se a casa-alvo já adota, espelhe-a (RI-04,
  `evals.json` caso 2). O invariante é injeção por **construtor**, não a ausência de Lombok.
- **`@Transactional(readOnly = true)`** em métodos de leitura; **`@Transactional`** simples em
  métodos de escrita (RO-SB3 — operação multi-passo precisa ser atômica).
- Violação de invariante de negócio: `.orElseThrow(() -> new IllegalArgumentException("mensagem
  clara"))` — sem hierarquia de exceção customizada a menos que o projeto já tenha uma.
- **Nunca devolve a entidade JPA.** Todo retorno público é um **record** de leitura, montado dentro
  do próprio método de serviço (`.map(this::toCard)` ou `new Record(...)` direto) — RO-SB4. Devolver
  a entidade acoplaria a camada de cima ao domínio e arriscaria lazy-loading fora de transação.
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

- Lista inversa é query própria no repositório, não `@OneToMany`/`getX().size()` (que carregaria a
  coleção toda) — ver `springboot-entity`.
- Não invente assinatura de repositório/entidade não confirmada (RO-01).

## Saída esperada

- Repositório em `infrastructure`, serviço em `application`, record(s) de leitura.
- Teste do serviço gated por `DB_URL` seguindo RO-SB8.
- `mvn test` executado como evidência (declarar se `DB_URL` não estava setada e o teste foi pulado
  — SKIP declarado, não sucesso simulado).

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: paginar uma listagem que hoje devolve tudo; **documentar o gatilho de
índice** de uma query de filtro frequente — inventário + porquê de não criar agora, ver Convenções;
extrair uma projeção nova se a tela só precisar de 2-3 campos).

**Gabarito Gradup (few-shot de código real):** projeto-alvo sendo o **Gradup ou família Spring Boot**, carregue `referencia-exemplos-reais-gradup.md` — CourseRepository/CatalogService verbatim + convenções reais (repo em `infrastructure`, serviço/DTOs em `application`; `@Query` JPQL em text block com `join fetch` anti-N+1 e filtros `:param is null or ...`; projeção por interface p/ consulta em lote; injeção por construtor `private final`; `@Transactional(readOnly=true)` em toda leitura; serviço NUNCA devolve entidade JPA — mapeia para record via `toCard`; decisão de índice documentada com GATILHO explícito de quando criar). O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Verificação de fechamento (RI-04)

Sem evidência, não está pronto. Esta skill entrega **repositório + serviço** — pergunte-se e comprove:

1. **Compila?** `mvn -q compile` verde — assinaturas de repositório, serviço e records batem.
2. **O contexto Spring sobe e a consulta roda?** O teste `@SpringBootTest` gated por
   `@EnabledIfEnvironmentVariable(DB_URL)` sobe o contexto contra o Postgres real (RO-SB8): é a prova
   de que o repositório encontra a tabela, a `@Query`/`join fetch` executa e o serviço devolve o
   record esperado. Verde quando `DB_URL` está setada; **SKIP declarado com o motivo** quando não está
   (`mvn test` sem banco não quebra), nunca "passou" fingido.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (limite entre `application`/`infrastructure`) · `dev-senior` (query e transação corretas).
- **Vem antes:** `springboot-entity` (a entidade que este repositório/serviço usa).
- **Vem depois:** `springboot-controller-thymeleaf` (a tela chama o serviço, nunca o repositório direto).
- **Não confundir com:** `java-jdbc-dao`/`java-service-usecase` (mesmo papel, mas no track desktop JavaFX/JDBC puro).

### 📜 Histórico
- **2026-08-11 — Regra de índice migrada da referência para o corpo (inventário do catálogo, `_auditoria/zelador-inventario-2026-08-10.md`, grupo "regra que precisa migrar"):** a pérola da casa — decisão de índice documentada com inventário, porquê de não criar agora e **gatilho** explícito — morava só em `referencia-exemplos-reais-gradup.md §3`, que não carrega em automação; virou bullet em Convenções/Repositório com a nuance copiada da referência. §Sugestões passou de "adicionar índice para uma query de filtro frequente" para "documentar o gatilho de índice", que era o reflexo contrário ao da própria skill. `description` intocada.
- **2026-08-09 — `description` comprimida (campanha das 61; degrau §6.10: 1).** Registro retroativo: a compressão foi aplicada e **não foi anotada aqui na época**, contra o §6 princípio 9 do [[PADRAO-DE-AUTORIA]], que exige o patch na fonte **com** registro. Achado do inventário de 2026-08-10, padrão transversal 5. Frases-gatilho e fronteira preservadas.
- **2026-07-20 — Polimento de disparo e verificação:** descrição reescrita para nomear a **camada** (dados + regra de negócio, 2ª de 3) e a **fronteira** com as skills irmãs logo no gatilho; caixa alta rígida atenuada e cada invariante ganhou o **porquê** (join fetch contra N+1; transação atômica para não deixar dado inconsistente; não vazar entidade para evitar lazy-loading fora de transação e acoplamento); fechamento reorganizado em 2 perguntas concretas (compila? o contexto Spring sobe e a consulta roda?). Sem mudança de código ou convenção.
- **2026-07-18 — Evolução ao 9,5 (núcleo Gradup):** princípio **espelhar-o-projeto** explicitado (Gradup = casa validada; Spring de outra casa → leia e espelhe, RI-04) + separação **invariante × estilo-da-casa** + seção de fechamento RI-04 consolidada + **eval executável** (`evals/evals.json`, 2 casos: Gradup × outra casa Spring — prova o espelho). Mesma receita que levou o núcleo SIGO ao 9,5. **Auto-verificada** contra os defeitos convergentes do painel SIGO (sem seção "Tensão" velha; teste de fechamento condicional com SKIP declarado; corpo↔referência coerentes — a referência reforça o corpo, não o contradiz). **Painel de 3 juízes adiado por limite de budget semanal**; promovida por ser estritamente melhor que a versão live (teto honesto ~9,2), sem regressão.
- **2026-07-18 — Few-shot de código real (onda Gradup/Spring Boot):** criada `referencia-exemplos-reais-gradup.md` (fonte: `catalog/infrastructure/CourseRepository.java`+`application/CatalogService.java`). Baseline §11: geração sem gabarito acertou repo/serviço/readOnly mas divergiu na projeção por interface p/ lote, no record de leitura obrigatório e — sobretudo — na convenção-pérola de documentar índice com gatilho em vez de criar por reflexo. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens A5-A7; −3 linhas.
