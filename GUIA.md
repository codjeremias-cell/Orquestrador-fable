# Guia do Catálogo — as 48 skills e como o orquestrador as rege

Referência rápida do `Catalogo-Skills-Unificado` (2026-07-07). Cada skill com sua função em uma linha, agrupada por papel. No fim, como o `orquestrador-fable` trabalha com elas.

---

## 🔬 Lentes do método (9) — *como pensar*, poliglotas, disparam por gatilho

Não executam; **decidem e revisam**. Formam o Comitê de Lentes.

1. **arquiteto-software** — estrutura macro do sistema: estilos/padrões, ISO 25010, SOLID/DDD, C4/ADR, sempre por trade-off explícito.
2. **arquiteto-dados** — arquitetura de dados: modelagem relacional/dimensional/NoSQL, evolução de schema sem downtime, particionamento, contratos de dados.
3. **dev-senior** — clareza do código (qualquer linguagem): Clean Code, algoritmos, testes, e a **implementação/tuning** do acesso a banco.
4. **designer-ux-ui** — a lente do usuário: fluxos, UI, Design Tokens, WCAG, estados de tela, referência Impeccable, loop anti-"AI slop", data-viz.
5. **especialista-seguranca** — AppSec/time vermelho: STRIDE, OWASP, LGPD, superfície de ataque.
6. **qa-usabilidade** — veredito de qualidade: projeta os casos e o critério (a **execução** é do testador).
7. **inovacao-melhorias** — melhoria contínua: Kaizen/PDCA, MVP, dívida técnica, "andaime tem prazo de validade".
8. **auditor-responsabilidades** — gate final: DoD, faz cumprir as RI/RO, veredito explícito (aprovado/ressalvas/reprovado).
9. **consultor-negocios-apps** — o app como negócio: mercado, monetização, retenção, go-to-market.

## 🧠 Memória e estado (2) — *contexto entre sessões*

10. **memoria-de-projeto** — arquivo portável de preferências, lições e costumes (*como* trabalhamos).
11. **estado-projeto** — estado de tarefas retomável (`estado.json` + `TAREFAS.md`): *onde cada tarefa está*.

## 🌍 Ciclo de vida universal (2) — *da ideia à entrega, qualquer plataforma*

12. **requisitos-descoberta** — transforma ideia vaga em requisitos com MVP, histórias e aceite verificável.
13. **docs-projeto** — README, guia de instalação, manual do usuário, doc técnica/ADR, changelog — do código real.

## 🧪 Testadores (2) — *EXECUTAM a prova, não entregam checklist*

14. **testador-real** — testador executor universal: bateria estática + dinâmica com evidência PASS/FAIL/SKIP, relatório datado; nunca simula sucesso.
15. **gradup-testador** — instância do testador para o Gradup (Spring Boot/HTTP).

## 🎼 Orquestradores (8) — *conduzem várias skills*

16. **orquestrador-fable** — o **maestro** multi-modelo: planeja, delega a subagentes (Opus/Sonnet/Haiku), avalia pelo Comitê + testador e itera até nota ≥ 9 (detalhes abaixo).
17. **spec-projeto-completo** — orquestrador universal (qualquer plataforma): da ideia ao sistema entregue, passando por todas as etapas.
18. **spec-javafx-new-system** — sistema Java/JavaFX do zero (Maven vazio → app rodando e empacotado).
19. **spec-javafx-crud-feature** — uma funcionalidade CRUD completa no track Java/JavaFX (domínio → tela).
20. **spec-springboot-crud-feature** — CRUD completo no track Java Web/Spring Boot (entidade → tela).
21. **spec-mobile-app** — app mobile (Flutter-first) da ideia à entrega.
22. **spec-frontend-web** — frontend web de ponta a ponta (requisitos → mockups → stack → tokens → componentes → data-layer → testes).
23. **spec-desktop-app** — app desktop moderno, com árvore de decisão de stack (Tauri v2 padrão; Avalonia/Electron/Flutter conforme o caso).

> Diferença: os `spec-` encadeiam skills **em ordem determinística** (a sequência do track); o `orquestrador-fable` decide **quem executa** (modelos/subagentes) e **quanta qualidade sai** (loop com nota de corte). Combinam: um subagente pode rodar um `spec-` inteiro como subtarefa.

## ⚙️ Geradores — Track Java / JavaFX desktop (11) — *scaffolders precisos do stack*

24. **java-project-bootstrap** — esqueleto do projeto Java desktop JavaFX com Maven (pom, estrutura, pronto pra compilar/empacotar).
25. **java-db-foundation** — fundação de acesso a banco: provedor de conexão (segredos fora do git), utilitários, retry.
26. **javafx-app-shell** — casca do app: janela principal, navegação, alertas PT-BR, controller-base.
27. **java-javafx-entity** — entidade/modelo de domínio (POJO com validação).
28. **java-jdbc-dao** — DAO/repositório JDBC com SQL parametrizado (anti-injection).
29. **java-service-usecase** — camada de serviço (regra de negócio) fora do controller.
30. **javafx-screen-fxml** — tela JavaFX (FXML + controller) com mockup antes do código e estados vazio/carregando/erro.
31. **javafx-dashboard** — dashboards/painéis JavaFX de excelência (executivo/operacional/decisão).
32. **javafx-theme-tokens** — tema visual por tokens de cor em CSS (claro/escuro), sem hex solto.
33. **java-logging-log4j2** — logging Log4j 2 padronizado (fim do printStackTrace/System.out).
34. **java-package-desktop** — empacota em .exe Windows com JRE embutido (jpackage sobre fat-jar).

