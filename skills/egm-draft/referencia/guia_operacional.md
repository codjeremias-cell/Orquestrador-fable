# Guia Operacional — EGM Draft

## Para que serve
Redige a especificação técnica formal, seção por seção, a partir do brief ou de notas, com trade-offs e salvaguardas.

## Quando acionar
- Já existe brief aprovado ou notas suficientes e a decisão precisa virar documento.
- O usuário quer um `design_draft.md` com alternativas, requisitos e riscos.

## Entradas
- `concepts_brief.md`, notas ou design doc existente.
- Restrições, requisitos e critérios de aceite.

## Saída
- `design_draft.md` completo, com alternativas consideradas e decisões registradas.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Ler `referencia/execution_instructions.md`: o escopo é design-only, sem código de produção.
2. Fazer uma pergunta por vez e obter consenso explícito a cada transição.
3. Redigir seção por seção, marcando suposições e trade-offs.
4. Não resumir o trabalho no fim: entregar o conteúdo técnico e o próximo passo.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
