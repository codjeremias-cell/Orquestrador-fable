---
name: spec-mobile-app
description: "Orquestrador do track MOBILE, Flutter-first: conduz um app de celular da ideia à entrega — descoberta, escolha de stack, arquitetura em camadas UI/Data com repositório abstrato, design com mockups aceitos — e cobre scaffold, features e conector Firebase. Acione com \"quero fazer um app mobile completo\", \"construir um aplicativo Flutter do início ao fim\", \"app de celular da ideia à publicação nas lojas\", \"conduz o projeto do app inteiro\", \"app Android/iOS novo\". NÃO acione fora disso — se a plataforma NÃO for mobile, spec-projeto-completo; se for desktop, spec-desktop-app (moderno) ou spec-javafx-new-system (JavaFX). NÃO acione para etapa isolada — use mobile-flutter-scaffold, mobile-flutter-feature ou mobile-flutter-firebase."
---

# Spec — App Mobile (orquestrador do track, Flutter-first)

Orquestradora do **track mobile (Flutter-first)** — medido com juiz cego em **2026-07-09**
(0,38 → 0,98; `evals/placar-baseline.md`) e roteado nominalmente por `spec-projeto-completo`. Espelha o
`spec-projeto-completo`, mas especializada em mobile: conduz da ideia crua ao app entregue com prova,
aplicando o método dos geradores do track (`mobile-flutter-scaffold`, `mobile-flutter-feature`,
`mobile-flutter-firebase`) e às lentes do Comitê, validando cada etapa. Não duplica o trabalho
detalhado das filhas.

## Quando usar / Quando NÃO usar

Use **esta** quando o alvo é um app de **celular** (Android/iOS) inteiro. Se a plataforma for outra, a filha certa é outra:

- Plataforma **indefinida**, ou web/API/CLI → `spec-projeto-completo`.
- **Desktop** moderno (Tauri/Avalonia/Electron) → `spec-desktop-app`; **desktop JavaFX** → `spec-javafx-new-system`.
- Mobile+desktop do **mesmo código** Flutter: comece aqui (este é o dono de Flutter); `spec-desktop-app` faz **handoff** para cá nesse caso.
- Só **uma etapa** (só o scaffold, só uma feature, só o Firebase) → `mobile-flutter-scaffold`, `mobile-flutter-feature`, `mobile-flutter-firebase`.

## Objetivo

Entregar um app mobile de ponta a ponta — requisitos → arquitetura/stack → design → scaffold →
backend → N features → testes reais → segurança → doc/release — aderente às [[REGRAS-DE-OURO]]
(RI + RO universais + **RO-FL1 a RO-FL4** do track Mobile/Flutter, que a fonte ainda marca como
proposta de 2026-07-07 a validar contra projeto real — RO-01).

## Entradas obrigatórias

1. A ideia/objetivo do app (mesmo em uma frase — a descoberta dá forma) e o público.
2. Autorização para recomendar a stack na etapa de arquitetura (default **Flutter**) ou a stack já
   escolhida.

## Entradas opcionais

- Restrições (prazo, offline/online, orçamento, lojas-alvo), backend preferido (Firebase default;
  Supabase = alternativa), se quer parecer de negócio, custom claims/roles.

## Validação do catálogo

Confirmar que existem as skills das etapas aplicáveis; se faltar uma crítica, **parar** e dizer qual
e para qual papel:
`requisitos-descoberta` · `consultor-negocios-apps` (opcional) · `arquiteto-software` ·
**`arquiteto-dados`** (modelo + rules do Firestore) · `designer-ux-ui` · `mobile-flutter-scaffold` ·
`mobile-flutter-firebase` · `mobile-flutter-feature` · `especialista-seguranca` · `testador-real` ·
`qa-usabilidade` · `docs-projeto` · `auditor-responsabilidades` · (opcional) `orquestrador-fable`
para o loop de qualidade.

## Sequência determinística

