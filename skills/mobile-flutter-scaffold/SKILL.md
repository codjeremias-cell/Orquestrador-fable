---
name: mobile-flutter-scaffold
description: Cria do zero o esqueleto de um app Flutter feature-first (camadas UI/Data), pronto para rodar — projeto gerado por scaffolder (Very Good CLI/Mason quando disponível), pubspec com go_router, flutter_riverpod + riverpod_generator (DI + estado, sistema único), freezed, flutter_lints, estrutura de pastas por feature e pastas de teste (unit/widget/integration_test). Acione quando o usuário disser coisas como "cria um app Flutter novo do zero", "começa um projeto mobile Flutter", "monta a base do aplicativo", "inicializa o projeto Flutter", "quero começar um app de celular". NÃO acione em projeto Flutter que já existe (para adicionar telas/lógica use mobile-flutter-feature) nem para conectar Firebase (use mobile-flutter-firebase).
---

# Flutter — Scaffold de Projeto (feature-first, camadas UI/Data)

Gerador do **track mobile (Flutter-first, proposta 2026-07-07)**. Materializa, numa pasta vazia, o
esqueleto de um app Flutter que **roda e passa no analyze** desde o primeiro minuto, com a
arquitetura oficial (MVVM, camadas UI/Data) e as libs do track já plugadas.

## Objetivo

Entregar o alicerce sobre o qual `mobile-flutter-feature` e `mobile-flutter-firebase` são
construídos: estrutura feature-first, injeção de dependência, roteamento, estado, modelo imutável,
lints e pastas de teste. Estabelece as convenções do projeto (feature-first, repositório abstrato,
fluxo unidirecional, nada de lógica no widget).

## Entradas obrigatórias

1. Nome do app e **org/bundle id** (ex.: `com.jere.meuapp`) — vira o `--org` do scaffolder.
2. Plataformas-alvo (Android, iOS, web/desktop) do MVP.
3. Confirmação do estado padrão do track: **Riverpod com code-gen** (Bloc só se domínio regulado).

## Entradas opcionais

- Versão mínima do Dart/Flutter, flavors (dev/stg/prod), tema/tokens iniciais, se já entra com
  Firebase (então encadeia `mobile-flutter-firebase` depois).

## Trava obrigatória

- Não executar se a pasta já contém um projeto Flutter (`pubspec.yaml` presente) — para evoluir,
  usar as skills específicas. Só do zero com pasta limpa ou pedido explícito de re-scaffold.
- Se o **org/bundle id** não vier, pedir antes de gerar (renomear depois é caro).

## Leituras obrigatórias (RO-01 — nunca inventar)

1. Se houver um app Flutter irmão do mesmo dono acessível, ler o `pubspec.yaml` e a árvore `lib/`
   dele para reproduzir versões e estrutura **reais já validadas** em vez de assumir.
2. **Pepita P-a (determinismo, §6.7):** checar se há scaffolder pronto — **Very Good CLI**
   (`very_good create flutter_app <nome> --org <org>`) ou **Mason** (`mason make <brick>`). Existindo,
   **invocar o scaffolder e preencher variáveis** em vez de escrever os arquivos à mão — gerar a
   partir de modelo torna classes inteiras de erro estruturalmente impossíveis. Fontes:
   https://github.com/VeryGoodOpenSource/very_good_cli (tem MCP embutido) ·
   https://github.com/felangel/mason
3. Sem referência real disponível: montar com práticas-padrão e **declarar as versões como
   confirmáveis**, validando pelo `flutter pub get`/`analyze` — nunca afirmar versão de cor.

## Convenções obrigatórias (Track Mobile Flutter)

