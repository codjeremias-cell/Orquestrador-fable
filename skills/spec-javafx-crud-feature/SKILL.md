---
name: spec-javafx-crud-feature
description: "Orquestra a criação de UMA funcionalidade CRUD completa numa entidade, em projeto Java/JavaFX que JÁ EXISTE, do domínio à tela — cobrindo entidade, DAO JDBC, serviço, tela FXML e logging, e garantindo as Regras de Ouro do stack. Acione com \"cria a funcionalidade completa de Cliente\", \"preciso do CRUD de Funcionário ponta a ponta\", \"monta tudo dessa entidade: domínio, banco e tela\", \"faz a feature inteira de Produto\", \"feature\". NÃO acione fora disso — é para UMA feature num sistema existente — se for um SISTEMA JavaFX NOVO do zero (projeto, banco, shell, empacotamento), use spec-javafx-new-system; se o stack for Spring Boot web, use spec-springboot-crud-feature; se a 'feature' for um painel de KPIs, quem conduz a tela é javafx-dashboard. NÃO acione para uma única camada isolada — para isso use a skill específica do track."
---

# Spec — Funcionalidade CRUD JavaFX (orquestrador)

Esta skill é uma **orquestradora**. Conduz, em ordem determinística, a criação de uma funcionalidade CRUD completa num projeto Java/JavaFX **já existente**, aplicando o método das skills especializadas do track e validando cada etapa. Não duplica o trabalho detalhado delas.

## Quando usar / Quando NÃO usar

Use **esta** para **uma** feature (uma entidade) num app JavaFX **que já roda**. Se a fronteira for outra:

- Sistema JavaFX **novo** do zero (projeto vazio → banco → shell → empacotado) → `spec-javafx-new-system`.
- Mesmo papel, mas stack **Spring Boot web** → `spec-springboot-crud-feature`.
- A "feature" é um **painel de KPIs/dashboard** → `javafx-dashboard` conduz a tela.
- Só **uma camada** (só a entidade, só o DAO, só a tela) → a skill específica do track.

## Objetivo

Entregar, de ponta a ponta, uma funcionalidade de uma entidade: domínio + persistência + regra de negócio + tela, respeitando as [[REGRAS-DE-OURO]] do track Java/JavaFX.

## Entradas obrigatórias

1. Nome da entidade e seus atributos.
2. Tabela/colunas reais (ou autorização para descobrir no projeto).
3. Operações desejadas (criar, listar, editar, excluir, buscas).
4. Confirmação de que a funcionalidade inclui tela.

## Entradas opcionais

- Regras de negócio específicas, navegação/menu, validações de formulário.

## Validação do catálogo

Antes de começar, confirmar que existem no catálogo as skills filhas (ajuste o caminho real de instalação):

- `java-javafx-entity`
- `java-jdbc-dao`
- `java-service-usecase`
- `javafx-screen-fxml`
- `java-logging-log4j2`

Se faltar uma skill crítica, **parar** e informar qual faltou e para qual papel.

## Sequência determinística

> **Invoque, não descreva.** Cada passo abaixo que cita um gerador exige
> **carregar a skill pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; validar cada etapa antes de seguir.

1. **Mockup primeiro (RO-06).** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva) → mockup da tela com os estados vazio/carregando/erro; obter aceite do Jeremias antes de qualquer código.
2. **Entidade.** Carregue a skill `java-javafx-entity` (ferramenta Skill — invoque, não descreva) e crie a entidade + teste.
3. **Persistência.** Carregue a skill `java-jdbc-dao` (ferramenta Skill — invoque, não descreva) e crie o DAO (SQL parametrizado, try-with-resources, colunas explícitas, transação onde precisar, retry nas operações críticas).
4. **Regra de negócio.** Carregue a skill `java-service-usecase` (ferramenta Skill — invoque, não descreva) e crie os casos de uso que a tela vai chamar.
5. **Tela.** Carregue a skill `javafx-screen-fxml` (ferramenta Skill — invoque, não descreva) e crie FXML + controller (estados vazio/carregando/erro, banco em `Task`, tokens de tema, FXML frágil respeitado).
6. **Logging.** Carregue a skill `java-logging-log4j2` (ferramenta Skill — invoque, não descreva) e garanta que erros usam Log4j 2 (sem `printStackTrace`/`System.out`).
7. **Fechamento com prova.** Rodar build/testes relevantes; conferir a feature de ponta a ponta. Quando existir bateria aplicável, acionar `testador-real` (ou o testador do projeto) — a evidência do gate é teste **executado**, não checklist (RI-04). Carregue a lente `qa-usabilidade` (ferramenta Skill — invoque, não descreva) para o defeito de uso e a a11y da tela nova.

## Regras de coerência

