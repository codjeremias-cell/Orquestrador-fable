# Placar baseline × com-skill — estado-projeto

## V3 — endurecimento de caminho e retomada (2026-07-23)

**PENDING — medição nunca executada.** O `evals.json` tem **3 casos** e a skill recebeu o
confinamento de caminho por **resolução canônica** (com inspeção de junction/reparse, no
lugar da checagem lexical anterior) e o `predicado_sucesso` pinado com retomada fail-closed.
Nenhuma medição baseline × com-skill foi rodada. Até essa evidência existir, o gate do §11 do
`PADRAO-DE-AUTORIA` permanece **aberto** — não declarar Selo Lendário.

| Origem | Casos | Baseline v3 | Com skill v3 | Acionou | Aderiu |
|---|---:|---|---|---|---|
| real | 0 | — | — | — | — |
| sintético | 3 | PENDING | PENDING | PENDING | PENDING |

## Limitações declaradas (2026-07-24, auditoria independente)

1. **Não existe runner de evals no cofre.** Os 3 casos são cobertura documental.
2. **É a menor cobertura das 4 skills do lote** (3 casos), apesar de a skill guardar o
   artefato de que todas as outras dependem para retomar. Uma falha aqui se propaga para o
   ciclo inteiro.
3. **O caso adversarial H09 não tem eval correspondente** — divergência entre `TAREFAS.md`
   (view derivada) e `estado.json` (fonte única) é o modo de falha mais provável desta skill
   no uso diário, e não está coberto. Promover H09 a eval.
4. **Zero casos de origem real.** Todos sintéticos.

## Verificação parcial já feita

Em 2026-07-24 o `estado.json` desta homologação foi editado (rebaixamento da rodada 3) e a
coerência com a view `TAREFAS.md` foi conferida manualmente: **não houve divergência**, porque
a edição tocou apenas o `placar`, que não é projetado na view. Isso é inspeção mecânica de um
caso isolado — não substitui o eval de H09 nem o placar acima.

Estado dos 12 casos adversariais:
`_homologacao/fable-method-2026-07-23/RESULTADOS-CASOS-ADVERSARIAIS.md`.
