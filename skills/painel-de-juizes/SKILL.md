---
name: painel-de-juizes
description: "Painel de juízes-subagentes de contexto limpo que COMPARA alternativas às cegas e ESCOLHE a melhor — nunca nota isolada, sempre ranking relativo. Dois modos: painel (tentativas de uma frente ampla, com vencedora e enxertos) e portão pareado (candidato contra campeão, ordens embaralhadas). Acione com \"painel\", \"qual dessas ficou melhor\", \"compara essas duas/três versões e escolhe\", \"esse resultado é melhor que o anterior?\", \"vale trocar pela nova versão?\", \"desempata entre X e Y\", \"faz um julgamento cego\", \"qual implementação seguir\". NÃO acione para avaliar UM resultado isolado em escala absoluta (isso é o Comitê de Lentes) nem para executar testes (testador-real prova)."
disallowed-tools: Write, Edit, NotebookEdit
---

# Painel de Juízes (comparação cega + portão pareado)

**Juiz ≠ lente.** A lente avalia *um* resultado em escala absoluta (nota 0–10 + críticas
acionáveis). O juiz **compara alternativas às cegas e escolhe** — ranking relativo, contexto
limpo, sem saber quem gerou o quê. Os dois se complementam no ciclo: o painel decide **qual**
versão segue; o comitê diz **o que falta** para a nota subir.

## Quando usar / quando NÃO usar

- **Use** quando há **2+ alternativas** (tentativas de uma frente ampla, ou candidato × campeão) e a decisão é **qual segue** / **se a troca vale**.
- **NÃO use** para julgar **um artefato isolado** em escala absoluta — isso é o **Comitê de Lentes** (devolva a ele). Sem disputa, não há o que o juiz faça.
- **NÃO use** para **executar testes** — isso é o `testador-real`; o relatório dele é **insumo** do juiz, não concorrente.
- **Não é o maestro:** o `orquestrador-fable` rege e decide *quando* chamar o painel; o painel só compara e devolve o veredito.

## Objetivo

Impedir dois defeitos do loop iterativo: (a) convergir para "medíocre polido" quando o espaço
de solução era amplo e só uma tentativa foi explorada; (b) **regredir por slop confiante**
quando o resultado de uma rodada substitui o campeão sem disputa.

## Entradas obrigatórias

1. Os artefatos em disputa, **anonimizados** (sem autor, modelo ou rodada de origem).
2. O critério de aceite da frente + a rubrica do placar (1–3 quebrado · 4–6 cru · 7–8 polido ·
   9–10 excelente) — calibração completa no orquestrador regente (hoje: `orquestrador-fable`).
3. O número da rodada do ciclo (define a escala do painel).

## Entradas opcionais

- **Relatório do testador** da rodada (PASS/FAIL/SKIP) — quando existir, é insumo obrigatório
  do julgamento; FAIL crítico pesa contra o artefato afetado.
- Screenshots do resultado real (modo visual).
- Restrições do Jeremias (rubrica extra, prioridades da frente).

## Modo 1 — Painel de tentativas (frente de espaço amplo)

O maestro marcou a frente como espaço amplo (2+ caminhos razoáveis, valor alto): **N ≤ 3
tentativas independentes** por ângulos distintos (ex.: MVP-first, risco-first, usuário-first),
executores isolados entre si. O painel recebe as N anônimas; cada juiz emite veredito
individual às cegas; agrega por maioria. Saída: **vencedora + enxertos** (o que cada derrotada
fez melhor). O maestro sintetiza a partir da vencedora enxertando os pontos — a síntese vira o
candidato da rodada. Com **juiz único** (rodada 3+), ele julga as N tentativas em **duas
chamadas com ordens embaralhadas distintas**; só há vencedora se a mesma tentativa liderar nas
duas — divergindo, o julgamento cai para painel ímpar de 3× do teto disponível.

## Modo 2 — Portão pareado (entre rodadas)

Candidato da rodada × **campeão vigente**, sem identificação, com controle de viés de ordem:

- **Juiz único (rodada 3+):** julga 2 vezes em chamadas separadas (ordem A-B e B-A, contexto
  fresco em cada). Promove só se o candidato **vencer nas duas**.
- **Painel (3 ou 2 juízes):** cada juiz julga uma apresentação com ordem sorteada
  individualmente. Painel de 3 promove por **maioria**; painel de 2 só por **unanimidade**.
