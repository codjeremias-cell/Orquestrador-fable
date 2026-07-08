---
name: spec-desktop-app
description: "Orquestrador de app desktop moderno: conduz da ideia ao app entregue quando a plataforma é desktop, com uma árvore de decisão de stack (Tauri v2 padrão; Avalonia .NET se o atrito mínimo vindo de JavaFX/JDBC pesar mais; Electron só com reuso web forte; Flutter se mobile+desktop) e delega scaffold → N×feature CRUD → empacotamento, aplicando as lentes e iterando com o testador até nota ≥9. Acione quando o usuário disser coisas como \"quero um app desktop novo do zero\", \"monta o desktop inteiro da ideia à entrega\", \"app de PC leve tipo Electron mas menor\", \"sistema desktop novo, mas não em JavaFX\". Para desktop JavaFX/Access, prefira spec-javafx-new-system. NÃO acione para uma etapa isolada — use a skill específica (desktop-tauri-scaffold, desktop-feature-crud, desktop-packaging)."
---

# Spec — App Desktop Moderno (orquestrador-topo, track desktop, proposta 2026-07-07)

Esta é a **orquestradora de topo do track desktop moderno**. Leva a ideia até um app desktop
rodando, assinado e com auto-update, **decidindo o stack por uma árvore de decisão** e delegando aos
geradores `desktop-*`, com as lentes conduzindo. Espelha o `spec-projeto-completo`/
`spec-javafx-new-system` e não duplica o trabalho das filhas.

## Objetivo

Entregar um app desktop de ponta a ponta — requisitos → **decisão de stack** → arquitetura/dados/
design/segurança → scaffold → features → empacotamento assinado com auto-update → testes reais →
veredito — aderente às [[REGRAS-DE-OURO]] (RI + RO universais + candidatas a RO do track desktop),
com **nota ≥9**.

## Entradas obrigatórias

1. A ideia/objetivo do app (a etapa 1 dá forma).
2. Alvos de SO e o "vindo-de": base JavaFX/JDBC atual, app web a reusar, ou necessidade de mobile —
   insumos da árvore de decisão.
3. As primeiras entidades (para o app nascer útil).

## Entradas opcionais

- Restrições (offline, binário mínimo, time .NET), tema/design, publisher/assinatura.

## Validação do catálogo

Confirmar as skills filhas; faltando uma crítica, **parar** e dizer qual e para qual papel:
`requisitos-descoberta` · `arquiteto-software` · `arquiteto-dados` · `designer-ux-ui` ·
`especialista-seguranca` · `desktop-tauri-scaffold` · `desktop-feature-crud` · `desktop-packaging` ·
`testador-real` · `auditor-responsabilidades`. (Se o galho for JavaFX, delega ao
`spec-javafx-new-system`.)

## Árvore de decisão de stack (registra a escolha como ADR)

