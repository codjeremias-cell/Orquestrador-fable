---
name: mobile-flutter-feature
description: Cria uma feature Flutter completa de ponta a ponta — repositório abstrato (interface) + implementação, modelo imutável com freezed, ViewModel/AsyncNotifier Riverpod com code-gen @riverpod, Screen (View sem lógica, estados vazio/carregando/erro/dados), rota go_router e testes (unit do repositório e do notifier com mocktail + teste de widget da tela). Acione quando o usuário disser coisas como "cria a feature de login", "preciso da tela de perfil com dados", "monta a funcionalidade de tarefas no app", "adiciona a feature de X no Flutter", "faz o fluxo de catálogo ponta a ponta". Comece SEMPRE pelo mockup (RO-06). NÃO acione para iniciar o projeto (use mobile-flutter-scaffold) nem para conectar Firebase/Auth (use mobile-flutter-firebase).
---

# Flutter — Feature Completa (Repo abstrato + Notifier + Screen + Rota + Testes)

Gerador do **track mobile (Flutter-first, proposta 2026-07-07)**. Entrega uma vertical completa de
uma feature: da fonte de dados à tela, seguindo a arquitetura oficial (camadas UI/Data, repositório
**abstrato**, fluxo unidirecional, modelo imutável, **nada de lógica no widget**).

## Objetivo

Materializar uma feature aderente ao track: repositório abstrato desacopla o backend, `freezed`
garante o modelo imutável, o `AsyncNotifier` (Riverpod code-gen) é o ViewModel que expõe o estado,
a `Screen` só desenha e reage, e a suíte de testes prova o fluxo.

## Regra de partida (RO-06): mockup antes de codar

Antes de gerar qualquer widget, apresentar o **mockup visual** da(s) tela(s) da feature (o Jeremias
processa print, não vídeo) e obter o aceite. Só codar a UI depois do "ok" — reforçado pela
referência **Impeccable** da lente `designer-ux-ui`.

## Entradas obrigatórias

1. Nome e propósito da feature (ex.: `auth`, `tasks`) e a(s) tela(s) envolvida(s).
2. O **modelo** (campos com tipo e obrigatoriedade) e a fonte de dados (REST? Firestore? local?).
3. Operações/estado que a tela expõe (listar, criar, editar, buscar) e ações do usuário.

## Entradas opcionais

- Se entra numa navegação/aba existente; regras de habilitação/validação de formulário; paginação.

## Trava obrigatória

- Não gerar a UI sem o **mockup aceito** (RO-06) e sem o modelo/fonte de dados definidos.
- Se a fonte de dados for ambígua (backend ainda não decidido), **parar e perguntar** — o
  repositório é abstrato justamente para não travar aqui, mas a **impl** precisa do alvo real.
- Feature que depende de Firebase → a **impl** do repositório vem de `mobile-flutter-firebase`;
  esta skill entrega a **interface** e o resto da vertical.

## Leituras obrigatórias (RO-01)

1. Uma feature já existente do projeto (repo + notifier + screen) para copiar o padrão real
   (nomes de provider, convenção de pastas, AsyncValue).
2. O `analysis_options.yaml` e o `pubspec.yaml` para confirmar as libs/versões (freezed, riverpod,
   go_router) — nunca assumir assinatura de API não vista.
3. Os tokens/tema do projeto (usar tokens, não cor fixa) e o router (`lib/src/routing/`).

## Convenções obrigatórias (Track Mobile Flutter)

- **Repositório abstrato (fortemente recomendado pela doc oficial):**
  `abstract interface class TasksRepository { ... }` com métodos `Future`/`Stream` no domínio, e
  uma impl concreta (`RemoteTasksRepository implements TasksRepository`). Exposto por um provider
  Riverpod (`@riverpod TasksRepository tasksRepository(Ref ref) => ...`). A UI **nunca** fala com a
  fonte de dados direto. Fonte: https://docs.flutter.dev/app-architecture/recommendations
- **Modelo imutável com `freezed`:** `@freezed class Task with _$Task { const factory Task({...}) =
  _Task; factory Task.fromJson(...) => _$TaskFromJson(json); }`. Sem setter; cópia via `copyWith`.
- **ViewModel = `AsyncNotifier` (Riverpod code-gen):**
  `@riverpod class TasksController extends _$TasksController { @override FutureOr<List<Task>>
  build() => ref.watch(tasksRepositoryProvider).fetchAll(); Future<void> add(...) async { ... } }`.
  Estado assíncrono como `AsyncValue`; fluxo **unidirecional** (View → método do notifier → novo
  estado). Fonte: https://codewithandrea.com/articles/flutter-riverpod-generator/
- **Screen (View) sem lógica:** `ConsumerWidget`/`ConsumerStatefulWidget` que faz
  `ref.watch(tasksControllerProvider)` e trata **todos os estados** com `.when(data / loading /
  error)` — vazio (mensagem PT-BR, nunca lista crua), carregando (spinner) e erro (mensagem
  amigável + retry). Nada de regra de negócio ou I/O no widget.
