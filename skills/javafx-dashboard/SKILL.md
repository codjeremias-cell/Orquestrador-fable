---
name: javafx-dashboard
description: Cria dashboards e painéis JavaFX de excelência — executivo, operacional e de decisão — no padrão dos melhores do mundo, começando pelo BLUEPRINT (público, decisão, perguntas, KPIs, escolha de gráfico, layout) e só depois construindo, com rigor de veracidade dos dados e estados vazio/carregando/erro/sem-dado. Acione sempre que o usuário falar em dashboard, painel, cockpit, indicadores, KPIs, métricas, monitor operacional, visão executiva, "tela de acompanhamento", "tela de gestão", gráfico gerencial, "bater o olho na operação" ou "mostrar os dados" — mesmo sem dizer a palavra dashboard. NÃO acione para uma tela CRUD comum (use javafx-screen-fxml) nem para tema/tokens de cor (use javafx-theme-tokens).
---

# JavaFX — Dashboard / Painel (executivo, operacional, decisão)

## Objetivo

Entregar um dashboard JavaFX no padrão dos melhores do mundo: um instrumento que responde a uma pergunta clara e **habilita uma decisão**, com rigor de veracidade dos dados e fidelidade ao stack real do SIGCOT. **Design primeiro** (blueprint + mockup aceitos), construção depois. Um dashboard medíocre mostra números; um excelente muda o que a pessoa faz nos próximos cinco minutos.

## A estrela-guia — leia antes de qualquer gráfico

Um dashboard **não é um depósito de dados** — é um instrumento de decisão. Antes de desenhar o primeiro card, responda quatro perguntas. Se você não souber respondê-las, você ainda não sabe qual é o dashboard:

1. **Quem** olha? (diretor, operador de sala de controle, analista de programação)
2. **Que decisão** ele toma a partir daqui?
3. **Com que frequência** olha? (uma vez ao dia / o tempo todo / sob demanda)
4. **O que ele faz quando o número fica vermelho?**

Tudo o que vem depois — KPI, gráfico, cor, layout, interação — **deriva dessas respostas**. Essa é a diferença entre um painel bonito e um painel que importa. O detalhamento desse raciocínio está em `referencia/design-canon.md` (leitura obrigatória) — ele é o cérebro de designer da Skill.

## Os três arquétipos de público

A maioria dos pedidos cai em um destes três. Identifique o arquétipo cedo: ele dita densidade, cadência, horizonte de tempo e nível de interação.

| Arquétipo | Quem / quando | O que valoriza | Erro fatal |
|---|---|---|---|
| **Executivo / Estratégico** | Diretoria, relance diário/semanal | Poucos KPIs com **contexto** (meta, tendência), visão macro, "bate o olho em 5 s" | Afogar em detalhe operacional |
| **Operacional / Tempo real** | Sala de controle, o tempo todo | Estado **agora**, alertas que saltam, densidade alta tolerada | Dado velho disfarçado de vivo |
| **Decisão / Analítico** | Analista, sob demanda | Comparação, **filtro/drill-down**, série temporal, "por quê" | Conclusão pronta sem deixar explorar |

Cada arquétipo tem um padrão de layout, escolha de gráfico e interação próprios — ver `referencia/design-canon.md`.

## Entradas obrigatórias

1. **Público e a decisão** que o painel habilita (o arquétipo).
2. **As perguntas** que o painel responde (de 3 a 7 — mais que isso vira dois dashboards).
3. **A fonte real** de cada número: DAO/serviço/query que o alimenta. Sem fonte, não há KPI.

## Trava obrigatória (RO-06 + veracidade)

- **Não construir** FXML/controller sem o **blueprint + mockup aceitos** pelo Mestre (que decide no visual).
- **Não exibir número sem fonte real rastreável.** Dado inventado, chumbado ou "de exemplo" passando por real é proibido — quebra a confiança no painel inteiro. Em dúvida sobre um valor, marque **"sem dado"** explicitamente; nunca disfarce ausência de dado como `0`.
- Se a decisão, o público ou a fonte de algum número forem ambíguos, **pergunte** — não invente.

## Leituras obrigatórias (RO-01)

