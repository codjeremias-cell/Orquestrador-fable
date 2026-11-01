# Guia Operacional — EGM Review Loop

## Para que serve
Motor configurável de revisão multiagente: revisores, padrões e templates definidos pelo usuário, com targeting semântico e reparos.

## Quando acionar
- A esteira fixa de cinco estágios não serve e o usuário quer revisores/padrões próprios.
- O documento precisa de rodadas repetidas até os apontamentos pararem.

## Entradas
- Documento-alvo, revisores e padrões customizados.
- Templates estruturais em `referencia/document_standards/`.

## Saída
- Relatório por rodada e reparos aplicados, com histórico do que mudou.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Declarar revisores, padrões e critério de parada.
2. Resolver as personas em `referencia/personas/` e os padrões em `referencia/document_standards/`.
3. Rodar o loop, auditando o trecho alvo no intervalo de linhas correto.
4. Parar quando o critério declarado for atingido; não rodar por rodar.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
