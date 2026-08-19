# Protocolo de depuração sistemática (dev-senior)

Carregue este arquivo quando estiver **depurando um bug**. O SKILL.md guarda só o princípio e o ponteiro; a mecânica completa vive aqui para não custar token em todo turno de codificação normal.

**Princípio:** fix sem investigar a causa-raiz é sintoma mascarado, não correção — cria dívida e recorrência.

**Cláusula de proporcionalidade:** o **passo 0** (premissa) vale para **todo bug reportado**, mesmo o de causa aparentemente óbvia; as fases 1–6 completas abaixo são obrigatórias **apenas quando** (i) a causa não é óbvia numa primeira leitura do erro, ou (ii) o sistema é multi-componente (várias camadas/serviços), ou (iii) uma tentativa de fix anterior já falhou. Para erro trivial e localizado (typo, import faltando, stack trace autoexplicativo), ler com atenção e confirmar a causa em uma frase já cumpre o espírito — não é preciso ritualizar as fases. Regra proporcional > regra cega (mesmo princípio de "não otimize prematuramente" aplicado ao processo, não só ao código).

**Passo 0 — para todo bug reportado:** antes de tratar como bug, confira **a alegação E a intenção** contra o código real — pode ser design intencional (não lacuna), ou a premissa do report não se sustenta; o report que *parece* óbvio é justamente o caso-alvo. **Leia a mensagem de erro inteira** (stack trace, linha, arquivo, código do erro) — com frequência a resposta está ali. Só então corrija.

---

## Fase 1 — Construa o laço de feedback

**Esta fase É o protocolo; o resto é mecânico.** Com um sinal passa/falha **apertado** — que fica vermelho *neste* bug — você acha a causa; bissecção, teste de hipótese e instrumentação apenas consomem esse sinal. Sem ele, olhar código não salva ninguém. Gaste esforço desproporcional aqui: seja agressivo, seja criativo, **recuse-se a desistir**.

### Escada de construção do laço (tente mais ou menos nesta ordem)

1. **Teste que falha** na costura que alcança o bug — unidade, integração ou ponta a ponta.
2. **Chamada curl / script HTTP** contra o servidor de desenvolvimento rodando.
3. **Invocação de CLI** com entrada de fixture, comparando a saída contra um snapshot bom conhecido.
4. **Script de browser headless** (Playwright/Puppeteer) que dirige a UI e afirma sobre DOM, console ou rede.
5. **Replay de trace capturado** — salve em disco uma requisição, payload ou log de evento real e reproduza-o pelo caminho de código isolado.
6. **Harness descartável** — suba o subconjunto mínimo do sistema (um serviço, dependências mockadas) que exercite o caminho do bug com uma chamada de função.
7. **Laço de propriedade / fuzz** — bug do tipo "às vezes sai errado": rode mil entradas aleatórias e procure o modo de falha.
8. **Harness de bissecção** — bug que apareceu entre dois estados conhecidos (commit, dataset, versão): automatize "suba no estado X, verifique, repita" até dar `git bisect run`.
9. **Laço diferencial** — mesma entrada na versão velha e na nova (ou em duas configs) e diff das saídas.
10. **Script HITL** — último recurso. Se um humano precisa clicar, dirija **ele** por um roteiro numerado, para o laço continuar estruturado, e traga a saída capturada de volta.

### Aperte o laço

Trate o laço como produto. Assim que tiver *um* laço, **aperte**:

- **Mais rápido?** Cacheie setup, pule inicialização não relacionada, estreite o escopo do teste.
- **Sinal mais afiado?** Afirme o **sintoma específico**, não "não estourou".
- **Mais determinístico?** Fixe o tempo, semeie o RNG, isole o sistema de arquivos, congele a rede.

Um laço instável de 30 segundos mal é melhor que nenhum; **um determinístico de 2 segundos é superpoder de depuração.**

### Bug não determinístico — a meta é a taxa, não o repro limpo

Não persiga reprodução perfeita: **suba a taxa de reprodução**. Rode o gatilho 100×, paralelize, adicione stress, estreite janelas de tempo, injete sleeps. Um bug que pisca em 50% das vezes é depurável; em 1%, não é — continue subindo a taxa até ficar depurável.

### Critério de conclusão da fase 1 — um laço apertado que fica vermelho

A fase 1 fecha quando você consegue **nomear um comando** — caminho de script, invocação de teste, um curl — que **já rodou pelo menos uma vez** (mostre a invocação e a saída) e que seja:

