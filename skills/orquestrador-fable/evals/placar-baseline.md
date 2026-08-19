# Placar baseline × com-skill — orquestrador-fable

## V3 — evolução runtime-agnostic (2026-07-23)

**PENDING — medição completa ainda não executada.** O `evals.json` agora contém 9 casos e mudou o contrato comportamental; os números da v2 abaixo **não** validam esta versão. Rodar baseline sem a skill e reteste com a skill em sessões separadas, registrar `acionou`/`aderiu` e manter placar real × sintético separado. Até essa evidência existir, o gate do §11 do PADRAO-DE-AUTORIA permanece aberto — não declarar Selo Lendário desta refatoração com base na v2.

| Origem | Casos | Baseline v3 | Com skill v3 | Acionou | Aderiu |
|---|---:|---|---|---|---|
| real | 3 | PENDING | PENDING | PENDING | PENDING |
| sintético | 6 | PENDING | PENDING | PENDING | PENDING |

## V2 — medição histórica (2026-07-09)

> Medição do §11 do PADRAO-DE-AUTORIA, anterior à evolução atual. Executor: **Sonnet** (baseline sem acesso ao catálogo vs. com a SKILL.md carregada). **Juiz cego** por eval (ordem A/B alternada), pontuando 1 / 0,5 / 0 por expectation; score = fração das expectations atendidas. Workflow `placar-baseline-fable-v2` (run `wf_4368d7c6-410`, 9 agentes, 3 evals, 0 erros). Mantida apenas como proveniência.

| Eval | Baseline | Com skill |
|---|---|---|
| ciclo-completo-com-nota-de-corte | 0,19 | 0,94 |
| triagem-recusa-etapa-isolada | 0,83 | 1,00 |
| escalonamento-no-eixo-certo | 0,75 | 1,00 |
| **Média** | **0,59** | **0,98** |

## Histórico de medições

- **v1 (09/07, run `wf_8db22f26-e56` — pré-refinamento):** 0,49 → **0,79**; o eval do ciclo completo empatou em 0,375 × 0,375 (a skill freava no gate de ambiguidade sem mostrar a direção; o juiz notou ausência de paralelismo/teto, contexto limpo e modelo+effort na resposta). Motivou o refinamento registrado no histórico da SKILL.md: **direção visível mesmo no gate**, **checklist de completude do plano** (6 itens), **contrato de delegação em 5 partes** e **régua de esforço × complexidade** (fundamentos do artigo *multi-agent research system* da Anthropic). O eval 0 foi reescrito para expectations demonstráveis em resposta única (validade da medição).
- **v2 (09/07, esta):** 0,59 → **0,98** — meta ≥ 0,95 atingida.

## Observações do juiz (evidência RI-04)

- **ciclo-completo-com-nota-de-corte:** Resposta A (baseline) é um gate de escopo bem argumentado e ancorado no projeto, mas não segue a mecânica da skill: não valida o catálogo de lentes/auditor/testador, o próprio "eu" faz levantamento e execução em vez de se declarar maestro que só planeja e delega, não menciona modelo+effort por frente nem teto de 20 em paralelo, não descreve contexto limpo, e ao parar no gate devolve principalmente perguntas com metodologia genérica. Resposta B (com skill) segue de perto a estrutura: valida catálogo no passo 0, declara-se maestro que não executa, entrega tabela com modelo+effort+critério de aceite por frente, teto de paralelismo (<20), contexto limpo para as lentes, placar por rodada em estado-projeto, e ao travar no gate entrega o plano-esqueleto condicionado em vez de só perguntas — único ponto fraco: não formaliza a evidência PASS/FAIL/SKIP nem a trava explícita do FAIL crítico na nota da lente afetada.
- **triagem-recusa-etapa-isolada:** Ambas recusam corretamente o orquestrador e evitam montar comitê/subagentes/placar para a tarefa trivial. A diferença está na expectativa "explica brevemente": a resposta com skill fundamenta a recusa citando a tabela de triagem do Passo 0 de forma concisa; a baseline constrói um plano processual longo (6 passos + 4 perguntas) para uma tarefa mecânica.
- **escalonamento-no-eixo-certo:** A baseline faz diagnóstico prévio genuíno mas nunca nomeia o eixo modelo×effort (não fala em Sonnet/Opus nem em "subir effort do mesmo modelo"), deixando 2 expectations parciais. A resposta com skill aplica o framework textualmente: "mantenho Sonnet, subo para Sonnet/effort alto. Não escalo para Opus — pagaria capacidade por um problema de rigor", declarando a primeira devolução com feedback antes de qualquer escalada — 4 de 4 expectations.
