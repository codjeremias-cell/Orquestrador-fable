# Caça-bugs — tipos de teste e arsenal do destruidor

## Passadas técnicas (Passo 3)

Execute cada passada como uma varredura separada. Não tente fazer tudo ao mesmo tempo —
foco por passada é o que dá cobertura.

### 1. Funcional (matriz de combinações)
Todo elemento interativo × todo estado relevante. Liste mecânicas, itens, personagens, fases,
botões de menu — e teste cada combinação que fizer sentido (método de matriz: personagem A com
arma 1, 2, 3… no cenário X, Y). Verifique: regras do jogo valem sempre? pontuação/dano/economia
calculam certo? condições de vitória/derrota disparam corretamente? tutorial reflete o jogo real?

### 2. Interface e conteúdo
Todos os menus, ida e volta. Textos: ortografia, truncamento, sobreposição, placeholder esquecido
("Lorem ipsum", "TODO"). HUD: valores atualizam na hora certa? elementos somem/aparecem quando
devem? Resoluções: redimensione a janela (desktop) e teste viewport mobile (390×844) — layout
quebra? botão fica inalcançável?

### 3. Estados e persistência
A classe de bug mais comum em jogos pequenos: **estado que vaza entre partidas**.
- Reiniciar limpa TUDO? (score, vidas, timer, posição, power-ups, inimigos, intervals/loops)
- Pausar congela TUDO? (timer, física, spawns, animações, áudio) e despausar retoma exato?
- Save/load restaura fielmente? Load no meio de ação corrompe algo?
- Game over → menu → nova partida: alguma sujeira sobra da anterior?
- Abrir/fechar o mesmo modal 10× seguidas: comportamento igual da 1ª à 10ª?

**Verifique cada valor de estado empiricamente, um por um — não infira.** Este é o erro mais
fácil de cometer aqui: você vê `startGame()` zerar vidas e timer, lê o código por cima e
conclui "o restart limpa tudo", quando na verdade *um* valor (o score, quase sempre) ficou de
fora e persiste. Nunca deduza que um valor reseta porque os vizinhos resetam ou porque o código
"parece" fazer isso. O método à prova de falha: **produza o estado de verdade** — jogue e faça
pontos (score > 0), acumule/perca vidas, deixe o timer correr, pegue um power-up — depois
reinicie e leia **cada campo do HUD individualmente**, confirmando que voltou ao valor inicial.
Um score que herda a pontuação da partida anterior é bug (frequentemente severidade A) e só
aparece se você tiver pontuado antes de reiniciar e olhado justamente aquele número.

### 4. Performance e sessão longa
FPS estável ou degrada com o tempo? (degradação = vazamento: intervals duplicados, listeners
acumulados, entidades nunca destruídas). Memória cresce sem parar? Loading piora a cada fase?
Sessão de 10+ min contínuos ou 10 restarts seguidos — o jogo continua igual ao minuto 1?
No harness: meça FPS no início e no fim da sessão e compare.

### 5. Compatibilidade (quando aplicável)
Outra resolução, outro navegador/dispositivo se acessível, com e sem mouse/touch. O que não der
para cobrir, declare nas limitações do relatório — não finja cobertura que não houve.

## Arsenal do destruidor

Táticas concretas para a sessão do Diego. Marque as que usou; achado vira bug no formato padrão.

**Input hostil**
- Spam: clicar/apertar o mesmo botão 20× o mais rápido possível (comprar, atirar, confirmar)
- Teclas simultâneas: andar + pular + atirar + pausar ao mesmo tempo; direções opostas juntas (← e →)
- Segurar teclas por 30s+ · trocar de direção a cada frame · soltar input durante animação
- Duplo clique em tudo que espera clique único (comprar item caro 2× com dinheiro para 1)
- Input durante transições: apertar durante loading, cutscene, animação de morte, troca de fase

**Timing hostil**
- Pausar no pior momento: durante pulo, no frame da colisão, na tela de game over, antes do jogo começar
- Morrer e coletar/vencer no mesmo instante · ações no último segundo do timer
- Interromper: refresh (F5) no meio da ação, botão voltar do navegador, fechar e reabrir a aba
- Perder foco: trocar de aba/minimizar por 2 min no meio da partida — o que acontece ao voltar?

**Limites e valores extremos**
- Bordas do mapa: encostar, pular e "esfregar" em todos os cantos e quinas; tentar sair da tela
- Campos de entrada: vazio, 500 caracteres, emoji, `<script>alert(1)</script>`, números negativos, 0, 9999999
- Economia: gastar até zerar e tentar gastar de novo; encher inventário e coletar mais um
- Velocidade máxima contra parede/quina · empilhar entidades no mesmo pixel

**Estados inválidos**
- Fazer as coisas fora de ordem: entrar na loja durante game over, abrir mapa dentro de menu, equipar item durante diálogo
- Recusar/cancelar tudo que der (Esc em todo modal, cancelar compra no meio)
- Ficar AFK 5 min em cada tela (menu, pausa, gameplay) — timers estouram? algo desincroniza?
- Repetir o ciclo completo (jogar → morrer → reiniciar) 10× e comparar a 10ª com a 1ª

## Bugs clássicos por área (onde procurar primeiro)

- **Colisão/física:** atravessar parede em quina/velocidade alta; hitbox maior/menor que o sprite; empurrar objeto para dentro de outro; cair fora do mundo.
- **Estado:** score/vidas/timer não resetam no restart; power-up permanente após morte; boss não reaparece; interval/loop duplicado a cada restart (jogo "acelera").
- **UI:** botão morto (sem handler); z-index (elemento clicável atrás de outro); texto estourando o container; HUD dessincronizado do estado real; foco de teclado preso.
- **Pontuação/economia:** contagem dupla (evento registrado 2×); valores negativos; multiplicador que não zera; high score que não salva ou salva errado.
- **Áudio:** som que não para no pause/game over; sons sobrepostos acumulando; mute que não silencia tudo (testar a lógica: a flag é respeitada em todos os `play()`?).
- **Race conditions:** duas colisões no mesmo frame; coletar item no frame da morte; clique duplo criando duas entidades/transações.

## Guia rápido de severidade

| Sev | Critério | Exemplos |
|---|---|---|
| **A** | Crash, softlock, perda de progresso/dados, impede avançar, exploit que destrói a economia | Jogo congela ao pausar; save corrompido; dinheiro infinito por duplo clique |
| **B** | Quebra uma mecânica ou atrapalha muito, mas há contorno | Vidas descontam 2 em vez de 1; timer corre durante pause; colisão furada numa parede específica |
| **C** | Cosmético, texto, polimento — não afeta a jogabilidade | Erro de ortografia; sprite piscando; som ligeiramente atrasado |
| **💡** | Não é defeito — é oportunidade de melhoria | "Um dash deixaria o movimento mais gostoso" → vai para o plano de melhorias |

Na dúvida entre duas severidades, pergunte: *"isso impediria um lançamento?"* (A), *"isso faria
um jogador reclamar em review?"* (B), *"só quem procura percebe?"* (C).
