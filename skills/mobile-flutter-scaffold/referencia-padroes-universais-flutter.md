# Padrões universais de scaffold Flutter — extraídos de um projeto real (Encontre a Marta)

> Fonte: `Jogo-Simples-Celular (Encontre a Marta)/lib/router/app_router.dart` + estrutura de `lib/` + `pubspec.yaml` (lidos 2026-07-18). **Escopo (RI-04):** jogo Flutter offline SEM code-gen. Estes padrões de estrutura e roteamento transferem para qualquer Flutter; o default da skill (feature-first + freezed + riverpod_generator) **continua valendo para app-style com code-gen**. Olhe o `pubspec.yaml` real ANTES (RO-01) para saber qual estilo o projeto adotou.

## Padrão 1 — Rotas centralizadas em `abstract final class` (universal, anti-string-solta)

Convenção real: TODOS os caminhos como constantes numa classe selada única (`Rotas`), zero string literal de rota espalhada; `criarRouter()` factory com helper local `rota(path, tela)`; transição de página que **respeita "reduzir movimento"** (acessibilidade — troca sem animação quando o usuário pediu). Transfere pra qualquer app go_router, jogo ou não.

```dart
/// Nomes/caminhos das rotas do app. Centralizados para evitar strings soltas.
abstract final class Rotas {
  static const splash = '/splash';
  static const home = '/';
  static const ajustes = '/ajustes';
  // ... todas as rotas como constante
}

/// Pagina com fade suave; respeita "reduzir movimento" (acessibilidade):
/// quando ligado, troca sem animacao.
Page<dynamic> _pagina(BuildContext context, GoRouterState state, Widget child) {
  final reduzir = ProviderScope.containerOf(context, listen: false)
      .read(reduzirMovimentoProvider);
  if (reduzir) {
    return NoTransitionPage<dynamic>(key: state.pageKey, child: child);
  }
  return CustomTransitionPage<dynamic>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

GoRouter criarRouter() {
  GoRoute rota(String path, Widget Function() tela) => GoRoute(
        path: path,
        pageBuilder: (context, state) => _pagina(context, state, tela()),
      );
  return GoRouter(
    initialLocation: Rotas.splash,
    routes: [
      rota(Rotas.splash, () => const SplashScreen()),
      rota(Rotas.home, () => const HomeScreen()),
      // ...
    ],
  );
}
```

## Padrão 2 — Estrutura layer-first (alternativa válida ao feature-first)

Real: `lib/` dividido por **camada** — `domain/` (models + regras puras), `data/` (repositórios), `presentation/` (uma pasta por tela + `widgets/` + `providers/`), mais `router/`, `theme/`, `l10n/`. É alternativa legítima ao feature-first do default da skill; para um app pequeno/médio de tela-por-fluxo (ou jogo), layer-first é mais direto. Decisão por tamanho e por quantos "features" independentes o app tem.

## Padrão 3 — Offline-first empacotado (universal p/ app sem backend)

Real: dado de conteúdo em **JSON empacotado** (`assets/data/*.json` declarado no `pubspec`), estado do usuário em **`shared_preferences`**, sem rede no caminho crítico. Deps enxutas: `flutter_riverpod` + `go_router` + `shared_preferences` + `intl`, e nada de `freezed`/`build_runner`. Para app que não precisa de backend, este é o piso — não puxar Firebase/servidor sem necessidade real (combate ao over-engineering).

## Limite do gabarito

Não força feature-first nem code-gen: se o projeto-alvo já tem `freezed`/`riverpod_generator` no pubspec, o default da skill vence. Este gabarito é o caminho enxuto para o caso oposto (o mais comum em app pequeno/jogo).