- Empate, divergência ou derrota → **mantém o campeão** (efeitos no placar: regra do
  orquestrador regente).
- **Oscilação de campeão (2026-07-10, garimpo autoresearch P6):** quem **detecta e conta as
  trocas é o maestro** — os juízes têm contexto limpo e não veem histórico; o portão só entrega
  o veredito da rodada. Limiar e parada: anti-estagnação do orquestrador regente (hoje:
  `orquestrador-fable`).

## Escala de juízes por rodada

| Rodada do ciclo | Painel | Decisão |
|---|---|---|
| 1 | 3× Sonnet | maioria (2 de 3) |
| 2 | 2× Opus | unanimidade; divergência mantém o campeão |
| 3+ | 1× Fable (topo da sessão, tier **acima** dos executores) | vencer nas duas ordens |
| 3+ sem tier acima | 3× Opus — ou 3× do teto disponível (sem Opus → 3× Sonnet) | maioria; degradação **declarada** no placar (RI-04) |

**Regra da degradação por tier:** capacidade a menos se compensa com voto a mais. O juiz
sênior é sempre o modelo mais capaz **disponível**; quando o teto da sessão é o mesmo tier que
executou o trabalho crítico, o juiz único vira painel ímpar de 3. A mesma regra vale na
**rodada 2**: sem Opus disponível, o par 2× Opus vira **painel ímpar de 3× do teto
disponível** (ex.: 3× Sonnet), decidindo por maioria — sempre declarado no placar. Effort dos
juízes: padrão; subir para alto quando o artefato é grande (muitos arquivos a conferir).

## Protocolo do julgamento (contexto limpo)

- Juiz é sempre **subagente de contexto fresco**: recebe só artefatos anônimos + critério +
  rubrica + relatório do testador. Nunca o raciocínio do maestro, o rastro de outra
  lente/juiz, nem a autoria.
- Juiz **nunca julga artefato que ele mesmo gerou** (nem a mesma conversa de execução).
- O maestro **nunca julga na própria conversa** — guardrail do orquestrador regente (hoje:
  `orquestrador-fable`); todo julgamento entra por esta skill.
- Veredito lê e analisa a evidência: cada julgamento cita o que conferiu no artefato e no
  relatório — impressão sem evidência não vale.
- Em revisões e disputas técnicas, classifique apontamentos pela **precedência estrita**: (1) Contrato mal lido/incompleto, (2) Válido e acionável, (3) Válido trade-off, (4) Ruído.
- **Validade da avaliação e verificação de alegações (pepita UK1):** ao julgar testes, benchmarks e baterias de evals, audite as 4 dimensões de validade (PADRÃO §11.10) — coerência das alegações com os dados reais inspecionados, viabilidade física de sucesso/falha sem alucinação de dados ausentes, alinhamento direto com o ground truth (execução real > proxies de mera compilação) e imunidade a acertos acidentais/edge cases.

### Anti-ancoragem *(2026-08-06, garimpo ECC E5)*


Contexto fresco resolve a ancoragem **do juiz**. Falta a metade que ancora **quem sintetiza** —
e é ela que decide o veredito final:

- **Forme a sua posição ANTES de ler as vozes.** Quem agrega escreve primeiro, para si: posição
  inicial, as três razões mais fortes dela, e o maior risco do caminho que prefere. Sem esse
  registro anterior, a síntese vira espelho da última voz lida, e ninguém consegue distinguir
  convencimento de eco.
- **Despache cada voz com SÓ a pergunta e o contexto mínimo — nunca a transcrição.** O que
  ancora não é o conteúdo do raciocínio alheio; é o **rastro da conversa**. *(Par cognitivo do
  isolamento físico: worktree separado impede um juiz de achar o rascunho do outro; isto impede
  a conversa de plantar a resposta.)*
- **Guardrails de síntese, todos checáveis:** não descarte voz externa sem dizer por quê · se
  uma voz **mudou** a sua recomendação, diga isso explicitamente · publique a **discordância
  mais forte** mesmo quando a rejeita · **duas vozes contra a sua posição inicial é sinal, não
  ruído** — trate como tal ou justifique por escrito · mantenha as posições cruas visíveis
  **antes** do veredito, nunca só o resumo.
- **A unanimidade não é o produto.** O produto é **tornar a discordância legível antes de
  escolher** — painel que converge cedo demais está medindo concordância, não qualidade.

