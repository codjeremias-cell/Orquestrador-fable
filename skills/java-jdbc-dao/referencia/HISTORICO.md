# Histórico — java-jdbc-dao

Registro de rodadas de evolução da skill (movido do corpo do SKILL.md para progressive disclosure; conteúdo verbatim).

- **2026-07-18 — Evolução ao 9,5 (núcleo SIGO):** corpo reestruturado em **invariantes inegociáveis** (parametrizado, try-with-resources, colunas explícitas, transação só multi-passo) × **o que varia por projeto** (onde vivem retry/log, retorno das escritas, forma do SQL — espelhar, não prescrever). Removida a fricção "corpo manda RetryDB+logger no DAO × referência SIGO diz que vivem na Database". Verificação de fechamento (RI-04). Eval em `evals/evals.json` (2 casos: SIGO → DAO limpo sem logger/retry; projeto genérico com RetryDB no DAO). Painel em `rodadas/R-nucleo-sigo-2026-07-18.md`.
- **2026-07-18 — Few-shot de código real (piloto):** criada `referencia-exemplos-reais-sigo.md` (`ViagemDAO.java`+`Database.java`). Baseline §11 e provas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda P1:** fonte única + referência com gloss (PADRAO §12.5); guardrail de concorrência do Access mantido literal.
