# Personas de jogador

Quatro personas, **nesta ordem** — cada uma encontra uma classe diferente de problema.
Para cada sessão registre: o que a persona tentou, onde travou/estranhou, screenshots,
e a resposta dela à pergunta-chave.

---

## 1. Nina, a Novata (15–20 min)

Nunca jogou este gênero. Não lê tutorial nem instruções — vai clicando/apertando para ver o
que acontece. Desiste fácil: se em 2 minutos não entendeu o objetivo ou morreu 3 vezes sem
saber por quê, fecharia o jogo.

- **Comportamento:** pula textos, clica em tudo que parece clicável, aperta teclas óbvias
  (setas, WASD, espaço, Enter, Esc), erra comandos, fica parada esperando o jogo se explicar.
- **Encontra:** onboarding confuso, affordances ruins (botão que não parece botão), falta de
  feedback ("apertei e nada aconteceu?"), objetivo obscuro, dificuldade inicial injusta,
  texto técnico demais.
- **Pergunta-chave:** *"Em 3 minutos eu entendi o que fazer, como fazer e por que continuar?"*

## 2. Cadu, o Casual (15–20 min)

Joga 10 minutos no ônibus. Quer diversão imediata e sem fricção. Tolera pouco: menu longo,
loading demorado, sessão que não pode ser interrompida.

- **Comportamento:** sessões curtas, interrompe no meio (minimiza, troca de aba, recebe
  "ligação"), volta depois esperando continuar de onde parou, joga relaxado sem otimizar.
- **Encontra:** problemas de ritmo (demora para chegar na diversão), punição excessiva,
  progresso perdido ao sair, sessões que não cabem em 10 min, grind cedo demais, falta de
  recompensa visível ("por que continuar?").
- **Pergunta-chave:** *"Se eu tiver só 10 minutos, o jogo me dá uma experiência completa e
  me deixa com vontade de voltar?"*

## 3. Helena, a Hardcore (20–30 min)

Quer dominar o jogo: entender todos os sistemas, otimizar, achar a estratégia dominante.
Lê tudo, testa cada mecânica de propósito, compara opções.

- **Comportamento:** testa limites legítimos (build mais forte, rota mais rápida, farm mais
  eficiente), procura estratégia dominante que trivializa o jogo, avalia se escolhas importam,
  repete trechos para verificar consistência (dano, drops, timings).
- **Encontra:** desbalanceamento (opção obviamente superior, mecânica inútil), profundidade
  falsa (escolhas que não mudam nada), curva de dificuldade quebrada (paredão ou platô),
  economia furada (dinheiro sobrando/faltando sempre), falta de conteúdo para quem domina.
- **Pergunta-chave:** *"Dominar este jogo é interessante — ou existe um botão 'ganhar' que
  torna todo o resto irrelevante?"*

## 4. Diego, o Destruidor (20–30 min)

QA adversarial. O objetivo dele é **quebrar o jogo**, não ganhar. Joga "errado" de propósito,
com o arsenal completo de `caca-bugs.md` (inputs impossíveis, timing hostil, spam, estados
inválidos, limites do mapa).

- **Comportamento:** faz tudo que o designer não previu, na ordem que ninguém faria, no
  momento mais inconveniente possível. Anota o estado exato antes de cada tentativa para
  conseguir reproduzir o que quebrar.
- **Encontra:** crashes, softlocks (jogo vivo mas impossível de continuar), estados corrompidos,
  exploits (dinheiro infinito, atravessar parede, pular fase), race conditions, vazamentos de
  performance.
- **Pergunta-chave:** *"O que eu consegui quebrar hoje — e um jogador de 12 anos entediado
  quebraria também?"*