- [ ] **Capaz de ficar vermelho** — percorre o caminho de código do bug e afirma **o sintoma exato que o usuário relatou**, de modo a ficar vermelho agora e verde depois do fix. "Roda sem erro" não serve: ele precisa poder **pegar este bug**.
- [ ] **Determinístico** — mesmo veredito toda vez (bug instável: taxa de reprodução alta e fixada, conforme acima).
- [ ] **Rápido** — segundos, não minutos.
- [ ] **Executável pelo agente sozinho** — sem humano no meio, exceto pelo roteiro HITL do degrau 10.

**Pegou-se lendo código para montar teoria antes de esse comando existir? Pare** — pular direto para a hipótese é exatamente a falha que este protocolo previne. Sem comando capaz de vermelho, não há fase 2. *(É a RI-04 aplicada à depuração: a prova é a execução, não a intenção.)*

### Quando genuinamente não dá para construir o laço

Diga isso explicitamente e liste o que tentou. Peça: (a) acesso ao ambiente que reproduz, (b) um artefato capturado e **redigido** (HAR, dump de log, core dump, gravação de tela com marcação de tempo), ou (c) autorização para instrumentação temporária em produção. **Siga para hipótese só depois de ter o laço.**

> **Redija antes de mostrar.** Este protocolo faz você exibir comandos, saídas e artefatos capturados. Substitua todo segredo por `<REDIGIDO>` antes de colar; monte o laço contra variável de ambiente, para a credencial ficar no ambiente e fora do que você mostra; artefato capturado carrega cabeçalho de autenticação — cite só as linhas que carregam o sinal. Se a saída redigida não bastar para diagnosticar, diga isso e peça ao Jeremias.

---

## Fase 2 — Reproduza e minimize

Rode o laço. Veja-o ficar vermelho.

- [ ] O laço produz **o modo de falha que o usuário descreveu** — não uma falha vizinha que aparece junto. Bug errado = fix errado.
- [ ] A falha se repete entre execuções (ou, para bug instável, numa taxa alta o bastante para depurar contra ela).
- [ ] O sintoma exato está capturado (mensagem, saída errada, tempo medido) para as fases seguintes verificarem que o fix o resolve.

**Minimize.** Com o laço vermelho, encolha o repro até o **menor cenário que ainda fica vermelho**: corte entrada, chamador, config, dado e passo **um de cada vez**, re-rodando a cada corte. Fica só o que sustenta a falha.

Por que vale: repro mínimo encolhe o espaço de hipóteses da fase 3 (sobra menos peça móvel para suspeitar) e vira o teste de regressão limpo da fase 5.

**Pronto quando todo elemento restante é load-bearing** — remover qualquer um deles deixa o laço verde.

---

## Fase 3 — Hipóteses

Gere **3 a 5 hipóteses ranqueadas antes de testar qualquer uma** — gerar uma só ancora você na primeira ideia plausível.

Cada hipótese precisa ser **falsificável**: enuncie a predição que ela faz.

> Formato: *"Se `<X>` é a causa, então `<mudar Y>` faz o bug sumir / `<mudar Z>` o piora."*

Hipótese sem predição enunciável é palpite — descarte ou afie. Uma fonte de hipótese sempre barata: **o que mudou recentemente** (`git diff`, commits recentes, dependência nova, config diferente).

**Mostre a lista ranqueada ao Jeremias antes de testar.** Ele re-ranqueia de graça ("acabamos de subir uma mudança na 3") ou já eliminou alguma. Checkpoint barato, economia grande — sem bloquear: se ele não estiver por perto, siga com o seu ranking.

---

## Fase 4 — Instrumente

Cada sonda mapeia para uma predição específica da fase 3. **Mude uma variável por vez.**

Ordem de preferência de ferramenta:

1. **Debugger / inspeção em REPL**, se o ambiente permite. Um breakpoint vale dez logs.
2. **Logs dirigidos** nas fronteiras que distinguem as hipóteses.
3. Varredura do tipo "loga tudo e faz grep" fica fora.

**Marque todo log de depuração com um prefixo único**, por exemplo `[DEBUG-a4f2]`: a limpeza da fase 6 vira um grep só. Log marcado morre; log sem marca sobrevive na base.

**Ramo de performance.** Para regressão de desempenho, log costuma ser a ferramenta errada: estabeleça primeiro uma **medição de baseline** (harness de tempo, `performance.now()`, profiler, plano de query) e então bissecte. Meça primeiro, corrija depois.

