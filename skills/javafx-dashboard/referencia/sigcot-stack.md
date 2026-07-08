# Construir no stack real do SIGCOT — não inventar API

Tudo aqui foi extraído do código de produção (`DashboardController` + `DashboardView.fxml` + `theme-base.css` + helpers em `com.sigo.util`). É o template-ouro. **Confira a assinatura real no projeto antes de usar** — nomes podem evoluir; este arquivo é o mapa, o código é a verdade (RO-01).

## Índice
1. [Template-ouro: anatomia do DashboardView](#1-template-ouro-anatomia-do-dashboardview)
2. [Tokens de tema disponíveis](#2-tokens-de-tema-disponiveis)
3. [KPI card — o padrão real](#3-kpi-card--o-padrao-real)
4. [Gráficos nativos + injeção de cor](#4-graficos-nativos--injecao-de-cor)
5. [Dados assíncronos — Task + daemon](#5-dados-assincronos--task--daemon)
6. [Auto-refresh](#6-auto-refresh)
7. [HoverDetalhe — detalhe sob demanda](#7-hoverdetalhe--detalhe-sob-demanda)
8. [Helpers e convenções](#8-helpers-e-convencoes)

---

## 1. Template-ouro: anatomia do DashboardView

`src/main/resources/views/DashboardView.fxml` + `com.sigo.controller.DashboardController` são o padrão a copiar. Estrutura de cima para baixo (a hierarquia da pirâmide invertida já está aplicada):

```
VBox (.root, style -sigo-app-bg)
├── Header (HBox): branding + relógio + DatePicker + "Atualizar Painel" + "Duplicar"
├── Bandeira de crise (HBox): cor por nível (verde/amarelo/vermelho/preto) + ícone SVG + contagem
├── Linha de KPIs (HBox, 6 cards, cada um HBox.hgrow="ALWAYS")
├── Grade de gráficos (GridPane 2x2): StackedBar, Bar, Line, Pie
└── Painéis de detalhe (HBox, altura fixa ~220): 3 TableView com contagem
```

Regras frágeis ao editar este FXML (RO-09): `HBox.hgrow`/`VBox.vgrow` numa linha só; marcar blocos novos com `★★★ INÍCIO/FIM V.X.Y ★★★`. Editar com `[System.IO.File]::ReadAllText/WriteAllText` (UTF-8) — `Get-Content -Raw` corrompe acento no PS 5.1.

O controller orquestra: `initialize()` → aplica ícones, liga DatePicker, configura tabelas, dispara `atualizarDashboard()`, inicia auto-refresh. Os dados vêm num DTO imutável (`DashboardSnapshot`) montado fora da thread da UI.

## 2. Tokens de tema disponíveis

Declarados no `.root` de `src/main/resources/css/theme-base.css` (variantes sobrescrevem: `theme-dark.css`, `theme-azul.css`, `theme-cinza.css`, `theme-grafite.css`, `theme-classico.css`). **Use o token pelo significado; nunca hex fixo (RO-12).**

**Superfícies e texto:**
`-sigo-app-bg` (fundo da tela) · `-sigo-surface` (card/painel/input) · `-sigo-text` (texto primário) · `-sigo-text-muted` (secundário) · `-sigo-border` (divisória) · `-sigo-accent` (verde marca) · `-sigo-focus-ring` (foco teclado).

**Semântica de texto/ícone (foreground):**
`-sigo-fg-green` · `-sigo-fg-red` · `-sigo-fg-orange` · `-sigo-fg-blue` · `-sigo-fg-purple` · `-sigo-fg-slate`.

**Aliases semânticos (preferir em tela nova):**
`-sigo-success` / `-sigo-success-bg` · `-sigo-danger` / `-sigo-danger-bg` · `-sigo-warning` / `-sigo-warning-bg` · `-sigo-info` / `-sigo-info-bg` · `-sigo-neutral` / `-sigo-neutral-bg`.

**Fundo de chip (badge claro):** `-sigo-chip-green-bg` · `-sigo-chip-orange-bg` · `-sigo-chip-red-bg` · `-sigo-chip-blue-bg` · `-sigo-chip-purple-bg`.

**Fundo de botão sólido (texto branco por cima):** `-sigo-btn-primary-bg` · `-sigo-btn-success-bg` · `-sigo-btn-warning-bg` · `-sigo-btn-danger-bg` · `-sigo-btn-info-bg` · `-sigo-btn-slate-bg` · `-sigo-btn-purple-bg`.

**Tabela:** `-sigo-tab-header-bg/-text` · `-sigo-tab-row` / `-sigo-tab-row-alt` (zebra) · `-sigo-tab-sel` / `-sigo-tab-sel-text` · `-sigo-tab-hover` · `-sigo-tab-grid`.

> ⚠️ **Regra dark-safe:** texto branco sobre um `-sigo-fg-*` de *fundo* quebra no Dark. Para fundo colorido com texto branco use `-sigo-btn-*-bg` ou `-sigo-fill-*`; `-sigo-fg-*` é para **cor de texto/ícone**, não fundo.

> 🎨 **6 temas (obrigatório virar nos 6):** `theme-base/azul/cinza/dark/grafite/classico.css` sobrescrevem o `.root`. O painel deve se ajustar **por inteiro** nos 6 — fundo, cards, texto, semântica, tabelas **e gráficos** (a injeção de cor lê tokens, nunca hex). **Verificar nos 6**, não só claro/escuro. Gotcha: o **clássico** tem `-sigo-menu-bg` **claro** — o texto/itens do header precisam **inverter para escuro**; não assuma header sempre escuro.

## 3. KPI card — o padrão real

Não há componente reutilizável ainda — cada card é um `VBox` inline com faixa colorida à esquerda. Padrão (de `DashboardView.fxml`):

```xml
<VBox fx:id="cardEventos" HBox.hgrow="ALWAYS" alignment="CENTER"
      style="-fx-background-color: -sigo-surface; -fx-padding: 14 12 14 12;
             -fx-background-radius: 10; -fx-border-color: -sigo-border;
             -fx-border-radius: 10; -fx-border-width: 0.5 0.5 0.5 6;
             -fx-border-left-color: -sigo-danger; -fx-cursor: hand;">
    <Label text="Eventos em andamento"
           style="-fx-font-size: 12.5px; -fx-text-fill: -sigo-text-muted; -fx-font-weight: bold;"/>
    <Label fx:id="lblKpiEventos" text="0"
           style="-fx-font-size: 34px; -fx-font-weight: bold; -fx-text-fill: -sigo-danger;"/>
</VBox>
```

A faixa de 6px à esquerda (`-fx-border-left-color`) é o canal de cor semântica do card. Número-herói 34px, rótulo 12.5px muted — a hierarquia interna que o `design-canon.md` pede. `-fx-cursor: hand` sinaliza que é clicável (gancho para drill-down). **Melhoria recomendável (RO-07):** extrair isso para um FXML include / fábrica de card — hoje é repetição.

## 4. Gráficos nativos + injeção de cor

O SIGCOT usa **os charts nativos do JavaFX** — `StackedBarChart`, `BarChart`, `LineChart`, `PieChart`. **Não há biblioteca de terceiros nem Canvas custom.** Não introduza uma sem combinar.

Montar série a partir de um `Map`:

```java
grafico.getData().clear();
XYChart.Series<String, Number> serie = new XYChart.Series<>();
serie.setName(nomeDaSerie);
for (Map.Entry<String, Integer> e : dados.entrySet()) {
    serie.getData().add(new XYChart.Data<>(e.getKey(), e.getValue()));
}
grafico.getData().add(serie);
```

Cor por token — a injeção roda **depois** do chart renderizar, por isso `Platform.runLater`:

```java
Platform.runLater(() -> {
    for (int i = 0; i < grafico.getData().size(); i++) {
        String cor = PALETA[i % PALETA.length];               // tons da marca
        for (Node n : grafico.lookupAll(".default-color" + i + ".chart-bar"))
            n.setStyle("-fx-bar-fill: " + cor + ";");
        for (Node n : grafico.lookupAll(".default-color" + i + ".chart-legend-item-symbol"))
            n.setStyle("-fx-background-color: " + cor + ";");
    }
});
```

Para `PieChart`, o seletor é `.data<i>.chart-pie` e a cor vem semântica (ex.: Programada=verde, Urgência=laranja, Emergência=vermelho). A rampa verde Neoenergia em uso: `#E6F5EC → #A9DEBF → #00A443 → #008C39 → #006B32 → #00402A`. Mantenha o `design-canon.md` em mente: poucas cores, com significado.

## 5. Dados assíncronos — Task + daemon

**Regra inegociável (RO-J1): banco nunca na thread da UI.** Padrão canônico (de `atualizarDashboard()`):

```java
if (carregando) return;          // guarda anti-empilhamento
carregando = true;
final LocalDate base = dpData.getValue();

Task<DashboardSnapshot> tarefa = new Task<>() {
    @Override protected DashboardSnapshot call() {
        return carregarDados(base);   // ← TODO o I/O aqui (fora da FX-thread)
    }
};
tarefa.setOnSucceeded(ev -> { carregando = false; aplicar(tarefa.getValue()); });  // UI aqui
tarefa.setOnFailed(ev -> { carregando = false; log.error("Falha ao carregar o painel.", tarefa.getException()); });

Thread t = new Thread(tarefa, "dashboard-carga");
t.setDaemon(true);   // não segura o shutdown da JVM
t.start();
```

- `call()` monta um DTO imutável (`DashboardSnapshot`) com **todas** as queries; `onSucceeded` só aplica na UI (`setText`, `setItems`, `setData`, instala hovers). Nunca toque em nó da cena dentro de `call()`.
- Mostrar placeholder "Carregando…" e desabilitar o botão de atualizar durante a carga.
- DAO típico: `DashboardDAO` retorna `Map<String,Integer>` (KPIs, estágios), `Map<String,Map<String,Integer>>` (volume por tipo/dia), `List<...Resumo>` (tabelas). UCanAccess/Access por baixo.

## 6. Atualização — manual + automática a cada 30 min (padrão SIGCOT)

Todo painel: **botão "Atualizar"** (manual) **+** auto-refresh de **30 minutos**. Scheduler daemon + `Platform.runLater` (de `iniciarAutoRefresh()`):

```java
private static final int INTERVALO_MIN = 30;   // padrao SIGCOT
scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
    Thread t = new Thread(r, "SIGO-Dashboard-AutoRefresh"); t.setDaemon(true); return t;
});
scheduler.scheduleAtFixedRate(
    () -> Platform.runLater(this::atualizarDashboard),
    INTERVALO_MIN, INTERVALO_MIN, TimeUnit.MINUTES);
```

Registrar `scheduler.shutdownNow()` no fechamento da janela. **Sempre** mostrar "Atualizado às HH:mm" no header (repintado no `onSucceeded`); em falha vira "Falha ao atualizar às HH:mm" no `onFailed` — tempo real que envelhece calado é o anti-padrão nº 1 do `design-canon.md`. Cadência diferente de 30 min só por decisão explícita do usuário.

## 7. HoverDetalhe — detalhe sob demanda

`com.sigo.util.HoverDetalhe` implementa o tooltip de dois níveis de Shneiderman (resumo instantâneo + detalhe assíncrono do banco, com cache). Liga a pirâmide invertida: o detalhe fica escondido até o usuário pedir.

```java
HoverDetalhe.instalar(
    cardEventos,                       // nó alvo
    "kpi:eventos:" + dataRef,          // chave de cache única
    () -> montarResumoEmMemoria(),     // Nível 1: instantâneo, em memória
    () -> consultarDetalheNoBanco());  // Nível 2: assíncrono (daemon), cacheado
```

Já usado nos KPIs e nos segmentos de gráfico do dashboard. Limpar o cache a cada refresh com `invalidarCache()`.

## 8. Helpers e convenções

- **`SvgIcons`** — ícones SVG inline centralizados (`FLAG`, `CLOCK`, `BOLT`, `ALERT_TRIANGLE`, `REFRESH`, `COPY`, `LIST`, `CALENDAR`…). Sem emoji, sem icon-font (RO-05). `ico.setContent(SvgIcons.MONITOR)`; cor por `-fx-fill` (token).
- **`EstadoTabela`** — estados vazio/carregando/erro padronizados (classes CSS `.estado-tabela/.estado-titulo/.estado-dica/.estado-spinner/.estado-erro`). Use no lugar do "No content in table" default.
- **`AlertHelper`** — erro amigável + detalhe técnico expansível, thread-safe (`Platform.runLater` interno). `AlertHelper.erroAoAbrirView(nome, erro)`.
- **`ScalingRoot` + `UIScaleManager`** — responsividade por transform de escala (base 1920×1080) + ScrollPane de fallback; zoom Ctrl +/−. Tela nova já é coberta pelo hook global; não reinventar media-query.
- **`JanelaUtil.abrirNaoModal` / `ClonadorForm`** — abrir o painel em janela flutuante e o "Duplicar" (clonar o painel para uma segunda tela). Já no header do dashboard.
- **`LayoutTabelaHelper`** — persiste ordem/largura/visibilidade/sort de coluna por usuário. Use nas tabelas de detalhe se o usuário deve poder reorganizar. Gotcha: `setItems()` limpa o sortOrder — vincular 1×, depois `setAll` + reaplicar sort.
- **Logging:** Log4j 2, `Throwable` como último argumento; nunca `System.out` (RO-08).
- **Controller fino:** sem SQL nem regra de negócio — delega a DAO/serviço. A query e a regra de agregação moram no DAO/serviço, não na tela.
