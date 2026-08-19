# Placar — baseline × pós-skill (`testador-jogos`)

> Padrão do §11 do PADRAO (v2.4): baseline = rodar o prompt SEM a skill instalada; pós-skill = com. Casos sintéticos criados DEPOIS de a skill existir rodam o baseline uma vez (salvaguarda §11.6). Colunas `acionou`/`aderiu` conforme §11.5.

| caso | origem | baseline | pós-skill | acionou | aderiu |
|---|---|---|---|---|---|
| eval-1 cacar-bugs-jogo-web | sintetico (2026-07-13) | 🔲 pendente | 🔲 pendente | — | — |
| eval-2 analise-critica-gdd | sintetico (2026-07-13) | 🔲 pendente | 🔲 pendente | — | — |

**Status:** 🔲 **baseline NÃO rodado** — pendência declarada (RI-04). As fixtures e gabaritos foram verificados por execução em 2026-07-13 (8/8 bugs do eval 1 reproduzem via `scripts/web_game_harness.py`), mas o ciclo vermelho→verde do §11 ainda não foi exercitado. Rodar antes de dar o Selo definitivo à skill.

*Histórico — 2026-07-13: placar criado na revisão pós-avaliação (nota 8,3); fixtures internalizadas em `evals/fixtures/` com gabarito em `evals/gabarito/`.*