- **Arquitetura oficial:** MVVM + duas camadas — **UI** (View + ViewModel) e **Data**
  (Repository + Service). **domain/** (use-case + model) só quando a lógica for complexa. Fluxo de
  dados **unidirecional**; **nada de lógica no widget**. Fonte:
  https://docs.flutter.dev/app-architecture/guide e /recommendations · app de referência **Compass**
  https://github.com/flutter/samples/tree/main/compass_app — vale como referência de
  **arquitetura/camadas (UI/Data)**; note que o Compass usa `provider` para DI+estado, **não**
  Riverpod, então cite-o pelo *layering*, não pela escolha de estado.
- **Estrutura feature-first:**
  `lib/src/features/<feature>/{presentation, application, data, domain}` +
  `lib/src/common/` (widgets/erros compartilhados) + `lib/src/routing/` (go_router) +
  `lib/src/utils/`. Cada feature separa internamente UI (presentation) de Data (data).
- **Estado + DI — Riverpod único (padrão do track):** `flutter_riverpod` + `riverpod_annotation`;
  dev `riverpod_generator` + `build_runner` + `custom_lint` + `riverpod_lint`. O `ProviderScope`
  na raiz do `main.dart` resolve **estado e injeção de dependência** — um sistema só, sem `provider`
  no pacote-base. Fonte: https://codewithandrea.com/articles/flutter-riverpod-generator/
- **`provider` fora do pacote-base:** o scaffold não pluga o pacote `provider` (evita dois sistemas
  de DI). Só **se surgir necessidade concreta de DI app-wide** que o Riverpod não cubra bem,
  registrar como **ADR** (`arquiteto-software`) antes de adicionar.
- **Navegação:** `go_router` (oficial) + `go_router_builder` (rotas type-safe via `@TypedGoRoute`).
- **Modelo imutável:** `freezed` (`freezed_annotation`/`json_annotation`; dev `freezed` +
  `json_serializable`).
- **Lints:** `flutter_lints` no `analysis_options.yaml` (opção mais estrita: `very_good_analysis`).
- **Testes:** pasta `test/` (unit + widget) e `integration_test/` (E2E; **`flutter_driver` está
  DEPRECADO** — usar o pacote `integration_test`). Mock com `mocktail`.
- Identificadores em inglês; textos de UI em PT-BR; sem emoji em código (RO-05).

## Fluxo

1. Validar entradas e confirmar pasta limpa.
2. Ler app irmão de referência, se houver, e escolher o scaffolder (RO-01 / Pepita P-a).
3. Gerar o projeto pelo scaffolder (Very Good CLI/Mason) **ou** `flutter create --org <org>` e
   ajustar para a estrutura feature-first.
4. Adicionar as libs do track ao `pubspec.yaml` (`flutter pub add ...`), configurar
   `analysis_options.yaml` (lints + `custom_lint`) e envolver `runApp` em `ProviderScope`.
5. Criar as pastas `features/`, `common/`, `routing/`, `utils/` e as pastas de teste, com um
   router `go_router` mínimo e uma tela placeholder (com token de tema, não cor fixa).
6. Rodar `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`,
   `flutter analyze` e `flutter test` — build/analyze verdes como **evidência (RI-04)**.
7. Reportar estrutura criada, versões usadas, decisões (DI+estado unificados em Riverpod) e próximos passos.

## Guardrails

- Não sobrescrever projeto existente.
- Não escrever à mão o que um scaffolder gera de forma determinística (Pepita P-a).
- Não afirmar versões de cor; validar pelo `pub get`/`analyze`.
- Não criar feature real, repositório concreto, telas de negócio ou conexão de backend aqui — só o
  esqueleto (isso é de `mobile-flutter-feature`/`mobile-flutter-firebase`).
- Nada de segredo no versionamento (chaves/`.env` no `.gitignore` + `*.example`).

## Saída esperada

- App Flutter feature-first que roda (`flutter run`) e passa em `flutter analyze`, com go_router,
  Riverpod code-gen (DI + estado), freezed, lints e pastas de teste configurados.
- `flutter analyze` + `flutter test` verdes como evidência.

## Few-shot (entra → sai)

**Entra:** `nome=meuapp`, `org=com.jere.meuapp`, plataformas Android/iOS, estado Riverpod code-gen.
**Sai** (árvore mínima gerada, que roda e passa no `analyze`):

```
meuapp/
  pubspec.yaml            # go_router, flutter_riverpod + riverpod_annotation, freezed, flutter_lints
  analysis_options.yaml   # flutter_lints + custom_lint/riverpod_lint
  lib/
    main.dart             # runApp(ProviderScope(child: MeuApp()))
    src/
      features/           # vazio (1a feature vem de mobile-flutter-feature)
      common/             # widgets/erros compartilhados
      routing/router.dart # go_router com 1 rota placeholder (tela com token de tema)
      utils/
  test/                   # unit + widget
  integration_test/       # E2E (pacote integration_test)
```

## Referências oficiais (RO-01)

- Arquitetura: https://docs.flutter.dev/app-architecture/guide · /recommendations · Compass app.
- Riverpod code-gen: https://codewithandrea.com/articles/flutter-riverpod-generator/
- Scaffolders: https://github.com/VeryGoodOpenSource/very_good_cli · https://github.com/felangel/mason

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: seguir com `mobile-flutter-feature`; configurar flavors dev/stg/prod;
adotar `very_good_analysis` e CI com `flutter analyze`/`test`; encadear `mobile-flutter-firebase`).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (camadas UI/Data; ADR se surgir DI app-wide além do Riverpod) · `dev-senior` (pubspec e main legíveis).
- **Vem antes:** `requisitos-descoberta` / `spec-mobile-app` (nome, org e stack já decididos).
- **Vem depois:** `mobile-flutter-feature` (primeira feature) · `mobile-flutter-firebase` (backend) · `testador-real`.
- **Não confundir com:** `java-project-bootstrap` (mesmo papel, track desktop JavaFX/Maven) · `spec-mobile-app` (o orquestrador que chama esta e as demais).
