# Guia Operacional — EGM Bootstrap

## Para que serve
Mapeia a árvore de diretórios e gera READMEs arquiteturais com contratos Peanuts (folha) e Hay (agregador).

## Quando acionar
- A base é legada e não tem documentação por módulo.
- O usuário quer contratos de interface para humanos e IAs navegarem a árvore.

## Entradas
- Árvore do repositório e pontos de entrada.
- Convenções de pacote e linguagem.

## Saída
- READMEs arquiteturais por pasta, com interfaces, invariantes e efeitos colaterais.

## Pré-condições
- Subagente de contexto limpo para os Goldfish. Sem essa ferramenta, a skill para em vez de simular a revisão.
- Ler `referencia/harnesses.md` para o mapa de delegação do harness em uso.

## Roteiro curto
1. Mapear a árvore e identificar pacotes-folha.
2. Ler `referencia/templates.md` e o schema de retorno do worker.
3. Gerar Peanuts nas folhas e Hay nos agregadores.
4. Validar que cada contrato descreve o que o código faz, não o que deveria fazer.

## Referências
- `SKILL.md` — método completo (inglês, fonte Apache-2.0).
- `referencia/harnesses.md` — delegação por harness.
- `evals/evals.json` — casos de acionamento.
