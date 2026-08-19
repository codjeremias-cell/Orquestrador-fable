# Placar baseline × com-skill — testador-real

## V3 — evolução do gate de integridade (2026-07-23)

**PENDING — medição nunca executada.** O `evals.json` tem **7 casos** e a skill recebeu o
`referencia-gate-integridade.md` (matriz alegação→prova, caça adversarial, TWINS, regra de
fechamento). Nenhuma medição baseline × com-skill foi rodada. Até essa evidência existir, o
gate do §11 do `PADRAO-DE-AUTORIA` permanece **aberto** — não declarar Selo Lendário.

| Origem | Casos | Baseline v3 | Com skill v3 | Acionou | Aderiu |
|---|---:|---|---|---|---|
| real | 0 | — | — | — | — |
| sintético | 4 | PENDING | PENDING | PENDING | PENDING |
| sem `origem` declarada | 3 | PENDING | PENDING | PENDING | PENDING |

## Limitações declaradas (2026-07-24, auditoria independente)

1. **Não existe runner de evals no cofre.** Os 7 casos são cobertura documental; nenhum foi
   executado. A validação estrutural confirma que existem e têm id único — nada além disso.
2. **Os evals de id 0, 1 e 2 não declaram `origem`.** O `validar-homologacao.ps1` filtra os
   checks de eval por `Where-Object { $_.origem }`, então esses três **não são cobrados de
   metadado algum** — incentivo invertido: omitir o campo isenta o caso. Preencher
   retroativamente.
3. **Zero casos de origem real.** Todos os declarados são sintéticos. O §11.6 do PADRÃO pede
   separar placar real × sintético justamente porque caso sintético tende a medir a skill
   contra frases derivadas dela mesma.

## Evidência comportamental existente

Apesar do placar pendente, há **uma** prova de comportamento real desta skill, produzida em
2026-07-24: o gate de integridade foi aplicado à fixture `integrity-trap` e **reprovou** a
entrega mentirosa, refutando 5 de 5 alegações (teste desativado, `--help` dessincronizado,
artefato prometido ausente, debris, pendência negada). Isso cobre os casos adversariais
**H04 e H05**. Ver
`_homologacao/fable-method-2026-07-23/RESULTADO-TRAP-EXECUTADO.md`.

Essa evidência **não substitui** o placar baseline × com-skill: prova que a referência
funciona quando aplicada, não que a skill muda o comportamento de quem não a tem.
