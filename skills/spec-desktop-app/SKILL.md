---
name: spec-desktop-app
description: "Orquestrador de app desktop MODERNO, não-JavaFX: conduz da ideia ao app entregue com árvore de decisão de stack (Tauri v2 padrão, Avalonia .NET quando o atrito de JavaFX/JDBC pesar, Electron só com reuso web forte, Flutter se mobile e desktop) e cobre scaffold, features CRUD e empacotamento assinado. Acione com \"quero um app desktop novo do zero\", \"monta o desktop inteiro da ideia à entrega\", \"app de PC leve tipo Electron mas menor\", \"sistema desktop novo, mas não em JavaFX\", \"desktop cross-platform em Tauri/Rust\". NÃO acione fora disso — para desktop JavaFX/Access, handoff para spec-javafx-new-system; para mobile+desktop do mesmo código, spec-mobile-app; para plataforma indefinida ou não-desktop, spec-projeto-completo. NÃO acione para etapa isolada — use desktop-tauri-scaffold, desktop-feature-crud ou desktop-packaging."
---

# Spec — App Desktop Moderno (orquestrador-topo, track desktop)

Esta é a **orquestradora de topo do track desktop moderno**. Leva a ideia até um app desktop
rodando, assinado e com auto-update, **decidindo o stack por uma árvore de decisão** e aplicando o método dos
geradores `desktop-*`, com as lentes conduzindo. Espelha o `spec-projeto-completo`/
`spec-javafx-new-system` e não duplica o trabalho das filhas.

## Quando usar / Quando NÃO usar

Use **esta** quando o alvo é um app desktop **novo** e a stack **não é JavaFX** (ou ainda está em aberto entre stacks modernas). Ela decide o stack pela árvore abaixo e conduz. Quando a árvore aponta para outro track, ela faz **handoff** e não segue sozinha:

- Stack decidida = **JavaFX/Access** → `spec-javafx-new-system`.
- Alvo é **mobile + desktop** do mesmo código (Flutter) → `spec-mobile-app`.
- Plataforma **indefinida** ou **não-desktop** (web/API/CLI) → `spec-projeto-completo`.
- Projeto desktop **já existe** / só **uma etapa** (só o scaffold, só o packaging) → `desktop-tauri-scaffold`, `desktop-feature-crud` ou `desktop-packaging`.

## Objetivo

Entregar um app desktop de ponta a ponta — requisitos → **decisão de stack** → arquitetura/dados/
design/segurança → scaffold → features → empacotamento assinado com auto-update → testes reais →
veredito — aderente às [[REGRAS-DE-OURO]] (RI + RO universais + **RO-DT1 a RO-DT4** do track
Desktop/Tauri, que a fonte ainda marca como proposta de 2026-07-07 a validar no primeiro projeto
real), com **nota ≥9**.

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

> **Invoque, não descreva.** Cada passo abaixo que cita uma skill exige
> **carregá-la pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


1. **Descoberta.** Carregue a skill `requisitos-descoberta` (ferramenta Skill — invoque, não descreva) → requisitos + corte de MVP. *Gate: MVP aprovado.*
2. **Decisão de stack.** Árvore acima → **ADR**. *Gate: stack registrado. Se ≠ Tauri: JavaFX →
   `spec-javafx-new-system`; Flutter → `spec-mobile-app`; Avalonia/Electron → sem gerador ainda, parar e
   avisar / conduzir manualmente com as lentes.*
3. **Arquitetura + modelo de dados.** Carregue as skills `arquiteto-software` (limite front×core, IPC) e `arquiteto-dados` (ferramenta Skill — invoque, não descreva)
   (modelo SQLite local, migrações, chaves). *Gate: ADRs + esquema inicial.*
4. **Design.** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva) → mockups das telas do MVP com estados (referência Impeccable).
   *Gate: mockups aceitos (RO-06) antes de qualquer UI.*
5. **Segurança de base.** Carregue a skill `especialista-seguranca` (ferramenta Skill — invoque, não descreva): define capabilities/permissions por janela + CSP
   estrita (default-deny). *Gate: superfície mínima desenhada.*
6. **Scaffold.** Carregue a skill `desktop-tauri-scaffold` (ferramenta Skill — invoque, não descreva) → base que abre e builda, com segurança, updater e CI.
   *Gate: dev abre + build verde.*
7. **Features (N×).** Carregue a skill `desktop-feature-crud` (ferramenta Skill — invoque, não descreva) por entidade do MVP (migração up/down + comando fino +
   binding tipado + tela). *Gate por feature: smoke CRUD verde.*
8. **Empacotamento.** Carregue a skill `desktop-packaging` (ferramenta Skill — invoque, não descreva) → instaladores assinados + auto-update via GitHub Releases.
   *Gate: update de teste `vN → vN+1` aplicado.*
