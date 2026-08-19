# Placar baseline × com-skill — auditor-responsabilidades

## V3 — evolução do gate de autorização (2026-07-23)

**PENDING — medição nunca executada.** O `evals.json` tem **5 casos** e a skill passou a ser
dona do gate `AUTH`/`autorizado × tocado`, das surpresas fora de escopo e da consolidação do
placar. Nenhuma medição baseline × com-skill foi rodada. Até essa evidência existir, o gate
do §11 do `PADRAO-DE-AUTORIA` permanece **aberto** — não declarar Selo Lendário.

| Origem | Casos | Baseline v3 | Com skill v3 | Acionou | Aderiu |
|---|---:|---|---|---|---|
| real | 0 | — | — | — | — |
| sintético | 5 | PENDING | PENDING | PENDING | PENDING |

## Limitações declaradas (2026-07-24, auditoria independente)

1. **Não existe runner de evals no cofre.** Os 5 casos são cobertura documental.
2. **Circularidade — a limitação mais séria desta skill.** Os 5 evals são sintéticos e todos
   carregam `"sessao": "fable-method-homologacao-auditor"`: foram gerados **na mesma sessão
   que escreveu o corpo da skill**. Medem a skill contra frases derivadas dela mesma, que é
   exatamente o que a salvaguarda do §11.6 do PADRÃO existe para impedir. Um caso escrito por
   quem acabou de escrever a regra tende a usar o vocabulário da regra — e então "aderiu"
   mede eco, não comportamento.
3. **Zero casos de origem real.** Sem caso vindo de uso real, não há sinal independente.

## Próximo passo para fechar o gate

Rodar baseline (sem a skill) e reteste (com a skill) em **sessões separadas**, com juiz cego,
e obter pelo menos 2 casos de **origem real** — preferencialmente derivados dos casos
adversariais **H06 e H07** (`_homologacao/fable-method-2026-07-23/CASOS-ADVERSARIAIS.md`),
cujo material já existe na fixture `integrity-trap` (artefato prometido ausente e debris fora
do escopo já verificados) mas cujo **julgamento do auditor** nunca foi exercitado. Estado
atual dos 12 casos: `_homologacao/fable-method-2026-07-23/RESULTADOS-CASOS-ADVERSARIAIS.md`.
