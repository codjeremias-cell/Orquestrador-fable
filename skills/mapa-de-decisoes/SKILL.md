---
name: mapa-de-decisoes
description: "Conduz trabalho grande demais para uma sessão e ainda enevoado como um MAPA de bilhetes de decisão: nomeia o destino, cria só os bilhetes cuja pergunta já dá para enunciar, declara o resto como névoa, e resolve um por sessão. Produz DECISÕES, não entregas. Acione com \"isso é grande demais, nem sei por onde começar\", \"não dá pra especificar ainda\", \"me ajuda a enxergar o caminho\", \"quais decisões eu preciso tomar antes de começar?\", \"esse projeto não cabe numa sessão só\", \"por onde eu começo isso?\", \"tem coisa demais aberta aqui\", \"a gente decide isso agora ou depois?\", \"o que trava o quê nessa campanha?\", \"isso vai levar semanas, como organizo?\", \"não sei nem quais são as perguntas ainda\". NÃO acione para ideia que fecha numa sessão (use requisitos-descoberta), para conduzir o projeto inteiro etapa a etapa (spec-projeto-completo), nem para guardar status de tarefa (estado-projeto)."
---

# Mapa de Decisões (cartografia de trabalho nebuloso)

Chegou uma ideia grande **e enevoada**: o caminho daqui até o destino ainda não está visível. Cartografar é achar o caminho, não correr para o destino. Esta skill desenha o caminho como um **mapa** e resolve os **bilhetes de decisão** dele — um de cada vez — até não sobrar o que decidir.

## Fronteira — por que esta skill existe separada

| Pergunta | Skill |
|---|---|
| O que construir e por quê, e **dá para fechar nesta sessão**? | `requisitos-descoberta` (satura e entrega o escopo) |
| Quais decisões existem, e **quais eu ainda nem consigo enunciar**? | **`mapa-de-decisoes` ← você está aqui** |
| Onde cada tarefa está agora? | `estado-projeto` |
| Como conduzir o projeto inteiro pelas etapas conhecidas? | `spec-projeto-completo` |
| Como executar com qualidade máxima e julgamento? | `orquestrador-fable` |

O corte é a **saturação**: a `requisitos-descoberta` fecha quando as rodadas saturam (RO-15). Quando a saturação **não é alcançável** — porque metade das perguntas depende de respostas que ainda não existem —, é aqui. E na direção oposta: quando o mapa clareia, ele **entrega e sai** — não constrói.

## Planeje, não faça

Cada bilhete resolve **uma decisão**. O mapa fecha quando não resta nada a decidir antes de alguém ir executar.

**A vontade de já fazer o trabalho é o sinal de que você chegou na borda do mapa** — é hora de handoff, não de execução. O handoff natural é a `requisitos-descoberta` (as decisões viram escopo) ou o `spec-projeto-completo` (o escopo vira projeto conduzido). Um esforço pode declarar exceção nas **Notas** do mapa e carregar execução para dentro dele; sem essa declaração, produza decisões.

## Onde o mapa mora (adaptação da casa)

- **O mapa** é um documento `estado/mapa-<slug>.md` na raiz do projeto — descubra o caminho real em runtime.
- **Cada bilhete** é uma tarefa no `estado.json` da `estado-projeto`, com a aresta `bloqueada_por` preenchida. Assim o mapa herda de graça o enum de status, a gravação segura e a view `TAREFAS.md`, em vez de inventar um segundo registro de estado — que seria duas fontes da verdade para a mesma pergunta.
- **A fronteira** — os bilhetes abertos, sem bloqueio pendente e não reivindicados — é o que se pode pegar agora.

### Corpo do mapa

```markdown
## Destino
<o que significa chegar ao fim deste mapa — a spec, a decisão ou a mudança que este esforço está procurando. Uma ou duas linhas; toda sessão se orienta por ele antes de escolher bilhete.>

## Notas
<domínio; skills que toda sessão deve consultar; preferências fixas deste esforço; exceção de execução, se houver>

## Decisões até agora
<!-- o índice: uma linha por bilhete fechado — o suficiente para julgar relevância; o detalhe fica no bilhete -->
- [<título do bilhete fechado>](ponteiro) — <resumo da resposta em uma linha>

## Ainda não especificado
<!-- a névoa: o que está dentro do escopo mas ainda não dá para enunciar como pergunta -->

## Fora de escopo
<!-- o que foi conscientemente posto além do destino; fechado, nunca gradua -->
```