> **Invoque, não descreva.** Cada passo abaixo que cita uma skill exige
> **carregá-la pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** Carregue a skill `requisitos-descoberta` (ferramenta Skill — invoque, não descreva) → requisitos + corte de MVP. *Gate: Jeremias aprovou o MVP.*
2. **Negócio (quando visa mercado/loja).** Carregue a skill `consultor-negocios-apps` (ferramenta Skill — invoque, não descreva) → parecer. *Gate: viável ou ressalvas aceitas.*
3. **Arquitetura + escolha de stack.** Carregue a skill `arquiteto-software` (ferramenta Skill — invoque, não descreva): default **Flutter** (RN = track paralelo futuro); define camadas UI/Data, **repositório abstrato**, estado (Riverpod default; Bloc se domínio regulado), backend (Firebase default). carregue **`arquiteto-dados`** (ferramenta Skill) para desenhar o **modelo de dados** e o rascunho das **security rules** já aqui. Em seguida carregue **`especialista-seguranca`** (ferramenta Skill — invoque, não descreva) para **auditar o modelo enquanto ele ainda é barato de mudar**: campo que o cliente controla e o servidor deveria (`createdAt`/`updatedAt` → `request.time`), campo que o dono não pode reescrever, e o que a posse ancora — caminho ou atributo. *Gate: ADR de stack + modelo de dados registrados; toda origem-de-verdade de campo temporal ou de posse **decidida aqui**, não no passo 9.*
4. **Design.** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva; + referência **Impeccable**) → mockups de todas as telas do MVP com estados vazio/carregando/erro. *Gate: mockups aceitos (RO-06) — antes de qualquer código de UI.*
5. **Scaffold.** Carregue a skill `mobile-flutter-scaffold` (ferramenta Skill — invoque, não descreva; via Very Good CLI/Mason quando disponível). *Gate: `flutter analyze`/`flutter run` verdes.*
6. **Backend/conector.** Carregue a skill `mobile-flutter-firebase` (ferramenta Skill — invoque, não descreva) → Auth (stream certo por caso), `FirestoreRepository`, Storage e **security rules starter** nascendo com o modelo. `especialista-seguranca` audita as rules. *Gate: rules default-deny + repositórios compilando; rules testadas no emulador ou SKIP declarado.*
7. **Features (N×).** Carregue a skill `mobile-flutter-feature` (ferramenta Skill — invoque, não descreva) para cada vertical (repo abstrato + `freezed` + `AsyncNotifier` + Screen + rota + testes), cada uma amarrada ao mockup e ao modelo. *Gate por feature: `flutter test` verde + critérios de aceite da história.*
8. **Testes de verdade.** Carregue a skill `testador-real` (ferramenta Skill — invoque, não descreva); ela executa estática (`flutter analyze`, `flutter test`, `dart run build_runner`) + dinâmica (`integration_test`/app no emulador). Carregue a lente `qa-usabilidade` (ferramenta Skill — invoque, não descreva) para o defeito de uso e a a11y das telas do MVP. *Gate: relatório datado sem FAIL crítico aberto.*
9. **Segurança.** Carregue a skill `especialista-seguranca` (ferramenta Skill — invoque, não descreva); ela revisa rules, Auth (anti-enumeração), dados sensíveis (LGPD) e **App Check** antes de publicar. *Gate: sem achado crítico/alto aberto **e todo `RISCO ACEITO` nomeado ao Jeremias** — risco aceito não se dilui entre os "baixos"; havendo a seção, o veredito é **liberar com ressalvas**, nunca liberar limpo.*
10. **Loop de qualidade (nota ≥ 9).** Comitê + `testador-real` dão nota; **iterar correção → reteste** até **nota ≥ 9** ou o limite de rodadas — pode ser **delegado ao `orquestrador-fable`** (maestro multi-modelo) ou rodado como loop leve aqui. *Gate: nota ≥ 9 ou decisão consciente do Jeremias registrada.*
11. **Documentação + Release.** `docs-projeto` (README/manual/changelog) + build do stack (`flutter build appbundle`/`ipa`) + ciclo git completo. *Gate: comandos do README testados; artefato gerado.*
12. **Gate final.** Carregue a skill `auditor-responsabilidades` (ferramenta Skill — invoque, não descreva); ela audita RI/RO, evidências e responsabilidades → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (requisitos → arquitetura; modelo de dados → rules
  e features; mockups → telas; relatório do testador → auditor). Nada de etapa decorativa.
