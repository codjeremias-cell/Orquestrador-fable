---
name: javafx-dashboard
description: "Cria dashboards e painéis JavaFX — executivo, operacional e de decisão — começando pelo BLUEPRINT (público, decisão, perguntas, KPIs, escolha de gráfico, layout) e só depois construindo, com rigor de veracidade dos dados e estados vazio, carregando, erro e sem-dado. Acione com \"tela de acompanhamento\", \"tela de gestão\", \"bater o olho na operação\", \"mostrar os dados\". Fronteira entre as skills-irmãs: aqui é um PAINEL de KPIs/decisão; para uma tela CRUD comum (cadastro/listagem) use javafx-screen-fxml; para tema/tokens de cor use javafx-theme-tokens; para a casca do app (janela/navegação onde o painel encaixa) use javafx-app-shell."
---

# JavaFX — Dashboard / Painel (executivo, operacional, decisão)

## Objetivo

Entregar um dashboard JavaFX no padrão dos melhores do mundo: um instrumento que responde a uma pergunta clara e **habilita uma decisão**, com rigor de veracidade dos dados e fidelidade ao stack real do **projeto-alvo** (padrão SIGCOT quando o projeto é SIGO/SIGCOT ou família — ver o Gabarito SIGO em `referencia/variacao-e-greenfield.md`; noutro projeto, espelhe o stack real dele). **Design primeiro** (blueprint + mockup aceitos), construção depois. Um dashboard medíocre mostra números; um excelente muda o que a pessoa faz nos próximos cinco minutos.

## Fronteira com as skills-irmãs (não confundir)

- **Aqui (`javafx-dashboard`):** um **painel de KPIs/decisão** — instrumento que habilita uma decisão.
- **`javafx-screen-fxml`:** uma **tela CRUD/operação comum** (cadastro/listagem/formulário), não um instrumento de decisão.
- **`javafx-theme-tokens`:** o **tema/os tokens de cor** que o painel consome (o painel nunca inventa hex).
- **`javafx-app-shell`:** a **casca** (janela/navegação) onde o painel encaixa.

## A estrela-guia — leia antes de qualquer gráfico

Um dashboard **não é um depósito de dados** — é um instrumento de decisão. Antes de desenhar o primeiro card, responda quatro perguntas. Se não souber respondê-las, você ainda não sabe qual é o dashboard:

1. **Quem** olha? (diretor, operador de sala de controle, analista de programação)
2. **Que decisão** ele toma a partir daqui?
3. **Com que frequência** olha? (uma vez ao dia / o tempo todo / sob demanda)
4. **O que ele faz quando o número fica vermelho?**

Tudo o que vem depois — KPI, gráfico, cor, layout, interação — **deriva dessas respostas**. O detalhamento desse raciocínio está em `referencia/design-canon.md` (leitura obrigatória) — é o cérebro de designer da skill.

## Os três arquétipos de público

A maioria dos pedidos cai em um destes três. Identifique o arquétipo cedo: ele dita densidade, cadência, horizonte de tempo e nível de interação.

| Arquétipo | Quem / quando | O que valoriza | Erro fatal |
|---|---|---|---|
| **Executivo / Estratégico** | Diretoria, relance diário/semanal | Poucos KPIs com **contexto** (meta, tendência), visão macro, "bate o olho em 5 s" | Afogar em detalhe operacional |
| **Operacional / Tempo real** | Sala de controle, o tempo todo | Estado **agora**, alertas que saltam, densidade alta tolerada | Dado velho disfarçado de vivo |
| **Decisão / Analítico** | Analista, sob demanda | Comparação, **filtro/drill-down**, série temporal, "por quê" | Conclusão pronta sem deixar explorar |

Cada arquétipo tem padrão de layout, escolha de gráfico e interação próprios — ver `referencia/design-canon.md`.

## Entradas obrigatórias

