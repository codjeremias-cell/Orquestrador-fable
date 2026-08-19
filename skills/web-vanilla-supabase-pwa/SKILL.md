---
name: web-vanilla-supabase-pwa
description: "Cria e evolui um app web mobile-first SEM framework (HTML, CSS e JavaScript vanilla ES6) sobre Supabase (Postgres, RLS, Auth, Storage), empacotado como PWA instalável e publicável na Play Store via TWA — o stack real dos apps do Jeremias. Acione com \"cria um app web tipo o Embalo\", \"app mobile-first com Supabase\", \"quero um PWA que vira app de loja\", \"adiciona login com Supabase no app\", \"faz o CRUD no Supabase\", \"cria a tela nova no app vanilla\", \"configura o RLS dessa tabela\", \"app web sem framework com banco na nuvem\". NÃO acione para app React/Vite/Next (use o track web-frontend: frontend-stack-decisor → web-component → web-data-layer), nem para escolher o stack do zero (use frontend-stack-decisor)."
---

# Web Vanilla + Supabase + PWA (o stack web do Jeremias)

Você constrói apps web **sem framework**: HTML + CSS + JavaScript vanilla (ES6+), mobile-first, com **Supabase** como backend (Postgres, RLS, Auth email/senha, Storage privado) e empacotamento **PWA** (instalável + publicável na Play Store via TWA). É o stack real, em produção, do **Embalo** (motorista-pro) — deploy no Vercel, na Play Store. Simplicidade é a regra: sem build, sem toolchain, o backend-as-a-service faz o trabalho pesado.

## Quando usar / não usar

- **Use** para: app pessoal/mobile-first de um-usuário-por-conta, sem SEO, dev solo, que precisa de auth + banco + fotos sem manter servidor próprio; ou para evoluir um app assim que já existe (nova tela, novo CRUD, nova policy RLS).
- **NÃO use** para: app React/Vite/Next (→ track `web-frontend`), site público indexável (→ Astro, ver `frontend-stack-decisor`), ou backend próprio (→ `arquiteto-software`). A escolha do stack em si é da `frontend-stack-decisor` — aqui o stack **já é** vanilla+Supabase+PWA.

## A regra de ouro do stack: a muralha é o RLS, não o JavaScript

O ponto que mais se erra sem este contexto: **a `anonKey` do Supabase fica exposta no front — e tudo bem.** A segurança real **não** é esconder a chave nem esconder telas; é a **Row Level Security (RLS) no servidor**. Toda tabela nasce com `enable row level security` e policies por `auth.uid()` (dono do dado) ou `auth.jwt() ->> 'email'` (admin). Uma tela "escondida" no app é **cosmética** — a muralha é a policy. Nunca guardar segredo (chave de API, token) em tabela lida por `authenticated`. Corolário: nunca confiar em validação só no front para autorização — o front valida UX, o RLS valida acesso.

## Convenções obrigatórias (padrão real do Embalo)

- **Idioma PT-BR nos identificadores** (`usuarioAtual`, `carregarMovimentacoes`, `escaparHTML`) — é o padrão da casa; **IDs HTML e classes CSS em kebab-case** (`form-movimentacao`). (Pendência de governança conhecida: contraria a RO "código em inglês"; o padrão real do projeto vence, RO-01/RI-04.)
- **Arquitetura de 3 arquivos:** `index.html` (telas como `<section class="tela">` + menu por `data-aba`), `style.css` (design tokens CSS no topo), `app.js` (toda a lógica; seções marcadas com `// ============`). `config.js` **gitignored** (chaves Supabase), com `config.exemplo.js` versionado.
- **Guarda de config à prova de deploy:** no topo do `app.js`, se `SUPABASE_CONFIG` faltar (ex.: Vercel sem o arquivo), **abortar com aviso claro** — nunca quebrar em silêncio.
- **Navegação sem router:** `mostrarTela(nome)` + objeto `telas` (refs por `getElementById`); sub-abas via `ativarSubAba(nome)`.
- **Cliente único:** `const db = supabase.createClient(url, anonKey)` (Supabase via CDN, sem bundler).
- **Saída sanitizada (XSS):** todo texto do usuário passa por `escaparHTML()` antes de ir pro DOM via `innerHTML`.
- **Libs por CDN** quando precisar (Chart.js, jsPDF, html2canvas, SheetJS) — sem npm.

## Os 5 padrões arquitetônicos da casa (seguir sempre)

1. **Batch Query (anti-N+1):** ao carregar filhos de uma lista, uma query só com `.in("dono_id", ids)` — nunca uma query por item.
2. **Snapshot antes de mutação:** guardar o valor de estado (ex.: id selecionado) **antes** de chamar função que limpa o estado.
3. **Soft Fail:** se um passo secundário falha (ex.: upload de foto), **não reverter** o dado principal já criado — só avisar.
4. **Foto múltipla** (itens com N anexos): selecionar → preview → upload no submit do dono → ícone na lista → modal → exclusão do dono cascateia.
5. **Foto única** (perfil/avatar): "Trocar" (exclui antiga + sobe nova = cota zero) vs "Remover" (só exclui); estados SEM/COM foto.

## Fluxo

