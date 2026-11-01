# NOTICE — egm-review (atribuição)

Esta skill é derivada do projeto **Elephant & Goldfish Model (EGM)**.

- **Projeto:** Elephant & Goldfish Model — https://github.com/google/elephant-goldfish-model
- **Site:** https://egm.dev/
- **Autor:** Dave Rensin
- **Licença:** Apache License 2.0 — texto integral em `LICENSE`
- **Origem:** `skills/egm-review/SKILL.md` no upstream (branch `main`), consultado em 2026-10-30.

## O que foi modificado nesta cópia

- Ponteiros de harness externos (`docs/codex.md`, `docs/claude.md`, `docs/harnesses.md`) foram consolidados em `referencia/harnesses.md`.
- Personas movidas de `agents/` para `referencia/personas/`; padrões movidos de `resources/document_standards/` para `referencia/document_standards/`.
- `resources/execution_instructions.md` copiado para `referencia/execution_instructions.md` quando a skill o consome.
- Frontmatter: `license: Apache-2.0` restaurado. `disable-model-invocation: true` do upstream **não** foi restaurado, por decisão da casa (RI-06: acionamento por gatilho), e isso está registrado no Histórico.
- Nota de idioma no topo e rodapé PT-BR no fim; o corpo em inglês foi preservado.
- Acréscimos da casa: `evals/evals.json` e `referencia/guia_operacional.md`.

O texto Apache-2.0 exige que arquivos modificados carreguem aviso proeminente de alteração; este NOTICE cumpre esse papel para o conjunto da pasta.