1. **Público e a decisão** que o painel habilita (o arquétipo).
2. **As perguntas** que o painel responde (de 3 a 7 — mais que isso vira dois dashboards).
3. **A fonte real** de cada número: DAO/serviço/query que o alimenta. Sem fonte, não há KPI.
   - **SIGO/SIGCOT (ou família):** a referência empacotada (`referencia/sigcot-stack.md` + `referencia-exemplos-reais-sigo.md`) **já É a fonte real** do padrão de construção (tokens, temas, `Task`+daemon, `AlertHelper`, `HoverDetalhe`) — não é preciso abrir um repositório vivo na sessão. Só a assinatura de um DAO/query específico e novo, que a referência não cobre, exige `SUPOSIÇÃO:` pontual (RO-01) — isso não autoriza recusar a construção inteira (ver Etapa 4).

## Trava obrigatória (RO-06 + veracidade)

- **Não construir** FXML/controller sem o **blueprint + mockup aceitos** pelo Jeremias (que decide no visual).
- **Não exibir número sem fonte real rastreável.** Dado inventado, chumbado ou "de exemplo" passando por real quebra a confiança no painel inteiro. Em dúvida sobre um valor, marque **"sem dado"** explicitamente — nunca disfarce ausência de dado como `0`.
- Se a decisão, o público ou a fonte de algum número forem ambíguos, **pergunte** — não invente.

## Leituras obrigatórias (RO-01)

1. **`referencia/design-canon.md`** — princípios de classe mundial: arquétipos detalhados, escolha de gráfico, hierarquia visual, cor semântica, decluttering (Tufte/Few) e galeria de anti-padrões.
2. **`referencia/sigcot-stack.md`** — como o SIGCOT constrói de verdade: tokens reais, o template-ouro `DashboardView.fxml`, o padrão `Task`+daemon, injeção de cor nos gráficos, `HoverDetalhe`, `SvgIcons`, `EstadoTabela`, `ScalingRoot`. Nunca inventar API/token — copiar daqui.
3. **`referencia/blueprint-template.md`** — o documento que você preenche **antes** de construir.
4. O **`DashboardView.fxml` + `DashboardController`** existentes no projeto, como template-ouro a copiar.
5. O **DAO/serviço** que fornece cada número (assinaturas reais, formato de retorno).

## Fluxo Design → Build (em ordem)

1. **Enquadrar (público + decisão).** Responda as quatro perguntas da estrela-guia, fixe o arquétipo, liste as 3–7 perguntas. Saída: um parágrafo de propósito que cabe numa frase ("painel para o operador da sala decidir, em tempo real, onde a janela vai estourar").
2. **Blueprint** (preencher `referencia/blueprint-template.md`). Para cada pergunta, decida o **mecanismo visual** e justifique a **escolha de gráfico** pela regra de `design-canon.md` (comparação→barra, tendência→linha…). Para cada número, anote **fonte (DAO/query), fórmula, contexto (meta/comparação) e estado sem-dado**. Defina o **layout em grid** com hierarquia (o mais importante no topo-esquerda) e os **estados**.
3. **Mockup e aceite (RO-06).** Apresente um mockup visual (HTML renderizado/wireframe claro) e obtenha o "ok" antes do código. É barato iterar no mockup, caro no FXML.
4. **Construir (no stack real do projeto).** Para o SIGO/SIGCOT, `referencia/sigcot-stack.md` é o gabarito verbatim (FXML no padrão do template-ouro, injeção de cor, `HoverDetalhe`, `SvgIcons`, `EstadoTabela`, `ScalingRoot`); noutro projeto, leia o equivalente real (view+controller existente, provedor de tema, helper de alerta) e espelhe — nunca importe o gabarito SIGO por padrão (RO-01; ver `referencia/variacao-e-greenfield.md`). **Com blueprint + mockup aceitos e a referência empacotada disponível, construir é o passo esperado — não trave alegando "não localizei o projeto"/"não há DAO real acessível".** Só a assinatura de um DAO/método/query específico e novo, fora do que a referência cobre, exige `SUPOSIÇÃO:` pontual (RO-01) para esse número.
5. **Verificar.** Ver "Verificação de fechamento (RI-04)" abaixo.

