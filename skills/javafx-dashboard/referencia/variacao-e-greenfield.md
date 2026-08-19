# O que varia por projeto + Gabarito SIGO + Greenfield — javafx-dashboard

Detalhamento movido para fora do `SKILL.md` (progressive disclosure). O corpo mantém os **invariantes inegociáveis** e um resumo com ponteiro para cá. Leitura obrigatória antes de escrever a primeira linha em um projeto **sem** referência própria.

## O que varia por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto: os **nomes e mecanismos concretos** que implementam os invariantes do corpo. Leia a tela/tema/DAO mais próximos que já existem no projeto-alvo e copie a forma real:

- **Prefixo do token de tema.** No SIGCOT, `-sigo-*` (dezenas de tokens semânticos — ver `referencia/sigcot-stack.md`); outro projeto pode usar `-color-*`, `-status-*` ou outro — use o que o `.root` do projeto já declara, nunca invente um prefixo novo.
- **Quantos temas existem e quais.** No SIGCOT hoje: **4** (claro, escuro, cinza, grafite — corrigido de um "6" desatualizado; ver Histórico). Confirme a contagem real antes de "virou em todos os temas"; tema de menu claro pode exigir o texto do header invertido (escuro) — checar no CSS real, não assumir.
- **Helper de alerta/erro amigável.** No SIGCOT (código real desta skill, `com.sigo.util`), a classe é `AlertHelper` (`AlertHelper.erroAoAbrirView(...)`); outro projeto pode ter outro nome (`AlertaUtil`, `Dialogos`, `Notificador`…) — use o que já existe, não recrie nem renomeie (RO-01). *(A skill `javafx-app-shell` cita `AlertaUtil`/`Dialogos` como o exemplo de outro projeto — não é contradição interna desta skill; ver Histórico.)*
- **Mecanismo de detalhe sob demanda.** No SIGCOT, `HoverDetalhe` (dois níveis de Shneiderman — resumo instantâneo + detalhe assíncrono cacheado; detalhe em `referencia-widgets-extraido.md`); outro projeto pode não ter esse componente — um `Tooltip`/modal simples também cumpre o princípio ("detalhe escondido até o usuário pedir"); greenfield sem projeto-irmão, proponha o mais simples e declare **SUPOSIÇÃO:** (RO-01).
- **Cadência/mecanismo de auto-refresh.** No SIGCOT, botão manual **+** automático a cada 30 min via scheduler daemon (detalhe em `referencia-widgets-extraido.md`); outro projeto/arquétipo pode ter cadência diferente (um painel Executivo de relance diário pode nem precisar de auto-refresh) — espelhe o real ou, greenfield, decida pelo arquétipo e declare **SUPOSIÇÃO:**.
- **Componente de ícone.** No SIGCOT, `SvgIcons`; outro projeto pode ter outro helper — a regra fixa é só "sem emoji" (RO-05).
- **Biblioteca de gráfico.** No SIGCOT, os charts nativos do JavaFX (`BarChart`, `LineChart`, `PieChart`…); espelhe o que o projeto já usa — não introduza lib de terceiros sem combinar.

## Gabarito SIGO (few-shot de código real)

Projeto-alvo sendo o **SIGO/SIGCOT ou sua família**, carregue `referencia-exemplos-reais-sigo.md` — DashboardController verbatim + 9 convenções reais (Task única com record `Dados` agregador; **reuso obrigatório do `AlertasService`** — nunca recalcular alertas localmente; KPIs clicáveis via `DESTINO_KPI` + `card-clicavel`; navegação injetada por `Consumer<String>`; saudação por horário + privacidade por papel; `Locale.of("pt","BR")`). Complementa o BLUEPRINT do corpo, não o substitui. O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Greenfield sem projeto-irmão — checklist negativo (leia ANTES de escrever a primeira linha)

Este é o ponto exato onde a maioria dos erros acontece: sem projeto-irmão real, o gabarito SIGO — porque está empacotado e é fácil de copiar — vira o padrão por reflexo, mesmo quando ninguém pediu. Isso já aconteceu em skill-irmã desta mesma família (`java-db-foundation`, caso 3 do `evals/placar-baseline.md`: greenfield importou o mecanismo do SIGO citando RO-01/RI-01 para parecer conforme, quando a regra pedia o oposto). Antes de gerar FXML/controller em um projeto **sem** referência real própria, confirme que você **NÃO**:

- [ ] usou `-sigo-*` (ou qualquer prefixo de token do SIGCOT) — proponha um prefixo próprio do projeto novo (ex. `-color-*`) e declare `SUPOSIÇÃO:`.
- [ ] criou, importou ou assumiu uma classe chamada `AlertHelper` — é nome específico do SIGCOT; use `Alert` nativo do JavaFX ou declare `SUPOSIÇÃO:` para um helper simples com nome genérico.
- [ ] criou, importou ou assumiu `HoverDetalhe` — é componente específico do SIGCOT; use `Tooltip` simples/expandir ou declare `SUPOSIÇÃO:`.
- [ ] implementou o refresh manual + automático de 30 min do SIGCOT por padrão — decida a cadência pelo **arquétipo** do painel (Executivo raramente precisa de auto-refresh) e declare `SUPOSIÇÃO:`.
- [ ] assumiu **4 temas** (claro/escuro/cinza/grafite) como se fosse regra universal — greenfield pode ter 1, 2 ou N; decida e declare.
- [ ] copiou nomes de classes utilitárias do SIGCOT (`SvgIcons`, `EstadoTabela`, `ScalingRoot`, `com.sigo.*`) — proponha nomes/pacote próprios do projeto novo.
- [ ] copiou a **ordem de boot**/estrutura de pastas específica do SIGO (ex. onde o `DashboardView.fxml` mora, como o `Task` é disparado no `initialize()`) sem checar se o projeto novo já tem uma convenção própria — se não tem, proponha a mais simples e declare `SUPOSIÇÃO:`, não replique a do SIGCOT por padrão.

Se qualquer item acima for "sim, fiz isso" sem uma `SUPOSIÇÃO:` explícita justificando por que essa é a decisão mais simples para *este* projeto, pare — isso é importação por reflexo, não espelhamento (RO-01 exige o oposto: declarar, não presumir).
