---
name: spec-projeto-completo
description: "Orquestrador universal de projeto completo, para QUALQUER plataforma (desktop, web, mobile, API, CLI): conduz da ideia ao sistema entregue passando por descoberta e requisitos, parecer de negócio quando fizer sentido, arquitetura, design, construção e testes. Acione com \"quero construir um sistema/app completo\", \"do início ao fim\", \"da ideia à entrega\", \"conduz o projeto inteiro\", \"faz tudo: requisitos, código, testes e entrega\". NÃO acione para feature isolada em projeto existente (spec-javafx-crud-feature/spec-springboot-crud-feature) nem para uma única etapa."
---

# Spec — Projeto Completo (orquestrador universal, qualquer plataforma)

Esta é a **orquestradora de topo do ciclo de vida inteiro**: da ideia crua ao sistema entregue com prova. Ela não sabe construir nada sozinha — sabe **em que ordem** as skills e lentes do catálogo entram, o que valida cada etapa e quando parar. Onde existir track de geradores para o stack (ex.: Java/JavaFX), delega ao track; onde não existir, as **lentes poliglotas** conduzem a construção com o mesmo rigor.

## Quando usar / Quando NÃO usar

Use **esta** skill quando o pedido é o **projeto inteiro** e você ainda é o ponto de partida (a plataforma pode nem estar decidida). É também o **roteador**: assim que o alvo se concretiza, faça handoff para o track dedicado — esta não reconstrói o que a filha faz melhor.

| Situação | Skill correta |
|---|---|
| Sistema completo, plataforma indefinida / API / CLI / backend + front + deploy juntos | **spec-projeto-completo** (esta) |
| Sistema desktop **novo** JavaFX/Access, do zero ao `.exe`/`.msi` | `spec-javafx-new-system` |
| App desktop **novo** moderno, não-JavaFX (Tauri/Avalonia/Electron/Flutter) | `spec-desktop-app` |
| App **mobile** (celular) inteiro | `spec-mobile-app` |
| Só o **frontend web** (backend já pronto expondo REST) | `spec-frontend-web` |
| Uma **feature CRUD** num projeto que **já existe** | `spec-javafx-crud-feature` / `spec-springboot-crud-feature` |
| Uma **única etapa** (só a arquitetura, só o design, só uma camada) | a skill/lente da etapa |

## Objetivo

Entregar um projeto de ponta a ponta — requisitos → arquitetura → design → construção → testes reais → segurança → documentação → release — aderente às [[REGRAS-DE-OURO]] (RI + RO universais + RO do track quando houver).

## Entradas obrigatórias

1. A ideia/objetivo do sistema (mesmo em uma frase — a etapa 1 dá forma).
2. Plataforma-alvo (desktop, web, mobile, API, CLI) ou autorização para recomendá-la na etapa de arquitetura.

## Entradas opcionais

- Restrições (prazo, stack, offline/online, orçamento), sistemas com que convive, se quer o parecer de negócio.

## Validação do catálogo

Confirmar que existem as skills das etapas aplicáveis; se faltar uma crítica, **parar** e dizer qual e para qual papel: `requisitos-descoberta` · `consultor-negocios-apps` (opcional) · `arquiteto-software` · `designer-ux-ui` · `dev-senior` · `especialista-seguranca` · `testador-real` (ou o testador do projeto) · `qa-usabilidade` · `docs-projeto` · `auditor-responsabilidades` · e o track do stack quando existir (ex.: `spec-javafx-new-system`).

## Sequência determinística