- Manter nomes consistentes entre entidade, DAO, serviço, controller e FXML.
- Reaproveitar o padrão real do projeto (controller-base, AlertaUtil, provedor de conexão, RetryDB, CSS de tema) — descobrir por leitura, nunca inventar (RO-01).
- Operação multi-passo = transação atômica; UI nunca congela (RO-J1).

## Verificação da spec da feature (autossuficiência)

Antes do código (após o mockup), confira que a feature está especificada de forma autossuficiente — o porquê: sem escopo e critério de aceite, a feature vaza para operações que ninguém pediu e "pronto" fica sem prova. A spec responde **sim** a:

- **Escopo** — entidade, atributos, tabela/colunas e operações (criar/listar/editar/excluir/buscas) estão definidos?
- **Fora-de-escopo** — o que esta feature **não** faz (relatórios, integrações, outras entidades) está declarado?
- **Critério de aceite ponta-a-ponta** — há um caminho verificável de fora — ex.: "criar um registro → aparece na listagem → editar → excluir → some" — que o fechamento com prova (passo 7) execute de verdade (RI-04)?

Faltando qualquer item, resolva antes de começar a entidade.

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Tabela/colunas ou regra de negócio ambíguas.
- Mockup não aprovado; feature sem escopo/fora-de-escopo/critério de aceite (ver acima).
- Falha em build/teste obrigatório.

## Formato do relatório final (RI-05)

Ao concluir, entregar resumo objetivo: skills usadas · arquivos criados/alterados (com caminho exato — RO-03) · testes executados · o que foi validado · pendências/limitações · **2–3 sugestões de evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito.

## Saída esperada

- Entidade + teste; DAO; serviço(s) + teste; FXML + controller; logging padronizado.
- Funcionalidade CRUD funcional de ponta a ponta, aderente às Regras de Ouro do track.

**Exemplo montado real (SIGO):** carregue `referencia-exemplo-montado-sigo.md` — a feature **Viagem** existe ponta a ponta e é o gabarito da SEQUÊNCIA deste orquestrador (entidade→DAO→serviço→tela→carga), cada elo citando o arquivo real e a skill que o gera. Amarra as referências `referencia-exemplos-reais-sigo.md` das skills do track. O padrão real vence o genérico (RO-01).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06) · `qa-usabilidade` e `auditor-responsabilidades` (fechamento e veredito).
- **Vem antes:** projeto com fundação pronta (`java-db-foundation`, `javafx-app-shell`, tema por tokens).
- **Vem depois:** `testador-real` (bateria da feature) · `docs-projeto` (se a feature muda o manual).
- **Não confundir com:** `spec-javafx-new-system` (sistema inteiro do zero) · `spec-springboot-crud-feature` (mesmo papel, track Spring Boot web) · `javafx-dashboard` (se a "feature" for um painel de KPIs, é ele quem conduz a tela).

### 📜 Histórico
- **2026-08-18 (2) — As duas lentes declaradas ganham call site (T39; degrau §6.10: 1 — só edição).** Mesmo defeito medido na irmã `spec-springboot-crud-feature`, e encontrado aqui por leitura estática, sem bancada: a Rede declarava três lentes em **"Lentes que ativam junto (RI-06)"** e **duas não eram chamadas por passo nenhum**. `designer-ux-ui` entrou no passo 1 — que já era o do mockup RO-06 e não carregava a lente que faz mockup — e `qa-usabilidade` no passo 7, o de fechamento com prova. Nenhum passo novo foi criado. O par de CRUD (esta e a de Spring) eram **os dois únicos desviantes** dos sete orquestradores; os outros cinco já chamavam todas as lentes que declaravam. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.
- **2026-08-11 — O eval alinhado à decisão da T29 (degrau §6.10: 1 — só edição).** A skill dizia no corpo que **não** encadeia (medido: aciona 6/6, delega 0/6) e o `evals/evals.json` **reprovava por não delegar** — a skill contradizia a si mesma. A expectativa passou a medir o **resultado** (as camadas cumprindo o método do gerador), não a **rota**. Decisão do Jeremias, estendida da description aos testes. Proveniência: `_auditoria/zelador-inventario-2026-08-10.md` e `_auditoria/zelador-custo-2026-08-08.md`.
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **encadear/delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. Os passos passam a dizer *criar X — método em `gerador`*, que é o comportamento real; os geradores seguem existindo e invocáveis. Escolha do Jeremias entre alinhar a promessa e forçar a delegação — alinhar venceu porque a saída medida é boa. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- **2026-07-18 — Exemplo montado real (orquestrador):** criada `referencia-exemplo-montado-sigo.md` mapeando a feature/sistema real (SIGO/Gradup) através da sequência que este orquestrador encadeia — capstone que amarra os few-shots das skills do track. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