**O mapa é índice, não depósito.** A decisão mora em exatamente um lugar — o bilhete dela. O mapa resume e aponta; nunca repete o conteúdo. Bilhete aberto **não** aparece no corpo do mapa: ele é achado por consulta ao estado.

## O bilhete de decisão

Corpo do bilhete = **a pergunta**, dimensionada para caber numa sessão. A resposta não nasce no corpo: ela é registrada na resolução. Artefato produzido enquanto se resolve (protótipo, relatório de pesquisa) é **apontado** pelo bilhete, não colado dentro dele.

Todo bilhete carrega um **tipo**, e cada tipo tem um dono:

| Tipo | Quem conduz | Quando é este |
|---|---|---|
| **Pesquisa** | Agente sozinho (AFK), em subagente | A decisão espera um **fato** que está fora deste diretório: documentação, API de terceiro, base de conhecimento |
| **Protótipo** | Com o Jeremias (HITL) | "Como deve parecer / como deve se comportar" é a pergunta-chave → suba a fidelidade com artefato concreto e barato (regras do descartável em `arquiteto-software`) |
| **Sabatina** | Com o Jeremias (HITL) | **O caso padrão.** Conversa. Rode `requisitos-descoberta` (rodadas e fronteira) e mantenha o glossário vivo (`docs-projeto` + `arquiteto-software`) |
| **Tarefa** | Agente sozinho, ou checklist preciso para o Jeremias | Trabalho manual que **destrava** uma decisão: assinar um serviço para poder julgar a API, provisionar acesso, mover dado para ver o formato. É o único tipo que *faz* em vez de decidir, e se justifica por desbloquear |

**Bilhete HITL só fecha na troca viva com o Jeremias.** Um agente de sabatina que responde as próprias perguntas quebrou a regra e produziu uma decisão de mentira — a resolução dele é inválida, não "provisória".

## Névoa de guerra

O mapa é **deliberadamente incompleto**: carte o que enxerga. Além dos bilhetes vivos fica a **névoa** — as decisões e investigações que dá para sentir chegando, mas que ainda dependem de perguntas abertas. Resolver um bilhete dissipa a névoa à frente dele, e o que ficou enunciável **gradua** em bilhete novo.

**Teste névoa × bilhete — o único que importa: você consegue ENUNCIAR a pergunta com precisão agora?** (Não: "consegue respondê-la agora?")

- **Bilhete** quando a pergunta já está afiada — mesmo bloqueada, mesmo sem poder agir nela hoje.
- **Ainda não especificado** quando ainda não dá para enunciar assim. Escreva a suspeita e a área a revisitar, tão solta quanto a vista permitir.

**Deixe a névoa grossa.** Uma mancha de névoa pode graduar em vários bilhetes, ou em nenhum — pré-fatiá-la em pedaços do tamanho de bilhete inventa perguntas que a realidade ainda não fez.

A seção **Ainda não especificado** exclui o que já foi decidido, o que já é bilhete vivo e o que está fora de escopo.

## Fora de escopo ≠ névoa

Névoa só se junta **em direção ao destino**. O destino fixa o escopo; trabalho além dele é **fora de escopo** — e o que o coloca ali é o escopo, não a falta de nitidez.

Fora de escopo **nunca gradua**. Volta apenas se o destino for redesenhado, e aí como esforço novo, não como retomada.

Bilhete que já existe e se revela além do destino: **feche-o** (bilhete fechado está inequivocamente fora da fronteira) e deixe uma linha em **Fora de escopo** com o resumo, o motivo e o ponteiro. Ele fica fora de **Decisões até agora**, que registra o caminho efetivamente andado — fronteira de escopo não é passo do caminho.

## Modo 1 — Cartografar

O Jeremias chega com a ideia solta.

