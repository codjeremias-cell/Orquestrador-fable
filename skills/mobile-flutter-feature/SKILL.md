---
name: mobile-flutter-feature
description: "PASSO 2 do fluxo Flutter (scaffold, feature, firebase): cria uma feature Flutter completa de ponta a ponta em projeto que já existe — repositório abstrato e implementação, modelo imutável com freezed, ViewModel/AsyncNotifier Riverpod. Acione com \"cria a feature de login\", \"preciso da tela de perfil com dados\", \"monta a funcionalidade de tarefas no app\", \"adiciona a feature de X no Flutter\", \"faz o fluxo de catálogo ponta a ponta\", \"feature\", \"cria a feature de X\", \"tela de perfil/lista/catálogo com dados\", \"adiciona a funcionalidade de tarefas\", \"fluxo de login ponta a ponta\". NÃO acione para iniciar o projeto (use mobile-flutter-scaffold) nem para conectar Firebase/Auth (use mobile-flutter-firebase)."
---

# Flutter — Feature Completa (Repo abstrato + Notifier + Screen + Rota + Testes)

Gerador do **track mobile (Flutter-first, proposta 2026-07-07)**. Entrega uma vertical completa de
uma feature: da fonte de dados à tela, seguindo a arquitetura oficial (camadas UI/Data, repositório
**abstrato**, fluxo unidirecional, modelo imutável, **nada de lógica no widget**).

## Onde entra no fluxo

Segunda das três skills Flutter: **mobile-flutter-scaffold** (alicerce) → **feature** (esta, cada
vertical) → **mobile-flutter-firebase** (backend). Roda **sobre um projeto já existente**; se a fonte
de dados da feature for Firebase, esta skill entrega só a **interface** do repositório e a **impl**
concreta vem de `mobile-flutter-firebase`.

## Objetivo

Materializar uma feature aderente ao track: repositório abstrato desacopla o backend, `freezed`
garante o modelo imutável, o `AsyncNotifier` (Riverpod code-gen) é o ViewModel que expõe o estado,
a `Screen` só desenha e reage, e a suíte de testes prova o fluxo.

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
  fonte de dados direto — a **impl** é o único ponto que conhece o backend (troca de backend não
  toca UI/notifier). *Por quê:* isolar o backend atrás de uma interface deixa você trocar REST por
  Firestore, ou plugar um fake nos testes, sem tocar em ViewModel nem em tela.
- **Modelo imutável com `freezed`:** `@freezed abstract class Task with _$Task { const factory Task({...}) =
  _Task; factory Task.fromJson(...) => _$TaskFromJson(json); }`. Sem setter; cópia via `copyWith`.
  A partir do **freezed 3.0** a classe com construtor `factory` exige o modificador `abstract` (ou
  `sealed`); em projeto ainda no 2.x, sem o modificador — confirme a versão no `pubspec.yaml` (RO-01).
  Modelo é dado puro (sem I/O). *Por quê:* imutabilidade + `==` gerado evitam estado mudando pelas
  costas e rebuilds errados; o modelo sem I/O é trivial de testar.
- **ViewModel = `AsyncNotifier` (Riverpod code-gen):**
  `@riverpod class TasksController extends _$TasksController { @override FutureOr<List<Task>>
  build() => ref.watch(tasksRepositoryProvider).fetchAll(); Future<void> add(...) async { ... } }`.
  Estado assíncrono como `AsyncValue`; fluxo **unidirecional** (View → método do notifier → novo
  estado). *Por quê `AsyncValue`:* ele já modela loading/erro/dados num tipo só, então a tela não
  precisa inventar flags soltas para cada estado.
- **Screen (View) sem lógica:** `ConsumerWidget`/`ConsumerStatefulWidget` que faz
  `ref.watch(tasksControllerProvider)` e trata **todos os estados** com `.when(data / loading /
  error)` — vazio (mensagem PT-BR, nunca lista crua), carregando (spinner) e erro (mensagem
  amigável + retry). Nada de regra de negócio ou I/O no widget; regra de negócio complexa vai para
  `domain/` (use-case), não para o notifier nem para o widget. *Por quê:* View burra é a única que
  se testa barato e se troca sem regressão; regra fora do widget é reutilizável e testável isolada.
- **Rota `go_router`:** registrar no router do projeto; preferir **type-safe** com
  `go_router_builder` (`@TypedGoRoute<TasksRoute>`). Sem string de rota solta espalhada. *Por quê:*
  rota gerada pega parâmetro/destino errado em compile-time.
- **Testes (mocktail):** unit do repositório (mock da fonte de dados), unit do notifier
  (`ProviderContainer` com `overrides` do repo por um mock), e **teste de widget** da tela
  (`pumpWidget` dentro de `ProviderScope(overrides: ...)`, verificando vazio/carregando/erro/dados).
  E2E opcional em `integration_test/` (**`flutter_driver` DEPRECADO**). *Por quê os três níveis:*
  cada um prova uma camada — contrato do repo, lógica do notifier, e a tela reagindo a cada estado.
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

## Guardrails

- Não codar a tela antes do mockup aceito (RO-06) — mockup em **print, não vídeo** (é o que o
  Jeremias processa); reforçado pela referência **Impeccable** da lente `designer-ux-ui`.