- **Rota `go_router`:** registrar no router do projeto; preferir **type-safe** com
  `go_router_builder` (`@TypedGoRoute<TasksRoute>`). Sem string de rota solta espalhada.
- **Testes (mocktail):** unit do repositório (mock da fonte de dados), unit do notifier
  (`ProviderContainer` com `overrides` do repo por um mock), e **teste de widget** da tela
  (`pumpWidget` dentro de `ProviderScope(overrides: ...)`, verificando vazio/carregando/erro/dados).
  E2E opcional em `integration_test/` (**`flutter_driver` DEPRECADO**).
- Identificadores em inglês; UI em PT-BR; sem emoji em código (RO-05).

## Fluxo

1. Apresentar o mockup e obter aceite (RO-06).
2. Ler a feature de referência, o pubspec/tema e o router (RO-01).
3. Escrever o **modelo** `freezed` e rodar `dart run build_runner build --delete-conflicting-outputs`.
4. Escrever o **repositório abstrato** + a **impl** (ou a interface, se a impl vier do Firebase).
5. Escrever o **AsyncNotifier** (ViewModel) com o estado e as ações; gerar o código.
6. Escrever a **Screen** cobrindo os quatro estados; registrar a **rota** `go_router`.
7. Escrever os **testes** (repo + notifier + widget) e rodar `flutter analyze` + `flutter test`.
8. Reportar arquivos criados, rota afetada, evidências e suposições (RO-01).

## Regras de implementação

- A View não conhece a fonte de dados — só o notifier; o notifier só conhece o repositório
  abstrato; a impl do repositório é o único ponto que conhece o backend (troca de backend não
  toca UI/notifier).
- Modelo é dado puro (sem I/O). Regra de negócio complexa vai para `domain/` (use-case), não para o
  notifier nem para o widget.

## Guardrails

- Não codar a tela antes do mockup aceito (RO-06).
- Não pôr I/O, `if` de regra de negócio ou acesso a backend no widget.
- Não instanciar a fonte de dados dentro da View/notifier — injetar pelo provider do repositório.
- Não inventar assinatura de método, nome de provider ou token de tema (RO-01).
- Não deixar estado sem cobertura — vazio/carregando/erro são obrigatórios, não só o "sucesso".

## Saída esperada

- `task.dart` (freezed) · `tasks_repository.dart` (abstrato + impl) · `tasks_controller.dart`
  (`@riverpod` AsyncNotifier) · `tasks_screen.dart` · rota registrada · testes unit + widget.
- `dart run build_runner build`, `flutter analyze` e `flutter test` verdes como **evidência**.
- Mockup aprovado registrado e nota com suposições.

## Few-shot (entra → sai)

**Entra:** feature `tasks` — modelo `Task{ id, title, done }`, fonte Firestore, tela lista + criar.
**Sai** (vertical completa; `build_runner`/`analyze`/`test` verdes):
- `task.dart` — modelo `@freezed` (imutável, `fromJson`)
- `tasks_repository.dart` — `abstract interface class TasksRepository` + impl (ou só a interface, se a impl vier de `mobile-flutter-firebase`)
- `tasks_controller.dart` — `@riverpod` AsyncNotifier (ViewModel, estado `AsyncValue`)
- `tasks_screen.dart` — `ConsumerWidget` cobrindo vazio/carregando/erro/dados
- rota `TasksRoute` registrada no `go_router` (type-safe)
- testes: repo + notifier (unit, `mocktail`) + tela (widget)

## Referências oficiais (RO-01)

- Repositório abstrato / camadas: https://docs.flutter.dev/app-architecture/recommendations
- Riverpod code-gen (`@riverpod`, AsyncNotifier): https://codewithandrea.com/articles/flutter-riverpod-generator/
- Arquitetura viva Flutter+Firebase+Riverpod: https://github.com/bizz84/starter_architecture_flutter_firebase

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair `use-case` em `domain/` se a regra crescer; paginação/cache
no repositório; golden test da tela; `AsyncValue.guard` para erros mais limpos no notifier).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-dados` (desenho do modelo imutável e do contrato do repositório) · `designer-ux-ui` (mockup RO-06, estados, a11y, Impeccable) · `dev-senior` (notifier/View limpos) · `qa-usabilidade` (caminho triste e estados cobertos).
- **Vem antes:** `mobile-flutter-scaffold` (estrutura e libs) · `mobile-flutter-firebase` (quando a impl do repositório é Firestore/Auth).
- **Vem depois:** `testador-real` (prova o fluxo de ponta a ponta com evidência) · `docs-projeto`.
- **Não confundir com:** `javafx-screen-fxml` (mesmo papel de tela, mas track desktop JavaFX) · `mobile-flutter-scaffold` (cria o projeto, não uma feature).
