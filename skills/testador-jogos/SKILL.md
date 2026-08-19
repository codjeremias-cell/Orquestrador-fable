---
name: testador-jogos
description: "Testa qualquer jogo como QA profissional e analista crítico: caça bugs jogando de verdade com personas (novata, casual, hardcore, destruidor), avalia o game design com notas por categoria e entrega relatório de bugs, análise crítica, plano de melhorias priorizado e checklist de regressão. Acione com \"testar meu jogo\", \"caçar bugs\", \"fazer QA do game\", \"playtest\", \"review do jogo\", \"meu jogo está pronto pra lançar?\", \"o que falta no meu jogo?\". NÃO acione fora disso — não acione para app/site que não é jogo (Embalo, Gradup/portal) nem bateria de código — isso é testador-real ou o testador do projeto; para só projetar casos sem jogar, qa-usabilidade."
---

# Game Tester — QA + Análise Crítica de Jogos

Metodologia para testar **qualquer jogo** que o usuário indicar, unindo os dois papéis da
indústria: o **testador QA** (encontra e documenta defeitos de forma reproduzível) e o
**analista crítico** (avalia design, diversão e experiência com olhar de crítico construtivo).

## Quando usar / Quando não usar
- **Use** para testar a *experiência* de um jogo: jogar por personas, caçar bugs de gameplay, avaliar design e dar nota — jogo web/HTML5, PC, mobile, protótipo, GDD ou vídeo.
- **Não use** para app/site que não é jogo nem para bateria de código de sistema: isso é `testador-real` (geral) ou o testador do projeto (ex.: `gradup-testador`). Para só projetar casos e heurísticas sem jogar, é `qa-usabilidade`. Um jogo com backend usa os dois: `testador-real` no servidor, esta skill no gameplay.

## Princípios

1. **Jogue de verdade, como jogador.** Assuma as personas de `referencia/personas.md` na ordem
   Nina (novata) → Cadu (casual) → Helena (hardcore) → Diego (destruidor). Cada uma enxerga
   problemas que as outras não veem. Não pule direto para "análise de código".
2. **Evidência antes de opinião.** A habilidade nº 1 do tester é atenção ao detalhe; a nº 2 é
   comunicar o que viu de forma que outra pessoa reproduza. Todo bug precisa de passos numerados,
   resultado esperado vs. atual e evidência (screenshot, erro de console, log). Bug que o dev
   não consegue reproduzir é bug que não será corrigido.
3. **Quebrar o jogo É o trabalho.** Jogar "certinho" encontra poucos bugs. Use o arsenal do
   destruidor (`referencia/caca-bugs.md`): inputs impossíveis, timing hostil, spam, estados
   inválidos. Criatividade destrutiva é uma habilidade, não má vontade.
4. **Bug ≠ opinião de design.** Defeito objetivo (crash, colisão furada, texto errado) vai para o
   relatório de bugs com severidade. Discordância de design (dificuldade, ritmo, economia) vai
   para a análise crítica com argumento e sugestão. Misturar os dois mina a credibilidade de ambos.
5. **Registre o positivo também.** Relatório só de defeitos distorce a visão do produto e
   desmotiva o time. Diga o que funciona bem e por quê — isso também orienta decisões.
6. **Paciência e repetição fazem parte.** Retestar o mesmo trecho 10 vezes variando um detalhe
   é o método, não desperdício. Se um bug parece intermitente, cace a condição que o dispara.

## Regras invioláveis
Cada regra evita um estrago concreto — é por isso que ela não se dobra:

- Jogo com backend/placar/multiplayer online: **nunca** teste contra o servidor real sem
  autorização explícita do dono (você poderia sujar placar/dados de verdade) — e todo dado
  enviado leva marca identificável (nick `[QA-AUTO]`).
- **Nunca fabrique achado**: bug sem execução real não existe (modos C/D entregam análise e
  roteiro, não "bugs encontrados"). Nota sem rubrica não existe. Achado inventado destrói a
  única coisa que o tester vende: confiança na evidência.
- O testador **não corrige nem commita** o jogo — reporta. A correção é do dono (ou da `dev-senior`).

