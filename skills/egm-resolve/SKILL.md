---
name: egm-resolve
license: Apache-2.0
description: "Realiza a triagem sistemática e a resolução de apontamentos levantados pelos revisores Goldfish no documento de design: opera no contexto do Elephant para defender decisões fundamentadas (CONTEST), propor correções textuais precisas e conduzir checkpoints interativos de alinhamento até a aprovação final. Acione com \"egm-resolve\", \"resolve os apontamentos do review\", \"triagem de findings da spec\", \"aplica correções no design doc\", \"/egm-resolve\". NÃO acione para rodar a auditoria inicial da especificação (use egm-review) nem para conferir código já implementado contra o design (use egm-drift-report)."
---

> **Idioma:** o corpo desta skill é mantido em inglês porque deriva do upstream Apache-2.0 (fonte da verdade do método). **Toda resposta ao Jeremias, todo artefato gerado e toda mensagem de interface saem em PT-BR**, salvo pedido explícito em contrário.

# Goldfish Review: Resolve

> **Harness:** read [`referencia/harnesses.md`](referencia/harnesses.md) before running. It is this house's local adaptation of the upstream multi-harness guide.

## Overview

This skill instructs the agent on how to operate within the primary Elephant
context window to parse flat deficiency reports from concurrent Goldfish
reviewers. It defends accurate design choices, applies automated textual
repairs, and manages interactive negotiation checkpoints.

## Prerequisites & Context Strategy

*   **Context Recommendation (Elephant Memory)**: This skill should be run in
    the persistent conversation session that generated the target document (the
    Elephant) to recall earlier reasoning and craft higher-quality fixes.

## Inputs

The caller or orchestration driver provides exactly these parameters:

*   **`TargetFile`**: Absolute or relative path to target document.
*   **`LineRange`**: Exact line numbers (or `full file`).
*   **`FindingsList`**: Aggregated flat list of findings from Goldfish
    reviewers.

## Execution Workflow

### Step 1: Intake Validation & Gather Context

1.  **Hybrid Execution UX**: Detect if execution arguments are present:

    *   *Automated Mode*: If all parameters are provided, execute silently as a
        subprocess.
    *   *Standalone Human Mode*: If parameters are omitted, trigger a friendly
        onboarding flow. Prompt for one piece of input at a time, waiting for
        the user's response after each turn. Once all inputs are specified,
        display the final setup and verify the user is ready to continue.

2.  Read `TargetFile` at `LineRange` by reading it and parse the `FindingsList`.

### Step 2: Evaluate & Categorize

Give each finding exactly one category:

*   **CONTEST**: The critique is inaccurate or relies on a misunderstanding of
    the codebase. Cite evidence that the reviewer could read: a file and
    symbol, or a decision recorded in the document.
*   **ESCALATE**: The critique is inaccurate, but the evidence is outside every
    file the reviewer could read (for example, a team convention or a verbal
    decision). State that fact. Do not fix the finding. Give it to the user.
*   **PROPOSE FIX**: The critique is valid. Define precise textual replacements
    or structural formatting adjustments to resolve the gap.
*   **DECLINE**: The finding is a Nit. Record it. Do not fix it. You can use
    PROPOSE FIX for a Nit if the fix is worth it.

Apply these rules:

*   **A contest must be checkable.** "This was intentional" is not evidence.
    If you cannot cite evidence the reviewer could read, use ESCALATE or
    PROPOSE FIX.
*   **Do not add context only to satisfy a reviewer.** Add context when a human
    reader of the document needs it. If only a zero-context subagent needs it,
    use ESCALATE.
*   **Do not contest a comprehension gap.** If a fresh reader could not follow
    the document, the document is missing context.
*   **Do not change a severity.** If you think a Blocker is a Nit, CONTEST it
    and state the reason.
*   You wrote the document under review. A wish to contest is not evidence
    that the reviewer is wrong.

### Step 3: Report Fixes

