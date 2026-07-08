---
name: spec-mobile-app
description: "Orquestrador do track mobile (Flutter-first): conduz um app de celular da ideia à entrega — descoberta/requisitos, escolha de stack (default Flutter; React Native como track paralelo futuro), arquitetura (camadas UI/Data + repositório abstrato), design com mockups aceitos, e então dispara o scaffold + N features + o conector Firebase, aplicando as lentes (arquiteto-software, arquiteto-dados para o modelo e as rules do Firestore, dev-senior, designer-ux-ui, especialista-seguranca), chamando o testador-real e iterando até nota ≥ 9. Acione quando o usuário disser coisas como \"quero fazer um app mobile completo\", \"construir um aplicativo Flutter do início ao fim\", \"app de celular da ideia à publicação\", \"conduz o projeto do app inteiro\". NÃO acione para uma etapa isolada — use mobile-flutter-scaffold, mobile-flutter-feature ou mobile-flutter-firebase. Se a plataforma-alvo não for mobile, prefira spec-projeto-completo."
---

# Spec — App Mobile (orquestrador do track, Flutter-first)

Orquestradora do **track mobile (Flutter-first, proposta 2026-07-07)**. Espelha o
`spec-projeto-completo`, mas especializada em mobile: conduz da ideia crua ao app entregue com prova,
delegando aos geradores do track (`mobile-flutter-scaffold`, `mobile-flutter-feature`,
`mobile-flutter-firebase`) e às lentes do Comitê, validando cada etapa. Não duplica o trabalho
detalhado das filhas.

## Objetivo

Entregar um app mobile de ponta a ponta — requisitos → arquitetura/stack → design → scaffold →
backend → N features → testes reais → segurança → doc/release — aderente às [[REGRAS-DE-OURO]]
(RI + RO universais; as RO específicas do track mobile são propostas nesta rodada e confirmadas com
o Jeremias no Claude Code).

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

Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** `requisitos-descoberta` → requisitos + corte de MVP. *Gate: Jeremias aprovou o MVP.*
2. **Negócio (quando visa mercado/loja).** `consultor-negocios-apps` → parecer. *Gate: viável ou ressalvas aceitas.*
3. **Arquitetura + escolha de stack.** `arquiteto-software`: default **Flutter** (RN = track paralelo futuro); define camadas UI/Data, **repositório abstrato**, estado (Riverpod default; Bloc se domínio regulado), backend (Firebase default). **`arquiteto-dados`** desenha o **modelo de dados** e o rascunho das **security rules** já aqui. *Gate: ADR de stack + modelo de dados registrados.*
4. **Design.** `designer-ux-ui` (+ referência **Impeccable**) → mockups de todas as telas do MVP com estados vazio/carregando/erro. *Gate: mockups aceitos (RO-06) — antes de qualquer código de UI.*
5. **Scaffold.** `mobile-flutter-scaffold` (via Very Good CLI/Mason quando disponível). *Gate: `flutter analyze`/`flutter run` verdes.*
6. **Backend/conector.** `mobile-flutter-firebase` → Auth (stream certo por caso), `FirestoreRepository`, Storage e **security rules starter** nascendo com o modelo. `especialista-seguranca` audita as rules. *Gate: rules default-deny + repositórios compilando; rules testadas no emulador ou SKIP declarado.*
7. **Features (N×).** `mobile-flutter-feature` para cada vertical (repo abstrato + `freezed` + `AsyncNotifier` + Screen + rota + testes), cada uma amarrada ao mockup e ao modelo. *Gate por feature: `flutter test` verde + critérios de aceite da história.*
8. **Testes de verdade.** `testador-real` executa estática (`flutter analyze`, `flutter test`, `dart run build_runner`) + dinâmica (`integration_test`/app no emulador). *Gate: relatório datado sem FAIL crítico aberto.*
9. **Segurança.** `especialista-seguranca` revisa rules, Auth (anti-enumeração), dados sensíveis (LGPD) e **App Check** antes de publicar. *Gate: sem achado crítico/alto aberto.*
10. **Loop de qualidade (nota ≥ 9).** Comitê + `testador-real` dão nota; **iterar correção → reteste** até **nota ≥ 9** ou o limite de rodadas — pode ser **delegado ao `orquestrador-fable`** (maestro multi-modelo) ou rodado como loop leve aqui. *Gate: nota ≥ 9 ou decisão consciente do Jeremias registrada.*
11. **Documentação + Release.** `docs-projeto` (README/manual/changelog) + build do stack (`flutter build appbundle`/`ipa`) + ciclo git completo. *Gate: comandos do README testados; artefato gerado.*
12. **Gate final.** `auditor-responsabilidades` audita RI/RO, evidências e responsabilidades → **veredito de prontidão (RI-05)**.

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

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Stack, backend ou primeira feature ambíguos após a etapa correspondente.
- Modelo de dados indefinido ao chegar nas rules (etapa 6) — rules exigem o modelo.
- Mockup não aprovado; rules não `default-deny`.
- Falta de skill filha crítica no catálogo.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas executadas e skills/lentes usadas · artefatos criados (caminhos exatos —
RO-03) · evidências por gate (MVP aprovado, ADR de stack + modelo, mockups aceitos,
`analyze`/`test` verdes, rules default-deny, relatório do testador, nota do loop, análise de
segurança, build) · pendências e limitações · **2–3 sugestões de evolução (RO-07)** · veredito do
`auditor-responsabilidades`.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas — este orquestrador é o mapa de quando cada uma entra; destaque para `arquiteto-dados` (modelo + rules do Firestore) e `especialista-seguranca` (rules = firewall); `auditor-responsabilidades` fecha.
- **Vem antes:** nada — é o ponto de partida quando o pedido é "o app mobile inteiro".
- **Vem depois:** `memoria-de-projeto` (registrar decisões/lições e as RO do track a oficializar) · `inovacao-melhorias` (retrospectiva e próximos ganhos).
- **Não confundir com:** `spec-projeto-completo` (ciclo universal, qualquer plataforma — este é o especializado em mobile) · `orquestrador-fable` (maestro de execução multi-modelo que este pode chamar no loop de qualidade, não uma sequência de track).