## ⚙️ Geradores — Track Java Web / Spring Boot (3)

35. **springboot-entity** — entidade JPA + migração Flyway (sem Lombok, sem setter público).
36. **springboot-repository-service** — repositório Spring Data + serviço transacional.
37. **springboot-controller-thymeleaf** — tela (controller @Controller + template Thymeleaf acessível).

## ⚙️ Geradores — Track Mobile / Flutter (3) — *proposta, validar no código real*

38. **mobile-flutter-scaffold** — esqueleto Flutter feature-first (camadas UI/Data), via Very Good CLI/Mason.
39. **mobile-flutter-feature** — feature completa: repositório abstrato + impl, modelo `freezed`, `AsyncNotifier` (Riverpod), tela, rota, testes.
40. **mobile-flutter-firebase** — conector Firebase: `flutterfire configure`, AuthRepository, FirestoreRepository, Storage, security rules default-deny.

## ⚙️ Geradores — Track Web Frontend (4) — *proposta, validar no código real*

41. **frontend-stack-decisor** — decide o stack por gatilho (SEO/login/estático/interativo → Next/Vite/Astro/Svelte/Vue).
42. **design-tokens-gen** — token-system nomeado em W3C DTCG → Tailwind v4 `@theme` (operacionaliza as leis da lente designer).
43. **web-component** — componente = comportamento a11y (Radix/Base UI/React Aria) + tokens + fronteira a11y invariável.
44. **web-data-layer** — separa server-state (TanStack Query) de client-state (Zustand/Jotai) com schema Zod único como contrato.

## ⚙️ Geradores — Track Desktop / Tauri (3) — *proposta, validar no código real*

45. **desktop-tauri-scaffold** — projeto base Tauri v2 (segurança default-deny, bridge tipada, updater, CI).
46. **desktop-feature-crud** — entidade desktop fim-a-fim a partir de `{entidade, campos}`: migração SQLite up + comando + binding tipado + tela.
47. **desktop-packaging** — instaladores por SO + assinatura + auto-update (GitHub Releases; Velopack no caminho .NET).

## 🧩 Blueprints (1)

48. **assistente-deterministico** — subsistema de assistente offline (sem LLM): busca tolerante + motor de documentos, parametrizável por projeto.

---

## 🎼 Como o `orquestrador-fable` trabalha com todas elas

O maestro **nunca executa — decide**. Ele usa as outras 47 skills em papéis distintos, num ciclo que repete até a qualidade:

**Passo 0 — Triagem (comece simples).** Classifica a tarefa e escolhe o loop mais leve que resolve: etapa isolada → a skill direta; sequência determinística de um stack → o `spec-` do track; entrega grande com risco → o ciclo completo abaixo.

**1. Planejamento (Fable).** Decompõe em subtarefas, cada uma com: objetivo, **qual skill do catálogo aplicar** (um gerador, um `spec-`, `docs-projeto`…), **qual modelo** (Opus para o pesado, Sonnet para o intermediário, Haiku para o volume) e o critério de aceite. Em trabalho multi-sessão, carrega o **`estado-projeto`** para retomar.

**2. Execução (subagentes).** Delega cada subtarefa a um subagente que **aplica a skill designada** — ex.: um subagente roda `springboot-entity`, outro `mobile-flutter-feature`, outro um `spec-` inteiro. Dispara em paralelo, com **largura de onda adaptativa** (piloto antes de onda grande; larga para Haiku, estreita para Opus/Fable) até 20 simultâneos (~30 só Haiku), ondas sequenciais acima disso.

**3. Consolidação (Fable).** Integra as entregas num resultado coeso (nada cai no vão).

**4. Comitê de Lentes.** As **7 lentes de revisão** (`arquiteto-software`, `arquiteto-dados`, `designer-ux-ui`, `dev-senior`, `especialista-seguranca`, `qa-usabilidade`, `inovacao-melhorias`) avaliam **em paralelo**, cada uma nota 0–10 + críticas; o **`auditor-responsabilidades`** consolida e emite o placar. Lente sem pertinência é dispensada declaradamente. Se a entrega tem UI, entra o **juiz de visão** (o designer em modo visão critica o screenshot).

**5. Testador Real.** O **`testador-real`** (ou a instância do projeto, ex.: `gradup-testador`) EXECUTA a bateria e traz evidência PASS/FAIL/SKIP — a prova entra no placar.

**6. Decisão (Fable).** Todas as notas ≥ 9 e sem FAIL crítico → **entrega**. Senão, transforma cada crítica em replanejamento (escala **modelo** se faltou saber, **effort** se faltou rigor; captura lacuna recorrente como melhoria do sistema) e volta ao passo 1. Para em nota atingida **ou** 10 rodadas. Ao fim de cada rodada, persiste o progresso no **`estado-projeto`**.

Transversais: **`memoria-de-projeto`** carrega o contexto no início; a **contabilidade de tokens por modelo** sai no relatório final; tudo é auditado pelas **REGRAS-DE-OURO** (RI-01…06 + RO por track).

> Em uma frase: as **lentes** decidem e revisam, os **geradores** produzem no stack certo, os **`spec-`** encadeiam a sequência de um track, o **testador** prova, a **memória/estado** dão continuidade — e o **`orquestrador-fable`** rege quem faz o quê, com que modelo, e itera até a excelência.