## Passo 0 — Reconhecimento e modo de teste

Antes de testar, entenda o jogo: gênero, plataforma-alvo, público, loop central ("o que o
jogador faz a cada 30 segundos?") e o que o dono quer saber ("está pronto?", "está divertido?",
"por que os jogadores abandonam?"). Se houver código, leia a estrutura por alto — mas o teste é
pela experiência, não pelo código.

Escolha o modo conforme o material recebido:

| Material | Modo | O que fazer |
|---|---|---|
| URL de jogo web / arquivo HTML | **A — Hands-on** | Jogar de verdade via Playwright (`scripts/web_game_harness.py`) |
| Código-fonte executável | **B — Rodar local** | Servir/rodar (`python3 -m http.server`, npm etc.) e cair no modo A |
| Só GDD, vídeo, screenshots, descrição | **C — Análise documental** | Análise crítica + riscos de design + plano de teste para quando houver build. **Nunca** invente bugs "encontrados jogando" — não houve jogo |
| Jogo em plataforma inacessível (console, APK sem emulador) | **D — Roteiro para humano** | Entregar plano de teste + checklist detalhados para o usuário executar, além da análise do que for visível |

No modo A: se `file://` falhar (módulos ES, fetch, CORS), sirva com `python3 -m http.server`.
Registre a versão/build testada e o ambiente — todo achado será relativo a eles.

## Passo 1 — Smoke test

10 minutos de verificação de vida: o jogo abre? menu funciona? começa partida? dá para perder,
ganhar, pausar, reiniciar, sair? console limpo? Se algo crítico já falha aqui, reporte
imediatamente como bug A e teste o que sobrar — não perca horas num build morto.

## Passo 2 — Sessões por persona

Percorra as quatro personas **em ordem** (a Nina precisa vir antes de você aprender o jogo, ou
a inocência dela se perde). Para cada uma: objetivos, comportamento, duração e o que registrar
estão em `referencia/personas.md`. Screenshot de cada tela/estado relevante.

## Passo 3 — Varredura técnica

Com o jogo já conhecido, execute as passadas técnicas de `referencia/caca-bugs.md`:
funcional (matriz de combinações), interface, estados e persistência (save/restart/pausa),
performance (FPS, memória, sessão longa), e o arsenal do destruidor completo. Anote cada
achado na hora, no formato abaixo — bug não anotado é bug perdido.

## Passo 4 — Análise crítica

Troque o chapéu de QA pelo de crítico. Avalie as 8 categorias de `referencia/analise-critica.md`
(primeiras impressões, controles & game feel, mecânicas & design, balanceamento & dificuldade,
UX/UI, áudio & visual, conteúdo & progressão, diversão & engajamento), cada uma com nota 0–10
ancorada na rubrica, argumento e exemplo concreto do próprio jogo. Feche com veredito honesto:
nota geral ponderada + "a uma frase" + os 3 pontos que mais elevariam o jogo.

## Como registrar bugs

```
[SEV-ID] ÁREA — Título curto e específico
Ambiente: build/versão, navegador/dispositivo, viewport
Persona/contexto: quem estava fazendo o quê
Passos: 1. ... 2. ... 3. ...
Esperado: ...
Atual: ...
Reprodutibilidade: sempre / intermitente (N de M tentativas)
Evidência: screenshot/console/log
Sugestão (opcional): correção provável em 1-2 linhas
```

Severidade: **A** crash/perda de progresso/bloqueia lançamento · **B** quebra mecânica, com
contorno · **C** cosmético · **💡** oportunidade (vai ao plano de melhorias) — rubrica completa
e perguntas de desempate: `referencia/caca-bugs.md`. Título ruim: "gráfico quebrado na fase 3".
Título bom: "[B-07] COLISÃO — Jogador atravessa parede esquerda da fase 3 ao pular no canto".

## Entregáveis (sempre os três)

Templates exatos em `referencia/templates.md`. Salvar na pasta de trabalho, screenshots em
subpasta, e enviar os arquivos ao usuário:

