# Guia Operacional — EGM Drift Report

## Para que serve
Compara o código implementado com a especificação e aponta funcionalidades faltantes, modelos incompletos e atalhos não autorizados.

## Quando acionar
- O código andou depois do design doc e ninguém sabe onde divergiu.
- O usuário quer um laudo de drift antes de refatorar ou documentar.

## Entradas
- Design docs, READMEs e a árvore de código real.
- Escopo de módulos a inspecionar.

## Saída
- Laudo de drift por arquivo, com o que falta, o que sobra e o que foi atalho.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Ler a especificação e o código, sem inferir API que não existe.
2. Marcar cada divergência com evidência e severidade.
3. Separar missing, incomplete e atalho arquitetural.
4. Não corrigir código: o laudo aponta, a dev-senior corrige.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
