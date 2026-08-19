# Histórico — java-javafx-entity

Registro de rodadas de evolução da skill (movido do corpo do SKILL.md para progressive disclosure; conteúdo verbatim).

- **2026-07-18 — Evolução ao 9,5 (núcleo SIGO):** corpo reescrito para **espelhar-não-impor** — a fricção "corpo prescreve validate/equals/inglês × referência SIGO contradiz" foi removida na raiz: o padrão do projeto virou o caminho primário e o default genérico só entra quando não há entidade para espelhar. Adicionada verificação de fechamento (RI-04, compila+teste). Eval em `evals/evals.json` (3 casos: SIGO → POJO sem validate/teste; greenfield → default a confirmar RI-04; projeto inglês → mantém inglês+validate — simetria do espelho). Painel em `rodadas/R-nucleo-sigo-2026-07-18.md`.
- **2026-07-18 — Few-shot de código real (piloto):** criada `referencia-exemplos-reais-sigo.md` (fonte: `Viagem.java`). Baseline §11 e provas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
