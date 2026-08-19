# Regras operacionais para automação (bot) — contrato duro

> Carregado sob demanda pela lente `trader-de-elite` sempre que o consumidor é um robô (ou o usuário está parametrizando um). É a versão completa da seção "Regras operacionais para automação" — aplique como **contrato determinístico**: número único, fórmula e teto que o bot **enforça**, nunca faixa para interpretar, nunca julgamento. Cada regra cita a seção do `referencia/GUIA-TRADER-DE-ELITE.md` de onde vem; o §11 do guia traz o porquê de cada guardrail de execução.

## Sumário
- [Parâmetros obrigatórios](#parâmetros-obrigatórios) — sem TODOS válidos, o bot não opera (fail-closed)
- [Dimensionamento e proteção (por operação)](#dimensionamento-e-proteção-por-operação)
- [Leis de Ferro — segurança de execução](#leis-de-ferro--segurança-de-execução) (8 leis)
- [Proibições absolutas](#proibições-absolutas)
- [Fail-safe](#fail-safe--na-dúvida-ou-com-dado-faltando-não-opera-fail-closed)
- [Observabilidade](#observabilidade)
- [Demo × real — gate derivado do ledger](#demo--real--gate-derivado-do-ledger-nunca-por-ansiedade-nem-por-checkbox)
- [Bordas declaradas com dono (v1)](#bordas-declaradas-com-dono-v1)

Quando o consumidor desta lente é um robô (ou o usuário está parametrizando um), estas regras são **contrato determinístico**: número único, fórmula e teto que o bot **enforça** — nunca faixa para interpretar, nunca julgamento. O bot não "sente" tilt — ou a regra está escrita, ou não existe. Cada regra cita a seção do `referencia/` de onde vem; o §11 do guia traz o porquê de cada guardrail de execução.

**Fronteira de entrada:** esta lente recebe o stop já **em pontos**. Derivar stop técnico (suporte/resistência, volatilidade) é responsabilidade da estratégia/código (`dev-senior`) — chega aqui como número.

## Parâmetros obrigatórios

**Sem TODOS presentes e válidos, o bot não opera.** Valor fora da banda → **rejeita na configuração** (nunca "aceita e avisa"):

| Parâmetro | Validação que o bot aplica |
|---|---|
| Capital da conta (R$) | > 0 |
| % de risco por trade | **≤ 1% sempre; > 1% e ≤ 2% somente com `track_record_ok = true`; > 2% rejeita SEMPRE** (partição sem sobreposição, §3.1) |
| `track_record_ok` (booleano) | **derivado, não declarado:** é o resultado selado do gate demo→real que o bot computa do próprio ledger (§4.5); o operador **dispara** a checagem, nunca **afirma** `true`. Sem ledger que satisfaça o gate → permanece `false` (teto volta a 1%) |
| Ativo (WIN/WDO/ação) | specs e margem confirmadas na sessão (§5.1) |
| Stop da operação (pontos) | > 0, **e ≥ piso de stop = `max(k_tick × tick, f_range × range_recente)`** — `k_tick`, `f_range` e a janela do `range_recente` (nº de candles, na série do **timeframe de operação do bot**) são parâmetros obrigatórios; stop pequeno demais infla a posição → abaixo do piso rejeita (§11.5) |
| `slippage_buffer` (pontos, por ativo) | > 0 — o sizing usa **stop + buffer** (fim do "dimensione com folga"; §11.5) |
| Payoff mínimo | **≥ 1:1** (guardrail conservador — payoff baixo é mais sensível a slippage/erro de acerto; o exemplo integrado usa 2:1, §3.2) |
| Stop diário (R$) | ≤ 3× o risco por trade em R$ (teto que o bot rejeita acima; referência 2–3×, §3.3) |
| Nº máx. de operações/dia | ≤ **5** (teto rígido; referência 3–5, §3.3). **Uma "operação" = uma abertura de posição**, conte independentemente do resultado |
| Exposição agregada máxima (%) | ≤ **10%** do capital (6% recomendado, §3.1). **Exposição = soma do RISCO original** de cada posição aberta = Σ(\|entrada − stop\| em pontos × tamanho × valor do ponto), **não** o notional — medida contra a **posição REAL** da conta (§11.3) |
| Janela de horário · **horário de force-flat** (min antes do leilão de fechamento) | dentro do pregão do ativo; force-flat > 0 (§5.1, §11.4) |
| Drawdown máx. da conta (% do pico) · dias perdedores seguidos máx. | > 0 — medidos contra o **equity REAL** da corretora, não o PnL interno; alimentam o circuit breaker (§3.4, §11.6) |
| Dias de lucro seguidos para escalar · **incremento por nível** | escalar ≥ 1 (**alerta se < 10**, referência do guia, §3.4); incremento em contratos por nível, teto = tamanho da fórmula sob o %risco |
| Teto de ordens/minuto · teto de volume financeiro/sessão | > 0 — alimentam o throttle (§11.1) |
| Prazo de confirmação do stop (s) · limiar de frescor do feed (s) · timeout de reconciliação (s) · **cadência de reconciliação periódica (s)** | > 0 — **disparam** as travas fail-safe; ausentes → o bot não sobe (senão a trava não tem gatilho, §11.3) |
| **Piso de expectância líquida p/ demotion (R/trade)** · **janela N de trades p/ demotion** | > 0 — sem eles a proteção de decaimento de edge fica desligada; fail-closed em Modo=real (§11.8) |
| Modo (demo/real) | demo→real só pelo gate abaixo |

> Sem **todos** os parâmetros acima presentes e válidos, o bot **não opera** (fail-closed) — inclui limiares de tempo e os do demotion, senão as travas correspondentes sobem sem valor de disparo (default silencioso é proibido).
>
> **Definições operacionais** (para os contadores baterem igual em todo lugar): **dia perdedor** = PnL líquido realizado do dia < 0; **dia de lucro** = > 0; **break-even** (= 0) e **dia sem trade** não incrementam nem zeram nenhum contador (nem do circuit breaker, nem da progressão).

## Dimensionamento e proteção (por operação)
- Tamanho = **⌊(Capital × %risco) ÷ ((stop + slippage_buffer) × valor do ponto)⌋** (§3.1, §11.5) — o buffer entra no denominador para o risco real (pós-slippage) caber no teto; arredonda **sempre para baixo** (para cima estoura o teto); resultado **0 → não opera** (subcapitalizada para esse stop).
- **Viabilidade antes de abrir (fail-closed):** nº de contratos × margem/contrato ≤ **margem livre × 0,8**; acima → reduz ou não opera (previne chamada de margem em vez de só reagir a ela, §11.4). Se o tamanho couber no risco mas **estourar o teto de exposição agregada → REJEITA a entrada** (não reduz para caber).
- Alvo derivado sem decisão humana: **alvo = entrada ± (payoff mínimo × stop em pontos)** na direção da operação; entrada + stop + alvo vão juntos numa **OCO real na corretora** (§4.6) — nunca stop "lógico" só no software.
- **Posição só existe quando protegida:** entrada preenchida sem stop **ACK/confirmado trabalhando** na corretora dentro do *prazo de confirmação do stop* = incidente → **zera imediatamente a posição nua** (§11.2). Verifique o ESTADO da OCO, não o envio.
- **Stop diário** — semântica única (§3.3, §11.5): mede a **perda efetiva do dia** = realizado (pós-slippage) **+** prejuízo aberto marcado a mercado pelo **último negócio** do ativo, **nunca** o risco nominal planejado. Assim uma posição aberta sangrando dispara *antes* de fechar. Cruzou → **force-exit** (sequência abaixo) das posições abertas e **bloqueia novas entradas até o próximo pregão**.
- **Force-flat de fechamento:** **force-exit** de todas as posições o *horário de force-flat* antes do leilão de fechamento; depois desse horário não abre — day trade **não** segura posição para o leilão nem overnight (§11.4).
- **Force-exit — sequência única para todo encerramento forçado** (stop diário, force-flat, circuit breaker, throttle, posição nua): **(1) cancela todas as ordens abertas → (2) reconcilia a posição real na corretora → (3) zera o líquido a mercado** — nunca flatten cego (§11.3). Se o ativo estiver em leilão/halt, **não** envia ordem: mantém modo de segurança + alerta do kill switch até reabrir.

## Leis de Ferro — segurança de execução
Nascem no grau máximo (PADRÃO §12, exceção de segurança) porque o risco é irreversível — posição nua, runaway de ordens, conta drenada (§11 do guia):
1. **Throttle independente da estratégia:** estourou o teto de ordens/minuto OU o volume financeiro da sessão → **HALT + force-exit** (sequência acima) **+ alerta**. O contador da estratégia não protege de bug de laço (caso Knight Capital, §11.1).
2. **Kill switch manual** fora da lógica do bot, sempre disponível: zera tudo e desliga.
3. **Config selada por sessão, assimétrica — regra de catch-all:** **toda** alteração de configuração que **não seja inequivocamente um APERTO** de risco/trava é tratada como **afrouxamento** e só vale no pregão seguinte; apertar vale na hora. Isso cobre, sem depender de lista, também reduzir `slippage_buffer` (infla a posição), alargar o limiar de frescor do feed, aumentar o prazo de confirmação do stop ou o timeout de reconciliação, e encurtar/adiar o force-flat — todos afrouxamentos. O bot recusa afrouxamento intra-sessão, **inclusive via edição de arquivo + reinício**. A fronteira "pregão seguinte" vem do **calendário/estado de sessão da B3/corretora**, nunca do relógio local (§11.6).
4. **Circuit breaker de conta:** drawdown ≥ limite (% do pico) OU dias perdedores seguidos ≥ limite → **HALT**. Drawdown/pico medidos contra o **equity real** da corretora, não o PnL interno (§3.4, §11.6).
5. **HALT persistente:** todo estado de HALT — throttle (Lei 1), circuit breaker de conta (Lei 4) e bloqueio pós-stop-diário — é **persistido junto do id da sessão de pregão e sobrevive a restart/edição de arquivo**; reiniciar com o bot em HALT reentra em modo não-operante. **Persiste também o nível de progressão e um flag `reset-pendente`** (§ Demo × real): um restart não pode re-escalar sozinho nem apagar um reset devido. Re-armar só manual, fora do pregão, com revisão.
6. **Ledger de demo íntegro:** o gate demo→real deriva do ledger que o bot escreveu; esse ledger é **append-only e à prova de adulteração** (encadeamento/assinatura — implementação `dev-senior`). Ledger adulterado, ilegível ou ausente → `track_record_ok` permanece `false` (não se opera real sobre histórico não confiável, §4.5/§11.8).
7. **Credencial trade-only:** a chave da corretora não tem poder de saque/transferência, fica fora do versionamento, com restrição de IP quando disponível (§11.7) — pré-condição de deploy.
8. **Deploy seguro:** toda versão nova do bot sobe **fora do pregão**, passa por **dry-run/reconciliação smoke** (envio simulado + conferência de estado) antes de armar, e roda a **1ª sessão real em tamanho reduzido (canário)** — promove só após a sessão limpa. É a lição Knight Capital no momento de maior risco: o deploy (§11.1). Implementação: `dev-senior`.

## Proibições absolutas
O bot NUNCA faz, mesmo se o operador pedir em runtime:
- Martingale / aumentar posição perdedora (§3.6).
- Mover ou cancelar stop contra a posição; afastar o alvo no meio do trade (§3.6).
- Nova entrada após o stop diário, fora da janela, acima do nº máximo de operações ou com a exposição agregada estourada.
- Aumentar o risco após perda ("recuperar", §3.6) ou após ganho (efeito "dinheiro da casa", §3.3).
- Operar em leilão (pré-abertura, fechamento, leilão de volatilidade) ou com o pregão interrompido — circuit breaker/halt (§11.4).
- Operar série em vencimento/rollover: só o **contrato-mês líquido (front)**; **nunca** carregar posição para o ajuste (§5.1, §11.4).
- Reenviar ordem às cegas — retry sem reconciliar com a corretora (§11.3).

## Fail-safe — na dúvida ou com dado faltando, NÃO opera (fail closed)
Regra transversal: **canal de PREÇO ≠ canal de ORDEM/POSIÇÃO** — feed de cotação morto não impede consultar posição nem enviar ordem pela API da corretora (§11.3).
- Parâmetro ausente/inválido → bloqueia e reporta o motivo; **nunca default silencioso**.
- **Árvore do modo de segurança — uma ação por estado (§11.3):** stop confirmado ativo → mantém a posição e só bloqueia novas · estado do stop/posição **desconhecido** → consulta a posição real na corretora e **zera a mercado + alerta** · nunca flatten cego sem reconciliar (fechar sem posição ABRE posição).
- **Frescor do feed:** sem tick/heartbeat dentro do limiar, **conexão viva ≠ dado válido** (§11.3). **Sem posição aberta** → não abre novas (fail-closed). **Com posição aberta** → **ramo protetivo**: reconcilia posição e pernas da OCO pela API de ordem (independe do feed de preço); qualquer perna não-working → zera. Posição aberta sob feed morto **nunca** fica em hold passivo.
- **Fill parcial** → reconcilia a OCO ao tamanho efetivamente preenchido antes de qualquer nova ação (§11.3).
- **Chamada de margem intradiária** → modo de segurança + alerta ao operador (§5.1, §11.4).
- **Idempotência:** toda ordem com client-order-id; envio ambíguo (timeout) → reconciliar antes de reenviar. **Instância única** do bot por conta (§11.3).
- **Reconciliação periódica:** além de por evento, o bot reconcilia posição/ordens internas contra a corretora em **cadência fixa** (parâmetro); divergência interno × corretora = incidente → modo de segurança (pega o fill perdido que não gerou timeout).
- **Ramo terminal — bot cego:** timeout de reconciliação estourado (canal de ordem inalcançável) **com posição aberta** → **persiste HALT + escalona ao humano** (kill switch / acesso direto do operador à corretora); **nunca** reenvia às cegas nem presume a posição zerada.
- Queda de conexão com posição aberta → reconexão é **incidente a auditar** (a OCO pode ter ficado sem perna ativa, §4.6/§11.2), não retomada normal.
- **Dados que mudam** (margem, horários, vencimentos) reconferidos na B3/corretora **a cada sessão** (§5.1); os números do guia são referência datada, não verdade permanente.

## Observabilidade
O bot mede o que faz (§11.8): toda ordem/fill/reconciliação/HALT gravada com client-order-id, **preço esperado × executado** (slippage real) e **R teórico × realizado**. O bot computa por janela a **expectância líquida realizada** (descontando emolumentos + slippage + IR de 20%), payoff, fator de lucro, drawdown e sequência de perdas — mesma régua do §3.5, agora como saída de máquina. Sem esse log, o gate demo→real é fé, não medição.

## Demo × real — gate DERIVADO do ledger, nunca por ansiedade nem por checkbox
(§4.5, §3.4):
- O bot **computa** a promoção a real do seu próprio ledger de demo — o operador dispara a checagem, não afirma o resultado. Exige TODAS: ≥ **100 trades** em demo (§4.5) · **expectância líquida** (custos + slippage + IR) **> 0** — nunca a bruta (§9 do guia: "líquido ≠ bruto") · drawdown ≤ limite · sequência de perdas ≤ limite. `track_record_ok` é o **resultado selado** desse gate — e **escopado ao hash da estratégia + parâmetros de risco vigentes**: trocou a estratégia ou o risco, o histórico anterior não vale mais e o gate reconta do zero (senão um restart pós-troca re-derivaria `true` do ledger antigo).
- Real começa com **capital reduzido (1 contrato, risco mínimo)**; escala um nível só após o nº configurado de dias de lucro seguidos (referência: 10, §3.4); após perdas, **encolhe** — nunca o contrário.
- **Demotion simétrico:** expectância líquida realizada abaixo do piso configurado por N trades → **volta a demo/tamanho mínimo** antes de reoperar real. O circuit breaker pega o colapso; o demotion pega o **decaimento lento de edge** (§11.8).
- Mudança de estratégia ou de parâmetro de risco **zera a progressão** (grava `reset-pendente`, Lei 5): volta a demo/tamanho mínimo antes de escalar de novo. *(Os parâmetros de demotion e do gate são obrigatórios para **armar Modo=real** — inertes em demo; o contador de dias de lucro faz carry-over: dia neutro/sem trade preserva, não reinicia.)*

## Bordas declaradas com dono (v1)
- **Evento macro agendado** (Copom, FOMC, payroll): parâmetro de *blackout* recomendado — não abrir e/ou force-flat X min antes (§7). Se o operador não configurar, o bot **não** trata o evento sozinho — é responsabilidade dele/da estratégia (`dev-senior`) evitar a janela.
- **Correlação:** os tetos assumem **ativo único**. Operar >1 ativo correlacionado (ex.: WIN + ações compradas = mesma aposta, §3.1) exige contar posições correlacionadas como **uma só** no teto de exposição — não coberto na v1; declare antes de ativar multi-ativo.
