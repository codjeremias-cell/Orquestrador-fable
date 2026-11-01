---
name: egm-drift-report
license: Apache-2.0
description: "Detecta desvio de implementação (drift) entre especificações técnicas (design documents e READMEs) e o código-fonte real: inspeciona classes, métodos, contratos e schemas para apontar funcionalidades faltantes, modelos incompletos ou atalhos arquiteturais não autorizados. Acione com \"egm-drift-report\", \"detectar drift no código\", \"o código divergiu da spec?\", \"audita desvio de implementação\", \"conferir código contra o design doc\", \"/egm-drift-report\". NÃO acione para testes unitários ou execução de build (use testador-real ou dev-senior) nem para redigir novas especificações (use egm-draft)."
---

> **Idioma:** o corpo desta skill é mantido em inglês porque deriva do upstream Apache-2.0 (fonte da verdade do método). **Toda resposta ao Jeremias, todo artefato gerado e toda mensagem de interface saem em PT-BR**, salvo pedido explícito em contrário.

# Detect Drift In Designs and Code

> **Harness:** read [`referencia/harnesses.md`](referencia/harnesses.md) before running. It is this house's local adaptation of the upstream multi-harness guide.

When the user asks to detect drift across all designs or a set of READMEs, the
goal is to identify all instances where the codebase has diverged or failed to
implement the specifications described by those designs or READMEs.

1.  **Check Input**: Verify a directory containing design documents or READMEs
    is provided. If not provided, ask the user to specify the target directory.
2.  **List Documents**: List all files in the design directory.
3.  **Analyze**: For EACH design document:

    *   **Contextualize**: Read the design document. Identify the intent,
        proposed changes, and specific filenames/symbols mentioned.
    *   **Locate Source**: Find the corresponding source code files in the
        source tree. If paths aren't explicit, use code search or grep to
        locate the relevant classes, functions, or API endpoints mentioned in
        the doc. Prompt the user to add missing links to the document to make
        future detection cheaper.
    *   **Verify**: Read the current state of those source files.
    *   **Detect Drift**: Compare the design vs. reality. Look specifically for:
        *   Missing Features: Logic described in the doc but absent in the code.
        *   Incomplete Models: Dataclasses/Classes/Structs/Protos missing fields
            specified in the design.
        *   Logic Shortcuts: Hardcoded values where dynamic logic was planned.
        *   Architectural Divergence: Implementation using different
            patterns/libraries than proposed.
    *   **Filter**: Report ONLY the differences. Do not describe what is working
        or what matches. If the code matches the design perfectly, output "No
        drift detected."

4.  **Report**: Produce a single report listing all discrepancies found.

    *   Append the analysis for each file to `{YYYY-MM-DD}_DRIFT_REPORT.md`
        using your file-writing tool.
    *   Strict Format:

        ```markdown
        ## <DESIGN_DOC_NAME>

        <Bulleted list of specific divergences found>
        <Or "No drift detected">
        ```

5.  **Guidance**

    -   Be rigorous. If a design doc mentions a specific object, field or file
        name and the code doesn't have it, that is a reportable drift. Double
        check for coverage. If there is some part of the logic that is not
        referenced in a design or README, this is a reportable drift.
    -   Read files liberally to ensure you are looking at the current state
        of the code, not relying on memory.
    -   Process the files sequentially to ensure the tool output buffer doesn't
        overflow.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `auditor-responsabilidades` e `reality-checker`.
- **Vem antes:** Conclusão da fase de codificação por `dev-senior`.
- **Vem depois:** Planejamento de refatoração ou alinhamento de documentação (`docs-projeto`).
- **Não confundir com:** `testador-real` (que executa código dinamicamente) nem `auditor-responsabilidades` (que audita processo).

### 📜 Histórico
- **2026-10-31 — Inventário das 10:** "Vem antes" e "Vem depois" trocados (estavam invertidos contra a convenção do catálogo). `referencia/harnesses.md` ganha a linha do Grok (`spawn_subagent`). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-10-30 — Port de integridade e licença (T67):** corpo em inglês preservado; ponteiros de harness consolidados em `referencia/harnesses.md`; personas e padrões movidos para `referencia/`; `LICENSE` e `NOTICE.md` Apache-2.0 acrescentados; `license: Apache-2.0` restaurado no frontmatter; `evals/evals.json` e guia operacional preenchidos; nota e rodapé de idioma PT-BR. `disable-model-invocation: true` do upstream NÃO foi restaurado, por decisão da casa (RI-06: acionamento por gatilho). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-10-29 — Integração ao Catálogo Unificado:** Adaptação da skill oficial do Elephant-Goldfish Model (Google EGM) com suporte multi-harness (Claude, Codex, Antigravity). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.

---

## 🌐 Idioma das respostas

**Responda sempre em PT-BR.** O corpo em inglês desta skill é a fonte do método (upstream Apache-2.0); tudo o que chega ao Jeremias — perguntas, relatórios, apontamentos, `concepts_brief.md`, `design_draft.md` e mensagens — sai em português do Brasil, salvo pedido explícito em contrário.