1. **Nomeie o destino.** Rode uma sabatina (`requisitos-descoberta`, rodadas e fronteira) para fixar o que este mapa está procurando: a spec, a decisão, a mudança. O destino fixa o escopo, então fecha primeiro. *Conclusão: o destino cabe em duas linhas e o Jeremias confirmou.*
2. **Mapeie a fronteira, em largura.** Sabatine de novo, agora **espalhando** pelo espaço inteiro em vez de aprofundar num fio: quais decisões estão abertas e quais dão para atacar já. **Nenhuma névoa apareceu?** Então o caminho já está claro e a jornada cabe numa sessão — **você não precisa de mapa**: pare e diga isso ao Jeremias.
3. **Crie o mapa** com Destino e Notas preenchidos, Decisões até agora vazio e a névoa esboçada em Ainda não especificado.
4. **Crie os bilhetes que dá para especificar** como tarefas no `estado.json`; depois, **numa segunda passada**, ligue as arestas `bloqueada_por` (um bilhete precisa existir para ser referenciado). O que não dá para especificar **fica na névoa**. *Conclusão: todo bilhete criado tem tipo e aresta de bloqueio resolvida; toda mancha de névoa está escrita.*
5. **Dispare as pesquisas.** Para cada bilhete de tipo pesquisa, suba um subagente em paralelo, com o resultado gravado em arquivo e apontado pelo bilhete.
6. **Pare.** Cartografar é o trabalho de uma sessão; ela não resolve bilhete à mão.

## Modo 2 — Trabalhar o mapa

O Jeremias chega com um mapa (e talvez com um bilhete escolhido).

1. **Carregue o mapa** — a visão de baixa resolução, sem abrir o corpo de todo bilhete.
2. **Escolha o bilhete.** Ele nomeou um? Use. Senão, pegue o primeiro da fronteira. **Reivindique antes de qualquer trabalho** (dono na tarefa + status `pesquisando`/`planejando`), para uma sessão paralela não pegar o mesmo — bilhete aberto e sem dono está livre, e é assim que duas frentes colidem.
3. **Resolva, com zoom sob demanda:** puxe o corpo inteiro de bilhetes relacionados ou fechados quando precisar; invoque as skills que as Notas mandam. Na dúvida, sabatina + glossário.
4. **Registre a resolução:** a resposta no bilhete, status `concluida`, e **uma linha nova** em Decisões até agora com o ponteiro.
5. **Atualize o mapa:** crie os bilhetes que a resposta tornou enunciáveis (criar → ligar arestas), **apague da névoa** cada mancha que graduou (ela passa a viver só como bilhete), e se a resposta revelou que algo está além do destino, **ponha fora de escopo** em vez de resolver. Decisão que invalida outros bilhetes: atualize ou apague os afetados.

**Uma resolução por sessão** (pesquisa é a exceção: várias podem correr em paralelo). Bilhete grande demais para uma sessão é bilhete mal cortado — divida.

## Guardrails

- **Chame pelo nome, nunca pelo número.** Em tudo que o Jeremias lê, o bilhete aparece pelo título; o número e o caminho viajam **dentro** do nome, como ponteiro. Uma parede de `#42, #43, #44` é ilegível.
- **Decisão mora em um lugar só.** O mapa resume e aponta; repetir a decisão no mapa cria a segunda cópia que envelhece.
- **Névoa não é preguiça, e bilhete não é adivinhação.** Enunciável vira bilhete no mesmo ato; inenunciável fica escrito como névoa, com a área a revisitar.
- **Sem destino, não há mapa.** Cartografar antes de o destino estar em duas linhas produz bilhete que ninguém sabe se está dentro do escopo.
- **RO-01:** fato que sustenta uma decisão vem de fonte real (código, documentação, medição) ou entra declarado como suposição no bilhete.

## Formato de entrega

- **Ao cartografar:** o arquivo `estado/mapa-<slug>.md` criado, os bilhetes no `estado.json` com tipo e arestas, a névoa escrita, e um resumo em uma tela — destino, quantos bilhetes na fronteira, quantos bloqueados, quantas manchas de névoa.
- **Ao trabalhar:** a resolução gravada no bilhete, a linha nova em Decisões até agora, os bilhetes graduados da névoa e o que mudou de escopo.
- **Evidência (RI-04):** a decisão está registrada e o `TAREFAS.md` regenerado — mapa que só existe na conversa não é entrega.