## Veredito padronizado (contrato de retorno)

Cada juiz devolve: `vencedor` (A/B/empate) · `nota` 0–10 por artefato (rubrica de faixas) ·
`razoes[]` (evidências concretas) · `enxertos[]` (o que o perdedor fez melhor) · `metricas`
(tokens, duração). Fora do contrato = julgamento incompleto (refaz uma vez); **segunda falha
= juiz FALHO declarado no placar**, e o painel se reconstitui pela **regra de degradação por
tier desta skill** (painel ímpar do teto disponível, degradação declarada) — nunca decidir
com painel par ou vazio, nunca assumir o veredito de juiz que não entregou (2026-07-12,
garimpo hermes-agent P9). A reconstituição **refaz o julgamento inteiro** com o painel novo
(contexto limpo — vereditos da tentativa anterior não se reaproveitam), declarado no placar. O agregado
(decisão + placar por juiz) entra no placar da rodada; a tabela de tokens do orquestrador
ganha **uma linha por juiz**.

**Rótulo de concordância, no agregado** *(2026-08-18, garimpo oh-my-opencode · G5)*. O agregado
declara o nível de acordo do painel num campo próprio: `concordancia: unanime | maioria | dividido`.
A regra que o produz já existe acima — painel de 3 promove por maioria, painel de 2 só por
unanimidade —, e o que faltava era **o leitor não precisar derivá-la somando notas**: é justamente
perto do corte que a derivação erra (mesma lente, duas instâncias, até 3 pontos de diferença).
O campo é do **agregado, nunca de cada juiz** — juiz com contexto limpo não vê os outros e não teria
como preenchê-lo. **O rótulo soma, não troca:** não dispensa a publicação da discordância mais forte,
e `dividido` nunca vira atalho para "mantém o campeão" sem as razões escritas.

## Modo visual (o antigo "juiz de visão")

Entrega com UI/artefato visual: o insumo inclui **screenshot do resultado real** (nunca
mockup) e a rubrica soma design, craft, estados e a11y visual — a ótica da lente
`designer-ux-ui`, sem virar lente extra no comitê. Casa com o passo "Audit" do Modo Polish
Pass e entra como evidência no `testador-real`.

## Verificação do veredito (antes de devolver ao maestro)

Confira cada item — veredito que falha qualquer um volta para refazer, não segue:

- [ ] Os artefatos chegaram **anonimizados** e cada juiz teve **contexto fresco** (sem autoria, sem raciocínio de outro juiz/maestro).
- [ ] Nenhum juiz julgou um artefato que **ele mesmo** gerou.
- [ ] Controle de viés de ordem aplicado (duas ordens no juiz único; ordem sorteada por juiz no painel).
- [ ] Cada veredito **cita a evidência** conferida (artefato + relatório do testador) — impressão sem evidência não conta.
- [ ] Veredito **dentro do contrato** (`vencedor` · `nota` · `razoes[]` · `enxertos[]` · `metricas`); fora do contrato refez uma vez, e a 2ª falha virou juiz FALHO declarado + painel reconstituído.
- [ ] Empate/divergência/derrota → **campeão mantido** (nunca promoção sem vitória clara).
- [ ] Painel **ímpar**, exceto a rodada 2 (2× Opus com unanimidade); degradação por tier **declarada no placar** quando houve (RI-04).

## Guardrails (o que o painel NUNCA faz)

- **Nunca julga com autoria visível** ou contexto contaminado pelo maestro/executor.
- **Nunca avalia artefato isolado** — sem disputa, devolve ao Comitê de Lentes.
- **Nunca promove sem vitória clara** — empate/divergência mantém o campeão.
- **Nunca simula veredito** de juiz que não rodou (RI-04); painel reduzido por
  indisponibilidade de modelo é declarado.
- **Painel par só na rodada 2** (2× Opus, com regra de unanimidade); fora isso, ímpar.

## 🔗 Rede da skill

- **Regida por:** `orquestrador-fable` — modo painel na consolidação (passos 2–3), portão
  pareado na avaliação/decisão (passos 4 e 6), modo visual no passo 4.
- **Não confundir com:** Comitê de Lentes (nota absoluta) e `testador-real` (evidência
  executada) — o relatório do testador é **insumo** do juiz, não concorrente.