> **Invoque, não descreva.** Cada passo abaixo que cita uma skill exige
> **carregá-la pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** Carregue a skill `requisitos-descoberta` (ferramenta Skill — invoque, não descreva) → documento de requisitos. *Gate: Jeremias aprovou o corte de MVP.*
2. **Negócio (quando o produto visa mercado/usuários pagantes).** Carregue a skill `consultor-negocios-apps` (ferramenta Skill — invoque, não descreva) → parecer. *Gate: veredito viável ou ressalvas aceitas conscientemente.*
3. **Arquitetura.** Carregue a skill `arquiteto-software` (ferramenta Skill — invoque, não descreva) → estrutura, stack recomendado com trade-offs, ADRs, não funcionais mensuráveis. *Gate: decisão de stack/estrutura registrada (ADR). Se o stack tiver track dedicado, **handoff** — ver a tabela acima.*
4. **Design.** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva) → fluxos e mockups de todas as telas do MVP com estados. *Gate: mockups aceitos (RO-06) — antes de qualquer código de UI.*
5. **Construção.** Com track do stack: carregue a skill do track pela ferramenta Skill e conduza por ela (ex.: `spec-javafx-new-system` faz bootstrap→banco→shell→features→empacote). Sem track: carregue `dev-senior` (ferramenta Skill) e conduza por feature, com as RO universais (segredos fora do git, dados parametrizados, transação atômica, estados cobertos, logging decente). *Gate por feature: build verde + critérios de aceite da história atendidos.*
6. **Testes de verdade.** Carregue a skill `testador-real` (ferramenta Skill — invoque, não descreva; ou o testador do projeto); ela executa as baterias estática + dinâmica. Carregue a lente `qa-usabilidade` (ferramenta Skill — invoque, não descreva) para o defeito de uso e a a11y das telas entregues. *Gate: relatório datado sem FAIL crítico aberto.*
7. **Segurança.** Carregue a skill `especialista-seguranca` (ferramenta Skill — invoque, não descreva); ela revisa superfície, autenticação, dados sensíveis (LGPD) — obrigatório antes de expor qualquer coisa publicamente. *Gate: sem achado crítico/alto aberto **e todo `RISCO ACEITO` nomeado ao Jeremias** — risco aceito não se dilui entre os "baixos"; havendo a seção, o veredito é **liberar com ressalvas**, nunca liberar limpo.*
8. **Documentação.** Carregue a skill `docs-projeto` (ferramenta Skill — invoque, não descreva) → README + manual do usuário + changelog da versão. *Gate: comandos do README testados.*
9. **Release.** Empacotamento/publicação do stack, carregando a skill do empacotador pela ferramenta Skill (ex.: `java-package-desktop` no desktop; deploy do track web) + ciclo git completo (RO-13). *Gate: artefato final aberto/acessado com sucesso.*
10. **Gate final.** Carregue a skill `auditor-responsabilidades` (ferramenta Skill — invoque, não descreva); ela audita RI/RO, evidências e responsabilidades → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (requisitos alimentam arquitetura; mockups amarram a construção; o relatório do testador alimenta o auditor) — nada de etapa decorativa.
- Plataforma sem track de geradores ⇒ as lentes assumem, e as convenções validadas viram candidatas a track novo ([[PADRAO-DE-AUTORIA]] §8).
- Pedido pequeno não vira burocracia: etapas 2 e 8 podem ser puladas **declaradamente** quando não se aplicam — pular em silêncio, não.

## Portão de fase e disciplina da lista *(2026-08-08, garimpo system-prompts · `Kiro`)*

**Portão de aprovação entre fases.** Cada fase entrega seu artefato e **para**, pedindo aprovação explícita.
Só avança com afirmativa clara ("aprovado", "pode seguir", "ok"); qualquer outra coisa — inclusive silêncio,
elogio ou pergunta — **não é aprovação**. Vindo correção: revisa, reapresenta e **pede de novo**, quantas vezes
forem. E oferece **voltar** de fase sempre que uma lacuna de fase anterior aparecer: descobrir na arquitetura que
faltava requisito é motivo para reabrir requisitos, não para improvisar.

> É a trava que impede a spec correr sozinha até o código. O custo de uma fase errada cresce com o quadrado da
> distância até onde ela é descoberta.

**Disciplina da lista de tarefas:**

- **Rastreabilidade em mão dupla** — todo requisito mapeia para **ao menos uma** tarefa, e toda tarefa **cita** o
  requisito que serve. Uma direção só deixa passar requisito órfão (ninguém constrói) ou tarefa órfã (alguém
  constrói o que não foi pedido). Hoje a `auditor-responsabilidades` **cobra** isso na entrega — aqui passa a ser
  **exigido de quem produz**, que é onde custa barato.
- **A lista contém trabalho automatizável** — escrever, alterar ou **testar** código, incluindo a bateria do
  `testador-real`. Fica **fora**: sessão com usuário, decisão de negócio, aprovação, deploy manual. Não porque
  não importem, mas porque não são executáveis por quem segue a lista — e item não executável trava a lista sem
  avisar.
