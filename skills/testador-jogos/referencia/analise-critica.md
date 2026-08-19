# Análise crítica — categorias, rubrica e método

Baseado em heurísticas de jogabilidade da literatura de games UX (avaliação heurística de
playability: game play, mecânicas, usabilidade, narrativa), adaptado para funcionar de
protótipo de game jam a jogo comercial.

## Método

- Avalie **depois** de jogar com as 4 personas — a análise usa as sessões como evidência.
- Cada categoria: nota 0–10 pela rubrica + argumento + **exemplo concreto do próprio jogo** +
  sugestão de melhoria. Crítica sem exemplo é achismo; nota sem sugestão não ajuda ninguém.
- Julgue o jogo **pelo que ele tenta ser** (gênero, escopo, público). Um endless runner não
  perde ponto por não ter narrativa profunda; um jogo narrativo perde.
- Em modo C (só GDD/vídeo), avalie o que o material permite e marque o resto como
  "não avaliável sem build" — sem inventar.

## Escala (âncoras)

**0–2** quebrado/ausente · **3–4** funciona mal, atrapalha a experiência · **5–6** funcional,
sem brilho ("ok") · **7–8** bom, contribui ativamente para a diversão · **9–10** excelente,
nível de referência no gênero. Nota 7+ exige apontar o que o jogo faz *bem* que a justifique.

## As 8 categorias

### 1. Primeiras impressões & onboarding (peso 1)
Os primeiros 3 minutos: o jogo comunica o que é, o que fazer e como? Tutorial ensina jogando ou
com paredão de texto? A Nina entendeu sozinha? Dá para pular o que é pulável?

### 2. Controles & game feel (peso 1,5)
Responsividade (input → reação imediata?), precisão (o personagem faz o que mandei?), feedback
de cada ação (visual, sonoro, tátil — o pulo tem peso? o acerto tem impacto?). O controle some
da consciência ou o jogador luta contra ele?

### 3. Mecânicas & design (peso 1,5)
O loop central é claro e se sustenta? As mecânicas conversam entre si ou são soltas? Escolhas
significativas (estratégias diferentes viáveis) ou caminho único disfarçado? Regras consistentes
— o jogo nunca trai a expectativa que ele mesmo criou?

### 4. Balanceamento & dificuldade (peso 1)
Curva: cresce suave ou tem paredão/marasmo? "Difícil mas justo" — morri por minha culpa (bom) ou
por culpa do jogo (ruim)? Punição proporcional ao erro? Helena achou estratégia dominante que
trivializa tudo? Economia fecha (recursos escassos o bastante para escolhas doerem)?

### 5. UX / UI (peso 1)
Menus: navegáveis, rasos, saída óbvia. HUD: informação certa, na hora certa, sem poluir.
Legibilidade (fonte, contraste, tamanho em mobile). Estados claros (pausado? salvo? vivo?).
Acessibilidade mínima: daltonismo não impede jogar? só cor nunca carrega informação crítica?

### 6. Áudio & visual (peso 1)
Coerência da direção de arte (estilo consistente ou colagem de assets?). Leitura visual: o
importante se destaca do fundo? Áudio: música combina, efeitos informam (dano, coleta, perigo)?
Silêncios e repetição irritante? (No headless, avalie a *intenção* audível no código/assets e
declare a limitação.)

### 7. Conteúdo & progressão (peso 1)
Há jogo suficiente para o que ele propõe? Variedade cresce (novos desafios, não só números
maiores)? Ritmo alterna tensão e alívio? Rejogabilidade: por que voltar depois de terminar?
Progresso é visível e recompensador?

### 8. Diversão & engajamento (peso 1,5)
A pergunta final e mais importante: **é divertido?** O teste do "só mais uma": ao morrer/terminar,
a vontade é jogar de novo ou fechar? Onde o tédio bateu (minuto exato)? O jogo respeita o tempo
do jogador? Qual emoção ele entrega (tensão, flow, curiosidade, poder) — e entrega mesmo?

## Nota geral e veredito

Nota geral = média ponderada (pesos acima, total 9,5). Arredonde para 1 casa decimal.
Apresente como tabela:

| Categoria | Peso | Nota |
|---|---|---|
| ... | ... | ... |
| **Geral (ponderada)** | | **X,X/10** |

Feche com:
- **Veredito em uma frase** — ex.: "Um puzzle charmoso e esperto que se sabota com onboarding confuso e 20 minutos de conteúdo."
- **Top 3 alavancas** — as 3 mudanças que mais elevariam a nota geral (alimentam o plano de melhorias).
- **Para quem é / para quem não é** — 1 linha cada.
