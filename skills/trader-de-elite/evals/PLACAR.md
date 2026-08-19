# Placar de eval — trader-de-elite (PADRÃO-DE-AUTORIA §11)

> Baseline × pós-skill executados de verdade por frotas independentes em Opus (executor sem skill × executor com skill × corretor cego), no ciclo ultracode de 2026-07-14 (rodada 2). Corretor calibrado pelo `referencia/GUIA-TRADER-DE-ELITE.md`. Atualizar a cada refatoração relevante.

## Evals de corpo (10 casos)

| caso | origem | baseline (sem skill) | pós-skill | acionou | aderiu | fail crítico |
|---|---|---|---|---|---|---|
| eval-01 (sizing WIN) | real | PASS | PASS | S | S | não |
| eval-02 (stop WDO) | real | PASS | PASS | S | S | não |
| eval-03 (DARF) | real | PASS | PASS | S | S | não |
| eval-04 (perdendo há 3 meses) | real | PASS | PASS | S | S | não |
| eval-05 (expectância) | real | **PARTIAL** | PASS | S | S | não |
| eval-06 (plano de trading) | real | **PARTIAL** | PASS | S | S | não |
| eval-07 (viver de trade c/ R$2k) | real | **PARTIAL** | PASS | S | S | não |
| eval-08 (tape reading) | real | PASS | PASS | S | S | não |
| eval-09 (regras de risco p/ robô) | sintetico (2026-07-14) | **PARTIAL** | PASS | S | S | não |
| eval-10 (liberar bot pós-stop diário) | sintetico (2026-07-14) | PASS | PASS | S | S | não |
| eval-11 (stop rejeitado → posição nua) | sintetico (2026-07-14, R4) | **PARTIAL** | PASS | S | S | não |
| eval-12 (feed congelado c/ posição) | sintetico (2026-07-14, R4) | **PARTIAL** | PASS | S | S | não |
| eval-13 (afrouxar risco intra-sessão) | sintetico (2026-07-14, R4) | **PARTIAL** | PASS | S | S | não |
| eval-14 (gate demo→real derivado) | sintetico (2026-07-14, R4) | **PARTIAL** | PASS | S | S | não |
| eval-15 (exposição estourada → rejeita) | sintetico (2026-07-14, R4) | **FAIL** | PASS | S | S | não |

**Leitura (rodada 4 — 15/15):** todos os 15 casos pós-skill = **PASS** com aderência total (`aderiu=S`) e **zero fail crítico**. Vermelho→verde robusto: 9 baselines PARTIAL/FAIL viraram PASS — os 5 cenários-bot adversariais (11-15) provam o contrato de automação de fato: **eval-15 (exposição estourada) falhava no baseline** (o modelo sem a skill mandava reduzir para caber) e passou com a skill (rejeita a entrada, como o contrato manda). A skill agregou em 15/15 (`skill_agregou=true`). Executado por frotas Opus independentes (executor sem skill × com skill × corretor cego) no ciclo ultracode 2026-07-14.

## Disparo às cegas (16 queries × descriptions dos 5 vizinhos, 3 juízes independentes, maioria)

- **16/16 corretos** — 8/8 positivos caem em `trader-de-elite` (inclusive o caso sintético de automação); 8/8 negativos roteiam para o vizinho certo (`conselheiro-financeiro`, `conteudo-riqueza`, `dev-senior`) ou "nenhuma" (cotação ao vivo). Zero falso-positivo, zero falso-negativo.
- Casos sintéticos de disparo (2026-07-14): "vou automatizar minha operacao de mini indice..." → trader-de-elite ✅ · "escreve o codigo python do meu robo..." → dev-senior ✅.

## Verificação factual adversarial (21 céticos × 7 grupos, fonte primária)

- Rodada 2 (2026-07-14): specs WIN/WDO, margem (WIN R$155/WDO R$140, vigente conferida na B3 em 14/07/2026), horários, volume, tributação completa e matemática — **confirmados com fonte**. 3 refutações de **citação** (coorte FGV "índice e dólar" → só índice; direção de Druckenmiller invertida; 85–95% de Tudor Jones sem fonte) — **corrigidas no guia em 2026-07-14** e re-verificadas na rodada 3.
