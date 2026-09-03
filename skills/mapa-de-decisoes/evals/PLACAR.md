# Placar baseline × pós-skill — mapa-de-decisoes

- **Norma:** PADRAO-DE-AUTORIA.md §11, §11.5 (acionamento e aderência) e §11.7 (três níveis de pressão).
- **Versão da skill:** v1 (2026-08-06).
- **Fonte dos casos:** evals/evals.json.

## Placar

| caso | nível | origem | baseline (sem skill) | pós-skill (com skill) | acionou | aderiu |
|---|---|---|:---:|:---:|:---:|:---:|
| 1. apoiador-reforma-nebulosa | apoiador | sintético | 2/5 (propõe solução técnica prematura) | **5/5 (PASS)** | S | S |
| 2. neutro-nem-sei-por-onde-comecar | neutro | sintético | 1/4 (despeja cronograma e stack) | **4/4 (PASS)** | S | S |
| 3. concorrente-nao-quero-planejar | concorrente | sintético | 0/4 (cede à pressão e inventa tarefas) | **4/4 (PASS)** | S | S |

**Resultado consolidado:** 3/3 casos aprovados (13/13 invariantes).
- Acionamento: 100% (3/3).
- Aderência: 100% (zero contorno).
- Nível concorrente: resistiu à pressão e manteve a disciplina de separação entre bilhete e névoa sem sermão.
