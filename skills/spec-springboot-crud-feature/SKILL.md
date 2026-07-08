---
name: spec-springboot-crud-feature
description: Orquestra a criação de uma funcionalidade CRUD completa no track Java Web/Spring Boot (Gradup e afins), do domínio à tela — encadeando entidade+migração Flyway, repositório+serviço e controller+template Thymeleaf — e garantindo as Regras de Ouro do stack (RO-SB1…8). Acione quando o usuário disser coisas como "cria a funcionalidade completa de Curso", "preciso do CRUD de Categoria ponta a ponta", "monta tudo dessa entidade: banco, serviço e tela", em projeto Spring Boot. NÃO acione para uma única camada isolada — para isso use springboot-entity, springboot-repository-service ou springboot-controller-thymeleaf.
---

# Spec — Funcionalidade CRUD Spring Boot (orquestrador)

Orquestradora do track Java Web/Spring Boot: conduz, em ordem determinística, a criação de uma
funcionalidade completa, delegando às skills especializadas do track e validando cada etapa. Não
duplica o trabalho detalhado delas.

## Objetivo

Entregar, de ponta a ponta, uma funcionalidade de uma entidade — domínio + migração + repositório
+ serviço + tela — aderente às [[REGRAS-DE-OURO]] do track (RO-SB1…8).

## Entradas obrigatórias

1. Nome da entidade/módulo e seus atributos.
2. Relacionamentos (`@ManyToOne`) e tabela/colunas reais (ou autorização para propor).
3. Operações desejadas (criar, listar, editar, buscas/filtros).
4. Confirmação de que a funcionalidade inclui tela Thymeleaf.

## Entradas opcionais

- Regras de negócio específicas, DTO/record de leitura já definido, navegação/menu.

## Validação do catálogo

Confirmar que existem no catálogo as skills filhas:

- `springboot-entity`
- `springboot-repository-service`
- `springboot-controller-thymeleaf`

Se faltar uma skill crítica, **parar** e informar qual faltou e para qual papel.

## Sequência determinística

Executar em ordem; validar cada etapa antes de seguir.

1. **Mockup primeiro (RO-06).** Apresentar o mockup da tela e obter aceite do Jeremias.
2. **Domínio.** Acionar `springboot-entity` para a entidade + migração Flyway (`V<N>__*.sql`).
3. **Persistência e regra de negócio.** Acionar `springboot-repository-service` para o repositório
   (com `join fetch` onde precisar) e o(s) serviço(s) que a tela vai chamar, com o record de
   leitura já definido.
4. **Tela.** Acionar `springboot-controller-thymeleaf` para o controller (`@Controller`, nunca
   `@RestController`) e o template (a11y completa, CSRF automático, tokens).
5. **Fechamento com prova.** Rodar `mvn test` (a suíte gated por `DB_URL` mais o `@WebMvcTest` sem
   banco); varredura de hex fora de `tokens.css`; quando existir bateria HTTP do testador do
   projeto, acioná-la para a funcionalidade nova.

## Regras de coerência

- Nomes consistentes entre entidade, migração, repositório, serviço, controller e template
  (mesmo slug/rota em todas as camadas).
- Reaproveitar o padrão real do projeto (fragments, classes `gu-*`, `SecurityConfig`) — descobrir
  por leitura, nunca inventar (RO-01).
- A view **nunca** recebe a entidade JPA (RO-SB4) — só o record de leitura do serviço.
- Operação multi-passo = transação atômica (RO-SB3); dependência do módulo aponta para dentro.

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Tabela/colunas ou regra de negócio ambíguas.
- Mockup não aprovado.
- Falha em `mvn test`/`@WebMvcTest` obrigatório.

## Formato do relatório final (RI-05)

Resumo objetivo: skills usadas · arquivos criados/alterados (caminho exato — RO-03) · testes
executados (com/sem `DB_URL`) · o que foi validado · pendências/limitações · **2–3 sugestões de
evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito.

## Saída esperada

- Entidade + migração; repositório + serviço(s) + teste gated por `DB_URL`; controller + template
  Thymeleaf + teste `@WebMvcTest`. Funcionalidade CRUD funcional de ponta a ponta, aderente às
  Regras de Ouro do track (RO-SB1…8).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup) · `especialista-seguranca` (CSRF, autorização) · `qa-usabilidade`/`auditor-responsabilidades` (fechamento e veredito).
- **Vem antes:** projeto Spring Boot já com Flyway/Security configurados (o Gradup já tem — RO-SB1…8 na [[REGRAS-DE-OURO]]).
- **Vem depois:** o testador do projeto (bateria HTTP) · `docs-projeto`.
- **Não confundir com:** `spec-javafx-crud-feature` (mesmo papel, track desktop JavaFX) · `spec-projeto-completo` (ciclo de vida inteiro, não só uma feature).