## Rigor de dados — a exigência inegociável

A entrega de dados é tão importante quanto o visual. Antes de declarar pronto, todo número passa por:

- **Rastreabilidade** — cada KPI/série aponta para uma query/método real. Nada de valor mágico.
- **Agregação correta** — sem dupla contagem; a janela temporal é a que o usuário espera (hoje = ?, "ativas" = quais status?). Documente a regra.
- **Sem-dado ≠ zero** — ausência de dado é exibida como "—"/"sem dado", não como `0`. Um `0` falso engana mais que um erro.
- **Sem distorção visual** — eixo de barra começa em zero; escala não infla diferença; gráfico certo para a pergunta.
- **Frescor** — mostrar o "atualizado às HH:mm"/data de referência. Dado de tempo real que envelhece em silêncio é um perigo.
- **Reconciliação** — partes somam o todo (a soma dos estágios bate com o total de SIs?). Quando não bater, explique por quê.

## Os invariantes inegociáveis (valem em qualquer projeto)

O que faz um dashboard ser instrumento de decisão (não decoração) e a correção do stack JavaFX. O porquê está em cada bullet:

- **RO-J1 — a UI nunca congela.** Todo acesso a banco roda em `Task` + thread daemon, UI só no `onSucceeded`/`onFailed`, com guarda anti-empilhamento e placeholder "Carregando…". Banco na thread da UI trava o painel.
- **Carimbo de frescor sempre visível.** Todo painel mostra quando os dados foram atualizados; falha de atualização vira aviso explícito ("Falha ao atualizar às HH:mm") — dado velho nunca passa por vivo em silêncio. A cadência/mecanismo concreto **varia** (`referencia/variacao-e-greenfield.md`).
- **RO-12 — cor só por token, nunca hex fixo.** Toda cor semântica usa uma variável de tema **declarada no `.root`** antes de ser usada (token não declarado é ignorado em silêncio). O **nome/prefixo** do token e **quantos temas existem** variam por projeto; confirme no CSS/enum real antes de dizer "virou em todos os temas".
- **RO-09 — FXML frágil.** `VBox.vgrow`/`HBox.hgrow` numa linha só (quebrar corrompe o parser); blocos editados marcados `★★★ INÍCIO/FIM V.X.Y ★★★`.
- **RO-08 — Log4j 2.** Nunca `System.out`/`printStackTrace` (some em produção); `Throwable` como último argumento.
- **RO-05 — sem emoji em código.** Ícone é componente (SVG/ícone real do projeto), nunca emoji.
- **Estados sempre cobertos.** Vazio (`setPlaceholder` PT-BR, nunca o default em inglês), carregando, erro (mensagem amigável, sem stack trace cru) e sem-dado — os quatro, sempre.
- **Densidade com hierarquia.** Mais de ~6–7 KPIs ou ~4 gráficos numa tela é sinal de dois dashboards (ou de hierarquia/abas faltando) — corte ou divida, não empilhe.
- **Controller fino.** Sem SQL nem regra de negócio no controller — mora no DAO/serviço.

## O que varia por projeto — espelhe, não prescreva

Os invariantes acima são fixos; os **nomes e mecanismos concretos** que os implementam variam. Leia a tela/tema/DAO mais próximos que já existem e copie a forma real — **nunca importe o mecanismo do SIGCOT por reflexo** (`-sigo-*`, `AlertHelper`, `HoverDetalhe`, refresh de 30 min, 4 temas, `SvgIcons`/`EstadoTabela`/`ScalingRoot`) fora do SIGO/SIGCOT.