1. **`referencia/design-canon.md`** — princípios de classe mundial: arquétipos detalhados, escolha de gráfico, hierarquia visual, cor semântica, decluttering (Tufte/Few) e a galeria de anti-padrões. É o que separa "excelente" de "mais um painel".
2. **`referencia/sigcot-stack.md`** — como o SIGCOT constrói de verdade: tokens reais, o template-ouro `DashboardView.fxml`, o padrão assíncrono `Task`+daemon, a injeção de cor nos gráficos, `HoverDetalhe`, `SvgIcons`, `EstadoTabela`, `ScalingRoot`. **Nunca inventar API/token** — copiar daqui.
3. **`referencia/blueprint-template.md`** — o documento que você preenche **antes** de construir.
4. O **`DashboardView.fxml` + `DashboardController`** existentes no projeto, como template-ouro a copiar.
5. O **DAO/serviço** que fornece cada número (assinaturas reais, formato de retorno).

## Fluxo Design → Build (as etapas, em ordem)

### Etapa 1 — Enquadrar (público + decisão)
Responda as quatro perguntas da estrela-guia e fixe o arquétipo. Liste as 3–7 perguntas que o painel responde. Saída desta etapa: um parágrafo curto de propósito que cabe numa frase ("painel para o operador da sala decidir, em tempo real, onde a janela vai estourar").

### Etapa 2 — Blueprint (preencher `referencia/blueprint-template.md`)
Para cada pergunta, decida o **mecanismo visual** (KPI com contexto? gráfico? tabela?) e justifique a **escolha de gráfico** pela regra de `design-canon.md` (comparação→barra, tendência→linha, etc.). Para cada número, anote **fonte (DAO/query), fórmula, contexto (meta/comparação) e estado sem-dado**. Defina o **layout em grid** com hierarquia (o mais importante no topo-esquerda) e os **estados** (vazio/carregando/erro/sem-dado).

### Etapa 3 — Mockup e aceite (RO-06)
Apresentar um **mockup visual** (HTML renderizado/wireframe claro) do blueprint e obter o "ok" do Mestre. Só passar para o código depois do aceite. É barato iterar no mockup, caro iterar no FXML.

### Etapa 4 — Construir (no stack real)
Seguir `referencia/sigcot-stack.md` à risca: FXML no padrão do template-ouro (regras frágeis RO-09), controller fino, **todo acesso a banco em `Task`+thread daemon** com `Platform.runLater` no `onSucceeded` (RO-J1), **cor só por token** (RO-12), gráficos com a injeção de cor padrão, `HoverDetalhe` para o detalhe sob demanda, `SvgIcons` (sem emoji, RO-05), `EstadoTabela` para os estados, `ScalingRoot` para responsividade, Log4j 2 para erro (RO-08).

### Etapa 5 — Verificar (compila + rigor de dados + QA visual)
**Compilar** o controller (`javac` contra `target/classes` + dependências do projeto) e conferir o **binding FXML↔controller** (todo `fx:id` tem campo `@FXML` do tipo certo; todo handler existe; `fx:controller` correto) — dá pra fazer **sem tocar `src/`**. Código que não compila ou com binding quebrado **não está pronto**. Depois, rodar o **checklist de rigor de dados** (abaixo) e o **teste dos 5 segundos** de `design-canon.md`. Conferir o painel **nos 6 temas** (legibilidade, semântica, gráficos), navegação por teclado e os quatro estados. Reportar arquivos criados, fontes de cada número e suposições.

## Rigor de dados — a exigência inegociável

A entrega de dados é tão importante quanto o visual. Antes de declarar pronto, todo número passa por:

- **Rastreabilidade** — cada KPI/série aponta para uma query/método real. Nada de valor mágico.
- **Agregação correta** — sem dupla contagem; a janela temporal é a que o usuário espera (hoje = ?, "ativas" = quais status?). Documente a regra.
- **Sem-dado ≠ zero** — ausência de dado é exibida como "—"/"sem dado", não como `0`. Um `0` falso engana mais que um erro.
- **Sem distorção visual** — eixo de barra começa em zero; escala não infla diferença; gráfico certo para a pergunta (ver anti-padrões).
- **Frescor** — mostrar o "atualizado às HH:mm" / data de referência. Dado de tempo real que envelhece em silêncio é um perigo.
- **Reconciliação** — partes somam o todo (a soma dos estágios bate com o total de SIs?). Quando não bater, explique por quê.

## Convenções de construção (Regras de Ouro do track)

