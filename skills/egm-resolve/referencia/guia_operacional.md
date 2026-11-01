# Guia Operacional — EGM Resolve

## Para que serve
Tria os apontamentos do review, defende o que é defensável e aplica correções textuais precisas no documento.

## Quando acionar
- Existe uma lista consolidada de apontamentos e o documento precisa responder a ela.
- O usuário quer distinguir o que corrigir do que contestar com fundamento.

## Entradas
- Documento de design e relatório de apontamentos.
- Decisões e restrições que sustentam os CONTESTs.

## Saída
- Documento corrigido, com resposta a cada apontamento: aceito, contestado ou pendente.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Classificar cada apontamento e explicitar a evidência.
2. Corrigir o texto no ponto exato, sem reescrever o documento inteiro.
3. Levar os checkpoints de alinhamento ao usuário antes de fechar.
4. Registrar o que ficou pendente em vez de declarar resolvido.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