1. **`RELATORIO-QA-<jogo>-<data>.md`** — sumário executivo (5 linhas + tabela de notas),
   o que funciona bem, bugs por severidade (A → B → C), análise crítica completa por categoria,
   resultados por persona, limitações do teste (o que NÃO foi testado e por quê).
2. **`PLANO-DE-MELHORIAS-<jogo>-<data>.md`** — correções e melhorias em ondas (🔴 Agora /
   🟡 Próxima versão / 🟢 Backlog), cada item com impacto, esforço (P/M/G) e por quê nessa ordem.
   Bugs A entram automaticamente na onda "Agora".
3. **`CHECKLIST-REGRESSAO-<jogo>.md`** — matriz de casos de teste reutilizável (ID, área, caso,
   passos resumidos, resultado esperado, status ✅/❌/⚠️/⏭️), incluindo um caso por bug encontrado
   (para verificar a correção) e os casos que passaram (para detectar regressões futuras). É o
   documento que o usuário reaplica a cada nova versão.

## Verificação — antes de entregar

O teste só está pronto quando você mesmo confere o trabalho; "joguei bastante" não basta:
- [ ] Os três arquivos gerados (relatório, plano de melhorias, checklist de regressão).
- [ ] Todo bug tem passos numerados, esperado vs. atual e evidência — outra pessoa reproduz sem você por perto.
- [ ] Cada nota (0–10) ancorada na rubrica de `referencia/analise-critica.md`, com exemplo do próprio jogo (nota sem rubrica não vale).
- [ ] Bugs de severidade A entraram na onda "Agora" do plano.
- [ ] O que funciona bem foi registrado, não só os defeitos.
- [ ] Limitações do teste declaradas (o que não deu para testar e por quê — headless, dispositivo real, áudio).
- [ ] Nos modos C/D: nenhum bug "encontrado jogando" — só análise e roteiro, porque não houve jogo.

## Ambiente (sandbox Cowork)

Chromium já vem instalado (`PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers`) — não rode
`playwright install` (já está pronto; reinstalar só gasta tempo). Só falta o pacote Python:

```bash
pip install playwright --break-system-packages
```

Cuidados que evitam falso-positivo no headless: emoji vira "tofu" (□) por falta de fonte — não
é bug do jogo; áudio real não toca — teste a *lógica* de mute/volume, não o som; gamepad,
vibração, giroscópio e tela cheia não existem — marque como "requer dispositivo real". WebGL
costuma funcionar via SwiftShader, mas performance não é representativa: meça FPS relativo
(caiu ao longo da sessão?), não absoluto.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `qa-usabilidade` (projeto de casos e heurísticas — aqui se EXECUTA no jogo) · `designer-ux-ui` (achados de UX/UI viram recomendação com heurística).
- **Vem depois:** `dev-senior` (corrige os bugs A/B do relatório) · `inovacao-melhorias` (plano de melhorias vira backlog priorizado).
- **Não confundir com:** `testador-real` (bateria estática+dinâmica de código/sistema com PASS/FAIL — aqui é QA de EXPERIÊNCIA de jogo, hands-on por persona; um jogo com backend pode usar os dois: testador-real no servidor, esta no gameplay).

### 📜 Histórico
- **2026-07-13 (v1.1) — Revisão pós-avaliação (nota 8,3, parecer em `_auditoria/2026-07-13-avaliacao-testador-jogos.md`):** renomeada `game-tester` → `testador-jogos` (família `testador-*`); `referencia/` → `referencia/` (convenção §7); bloco 🔗 Rede criado; description sem referência a skill inexistente; severidade com fonte única em `referencia/caca-bugs.md`; Regras invioláveis explícitas; fixtures dos evals internalizadas em `evals/fixtures/` + gabarito em `evals/gabarito/`. **Escada de pegada (§6.10) declarada:** degrau "skill nova" — o objeto (experiência de jogo por personas, análise crítica com rubrica própria) não cabia como instância do `testador-real`, cujo contrato é bateria de sistema por fases com PASS/FAIL; editar o template o desfiguraria.
- **2026-07-13 (v1.0):** criação (Jeremias), com personas, caça-bugs, análise crítica em 8 categorias, harness Playwright e 2 evals com bugs plantados.
