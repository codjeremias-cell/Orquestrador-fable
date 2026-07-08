# O cânone do design de dashboards de classe mundial

Este é o cérebro de designer da Skill. Ele responde *por que* uma escolha é boa, não só *qual*. Leia antes de desenhar; volte aqui na hora de escolher cada gráfico.

> A síntese vem de quem definiu o campo: **Edward Tufte** (data-ink, integridade gráfica), **Stephen Few** (*Information Dashboard Design* — o dashboard como tela única de monitoramento), e **Cole Nussbaumer Knaflic** (*Storytelling with Data* — contexto e foco). Os princípios abaixo são desses autores; aplique-os, não os cite no produto.

## Índice
1. [A pergunta antes do gráfico](#1-a-pergunta-antes-do-grafico)
2. [Os três arquétipos, em detalhe](#2-os-tres-arquetipos-em-detalhe)
3. [Hierarquia visual e o teste dos 5 segundos](#3-hierarquia-visual-e-o-teste-dos-5-segundos)
4. [Escolha de gráfico — guia de decisão](#4-escolha-de-grafico--guia-de-decisao)
5. [Design de KPI — contexto é tudo](#5-design-de-kpi--contexto-e-tudo)
6. [Cor — semântica, nunca decoração](#6-cor--semantica-nunca-decoracao)
7. [Decluttering — a razão dado-tinta](#7-decluttering--a-razao-dado-tinta)
8. [Galeria de anti-padrões](#8-galeria-de-anti-padroes)

---

## 1. A pergunta antes do gráfico

Todo elemento existe para responder a uma pergunta de negócio. Se você não consegue escrever a pergunta que um card responde, **o card não deveria existir**. Comece pela lista de perguntas (3–7), não pela lista de dados disponíveis. "Temos esse dado" nunca é razão para mostrar — só "alguém decide algo com ele" é.

O teste decisivo: para cada elemento, complete a frase *"Olhando isto, a pessoa decide ___"*. Não conseguiu? Corte ou junte.

## 2. Os três arquétipos, em detalhe

### Executivo / Estratégico
- **Mentalidade:** "está tudo bem? onde não está?" Relance de segundos.
- **Densidade:** baixa. 4–6 KPIs com contexto + 1–2 gráficos de tendência. Espaço em branco é aliado.
- **Horizonte:** semana/mês/trimestre; tendência > instantâneo.
- **Interação:** mínima. Talvez um filtro de período. A conclusão tem que saltar sem cliques.
- **"Bom" se:** em 5 segundos o diretor sabe se há um problema e qual área olhar.

### Operacional / Tempo real
- **Mentalidade:** "o que está acontecendo agora e o que exige ação?" Olho contínuo.
- **Densidade:** alta tolerada — é uma estação de trabalho, não um slide. Mas com hierarquia: o que exige ação tem que gritar.
- **Horizonte:** agora / próximas horas. Atualização automática + carimbo de frescor.
- **Interação:** alertas que mudam de cor/saltam; drill rápido para o item problemático.
- **"Bom" se:** o operador nota a anomalia antes de ela virar crise, sem caçar.

### Decisão / Analítico
- **Mentalidade:** "por que isto está assim, e o que muda se eu olhar por outro ângulo?"
- **Densidade:** média, mas **explorável** — filtro, recorte, comparação lado a lado.
- **Horizonte:** série temporal + comparação entre categorias.
- **Interação:** filtros (regional, tipo, período), drill-down, ordenação. O usuário conduz.
- **"Bom" se:** a pessoa consegue testar uma hipótese e sair com uma decisão fundamentada.

> Um mesmo assunto vira três dashboards diferentes conforme o público. Não tente servir os três na mesma tela — você acaba não servindo nenhum.

## 3. Hierarquia visual e o teste dos 5 segundos

O olho ocidental lê em Z / F: **topo-esquerda primeiro**. Coloque ali o que mais importa. Tamanho, peso e cor criam camadas de leitura — o número-herói grande, o rótulo pequeno e suave, o detalhe escondido no hover.

- **Pirâmide invertida:** o "e daí" no topo (KPIs, bandeira de estado), o "como chegamos" no meio (gráficos), o "detalhe" embaixo/sob demanda (tabelas, hover).
- **Agrupar por proximidade** (Gestalt): o que é relacionado fica junto e separado por espaço, não por borda. Espaço em branco separa melhor que linha.
- **Teste dos 5 segundos:** mostre o mockup por 5 s e pergunte "qual o estado da operação e onde está o problema?". Se a resposta não vier, a hierarquia falhou — não adiante cor, conserte a ordem e o tamanho.

## 4. Escolha de gráfico — guia de decisão

Escolha pela **pergunta**, não pela estética. Regra geral: a posição ao longo de um eixo comum é o canal mais preciso que o olho tem; comprimento vem em seguida; **ângulo e área (pizza, bolha, rosca) são os piores** — use só quando a precisão não importa.

| A pergunta é sobre… | Use | Evite |
|---|---|---|
| **Comparar** categorias (quanto cada um) | Barra (horizontal se rótulo longo), ordenada por valor | Pizza com >4 fatias; barra fora de ordem |
| **Tendência** no tempo | Linha (poucas séries) | Barra para série temporal longa |
| **Parte do todo** num instante | Barra empilhada/100% ou só os números; pizza **só** com 2–3 fatias | Pizza com muitas fatias; rosca decorativa |
| **Um número-chave** com contexto | **KPI tile** (número + meta + variação + sparkline) | Medidor/gauge (gasta espaço, lê mal) |
| **Distribuição** | Histograma / box plot | Pizza |
| **Relação** entre duas medidas | Dispersão (scatter) | Dois eixos Y no mesmo gráfico |
| **Lista priorizada / status item a item** | Tabela enxuta com chip de status + barra de dado | Gráfico quando a pessoa precisa do número exato |

Princípios que evitam 90% dos erros:
- **Barra começa em zero, sempre.** Truncar a base de barra mente sobre a proporção. (Linha pode não começar em zero se a variação for o ponto — mas sinalize.)
- **Ordene por valor**, não por ordem alfabética/aleatória — a ordem já conta a história.
- **Rotule direto** a série quando der, em vez de obrigar o olho a ir e voltar na legenda.
- **Menos séries:** mais de 4–5 linhas viram espaguete. Destaque uma, esmaeça o resto.
- **Pizza:** só para 2–3 fatias e quando "parte do todo" é literalmente a pergunta. Acima disso, barra ganha sempre.

## 5. Design de KPI — contexto é tudo

Um número sozinho é inútil: **42** é bom ou ruim? KPI de classe mundial sempre carrega contexto:

- **Comparação:** vs. meta, vs. período anterior, vs. mesmo dia da semana passada. A variação (Δ) com **direção** (▲▼) e **cor semântica** conta a história num relance.
- **Cuidado com a cor da variação:** "subiu" nem sempre é verde. Mais eventos de crise subindo é **ruim** → vermelho. A cor segue o *significado de negócio*, não o sinal do número.
- **Sparkline:** uma minilinha de tendência ao lado do número dá o "para onde vai" sem ocupar um gráfico inteiro.
- **Microcópia honesta:** "0 concluídas" e "sem dado" são coisas diferentes — diga qual é.
- **Hierarquia interna do card:** número-herói grande; rótulo pequeno e suave; contexto menor ainda. Três tamanhos, uma leitura.

## 6. Cor — semântica, nunca decoração

- **Cor carrega significado, não enfeite.** Verde/laranja/vermelho = estado (ok/atenção/crítico). Se duas coisas têm cores diferentes, o usuário **vai** procurar o porquê — não frustre isso com arco-íris.
- **Padrão de poucas cores:** uma família neutra para o "normal" e cor saturada só para o que merece atenção. Tela colorida demais não tem foco — tudo grita, nada grita.
- **Nunca codifique só por cor** (8% dos homens têm daltonismo): acompanhe com ícone, rótulo, posição ou forma. Vermelho + ▲ + "crítico" é robusto; só vermelho, não.
- **Contraste:** texto ≥ 4.5:1 (WCAG AA). Confira no claro **e** no escuro.
- No SIGCOT isso já é resolvido por tokens semânticos (`-sigo-success/warning/danger/info`) — ver `sigcot-stack.md`. Use o token pelo **significado**, nunca o hex.

## 7. Decluttering — a razão dado-tinta

Tufte: maximize a razão **dado-tinta**. Cada pixel deve carregar informação; o resto é ruído. Antes de entregar, remova o que não informa:

- Linhas de grade pesadas → suaves ou ausentes.
- Bordas de caixa em volta de tudo → espaço em branco no lugar.
- Efeito 3D, sombra, gradiente, textura decorativa → fora (distorcem e distraem).
- Legenda redundante → rótulo direto.
- Casas decimais que ninguém usa → arredonde (1.234.567 → 1,2 mi).
- Eixo com excesso de marcas → poucas, bem escolhidas.

A meta: se apagar um elemento não tira informação, ele era ruído.

## 8. Galeria de anti-padrões

O que faz um dashboard parecer amador (e por quê):

- **Vanity metrics** — número grande que não muda decisão nenhuma ("total histórico de SIs"). Bonito, inútil.
- **KPI sem contexto** — 42 sem meta nem comparação. Impossível saber se é bom.
- **Pizza com 8 fatias** — o olho não compara ângulos. Vira barra.
- **Eixo de barra truncado** — começa em 80 e a diferença parece 10×. Desonesto.
- **Dois eixos Y** — sugere correlação que pode não existir; quase sempre engana. Separe em dois gráficos.
- **Arco-íris** — cor sem significado. O usuário procura um padrão que não existe.
- **Mar de medidores/gauges** — ocupam muito, leem mal, raramente trazem contexto.
- **Sopa de KPIs** — 15 números do mesmo tamanho, sem hierarquia. Nada se destaca.
- **Dado velho sem aviso** — pior que não ter o dado: o tempo real que envelheceu em silêncio.
- **Decoração** — imagem de fundo, ícone gigante, moldura. Tinta sem dado.

Quando bater a dúvida "fica bonito mas…", confie no *mas*: provavelmente é um destes.