Construct the final report and save it named
`goldfish_review_report.md` in the working directory (or your harness's artifact directory, if it has one)
using your file-writing tool. Use this layout:

```markdown
# Goldfish Annotated Review Report

**Target:** `[TargetFile]` (`[LineRange]`)

## Prioritized Findings & AI Suggestions

{{range findings, ordered by Severity}}
### [Issue 1] [`[ReviewerPersona]`] - Severity: [High | Medium | Low]
*   **Affected Scope:** [Lines Start-End]([RelativePath]#L[Start]-L[End]) ([Sub-header])
*   **Discrepancy Description:** [copied from FindingsList]
*   **Rationale:** [copied from FindingsList]
*   ***AI Suggestion:*** [CONTEST | ESCALATE | PROPOSE FIX | DECLINE]
*   ***Justification:*** [Detailed reason]
*   ***Proposed Edit:***
    *   Location: [Line/Header]
    *   Change: [Precise replacement string or deletion note]
{{end}}
```

### Step 4: Interactive Resolution Gate

If any finding is `ESCALATE`, list those findings first in the chat message.
They need the user's knowledge, not only approval.

Before proceeding, output a visible chat message to the user: *"I have compiled
the audit findings into `goldfish_review_report.md`. Please review the findings there and choose how you would like to
proceed:

-   **Comment directly on the file**: Review `goldfish_review_report.md` in
    chat or the file and leave comments/edits to approve, reject, or contest
    specific items.
-   **Auto accept**: Reply "auto accept" to batch-apply all proposed fixes
    (skipping contested items).
-   **Continue to next phase**: Reply "continue" or "no changes" to proceed
    without applying fixes.
-   **Interactive breakdown**: Reply "interactive breakdown" for a guided,
    item-by-item walkthrough in chat with detailed explanations for each
    proposed edit or contested finding before making decisions.
-   **Custom instruction / Wildcard request**: Reply with any custom
    instruction, question, or out-of-band request."*

You **MUST** immediately yield active execution by calling **zero tools** in
this turn payload. You must stop execution and go idle, waiting for the human
developer to comment on/edit the artifact or reply in the chat.

Interpret the user's action/response as follows:

-   **"Auto accept" / "Accept all suggestions" / User clicks "Proceed" without
    contesting**: Apply all fixes where the AI suggestion was `PROPOSE FIX`
    directly to `TargetFile` at `LineRange` in a single batch using
    your file-editing tool. Any items categorized as `CONTEST`, `ESCALATE`, or
    `DECLINE` are explicitly bypassed. Then proceed to Step 5.
-   **"Continue to next phase" / "No changes"**: Do not apply any automated
    fixes. Then proceed to Step 5.
-   **"Interactive breakdown"**: Enter a sequential breakdown loop over ALL
    finding items (all categories except `DECLINE`):

    1.  For each item `i`, output a visible chat message formatting the full
        finding details and explanation in rich markdown:

        ```markdown
        ### Breakdown Item [i]: [Issue Title] [`[ReviewerPersona]`]
        * **Scope:** [Lines Start-End]([RelativePath]#L[Start]-L[End]) ([Sub-header])
        * **Description:** [Description]
        * **AI Suggestion:** [CONTEST | ESCALATE | PROPOSE FIX]
        * **Explanation & Justification:** [Detailed reason and background explaining why the fix is proposed or why the finding is contested]
        * **Proposed Edit:** [Precise replacement text or deletion note]
        ```

        Then prompt the user in chat for their decision on this item (calling
        **zero tools** and going idle):

        *   If `PROPOSE FIX`: Ask the user to reply with **Accept proposed
            fix**, **Skip / ignore**, or **Discuss**.
        *   If `CONTEST`: Ask the user to reply with **Skip / agree with
            contest**, **Overrule contest (propose fix)**, or **Discuss**.
        *   If `ESCALATE`: Ask the user to reply with **Confirm (no change)**,
            **Add the fact to the document**, or **Discuss**.

    2.  Record the user's decisions in an internal memory checklist (e.g., *Item
        1: Accepted*, *Item 2: Ignored*, *Item 3: Overruled*). **Do NOT call any
        file editing tools during this sequential loop.**

    3.  Once all items have been decided, summarize the accepted edits, execute
        them using your file-editing tool, and proceed to Step 5.

-   **Custom instruction / Out-of-band edit**: If the user provides targeted
    instructions, apply them and proceed.

### Step 5: Post-Resolution Synchronization & Exit

1.  **Re-verify Lines**: If changes were made to `TargetFile`, verify that the
    file remains structurally coherent and valid markdown.
2.  Mark the report as resolved (add a `Status: resolved` line at the top).
3.  **Handoff**: Exit cleanly back to the caller (such as `egm-review-loop`)
    with the count of accepted fixes, contested items, escalated items,
    declined items, and remaining unaddressed issues.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` e `dev-senior`.
- **Vem antes:** `egm-review` (que gerou a lista consolidada de apontamentos).
- **Vem depois:** Aprovação do design e autorização de codificação pela `dev-senior`.
- **Não confundir com:** `egm-review` (que audita sem resolver) nem `engenharia-diff-minimo`.

### 📜 Histórico
- **2026-10-31 — Inventário das 10:** "Vem antes" e "Vem depois" trocados (estavam invertidos contra a convenção do catálogo). `referencia/harnesses.md` ganha a linha do Grok (`spawn_subagent`). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-10-30 — Port de integridade e licença (T67):** corpo em inglês preservado; ponteiros de harness consolidados em `referencia/harnesses.md`; personas e padrões movidos para `referencia/`; `LICENSE` e `NOTICE.md` Apache-2.0 acrescentados; `license: Apache-2.0` restaurado no frontmatter; `evals/evals.json` e guia operacional preenchidos; nota e rodapé de idioma PT-BR. `disable-model-invocation: true` do upstream NÃO foi restaurado, por decisão da casa (RI-06: acionamento por gatilho). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-10-29 — Integração ao Catálogo Unificado:** Adaptação da skill oficial do Elephant-Goldfish Model (Google EGM) com suporte multi-harness (Claude, Codex, Antigravity). Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.

---

## 🌐 Idioma das respostas

**Responda sempre em PT-BR.** O corpo em inglês desta skill é a fonte do método (upstream Apache-2.0); tudo o que chega ao Jeremias — perguntas, relatórios, apontamentos, `concepts_brief.md`, `design_draft.md` e mensagens — sai em português do Brasil, salvo pedido explícito em contrário.
