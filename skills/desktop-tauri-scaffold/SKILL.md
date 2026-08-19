---
name: desktop-tauri-scaffold
description: "Cria o projeto base de um app desktop moderno com Tauri v2 (React+TS+Vite ou vanilla TS): estrutura de pastas, segurança default-deny com capabilities e CSP estrita por janela, config do updater e CI. Substituto leve do stack JavaFX+Access. Acione com \"começa um app desktop novo em Tauri\", \"quero um desktop leve tipo Electron mas menor\", \"scaffold do Tauri v2\", \"monta a base do app desktop com web UI\", \"app nativo com React\". NÃO acione para o app inteiro da ideia à entrega (use spec-desktop-app, o orquestrador), nem para o track JavaFX/JDBC existente (use java-project-bootstrap), empacotar/assinar (use desktop-packaging) ou criar a feature CRUD (use desktop-feature-crud)."
argument-hint: "[nome-do-app]"
---

# Desktop Tauri v2 — Scaffold do Projeto (track desktop, proposta 2026-07-07)

## Objetivo

Entregar o esqueleto de um app desktop **Tauri v2** que compila e abre, já com **segurança
default-deny**, **updater** configurado e **CI** — a base leve que substitui JavaFX+Access quando se
quer UI web e binário pequeno. Medido: Tauri ~8 MB / ~172 MB RAM vs Electron ~244 MB / ~409 MB RAM
(gethopp, https://www.gethopp.app/blog/tauri-vs-electron — ordem de grandeza, verificar na data).
Trade-off assumido: renderização pelo **WebView do SO** (WebKit no macOS/Linux,
WebView2/Chromium no Windows) pode divergir entre plataformas.

> **Alternativa .NET (Avalonia):** se o atrito vindo de JavaFX/JDBC pesa mais que o binário leve
> (XAML≈FXML, C#≈Java, ADO.NET≈JDBC), o stack certo é Avalonia, não Tauri — a escolha é feita no
> `spec-desktop-app` (árvore de decisão). Esta skill assume que Tauri já foi decidido.

## Entradas obrigatórias

1. Nome do app + **identifier** (ex.: `com.jere.<app>`) e a coordenada/repo.
2. Front: **React+TS+Vite** (padrão) ou **vanilla TS**.
3. Alvos de SO (Windows/macOS/Linux) — definem capabilities e artefatos.

## Entradas opcionais

- Ícone, janelas adicionais, se já quer o updater ligado, se usa banco local (a feature vem depois
  em `desktop-feature-crud`).

## Trava obrigatória

- **Delegar ao scaffolder quando existir (Pepita P-a; [[PADRAO-DE-AUTORIA]] §6.7):** rodar
  `create-tauri-app` preenchendo as variáveis, em vez de escrever os arquivos à mão. Só editar o que
  o template não cobre. Gerar a partir de modelo torna classes inteiras de erro impossíveis.
- Sem **identifier**/nome definidos, parar e perguntar — viram bundle id e nome dos artefatos.

## Leituras obrigatórias (RO-01)

1. Docs de segurança v2 — **capabilities** (https://v2.tauri.app/security/capabilities/) e **CSP**
   (https://v2.tauri.app/security/csp/) — antes de liberar qualquer permission.
2. Doc do **updater** (https://v2.tauri.app/plugin/updater/) para os campos de config.
3. Template Claude-Code-ready de referência (https://github.com/dannysmith/tauri-template) — reusar
   estrutura/CI antes de inventar.
4. Se o projeto já existe: o `src-tauri/tauri.conf.json` e `src-tauri/capabilities/` atuais — não
   sobrescrever cegamente.

## Convenções obrigatórias (Track desktop Tauri v2, proposta 2026-07-07)

- **Estrutura:** `src/` (front) · `src-tauri/` (Rust: `src/main.rs`, `tauri.conf.json`,
  `capabilities/*.json`, `migrations/`) · `src-tauri/Cargo.toml`.
- **Segurança default-deny (RO-DT1):** nada é permitido por omissão. Cada janela recebe um arquivo de
  capability em `src-tauri/capabilities/<janela>.json` associando a janela ao **conjunto mínimo** de
  permissions (escopadas). Nunca um `core:default` amplo se der para escopar.
  **Escopo, não obrigatoriedade:** capabilities governam comandos de **plugin/core** e restrições
  **multi-janela** — um comando próprio no `generate_handler!` já é invocável sem entrada de capability
  por janela; o default-deny segue como **postura** (não abrir permission de plugin/core além do
  necessário e escopar por janela quando houver mais de uma).
- **CSP estrita** em `tauri.conf.json` → `app.security.csp`: sem `unsafe-inline`/`unsafe-eval`;
  scripts/styles por **nonce/hash** (Tauri injeta os dele); `connect-src` só nos hosts necessários;
  **evitar CDN** — empacotar assets localmente.
- **Bridge tipada de ponta a ponta (Pepita P-e):** configurar `tauri-specta` já no scaffold para
  exportar os tipos do Rust → `src/bindings.ts`; o compilador TS passa a validar o contrato
  (https://github.com/specta-rs/tauri-specta). Alternativa: TauRPC.
- **Updater:** bloco `plugins.updater` com `pubkey` (a chave é gerada depois no `desktop-packaging`)
  e `endpoints` (GitHub Releases). A **chave privada nunca no repo** (RO-DT4) — vai por secret de CI.
- **CI (GitHub Actions):** matriz de SO, `tauri build`, cache de Rust; segredos de assinatura como
  secrets do repositório.

## Fluxo

1. Confirmar nome/identifier/front/alvos.
2. Delegar ao `create-tauri-app` (Pepita P-a) com as variáveis; se indisponível, seguir o template
   de referência.
3. Ajustar `tauri.conf.json`: **CSP estrita** + bloco **updater**; criar `capabilities/main.json`
   mínimo.
4. Ligar `tauri-specta` e exportar `bindings.ts` a partir de um comando `ping` de exemplo.
5. Adicionar o workflow de CI (matriz de SO).
6. Rodar `npm run tauri dev` (abre?) e `npm run tauri build` (compila?) como evidência (RI-04).
7. Reportar arquivos criados e suposições (RO-01).

## Few-shot (entra → sai)

**Entra:** `nome: Estoque` · `identifier: com.jere.estoque` · front: React+TS+Vite · alvos: Windows+Linux.

**Sai** (base que abre e builda):
- `src/` (front React) + `src-tauri/` (`main.rs`, `tauri.conf.json`, `capabilities/main.json`, `migrations/`).
- `tauri.conf.json` com **CSP estrita** (sem `unsafe-inline`) + bloco `plugins.updater` (`pubkey` vem depois, no packaging).
- `capabilities/main.json` mínimo (default-deny) escopando a janela `main`.
- `bindings.ts` gerado de um comando `ping` de exemplo (`tauri-specta`).
- Workflow de CI (matriz Windows/Linux). `tauri dev` abre e `tauri build` compila (RI-04).

## Guardrails

- **RO-DT1/RO-DT4 valem sem exceção** — nada de permission ampla, CSP frouxa/`unsafe-*`/CDN ou chave privada no repo ou no `tauri.conf.json` (detalhe: Convenções).
- Não sobrescrever `capabilities/`/config de projeto existente sem ler antes (RO-01).

## Saída esperada

- Projeto Tauri v2 que abre em dev e builda; `tauri.conf.json` com CSP estrita + updater;
  `capabilities/main.json` mínimo; `bindings.ts` gerado; workflow de CI. Build/dev verdes como
  evidência (RI-04).

## Verificação / Checklist final

- **Abre e builda:** `npm run tauri dev` abre a janela; `npm run tauri build` compila (RI-04).
- **CSP estrita:** sem `unsafe-inline`/`unsafe-eval` e sem CDN (assets locais); nonce/hash da Tauri no lugar.
- **Default-deny:** `capabilities/main.json` mínimo, escopado à janela `main` — nenhuma permission ampla sem justificativa.
- **Bridge tipada:** chamar o comando `ping` pelo `bindings.ts` no front e o `tsc --noEmit` valida o contrato.
- **Updater:** bloco `plugins.updater` presente (só `pubkey`/`endpoints`; a **privada** entra no `desktop-packaging`, nunca no repo).
- **CI:** workflow com matriz de SO presente.

## Sugestões de evolução (RO-07)

Fechar com 2–3 (ex.: ligar o **Isolation Pattern** para blindar o IPC; extrair um crate só de
comandos; pré-commit com `cargo clippy` + `tsc --noEmit`).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (capabilities/CSP default-deny) · `arquiteto-software` (limite front×core) · `dev-senior` (Rust/TS idiomáticos) · `designer-ux-ui` (shell da UI web, referência Impeccable).
- **Vem antes:** `requisitos-descoberta` / `arquiteto-software` (decisão de stack — normalmente via `spec-desktop-app`).
- **Vem depois:** `desktop-feature-crud` (primeira entidade) · `desktop-packaging` (instalador + updater assinado) · `testador-real`.
- **Não confundir com:** `java-project-bootstrap` (scaffold do track JavaFX/Maven — não Tauri).

### 📜 Histórico
- **2026-08-11 — Nuance de RO-DT1 importada da irmã (inventário do catálogo, `_auditoria/zelador-inventario-2026-08-10.md`, grupo "regra que precisa migrar"):** o bullet de default-deny afirmava sobre capabilities o que `desktop-feature-crud` já corrigiu — quem roda só o scaffold ficava com a versão imprecisa. Acrescentado "escopo, não obrigatoriedade" verbatim da irmã: capabilities governam plugin/core e multi-janela; comando próprio no `generate_handler!` não precisa de entrada; default-deny permanece como postura. Nenhuma remoção; `description` intocada.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens C1-C3, C4; −2 linhas.
- **2026-07-20 — Polimento de autoria:** `when_to_use` + `argument-hint`; +checklist de Verificação consolidando dev/build verdes, CSP estrita, default-deny e a bridge tipada `ping`. Trava do scaffolder, convenções e few-shot preservados.