## Verificação (antes de fechar a sessão)

- [ ] **O destino está escrito e orientou as escolhas?** Sem ele, escopo é opinião.
- [ ] **Todo bilhete criado passa no teste da pergunta enunciável?** Se não passa, ele é névoa, não bilhete.
- [ ] **Toda mancha de névoa graduada saiu da seção Ainda não especificado?** Duplicata entre névoa e bilhete é a divergência começando.
- [ ] **Todo bilhete tem tipo e as arestas de bloqueio resolvidas?** Sem aresta, não existe fronteira, e sem fronteira o paralelismo colide.
- [ ] **Bilhete HITL foi resolvido com o Jeremias de verdade?** Resposta que o agente deu por ele é decisão inválida.
- [ ] **No máximo um bilhete não-pesquisa resolvido nesta sessão?**
- [ ] **O mapa continua índice** — cada decisão em um lugar só, com ponteiro?

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (bilhete de decisão estrutural vira ADR pelo teste dos três critérios) · `inovacao-melhorias` (hipótese e corte do que vale investigar) · `consultor-negocios-apps` (quando o destino tem lado comercial).
- **Vem antes:** nada — esta é a porta para o esforço nebuloso; se ele **não** for nebuloso, a porta é `requisitos-descoberta`.
- **Vem depois:** `requisitos-descoberta` (as decisões viram escopo e MVP) · `spec-projeto-completo` (o escopo vira projeto conduzido) · `estado-projeto` (guarda os bilhetes e as arestas o tempo todo).
- **Não confundir com:** `estado-projeto` (guarda **onde cada tarefa está**; aqui se descobre **quais decisões existem e quais ainda não dá para enunciar**) · `spec-projeto-completo` (conduz as etapas **conhecidas**; aqui elas ainda não são conhecíveis) · `orquestrador-fable` (executa e julga com nota; aqui não se executa).

---

### Regras de Ouro compartilhadas
- Comunicação em PT-BR; código e identificadores em inglês.
- **RO-01:** nunca inventar API, método, biblioteca, número ou fato — pedir a fonte real ou declarar a suposição de forma explícita.
- **RO-15:** descoberta roda até saturar e **declara** a saturação — aqui a saturação é do *bilhete*, não do mapa; o mapa fecha quando a névoa acaba.
- Princípios comuns: clareza acima de esperteza · tudo é trade-off · comece simples · humildade técnica ("não sei → pergunto").

### 📜 Histórico
- **2026-08-06 — Criação (garimpo `mattpocock/skills`, N1; degrau da escada de pegada §6.10: 3 — skill nova).** Adaptada de `skills/engineering/wayfinder/` (`github.com/mattpocock/skills` @ `6acc160`, MIT, Matt Pocock — repo auditado limpo arquivo a arquivo). Pepitas que só existem aqui e justificaram o degrau 3: planeje-não-faça (a vontade de executar é o sinal da borda do mapa), névoa de guerra com o teste "consegue enunciar a pergunta?" (não "responder"), a proibição de pré-fatiar a névoa, fora-de-escopo que nunca gradua, os quatro tipos de bilhete com a divisão HITL × AFK, uma resolução por sessão com reivindicação prévia, e chamar pelo nome nunca pelo número. **Por que os degraus 1 e 2 não bastaram:** `requisitos-descoberta` fecha por saturação numa sessão e o caso aqui é a saturação inalcançável; `spec-projeto-completo` já conhece as etapas, e este mapa existe antes de elas serem conhecíveis; `estado-projeto` guarda onde a tarefa está e fundir violaria a fronteira da família, normativa e citada em quatro skills. **Adaptação da casa:** o rastreador de issues deles virou o par `estado/mapa-<slug>.md` + tarefas no `estado.json` com a aresta `bloqueada_por` (criada no mesmo garimpo, G11), evitando um segundo registro de estado. Relatório completo em `garimpo-mattpocock-2026-08-06.md`.