9. **Testes de verdade.** Carregue a skill `testador-real` (ferramenta Skill — invoque, não descreva): estática + dinâmica. *Gate: relatório datado sem FAIL
   crítico.*
10. **Iteração até ≥9.** Comitê + testador avaliam; iterar as etapas fracas até **nota ≥9** (ou o
    limite de rodadas), no espírito do `orquestrador-fable`.
11. **Gate final.** Carregue a skill `auditor-responsabilidades` (ferramenta Skill — invoque, não descreva) → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (requisitos→arquitetura; modelo de dados→migrações;
  mockups→telas; scaffold→features) — nada decorativo.
- Nomes consistentes entre entidade, migração, comando, binding e tela.
- **Segurança default-deny é piso** em toda feature (capabilities escopam comandos de plugin/core e o
  multi-janela — não afrouxar o escopo; o comando próprio não exige entrada de capability); segredos e
  chaves fora do git.
- Pedido pequeno não vira burocracia: etapas puláveis são puladas **declaradamente**, não em silêncio.

## Verificação da spec (autossuficiência)

Antes de sair do design (etapa 4) para o scaffold, confira que a spec do app se sustenta sozinha — o porquê: sem fronteira e sem critério de aceite, o binário nasce fazendo coisa fora do alvo e "pronto" vira opinião. A spec responde **sim** a:

- **Escopo** — SO-alvo, stack decidido (ADR) e as primeiras entidades/telas do MVP estão listados?
- **Fora-de-escopo** — o que fica para depois (features, integrações, plataformas) está declarado?
- **Critério de aceite ponta-a-ponta** — há, por feature, um caminho verificável de fora (ex.: "app abre → cria registro → persiste no SQLite → reabre e continua lá") que o smoke CRUD/`testador-real` prove, além do update de teste `vN→vN+1`?

Faltando qualquer item, volte à etapa correspondente antes do scaffold.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Stack ambíguo (decidir por ADR); mockup não aprovado; spec sem escopo/fora-de-escopo/critério de aceite (ver acima).
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
- **Não confundir com:** `spec-javafx-new-system` (track desktop JavaFX/Access — prefira-o nesse galho) · `spec-projeto-completo` (universal, qualquer plataforma) · `spec-mobile-app` (quando o alvo é mobile+desktop) · `orquestrador-fable` (maestro multi-modelo; aqui o loop até ≥9 é herdado, mas a sequência é a do track desktop).

### 📜 Histórico
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.
- **2026-08-11 — O eval alinhado à decisão da T29 (degrau §6.10: 1 — só edição).** A skill dizia no corpo que **não** encadeia (medido: aciona 6/6, delega 0/6) e o `evals/evals.json` **reprovava por não delegar** — a skill contradizia a si mesma. A expectativa passou a medir o **resultado** (as camadas cumprindo o método do gerador), não a **rota**. Decisão do Jeremias, estendida da description aos testes. Proveniência: `_auditoria/zelador-inventario-2026-08-10.md` e `_auditoria/zelador-custo-2026-08-08.md`.

- **2026-08-11 — Rótulo "proposta" fora do título, e "candidatas a RO" resolvidas em RO-DT1 a RO-DT4.** Proveniência: `_auditoria/zelador-inventario-2026-08-10.md`, ATUALIZAR item 12. O título carregava "proposta 2026-07-07" e o §Objetivo falava em "candidatas a RO do track desktop" — as regras já existem nomeadas em REGRAS-DE-OURO.md (**RO-DT1** default-deny · **RO-DT2** bridge tipada · **RO-DT3** migração versionada · **RO-DT4** distribuição assinada), então "candidatas" era imprecisão. A ressalva foi preservada: a fonte ainda marca o bloco como proposta de 2026-07-07 a validar no primeiro projeto real. Estado medido do track: juiz cego em 2026-07-09, 0,35 → 0,97 (`evals/placar-baseline.md`). A parte da ação que mandava mexer em `evals/evals.json` ficou **fora do escopo deste lote** e não foi aplicada — mas registre-se o que a conferência achou: a expectativa `"Delega scaffold/features/empacotamento aos geradores desktop-* em vez de escrever à mão"` **existe**, literal, na linha 14 do `evals/evals.json`, exatamente onde o laudo apontou. A refutação genérica de 2026-08-10 ("nenhum evals.json exige delegação") **não vale para esta skill** e precisa ser rejulgada, porque essa expectativa contradiz o comportamento medido e aceito em 2026-08-09 (acionou 6/6, delegou 0/6).
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. O texto passa a dizer *aplicar o método*, que é o comportamento real; os geradores seguem existindo e invocáveis. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- *(Seção de Histórico criada nesta data — a skill não tinha nenhuma, e sem ela a proveniência da RI-04 não tem onde morar.)*