**Sistema multi-componente:** instrumente **cada fronteira entre componentes** (o que entra, o que sai, se config/env propagou) e rode uma vez para ver ONDE quebra — só então investigue o componente específico.

---

## Fase 5 — Fix + teste de regressão

Escreva o teste de regressão **antes do fix** — desde que exista uma **costura correta** para ele.

Costura correta é aquela em que o teste exercita o **padrão real do bug como ele acontece no ponto de chamada**. Se a única costura disponível é rasa demais (teste de um chamador só quando o bug precisa de vários; teste de unidade que não replica a cadeia que disparou a falha), o teste ali dá **falsa confiança**.

**Sem costura correta, a ausência dela É o achado.** Registre: a arquitetura está impedindo que o bug seja travado. Escale para o `arquiteto-software` (vocabulário de costura e módulo profundo em `arquiteto-software/referencia/modulo-profundo.md`) — e escale **depois** do fix entrar, quando você já sabe mais.

Havendo costura correta:

1. Transforme o repro minimizado num teste que falha naquela costura.
2. Veja-o falhar.
3. Aplique o fix.
4. Veja-o passar.
5. Re-rode o laço da fase 1 contra o cenário **original** (não minimizado).

---

## Fase 6 — Limpeza + post-mortem

Antes de declarar pronto:

- [ ] O repro original não reproduz mais (re-rode o laço da fase 1).
- [ ] O teste de regressão passa (ou a ausência de costura está registrada).
- [ ] Toda instrumentação `[DEBUG-...]` saiu (`grep` do prefixo).
- [ ] Protótipos descartáveis apagados (ou movidos para local claramente marcado).
- [ ] A hipótese que se confirmou está escrita no commit/PR — quem depurar depois aprende com ela.

**Então pergunte: o que teria evitado este bug?** Se a resposta envolve mudança estrutural (sem costura boa, chamadores emaranhados, acoplamento escondido), leve o caso ao `arquiteto-software` com as especificidades — e faça a recomendação **depois** do fix, nunca antes: agora você tem informação que não tinha no começo.

---

## Guard e Regra dos Três (travas de série)

**Guard declarado em correção em série:** ao corrigir uma sequência de bugs/erros (zerar uma lista de falhas, não um fix isolado), declare **antes da primeira correção** o **Guard** — o comando que não pode quebrar (ex.: `mvn -B test`, `tsc --noEmit`) — e rode-o **a cada correção**, não só no fim. Métrica de erros caiu mas o Guard falhou = a "correção" quebrou outra coisa; desfaça antes de seguir. É a versão manual do invariante do modo métrica do `orquestrador-fable` (`referencia/modo-metrica.md`).

**Regra dos Três (escada única com a proporcionalidade acima):** o contador conta **fix implementado que não resolveu** — hipótese formada e descartada na investigação é o método científico saudável, não conta. **1** fix falho ⇒ protocolo completo obrigatório (item iii da cláusula de proporcionalidade); **3** fixes implementados falhos ⇒ **pare — o problema não é a hipótese, é o modelo mental ou a arquitetura**: questione a abordagem (com o `arquiteto-software` se estrutural) em vez de tentar a 4ª. Par do Guard: o Guard pega correção que quebra outra coisa; a Regra dos Três pega a série que não converge. (O contador **zera** após o "pare" e a revisão do modelo mental — a nova abordagem recomeça do zero.)

## Proveniências (datas)

- Protocolo inspirado em `systematic-debugging` do `obra/superpowers` (proposta 2026-07-07; avaliado pelo `auditor-responsabilidades`, 7/10 — a cláusula de proporcionalidade é a ressalva dele, já incorporada).
- Passo 0, laço vermelho-verde e Regra dos Três: garimpo hermes-agent P7 (2026-07-12).
- Guard declarado: garimpo autoresearch P2 (2026-07-10).
- **Fases 1–6 (2026-08-06, garimpo mattpocock G2, de `diagnosing-bugs`):** escada de 10 formas de construir o laço; "aperte o laço" e o laço determinístico de 2 s; taxa de reprodução como meta em bug instável; critério de conclusão da fase 1 com comando já executado; fase de minimização até todo elemento ser load-bearing; 3–5 hipóteses ranqueadas e falsificáveis mostradas antes do teste; marcação `[DEBUG-xxxx]`; ramo de performance (medir antes); "ausência de costura correta é o achado"; post-mortem "o que teria evitado", feito depois do fix; seção Redija. A cláusula de proporcionalidade, o Passo 0, o Guard e a Regra dos Três são desta casa e **não** têm equivalente na fonte — ficaram.