O catálogo completo (prefixo de token, contagem de temas, helper de alerta, hover/detalhe, cadência de refresh, ícone, lib de gráfico), o **Gabarito SIGO** (few-shot de código real) e o **checklist negativo de greenfield** — o que NÃO importar do SIGO quando não há projeto-irmão — estão em **[referencia/variacao-e-greenfield.md](referencia/variacao-e-greenfield.md)** (leitura obrigatória antes de escrever a primeira linha em projeto sem referência própria).

## Verificação de fechamento (RI-04)

Antes de declarar pronto, responda com evidência:

1. **Compila?** O controller compila contra o projeto (`javac` + dependências reais).
2. **Binding FXML↔controller confere?** Todo `fx:id` tem campo `@FXML` do tipo certo, todo handler existe, `fx:controller` correto — dá para fazer **sem abrir o app**. Código que não compila ou com binding quebrado não está pronto.
3. **O painel renderiza e decide?** Quando o projeto roda na sessão: a `DashboardView.fxml` sobe **sem `LoadException`**; os **temas que o projeto realmente declara** funcionam (SIGCOT hoje: 4 — reconfirme, não assuma o "6" antigo); os quatro estados aparecem; navegação por teclado; e o **teste dos 5 segundos** de `design-canon.md` passa (a pergunta central se responde de relance).
4. **Rigor de dados conferido?** O checklist de "Rigor de dados" acima, número a número.

Sem projeto/app acessível na sessão (sem `target/classes`, sem os temas para alternar), os itens que exigem execução viram **SKIP declarado** com o motivo — nunca "compilou"/"virou nos temas" fingido. Reportar arquivos criados, fontes de cada número e suposições.

## Guardrails

- Não exibir dado sem fonte real; não disfarçar sem-dado como zero.
- Não inventar id de componente, método de DAO, nome de helper (alerta/ícone/tema) ou biblioteca de gráfico — ler e espelhar o real (RO-01).
- Não acessar banco na thread da UI; não bloquear a interface.
- Não decorar: todo pixel de tinta carrega informação (Tufte). Sem 3D, sombra gratuita, gradiente decorativo, pizza com muitas fatias.
- Não impor o mecanismo do SIGCOT fora do SIGO/SIGCOT (ver `referencia/variacao-e-greenfield.md`).
- Não entregar sem a Verificação de fechamento (RI-04) acima.

## Saída esperada

- **Blueprint** preenchido + **mockup** aprovado registrados.
- `DashboardXyzView.fxml` + `DashboardXyzController.java` no padrão do projeto, com KPIs, gráficos e tabelas alimentados por DAO/serviço real, **assíncrono**, com os quatro estados e tokens de tema.
- Nota final com: fonte de cada número, regra de agregação/janela, e o checklist de rigor de dados conferido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões pertinentes — por exemplo: extrair um componente reutilizável de **KPI card** (hoje é VBox inline repetido); **drill-down** (clique no card abre a lista filtrada); **alerta proativo** quando um KPI cruza o limite; export do painel (PDF/imagem); sparkline no KPI para dar tendência sem ocupar espaço.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (hierarquia, cor semântica, mockup) · `qa-usabilidade` (teste dos 5 segundos, estados) · `dev-senior` (controller e binding).
- **Vem antes:** `java-jdbc-dao` / `java-service-usecase` (as fontes reais de cada número) · `javafx-theme-tokens` (tokens dos temas) · `javafx-app-shell` (onde o painel se encaixa).
- **Vem depois:** `testador-real` (verificação executada) · `java-logging-log4j2` (erros logados).
- **Não confundir com:** `javafx-screen-fxml` (tela CRUD comum — aqui é instrumento de decisão com KPIs).

### 📜 Histórico
O changelog detalhado de evolução desta skill está em [referencia/historico.md](referencia/historico.md) (movido para fora do corpo para reduzir custo de token em cada turno — progressive disclosure).