- **Feature fica backend-agnóstica** atrás do repositório abstrato — o Firebase entra só na impl
  (etapa 6 alimenta a 7). Trocar de backend não toca UI/notifier.
- **As rules nascem com o modelo** (`arquiteto-dados` na etapa 3, materializadas na 6) — nunca
  "depois que der tempo".
- **RN é track paralelo futuro:** não forçar agora; se o requisito empurrar para RN, registrar como
  decisão e track a criar ([[PADRAO-DE-AUTORIA]] §8), não improvisar.
- Pedido pequeno não vira burocracia: etapas 2 e 9 podem ser puladas **declaradamente** quando não
  se aplicam — pular em silêncio, não.

## Verificação da spec (autossuficiência)

Antes de sair do design (etapa 4) para o scaffold, confira que a spec do app se sustenta sozinha — o porquê: sem fronteira e sem critério de aceite, o app nasce cobrindo coisa fora do alvo e "pronto" fica sem prova. A spec responde **sim** a:

- **Escopo** — plataformas-alvo (Android/iOS), stack (ADR), modelo de dados e as telas/features do MVP estão listados?
- **Fora-de-escopo** — o que fica para depois (telas, integrações, lojas, custom claims) está declarado?
- **Critério de aceite ponta-a-ponta** — há, por feature, um caminho verificável de fora (ex.: "usuário loga → cria item → aparece na lista → relança o app e persiste, respeitando as rules") que o `flutter test`/`integration_test` prove?

Faltando qualquer item, volte à etapa correspondente antes do scaffold.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Stack, backend ou primeira feature ambíguos após a etapa correspondente.
- Modelo de dados indefinido ao chegar nas rules (etapa 6) — rules exigem o modelo.
- Mockup não aprovado; rules não `default-deny`; spec sem escopo/fora-de-escopo/critério de aceite (ver acima).
- Falta de skill filha crítica no catálogo.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas executadas e skills/lentes usadas · artefatos criados (caminhos exatos —
RO-03) · evidências por gate (MVP aprovado, ADR de stack + modelo, mockups aceitos,
`analyze`/`test` verdes, rules default-deny, relatório do testador, nota do loop, análise de
segurança, build) · pendências e limitações · **2–3 sugestões de evolução (RO-07)** · veredito do
`auditor-responsabilidades`.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas — este orquestrador é o mapa de quando cada uma entra; destaque para `arquiteto-dados` (modelo + rules do Firestore) e `especialista-seguranca` (rules = firewall); `auditor-responsabilidades` fecha.
- **Vem antes:** nada — é o ponto de partida quando o pedido é "o app mobile inteiro" (ou `spec-desktop-app`, que faz handoff para cá no caso mobile+desktop Flutter).
- **Vem depois:** `memoria-de-projeto` (registrar decisões/lições e as RO do track a oficializar) · `inovacao-melhorias` (retrospectiva e próximos ganhos).
- **Não confundir com:** `spec-projeto-completo` (ciclo universal, qualquer plataforma — este é o especializado em mobile) · `spec-desktop-app`/`spec-javafx-new-system` (desktop) · `orquestrador-fable` (maestro de execução multi-modelo que este pode chamar no loop de qualidade, não uma sequência de track).