1. **Confirmar o alvo:** app novo (do zero) ou evolução (nova tela/CRUD/policy). Ler o `CLAUDE.md` do projeto e o `app.js`/`index.html` reais antes de editar (RO-01 — não assumir helpers/tabelas).
2. **Banco primeiro (quando há dado novo):** criar a tabela com `enable row level security` + policies (ver referência) — a policy é parte da entrega, não um extra.
3. **Auth quando aplicável:** `signUp` (com `emailRedirectTo` + metadata de consentimento), `signInWithPassword`, guarda de sessão no init (`getSession`), e `onAuthStateChange` (sessão caiu → volta ao login com aviso).
4. **UI:** nova `<section class="tela">` + entrada na navegação; estados de carregando/vazio/erro; texto do usuário via `escaparHTML`.
5. **Lógica no `app.js`:** seção marcada, helpers reusados, os 5 padrões acima; feedback no botão ("Salvando...").
6. **PWA/deploy quando fechar:** `manifest.json` (standalone, portrait, theme_color, ícones 192/512/maskable/svg) + `.well-known/assetlinks.json` (TWA Play Store) + deploy Vercel.

## Salvaguardas inegociáveis

- **RLS é a segurança (não o front).** Nenhuma tabela sem `enable row level security` + policy; nada sensível em tabela lida por `authenticated`. Autorização no servidor, sempre.
- **`config.js` nunca no git.** A `anonKey` pode aparecer no front; **segredo (service_role, API keys) NUNCA** — nem no front, nem em tabela pública.
- **Storage privado + URL assinada:** bucket privado, policies por `auth.uid()`, URLs assinadas de validade curta (ex.: 1h) — nunca bucket público para dado de usuário.
- **Sanitizar toda saída** de usuário com `escaparHTML` (defesa CWE-79).
- **RO-01:** não inventar tabela, coluna, helper ou método do Supabase — ler o schema/`app.js` reais ou declarar a suposição.

## Exemplo (entra → sai)

> Pedido: *"adiciona no Embalo uma tabela de 'metas mensais' que só o dono vê e edita"*.
>
> Saída: (1) SQL com `create table metas_mensais (... user_id uuid default auth.uid() ...)` + `enable row level security` + 4 policies por `auth.uid() = user_id` (select/insert/update/delete do dono); (2) tela `<section class="tela" id="tela-metas">` + item no menu; (3) no `app.js`, seção `// ===== METAS =====` com `carregarMetas()` (query filtrada pelo RLS, sem `where user_id` no front — o RLS já filtra), `salvarMeta()` com feedback no botão e `escaparHTML` na exibição. Sem `where` de dono no JS: **confiar no RLS**, não reimplementar a regra no front.

## Verificação / Checklist final

Prove a muralha com **evidência** (casa com `testador-real`) — "escondi a tela" não é segurança:

- **RLS com 2 contas:** logado como A, criar um registro; logar como B → **não** vê nem edita o dado de A (a policy barra, não a UI). Admin (email da allowlist) enxerga o que deve.
- **Config-guard:** subir sem `config.js`/`SUPABASE_CONFIG` → o app **aborta com aviso claro**, não quebra em silêncio.
- **XSS:** digitar `<img src=x onerror=alert(1)>` num campo → aparece como **texto** (via `escaparHTML`), não executa.
- **Storage:** o bucket é privado e a URL assinada expira (não é URL pública permanente).
- **PWA:** Lighthouse/DevTools → **instalável** (manifest válido, ícones 192/512/maskable); TWA com `assetlinks.json` servido em `/.well-known/`.
- **Segredo:** nenhuma `service_role`/API key no front nem em tabela lida por `authenticated`.

## Referência

Padrões verbatim do Embalo (config-guard, auth completo, CRUD, RLS documentado, PWA) em `referencia-exemplos-reais-embalo.md` — carregue ao gerar código.

## 💡 Sugestões de evolução (RO-07)
Feche com 2–3 (ex.: extrair helpers repetidos de `app.js` grande em seções nomeadas; migração incremental de SQL versionado em `sql/`; service worker de cache offline se o app crescer).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (RLS, XSS, segredos, storage) · `arquiteto-dados` (modelo das tabelas Supabase) · `designer-ux-ui` (mobile-first, tokens) · `dev-senior` (JS limpo).
- **Vem antes:** `frontend-stack-decisor` (que ESCOLHE este stack — ver o caso Embalo na referência dela) · `requisitos-descoberta`.
- **Vem depois:** `testador-real` (prova as telas e o RLS com 2 contas) · `especialista-seguranca` (auditoria).
- **Não confundir com:** `web-component`/`web-data-layer` (track React) · `frontend-stack-decisor` (decide o stack; aqui já está decidido).

---

### Regras de Ouro compartilhadas (todas as lentes)
- Comunicação em PT-BR; no SIGO/Embalo os identificadores também são PT-BR (padrão real do projeto vence — RO-01).
- **RO-01:** nunca inventar API, método, tabela ou coluna — ler a fonte real ou declarar a suposição.
- Princípios comuns: comece simples · segurança no servidor (RLS) · acessibilidade é padrão · sanitizar entrada/saída.

### 📜 Histórico
- **2026-07-18 (v1) — Skill nova criada com `skill-creator`:** garimpo profundo do **Embalo/motorista-pro** (app em produção, Vercel+Play Store) para dar ao catálogo o stack web REAL do Jeremias (vanilla+Supabase+PWA), que o track web-frontend (React) não cobria. Fonte: `CLAUDE.md`, `app.js`, `sql/configuracoes.sql`, `manifest.json`, `.well-known/assetlinks.json`. Baseline §11 (vermelho): sem a skill o gerador default assume React/framework e ignora RLS-como-muralha. Motivada pelo caso registrado em `frontend-stack-decisor/referencia-caso-real-embalo.md`. Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-20 — Polimento de autoria:** `when_to_use` reforça a fronteira (vanilla vs. React vs. decisor); +checklist de Verificação com **evidência** (RLS com 2 contas, config-guard, XSS, PWA). Convenções, os 5 padrões, o exemplo e o ponteiro de referência preservados.
