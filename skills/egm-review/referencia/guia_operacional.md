# Guia Operacional — EGM Review

## Para que serve
Submete um design doc a cinco estágios de revisão adversarial com Goldfish de contexto limpo.

## Quando acionar
- O design doc está pronto para ser desmontado antes de virar código.
- O usuário quer premissas ocultas, complexidade desnecessária e riscos expostos.

## Entradas
- `design_draft.md` ou documento equivalente.
- Padrões em `referencia/document_standards/`.

## Saída
- Relatório consolidado de apontamentos por estágio, com severidade e evidência.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Confirmar que existe subagente de contexto limpo; sem ele, parar.
2. Rodar os cinco estágios na ordem, cada revisor lendo a persona em `referencia/personas/`.
3. Consolidar sem suavizar: apontamento sem evidência não vira elogio.
4. Entregar o relatório ao usuário e apontar o próximo passo (egm-resolve).

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
