# 🔒 GABARITO — coleta-estelar (eval 1 da `testador-jogos`)

> **Uso exclusivo do avaliador/runner. NUNCA anexar, citar ou deixar acessível ao agente sob avaliação** — contamina o eval (salvaguarda §11.6 do PADRAO). Os 8 bugs abaixo foram **plantados de propósito** e **todos reproduzem** — verificados em 2026-07-13 via o próprio `scripts/web_game_harness.py` (Chromium headless, sandbox Cowork).

## Os 8 bugs plantados (`evals/fixtures/coleta-estelar/index.html`)

| ID | Sev | Sintoma (o que o agente deve encontrar) | Reprodução | Onde no código |
|---|---|---|---|---|
| A-01 | **A** | Apertar **P na tela inicial** gera erro (`Cannot read properties of null (reading 'v')`, pageerror) e trava o jogo: o estado vira "pausado" e o ENTER do menu morre — **softlock até o F5** | Abrir o jogo → apertar P → apertar Enter (nada acontece) | `togglePause()` não checa o estado; `player` ainda é `null` |
| A-02 | **A** | **Score não reseta ao reiniciar** — a partida nova herda a pontuação da anterior | Jogar e pontuar → morrer/esgotar tempo → Enter → HUD já abre com o score antigo | `startGame()` zera `lives` e `tempo`, mas não `score` |
| B-01 | B | **Timer continua correndo durante a pausa** (dá para "esgotar o tempo" pausado) | Iniciar → P → esperar → tempo cai; despausar mostra a perda | `tick1s()` decrementa também no estado `pausado` |
| B-02 | B | Jogador **atravessa a parede esquerda** e some da tela (x negativo) | Segurar ← encostado na borda esquerda | clamp só na direita/cima/baixo |
| B-03 | B | Colidir com meteoro **desconta 2 vidas** em vez de 1 | Bater em 1 meteoro com 3 vidas → HUD mostra 1 | `lives--` duplicado (no `filter` e na varredura seguinte) |
| B-04 | B | **Jogo acelera a cada restart** — relógio cai 2×/s e spawns dobram na 2ª partida (4× na 3ª…) | Jogar → game over → Enter → observar o tempo caindo em dobro | `setInterval` nunca é limpo; um novo se acumula por `startGame()` |
| C-01 | C | Typo no HUD: "**Pontacão**" (deveria ser Pontuação) | Ler o HUD | rótulo estático no HTML |
| C-02 | C | Placeholder esquecido na pausa: "**TODO: instruções de pausa**" | Iniciar → P → ler a mensagem | string em `togglePause()` |

## Armadilhas de falso-positivo (o agente NÃO deve reportar como bug)

- O **emoji ⭐/☄️/quadrado (tofu □)** renderizado como caixa no headless é limitação de fonte do ambiente, não bug do jogo (o SKILL.md avisa).
- FPS absoluto baixo no headless (SwiftShader) não é bug — só degradação *relativa* ao longo da sessão contaria.

## Critérios de nota do eval (espelham as assertions do evals.json)

≥5/8 bugs pelo sintoma · os 2 A obrigatórios · passos numerados + severidade em todo bug · evidência real (screenshot/pageerror) · análise crítica com notas (≥6 categorias + geral) · plano de melhorias em ondas com bugs A na primeira · checklist de regressão ≥15 casos incluindo REG-* dos bugs · ≥3 personas citadas com resultado.
