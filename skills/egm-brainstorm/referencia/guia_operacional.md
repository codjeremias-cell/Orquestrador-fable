# Guia Operacional — EGM Brainstorm

## Para que serve
Transforma uma ideia crua em hipótese ancorada e num `concepts_brief.md` que sobreviveu a revisores neutros.

## Quando acionar
- A ideia ainda está nebulosa e as premissas precisam ser estressadas antes do design.
- O usuário quer um brief conceitual, não uma especificação formal.
- Há risco de consenso barato: a skill obriga a criticar antes de concordar.

## Entradas
- Problema, público e restrições em linguagem natural.
- Contexto do projeto e decisões já tomadas.

## Saída
- `concepts_brief.md` com overview, análise, metas/não-metas, alternativas e decisões.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Perguntar em modo aberto, uma pergunta por vez, até o problema e as fronteiras ficarem claros.
2. Ancorar a hipótese em 2-3 frases e pedir confirmação explícita.
3. Acionar o sintetizador e os Goldfish em paralelo, em contexto limpo.
4. Deduplicar os achados, escrever o brief em arquivo e destacar 2-3 riscos.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