- Não pôr I/O, `if` de regra de negócio ou acesso a backend no widget.
- Não instanciar a fonte de dados dentro da View/notifier — injetar pelo provider do repositório.
- Não inventar assinatura de método, nome de provider ou token de tema (RO-01).
- Não deixar estado sem cobertura — vazio/carregando/erro são obrigatórios, não só o "sucesso".

## Saída esperada

- `task.dart` (freezed) · `tasks_repository.dart` (abstrato + impl) · `tasks_controller.dart`
  (`@riverpod` AsyncNotifier) · `tasks_screen.dart` · rota registrada · testes unit + widget.
- `dart run build_runner build`, `flutter analyze` e `flutter test` verdes como **evidência**.
- Mockup aprovado registrado e nota com suposições.

## Verificação (checklist final)

A vertical só está "pronta" quando o analyze e os testes **provam** o fluxo — "parece pronto" costuma
esconder o caminho triste (vazio/erro). Confira, com evidência real:

- [ ] `dart run build_runner build --delete-conflicting-outputs` gera `.freezed.dart`/`.g.dart` **sem erro**.
- [ ] `flutter analyze` → **zero issues**.
- [ ] `flutter test` → **verde** nos três níveis: unit do repo, unit do notifier, widget da tela.
- [ ] O teste de widget cobre os **quatro estados** (vazio, carregando, erro, dados) — não só o sucesso.
- [ ] A rota (`@TypedGoRoute`) está registrada no router e a tela é navegável.
- [ ] Sanidade de camadas: a View só faz `ref.watch` + `.when`; **nenhum** `if` de regra de negócio,
      I/O nem tipo de backend dentro do widget (a fonte de dados chega pelo provider do repositório).
- [ ] Mockup aprovado registrado **antes** do código da tela (RO-06).

Se algum teste não puder rodar no ambiente, declarar **SKIP com motivo** (RI-04), nunca "passou" fingido.

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

**Gabarito universal (few-shot de código real — projeto SEM code-gen):** carregue `referencia-padroes-universais-flutter.md` — modelo imutável À MÃO (const + `fromJson`/`toJson` manuais + `==`/`hashCode` por id) e repositório testável (`factory fromJson(String)` puro × `static carregarDoAsset()`) + validação de invariantes, extraídos do jogo real Encontre a Marta (offline, sem `freezed`/`riverpod_generator`). **Regra de decisão (RO-01):** olhe o `pubspec.yaml` — projeto COM freezed/@riverpod segue o default desta skill; projeto SEM code-gen segue o gabarito. Não misturar os dois estilos. Firebase/backend não se aplica à Marta (ver `mobile-flutter-firebase`).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-dados` (desenho do modelo imutável e do contrato do repositório) · `designer-ux-ui` (mockup RO-06, estados, a11y, Impeccable) · `dev-senior` (notifier/View limpos) · `qa-usabilidade` (caminho triste e estados cobertos).
- **Vem antes:** `mobile-flutter-scaffold` (estrutura e libs) · `mobile-flutter-firebase` (quando a impl do repositório é Firestore/Auth).
- **Vem depois:** `testador-real` (prova o fluxo de ponta a ponta com evidência) · `docs-projeto`.
- **Não confundir com:** `javafx-screen-fxml` (mesmo papel de tela, mas track desktop JavaFX) · `mobile-flutter-scaffold` (cria o projeto, não uma feature).

### 📜 Histórico
- **2026-08-11 — `freezed` ≥3.0 no bullet do modelo:** `@freezed class Task with _$Task` → `@freezed abstract class Task with _$Task`, com a ressalva de espelho para projeto ainda em 2.x. Fato externo **confirmado antes de editar** (RO-01): guia de migração oficial do freezed — *"classes using the factory constructor now require a keyword `sealed` / `abstract`"* — e CHANGELOG 3.0.0 (2025-02-25), *"Freezed classes should now either be `abstract`, `sealed`, or manually implements `_$MyClass`"*. Nenhum projeto Flutter da casa usa `freezed` hoje (`Jogo-novo-melhorias` e `Jogo-Simples-Celular` rodam sem code-gen), então a confirmação veio da fonte upstream, não do espelho. Proveniência: inventário do zelador de 2026-08-10, ATUALIZAR item 8 (RI-04). **Não aplicada** a deduplicação de `description` do mesmo item: as 5 frases finais são paráfrases distintas, não repetição literal, e cortá-las destruiria gatilho medido; a `description` está em 636 de 1024 chars, sem pressão de teto.
- **2026-07-18 — Few-shot de código real (onda mobile, captura universal):** criada `referencia-padroes-universais-flutter.md` (fonte: `city.dart` + `cities_repository.dart` do jogo Encontre a Marta). **Captura só o universal por decisão do Jeremista** (2026-07-18): a Marta é jogo offline SEM code-gen, não bate com o default freezed/Firebase/AsyncNotifier da skill — em vez de forçar, capturado o que transfere (modelo imutável à mão, repositório testável) com regra de decisão pelo pubspec; default da skill intacto para app-style com code-gen. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens B1, B2, B4; −10 linhas.