- **No máximo dois níveis** de hierarquia (`1`, `1.1`), nunca três. O terceiro nível é sempre sintoma: ou a tarefa
  raiz é grande demais, ou a folha é pequena demais.
- **Reler os três documentos antes de cada tarefa** — requisitos, arquitetura e lista, sempre, mesmo na décima
  tarefa seguida. É o antídoto do agente que passa a decidir pela memória da conversa em vez do que está escrito;
  a memória deriva, o documento não.

## Verificação da spec (autossuficiência)

Antes de sair da descoberta/arquitetura para a construção, confira que a spec produzida se sustenta sozinha — o porquê: uma spec que não define fronteira gera código fora do alvo e "pronto" impossível de conferir. Só passe do gate 4 para o 5 quando a spec responder **sim** a:

- **Escopo** — o que o MVP faz está listado (features, telas, plataforma-alvo)?
- **Fora-de-escopo** — o que ele explicitamente **não** faz nesta entrega está registrado (evita gold-plating e escopo infinito)?
- **Critério de aceite ponta-a-ponta** — existe, por feature do MVP, ao menos **um** critério verificável de fora (ex.: "criar Cliente → aparece na listagem → editar → excluir", ou "GET /pedidos devolve 200 com o pedido criado"), e não só "a tela existe"?

Se qualquer resposta for "não", volte à etapa correspondente antes de codar.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Requisitos, stack ou primeira feature ambíguos após a etapa correspondente.
- Spec sem escopo, fora-de-escopo ou critério de aceite verificável (ver acima).
- Falta de skill crítica no catálogo.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas executadas e skills usadas · artefatos criados (caminhos exatos — RO-03) · evidências por gate (requisitos aprovados, ADRs, mockups aceitos, builds, relatório do testador, análise de segurança, release) · pendências e limitações · **2–3 sugestões de evolução (RO-07)** · veredito do auditor.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas — este orquestrador é o mapa de quando cada uma entra; `auditor-responsabilidades` fecha.
- **Vem antes:** nada — é o ponto de partida quando o pedido é "o projeto inteiro".
- **Vem depois:** `memoria-de-projeto` (registrar decisões e lições do ciclo) · `inovacao-melhorias` (retrospectiva e próximos ganhos).
- **Não confundir com:** `spec-javafx-new-system` (track JavaFX do zero — prefira-o quando o alvo já é desktop JavaFX) · `spec-desktop-app` (desktop moderno não-JavaFX) · `spec-mobile-app` (mobile) · `spec-frontend-web` (só o front) · `spec-javafx-crud-feature`/`spec-springboot-crud-feature` (uma feature num projeto existente).

### 📜 Histórico
- **2026-08-19 — `qa-usabilidade` ganha call site: a T39 corrigiu dois dos quatro (degrau §6.10: 1 — só edição).** A T39 fechou declarando **"0 lentes sem call site nos sete"**, e a varredura de 2026-08-19 mediu **duas** sobrando — aqui e na `spec-mobile-app`. `qa-usabilidade` era citada **uma única vez**, na lista de *Validação do catálogo*, sem passo nenhum que a chamasse: prometida como skill de etapa aplicável, e sem etapa. A T39 varreu o campo **"Lentes que ativam junto"** da Rede; a promessa que mora na *Validação do catálogo* passou invisível. Corrigido sem inventar passo, pela mesma fórmula da T39: entrou no passo **6**, que já era o de prova executada. Aqui **não há medição própria** — o efeito foi medido na `spec-mobile-app` pela bancada T15, onde a lente disparava 2/2 no braço tratado e 0/3 no controle, puxada pelo *"Comitê"* genérico e não por call site. Mesma família de [[verificar-presenca-nao-e-verificar-efeito]]: a declaração existia, o gate a lia como cumprida. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.

- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. O texto passa a dizer *aplicar o método*, que é o comportamento real; os geradores seguem existindo e invocáveis. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- *(Seção de Histórico criada nesta data — a skill não tinha nenhuma, e sem ela a proveniência da RI-04 não tem onde morar.)*