- **RO-J1 — a UI nunca congela:** banco em `Task` (daemon), UI só no `onSucceeded`/`onFailed`, com guarda anti-empilhamento e placeholder "Carregando…".
- **Atualização padrão (SIGCOT) — manual + automática a cada 30 min:** todo painel tem o botão **"Atualizar"** (manual) **e** auto-refresh de **30 min** (scheduler daemon + `Platform.runLater`; `shutdownNow()` ao fechar a janela). Sempre com carimbo **"Atualizado às HH:mm"** que vira **aviso de falha** no `onFailed` — dado velho nunca passa por vivo. Cadência diferente de 30 min só por decisão explícita do usuário.
- **Detalhe sob demanda (hover) — `HoverDetalhe`:** passar o mouse num KPI/card/segmento **traz a lista organizada** por trás do número (cabeçalho + mini-tabela + rodapé-resumo); nível 1 instantâneo em memória, nível 2 assíncrono do banco com cache. É o drill que liga o número à sua origem sem tirar o usuário do panorama.
- **RO-12 — cor só por token / tema-completo nos 6 temas:** cor só por token `-sigo-*` no `.root` (nada de hex fixo). O painel **tem que virar inteiro** nos **6 temas** (base, azul, cinza, dark, grafite, clássico) — fundo, cards, texto, semântica, tabelas **e gráficos** (a injeção de cor lê tokens, não hex). **Verificar nos 6**, não só claro/escuro. Gotcha: temas de **menu claro** (clássico) precisam do texto do header **invertido** (escuro), senão some.
- **RO-09 — FXML frágil:** `VBox.vgrow`/`HBox.hgrow` em uma linha; marcar blocos editados com `★★★ INÍCIO/FIM V.X.Y ★★★`.
- **RO-08** Log4j 2 (sem `System.out`); **RO-05** sem emoji em código (usar `SvgIcons`); controller **fino** (sem SQL/regra).
- **Estados sempre cobertos:** vazio (`setPlaceholder` PT-BR, nunca o default em inglês), carregando, erro (alerta amigável via `AlertHelper`) e sem-dado.

## Guardrails

- Não construir antes do blueprint + mockup aceitos (RO-06).
- Não exibir dado sem fonte real; não disfarçar sem-dado como zero.
- Não inventar id de componente, método de DAO, token de tema nem biblioteca de gráfico (o SIGCOT usa os charts nativos do JavaFX — ver `sigcot-stack.md`).
- Não acessar banco na thread da UI; não bloquear a interface.
- Não empilhar KPI: se passar de ~6–7 indicadores ou ~4 gráficos numa tela, é sinal de que são dois dashboards (ou que falta hierarquia/abas).
- Não decorar: todo pixel de tinta deve carregar informação (Tufte). Sem 3D, sombra gratuita, gradiente decorativo, pizza com muitas fatias.
- Não entregar sem **compilar + conferir o binding** FXML↔controller e sem **validar os 6 temas** — o que não compila ou não vira no tema não está pronto.

## Saída esperada

- **Blueprint** preenchido + **mockup** aprovado registrados.
- `DashboardXyzView.fxml` + `DashboardXyzController.java` no padrão do projeto, com KPIs, gráficos e tabelas alimentados por DAO/serviço real, **assíncrono**, com os quatro estados e tokens de tema.
- Nota final com: fonte de cada número, regra de agregação/janela, e o checklist de rigor de dados conferido.

## Sugestões de evolução (RO-07)

Fechar com 2–3 sugestões pertinentes — por exemplo: extrair um componente reutilizável de **KPI card** (hoje é VBox inline repetido); adicionar **drill-down** (clique no card abre a lista filtrada); **alerta proativo** quando um KPI cruza o limite; export do painel (PDF/imagem) para a reunião; sparkline no KPI para dar tendência sem ocupar espaço.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (hierarquia, cor semântica, mockup) · `qa-usabilidade` (teste dos 5 segundos, estados) · `dev-senior` (controller e binding).
- **Vem antes:** `java-jdbc-dao` / `java-service-usecase` (as fontes reais de cada número) · `javafx-theme-tokens` (tokens dos 6 temas) · `javafx-app-shell` (onde o painel se encaixa).
- **Vem depois:** `testador-real` (verificação executada) · `java-logging-log4j2` (erros logados).
- **Não confundir com:** `javafx-screen-fxml` (tela CRUD comum — aqui é instrumento de decisão com KPIs).