### 📜 Histórico
- **2026-08-19 (2) — a lente de segurança entra no passo 3, onde a decisão ainda é barata (T45; degrau §6.10: 1 — só edição).** Medido: nas duas rodadas tratadas da bancada T15 o `especialista-seguranca` foi **invocado**, e mesmo assim as *security rules* **empataram** com o braço que não o invocou (18×18). O total escondia o oposto de equivalência — o braço tratado tinha **o melhor e o pior**: 10/10/10 numa rodada e **9/8/8** na outra, a pior das quatro. O defeito concreto: aquela rodada foi **a única sem nenhuma ocorrência de `request.time`**, checando só o *tipo* do timestamp, de modo que o cliente escolhia o próprio `createdAt` — que é o campo de ordenação. **E a lente não foi cega:** catalogou como F6, categoria OWASP, STRIDE-R, severidade **baixa** com contra-evidência defensável e gatilho de reabertura escrito. Ela **viu e aceitou**. O mecanismo, provado por comparação interna ao próprio braço: sobre a **mesma ameaça**, ela escreveu *"mitigado nas rules"* onde o design já usava `request.time` e *"baixo, trade-off aceito"* onde não usava — **a lente ratifica a decisão de design, não a determina**, porque chegava no passo 9 com as rules já nascidas. A emenda a chama **junto do `arquiteto-dados`**, no passo que desenha o modelo, com o gate exigindo que origem-de-verdade de campo temporal e de posse seja decidida ali. Não resolve tudo: um achado rebaixado a "baixo" com contra-evidência continua passando o gate por construção, e dar marca própria a ele é emenda separada, no contrato da lente. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-19 — `qa-usabilidade` ganha call site: a T39 corrigiu dois dos quatro (degrau §6.10: 1 — só edição).** A T39 fechou declarando **"0 lentes sem call site nos sete"**, e a varredura de 2026-08-19 mediu **duas** sobrando — aqui e na `spec-projeto-completo`. `qa-usabilidade` era citada **uma única vez**, na lista de *Validação do catálogo*, sem passo nenhum que a chamasse: prometida como skill de etapa aplicável, e sem etapa. A T39 varreu o campo **"Lentes que ativam junto"** da Rede, onde esta skill diz apenas *"todas"* — por isso a promessa que mora na *Validação do catálogo* passou invisível. Corrigido sem inventar passo, pela mesma fórmula da T39: entrou no passo **8**, que já era o de prova executada. **A bancada T15 mediu o efeito antes da correção:** `qa-usabilidade` disparou **2/2** nas rodadas tratadas e **0/3** nas de controle — ou seja, ela vinha sendo puxada pelo *"Comitê"* genérico do passo 10, **por sorte de redação e não por call site**, e some inteira quando o callout não está lá. Mesma família de [[verificar-presenca-nao-e-verificar-efeito]]: a declaração existia, o gate a lia como cumprida. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.
- **2026-08-11 — O eval alinhado à decisão da T29 (degrau §6.10: 1 — só edição).** A skill dizia no corpo que **não** encadeia (medido: aciona 6/6, delega 0/6) e o `evals/evals.json` **reprovava por não delegar** — a skill contradizia a si mesma. A expectativa passou a medir o **resultado** (as camadas cumprindo o método do gerador), não a **rota**. Decisão do Jeremias, estendida da description aos testes. Proveniência: `_auditoria/zelador-inventario-2026-08-10.md` e `_auditoria/zelador-custo-2026-08-08.md`.

- **2026-08-11 — Rótulo "proposta" trocado pelo estado medido, e as RO do track citadas por número.** Proveniência: `_auditoria/zelador-inventario-2026-08-10.md`, ATUALIZAR item 11. O cabeçalho dizia "proposta 2026-07-07" e o §Objetivo dizia que as RO do track "são propostas nesta rodada" — as duas envelheceram: `evals/placar-baseline.md` registra medição com juiz cego em 2026-07-09 (0,38 → 0,98), e as RO existem nomeadas em REGRAS-DE-OURO.md como **RO-FL1 a RO-FL4**. A ressalva foi preservada, não apagada: a fonte ainda marca o bloco como proposta de 2026-07-07 a validar contra projeto real (RO-01) — afirmar oficialização criaria divergência com o canônico. A parte da ação que mandava mexer em `evals/evals.json` ficou **fora do escopo deste lote** e não foi aplicada — mas registre-se o que a conferência achou: a expectativa `"Delega scaffold/backend/features aos geradores do track em vez de escrever à mão"` **existe**, literal, na linha 15 do `evals/evals.json`, exatamente onde o laudo apontou. A refutação genérica de 2026-08-10 ("nenhum evals.json exige delegação") **não vale para esta skill** e precisa ser rejulgada, porque essa expectativa contradiz o comportamento medido e aceito em 2026-08-09 (acionou 6/6, delegou 0/6).
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. O texto passa a dizer *aplicar o método*, que é o comportamento real; os geradores seguem existindo e invocáveis. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- *(Seção de Histórico criada nesta data — a skill não tinha nenhuma, e sem ela a proveniência da RI-04 não tem onde morar.)*