- **Tauri v2 — padrão.** UI web, binário ~8 MB e ~172 MB RAM (vs Electron ~244 MB / ~409 MB —
  gethopp, https://www.gethopp.app/blog/tauri-vs-electron; ordem de grandeza, verificar na data),
  segurança default-deny. Trade-off: WebView do SO (render WebKit×Chromium pode divergir). **Tem
  geradores neste catálogo:** `desktop-tauri-scaffold` → `desktop-feature-crud` → `desktop-packaging`.
- **JavaFX/Access** → **handoff** para `spec-javafx-new-system` (track próprio).
- **Flutter — se o alvo é mobile + desktop** do mesmo código → **handoff** para `spec-mobile-app`.
- **Avalonia (.NET) — atrito mínimo vindo de JavaFX/JDBC.** XAML≈FXML, C#≈Java, ADO.NET≈JDBC;
  escolher quando a curva importa mais que o binário e o time é .NET/Java. Packaging por **Velopack**.
  **Sem gerador neste catálogo ainda** → registrar a decisão em **ADR** e **parar e avisar** / conduzir
  manualmente com as lentes (não é um beco).
- **Electron — só com reuso web forte** (app React/web grande já pronto, ou exigência de Chromium
  consistente). Aceitar o custo de tamanho/RAM conscientemente. **Sem gerador neste catálogo ainda** →
  **ADR** + **parar e avisar** / conduzir manualmente com as lentes.
- Empate/dúvida → **parar** e decidir com o Jeremias (ADR), nunca adivinhar.

## Sequência determinística (galho Tauri; cada etapa tem gate)

1. **Descoberta.** `requisitos-descoberta` → requisitos + corte de MVP. *Gate: MVP aprovado.*
2. **Decisão de stack.** Árvore acima → **ADR**. *Gate: stack registrado. Se ≠ Tauri: JavaFX →
   `spec-javafx-new-system`; Flutter → `spec-mobile-app`; Avalonia/Electron → sem gerador ainda, parar e
   avisar / conduzir manualmente com as lentes.*
3. **Arquitetura + modelo de dados.** `arquiteto-software` (limite front×core, IPC) + `arquiteto-dados`
   (modelo SQLite local, migrações, chaves). *Gate: ADRs + esquema inicial.*
4. **Design.** `designer-ux-ui` → mockups das telas do MVP com estados (referência Impeccable).
   *Gate: mockups aceitos (RO-06) antes de qualquer UI.*
5. **Segurança de base.** `especialista-seguranca` define capabilities/permissions por janela + CSP
   estrita (default-deny). *Gate: superfície mínima desenhada.*
6. **Scaffold.** `desktop-tauri-scaffold` → base que abre e builda, com segurança, updater e CI.
   *Gate: dev abre + build verde.*
7. **Features (N×).** `desktop-feature-crud` por entidade do MVP (migração up/down + comando fino +
   binding tipado + tela). *Gate por feature: smoke CRUD verde.*
8. **Empacotamento.** `desktop-packaging` → instaladores assinados + auto-update via GitHub Releases.
   *Gate: update de teste `vN → vN+1` aplicado.*
9. **Testes de verdade.** `testador-real` (estática + dinâmica). *Gate: relatório datado sem FAIL
   crítico.*
10. **Iteração até ≥9.** Comitê + testador avaliam; iterar as etapas fracas até **nota ≥9** (ou o
    limite de rodadas), no espírito do `orquestrador-fable`.
11. **Gate final.** `auditor-responsabilidades` → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (requisitos→arquitetura; modelo de dados→migrações;
  mockups→telas; scaffold→features) — nada decorativo.
- Nomes consistentes entre entidade, migração, comando, binding e tela.
- **Segurança default-deny é piso** em toda feature (capabilities escopam comandos de plugin/core e o
  multi-janela — não afrouxar o escopo; o comando próprio não exige entrada de capability); segredos e
  chaves fora do git.
- Pedido pequeno não vira burocracia: etapas puláveis são puladas **declaradamente**, não em silêncio.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Stack ambíguo (decidir por ADR); mockup não aprovado.
- Falta de skill filha crítica no catálogo.
- Nota < 9 após o limite de rodadas.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas e skills usadas · **decisão de stack (ADR)** · arquivos/artefatos (caminhos
exatos — RO-03) · evidências por gate (MVP, ADRs, mockups aceitos, builds, smokes CRUD, update de
teste, relatório do testador) · **nota atual** e o que faltou para ≥9 · pendências/limitações ·
**2–3 sugestões de evolução (RO-07)** · veredito do `auditor-responsabilidades`.

## Saída esperada

- App desktop novo, da ideia ao **instalador assinado com auto-update**, com features CRUD sobre
  SQLite e segurança default-deny — aderente às Regras de Ouro, com **nota ≥9**.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` + `arquiteto-dados` (modelo local) + `designer-ux-ui` + `especialista-seguranca` (capabilities/CSP) ao longo das etapas; `auditor-responsabilidades` fecha com o veredito.
- **Vem antes:** `requisitos-descoberta`, ou `spec-projeto-completo` (que delega para cá quando a plataforma é desktop moderno).
- **Vem depois:** `testador-real` (bateria completa) · `docs-projeto` · `memoria-de-projeto`.
- **Não confundir com:** `spec-javafx-new-system` (track desktop JavaFX/Access — prefira-o nesse galho) · `spec-projeto-completo` (universal, qualquer plataforma) · `orquestrador-fable` (maestro multi-modelo; aqui o loop até ≥9 é herdado, mas a sequência é a do track desktop).
