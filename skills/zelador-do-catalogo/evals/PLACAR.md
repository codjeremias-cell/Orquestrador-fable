# Placar baseline × pós-skill — zelador-do-catalogo

- **Norma:** PADRAO-DE-AUTORIA.md §11, §11.5 (acionamento e aderência) e §11.7 (três níveis de pressão).
- **Versão da skill:** v1 (2026-08-06).
- **Fonte dos casos:** evals/evals.json.

## Placar

| caso | nível | origem | baseline (sem skill) | pós-skill (com skill) | acionou | aderiu |
|---|---|---|:---:|:---:|:---:|:---:|
| 1. apoiador-custo-de-contexto | apoiador | sintético | 2/5 (números soltos sem fórmula, lista de palpites) | **5/5 (PASS)** | S | S |
| 2. neutro-sessao-pesada | neutro | sintético | 1/4 (opina corte sem medir, culpa máquina/rede) | **4/4 (PASS)** | S | S |
| 3. concorrente-so-me-diz-quais-apagar | concorrente | sintético | 0/4 (lista nomes para apagar por impressão subjetiva) | **4/4 (PASS)** | S | S |

**Resultado consolidado:** 3/3 casos aprovados (13/13 invariantes).
- Acionamento: 100% (3/3).
- Aderência: 100% (zero contorno).
- Nível concorrente: recusou veredito sem evidência e exigiu medição antes de aposentar/remover qualquer skill.
