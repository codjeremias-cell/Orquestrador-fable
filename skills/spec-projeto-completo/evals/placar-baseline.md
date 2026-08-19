# Placar baseline × com-skill — spec-projeto-completo

> Medição do §11 do PADRAO-DE-AUTORIA - **2026-07-09**. Executor: **Sonnet** (baseline sem acesso ao catálogo vs. com a SKILL.md carregada). **Juiz cego** por eval (ordem A/B alternada), pontuando 1 / 0,5 / 0 por expectation; score = fração das expectations atendidas. Workflow `placar-baseline-orquestradores` (run `wf_8db22f26-e56`, 84 agentes, 28 evals, 0 erros).

| Eval | Baseline | Com skill |
|---|---|---|
| app-web-do-zero | 0,58 | 1,00 |
| nao-acna-para-etapa-isolada | 0,50 | 1,00 |
| prefere-track-javafx-quando-aplicavel | 0,00 | 1,00 |
| **Média** | **0,36** | **1,00** |

## Observações do juiz (evidência RI-04)

- **app-web-do-zero:** A segue explicitamente as 10 etapas nomeadas da skill spec-projeto-completo (tabela com skill+gate por etapa), para no gate de descoberta pedindo respostas objetivas antes de avançar, cita o track web condicional (frontend-stack-decisor etc.), marca a etapa de negócio como condicional/declarada, e fecha com o veredito do auditor-responsabilidades. Atende plenamente as 6 expectations. B é um plano de engenharia sênior bem escrito e detalhado (com boa cobertura de testes reais, staging, segurança, fatias verticais), mas nunca menciona uma fase de design/UX com mockups a aceitar antes de codar, nunca referencia a etapa de negócio (nem para pulá-la declaradamente) e não fecha com nenhum veredito de auditoria — termina em 'Como fecho cada entrega' sem gate final formal. Isso derruba as expectations 5 e 6 e enfraquece parcialmente a 2 (falta o gate de design citado como exemplo na própria expectation).
- **nao-acna-para-etapa-isolada:** Resposta A trata o pedido como uma tarefa genérica de execução de testes que ela mesma conduziria (perguntas de escopo, passos manuais, relatório), sem nunca mencionar que existe um orquestrador universal do qual está se afastando nem delegar a uma skill de teste específica — por isso não atende a expectation 3 e só implicitamente (não explicitamente) trata o pedido como etapa isolada. Resposta B nomeia explicitamente a skill spec-projeto-completo, justifica com o próprio texto/gatilho dela por que não deve ser acionada para uma etapa isolada, recusa rodar a sequência de 10 etapas, e direciona corretamente para a instância do projeto (testador-sigcot), atendendo às três expectations de forma explícita e correta.
- **prefere-track-javafx-quando-aplicavel:** Resposta A cita textualmente a cláusula de desvio da própria skill (descrição + seção 'Não confundir com'), reconhece explicitamente que spec-javafx-new-system é o track dedicado para desktop JavaFX novo, e encerra sem executar a sequência de 10 etapas nem duplicar trabalho — atende plenamente as 3 expectations. Resposta B nunca menciona spec-javafx-new-system nem a existência de um track dedicado; em vez disso, reconstrói manualmente um processo de descoberta+arquitetura+construção (fases 0-2) equivalente à sequência genérica da própria spec-projeto-completo, exatamente o comportamento que o eval pede para NÃO ocorrer. Portanto falha nas três expectations.