- **Rubrica visual:** `designer-ux-ui`.
- **Persistência:** campeão vigente + placar por rodada gravados via `estado-projeto` pelo
  maestro (escritor único) — esta skill não escreve estado.

---
### 📜 Histórico
- **2026-08-27 — As 4 Dimensões de Validade de Avaliações em Julgamentos (garimpo inspect_evals 2026-08-27 · UK1; degrau §6.10: 1 — só edição).** Incorpora ao Protocolo do Julgamento as 4 dimensões de validade de testes (Claims Coherence, viabilidade/verificabilidade de falha, alinhamento com o ground truth sobre proxies fracos e edge cases). Fonte canônica no [[PADRAO-DE-AUTORIA]] §11.10. Proveniência: `.claude/skills/eval-validity-review/SKILL.md` de `github.com/UKGovernmentBEIS/inspect_evals` (MIT) — laudo em `garimpo-lote-9-fontes-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-26 — Classificação de 4 níveis e protocolo de dúvida adversarial (garimpo lote-5repos 2026-08-26 · G1; degrau §6.10: 1 — só edição).** Incorpora a precedência de classificação de achados em 4 níveis (Contrato mal lido, Válido+acionável, Válido trade-off, Ruído) e o princípio de supressão da CLAIM/hipótese do autor no isolamento do artefato para julgamento cego. Proveniência: `skills/doubt-driven-development/SKILL.md` de `github.com/addyosmani/agent-skills` (MIT) — laudo em `garimpo-lote-5repos-2026-08-26.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-18 — Rótulo de concordância no agregado (garimpo oh-my-opencode 2026-08-18 · G5; degrau §6.10: 1 — só edição).**

  A regra de agregação já era unânime/maioria/divergência e a publicação da discordância mais
  forte já era obrigatória, mas o **contrato de retorno** devolvia `vencedor · nota · razoes[]`
  sem campo para o nível de acordo — quem lia o placar precisava derivá-lo somando notas, e é
  justamente perto do corte que a derivação erra (mesma lente, duas instâncias, até 3 pontos de
  diferença). O agregado passou a declarar `concordancia: unanime | maioria | dividido`. O campo
  é do **agregado, nunca de cada juiz**: juiz com contexto limpo não vê os outros e não teria
  como preenchê-lo. Guardrail: o rótulo **soma, não troca** — não dispensa a discordância
  publicada, e `dividido` não vira atalho para "mantém o campeão" sem as razões escritas.
  Proveniência: `docs/council.md` de `github.com/alvinunreal/oh-my-opencode-slim` (MIT) — laudo
  em `garimpo-oh-my-opencode-2026-08-18.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única +
  referência com gloss (PADRAO §12.5); itens E2, E3, E4, E6 (fraseio "orquestrador regente"
  do E1); −1 linha física (economia real de texto ~4 linhas).
*Histórico — 2026-08-06: seção **Anti-ancoragem** no protocolo (garimpo `affaan-m/ECC` E1/E5,
do `council`; MIT) — quem sintetiza registra a própria posição **antes** de ler as vozes;
despacho com só a pergunta, nunca a transcrição; guardrails de síntese checáveis (dizer quando
uma voz mudou a recomendação, publicar a discordância mais forte, tratar duas vozes contra a
posição inicial como sinal, mostrar as posições cruas antes do veredito); e a regra de que o
produto é tornar a discordância legível, não a unanimidade. É o par cognitivo do isolamento
físico por worktree: aquele impede um juiz de achar o rascunho do outro, este impede a conversa
de plantar a resposta em quem agrega. Relatório em `garimpo-ecc-2026-08-06.md`.*
*Histórico — 2026-07-10: nota de oscilação de campeão no portão pareado (garimpo autoresearch
P6, ver `Novo Conceito/garimpo-autoresearch-2026-07-10.md`) — detecção, contagem e decisão são
do maestro (juiz não vê histórico); limiar na anti-estagnação do orquestrador regente.*
*Histórico — 2026-07-12: veredito fail-closed (garimpo hermes-agent P9) — segunda falha de
contrato = juiz falho declarado, painel reconstituído pela degradação por tier existente.*
*Histórico — 2026-07-09: criada a partir do juiz de visão do `orquestrador-fable` (harness
GAN/`auto-improve`), generalizando o portão pareado para qualquer artefato e adicionando o
modo painel de N tentativas + escala por rodada com degradação por tier (decisões do Jeremias
09/07).*
