# Módulo profundo — vocabulário de forma de interface (arquiteto-software)

Carregue este arquivo quando o assunto for **a forma de um módulo**: onde colocar a costura, quanto a interface deve expor, por que um pedaço do código é difícil de testar, ou quando outra lente pedir este vocabulário. O SKILL.md guarda o princípio e o ponteiro; a mecânica mora aqui.

**O alvo:** muito comportamento atrás de uma interface pequena, numa costura limpa, testável por essa interface. O que se ganha é **alavancagem** para quem chama, **localidade** para quem mantém e testabilidade para todo mundo.

## Glossário — use estes termos exatos

Consistência de linguagem é o mecanismo inteiro; termo trocado no meio derruba o ganho (é o modo de falha 5 do `PADRAO-DE-AUTORIA` §12).

**Módulo** — qualquer coisa com interface e implementação. Deliberadamente **agnóstico de escala**: uma função, uma classe, um pacote, uma fatia que atravessa camadas. *Prefira a "módulo":* unidade, componente, serviço.

**Interface** — **tudo** que quem chama precisa saber para usar corretamente: a assinatura de tipo, e também invariantes, restrição de ordem, modos de erro, configuração exigida e características de desempenho. *Prefira a "interface":* API, assinatura — as duas são estreitas demais, falam só da superfície de tipo.

**Implementação** — o que está dentro do módulo, o corpo do código. Distinta de **adaptador**: uma coisa pode ser adaptador pequeno com implementação grande (um repositório PostgreSQL) ou adaptador grande com implementação pequena (um fake em memória). Diga "adaptador" quando o assunto é a costura; "implementação" no resto.

**Profundidade** — alavancagem na interface: **quanto comportamento quem chama (ou o teste) consegue exercitar por unidade de interface que precisou aprender**. Módulo é **profundo** quando muito comportamento fica atrás de uma interface pequena; **raso** quando a interface é quase tão complexa quanto a implementação.

**Costura (*seam*, de Michael Feathers)** — lugar onde dá para **alterar o comportamento sem editar naquele lugar**; é a *localização* onde a interface do módulo mora. **Onde colocar a costura é uma decisão de projeto separada de o que fica atrás dela.** *Prefira a "costura":* fronteira — sobrecarregada com o bounded context do DDD.

**Adaptador** — coisa concreta que satisfaz uma interface numa costura. Descreve o **papel** (que vaga preenche), não a substância (o que tem dentro).

**Alavancagem** — o que quem chama ganha com profundidade: mais capacidade por unidade de interface aprendida. Uma implementação se paga em N pontos de chamada e M testes.

**Localidade** — o que quem mantém ganha com profundidade: mudança, bug, conhecimento e verificação se concentram num lugar em vez de se espalharem pelos chamadores. Corrige uma vez, corrigido em todo lugar.

## Profundo × raso

```
Módulo PROFUNDO                      Módulo RASO (a evitar)
┌────────────────────┐               ┌──────────────────────────────┐
│  Interface pequena │               │      Interface grande        │
├────────────────────┤               ├──────────────────────────────┤
│                    │               │  Implementação fina          │
│   Implementação    │               │  (só repassa a bola)         │
│   profunda         │               └──────────────────────────────┘
│                    │
└────────────────────┘
```

Ao desenhar uma interface, pergunte: dá para reduzir o número de métodos? dá para simplificar os parâmetros? dá para esconder mais complexidade lá dentro?

## Princípios

- **Profundidade é propriedade da interface, não da implementação.** Um módulo profundo pode ser composto internamente de partes pequenas, mockáveis e trocáveis — elas só não fazem parte da interface. Um módulo tem **costuras internas** (privadas à implementação, usadas pelos testes dele) além da **costura externa** na interface.
- **Teste da deleção.** Imagine apagar o módulo. A complexidade **some**? Era passagem de bola. A complexidade **reaparece em N chamadores**? Estava pagando aluguel. Aplique-o a todo módulo que você suspeita ser raso — "reaparece em N" é o sinal que você procura.
- **A interface é a superfície de teste.** Quem chama e quem testa cruzam a mesma costura. Querer testar **além** da interface é sinal de que o módulo está com a forma errada.
- **Um adaptador é costura hipotética; dois adaptadores são costura real.** Só introduza costura quando alguma coisa de fato varia através dela.

## Desenhando para testabilidade

1. **Receba dependências, não as crie.** `processaPedido(pedido, gateway)` é testável; `processaPedido(pedido)` que instancia `new StripeGateway()` por dentro, não.
2. **Devolva resultado em vez de produzir efeito colateral.** `calculaDesconto(carrinho): Desconto` é testável; `aplicaDesconto(carrinho): void` que muda `carrinho.total` por dentro, não.
3. **Superfície pequena.** Menos métodos = menos testes necessários; menos parâmetros = setup de teste mais simples.

## Como os termos se ligam

- Um **módulo** tem exatamente uma **interface** (a superfície que apresenta a chamadores e testes).
- **Profundidade** é propriedade de um **módulo**, medida contra a **interface** dele.
- Uma **costura** é onde a **interface** de um **módulo** mora.
- Um **adaptador** fica numa **costura** e satisfaz a **interface**.
- **Profundidade** produz **alavancagem** para quem chama e **localidade** para quem mantém.

## Framings rejeitados (e por quê)

- **Profundidade como razão linhas-de-implementação ÷ linhas-de-interface** (Ousterhout): **premia inchar a implementação** — quanto mais código dentro, melhor o número, o que é o incentivo errado. Aqui profundidade é **alavancagem**.
- **"Interface" como a palavra-chave `interface` da linguagem, ou os métodos públicos de uma classe**: estreito demais — aqui interface inclui todo fato que quem chama precisa saber (invariante, ordem, erro, config, desempenho).
- **"Fronteira"**: sobrecarregada com o bounded context do DDD, que esta lente também usa. Diga **costura** ou **interface**.

## Quem consome este vocabulário

- **`dev-senior`** — "só teste em costura pré-acordada"; e, na depuração, "ausência de costura correta É o achado" (`dev-senior/referencia/protocolo-depuracao.md`, fase 5).
- **`inovacao-melhorias`** — as oportunidades de aprofundamento saem do teste da deleção aplicado aos *hot spots* do `git log`.
- **`qa-usabilidade`** — costura acordada define onde o caso de teste mora.

## Proveniência

2026-08-06, garimpo `mattpocock/skills` G3, de `skills/engineering/codebase-design/` (MIT, Matt Pocock). Lacuna confirmada por busca antes de absorver: `seam`, `módulo profundo`, `Ousterhout` e `teste da deleção` não apareciam em nenhuma das 57 skills do catálogo. Traduzido para PT-BR com os termos fixados acima; a rejeição do framing de razão é da fonte e foi mantida porque é a parte que muda comportamento.
