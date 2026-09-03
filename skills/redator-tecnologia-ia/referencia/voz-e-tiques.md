# Voz do autor e tiques banidos (referência detalhada)

Documento de apoio da skill `redator-tecnologia-ia`. Carregado sob demanda
antes de redigir e na releitura do passo 5 do Fluxo. O resumo operacional
está no corpo do SKILL.md; aqui fica o detalhamento com o **porquê** de
cada item e a fronteira entre assinatura do autor e tique de AI-slop.

> **Fonte de verdade da voz:** `referencia/voz-do-autor-corpus.md` (3 textos
> reais). Em conflito entre uma regra abaixo e o corpus, **o corpus
> prevalece** — a regra é a destilação, o texto real é a evidência.

## Índice

1. Voz do autor (v2 — corpus real de 3 textos)
2. Voz e tiques banidos (anti-AI-slop — banir + substituto obrigatório)
3. Diagnóstico ampliado de prosa artificial (H1)
4. Fronteira "assinatura × tique"

---

## 1. Voz do autor (v2 — corpus real de 3 textos, 2026-07-20)

**Ler o corpus antes de redigir peça editorial** — o few-shot de voz
ensina mais que as regras. Exceções de formato: tutorial usa imperativo
instrucional em passos numerados; página de produto fala com o comprador.
No resto:

- **Neutro-profissional, assunto como sujeito.** Sem conversa dirigida ao
  leitor ("você já passou por isso") nem pergunta retórica vazia.
  **Permitido** (uso real do autor): convite de cenário pontual —
  "Imagine, por exemplo, que uma linha seja desligada."
- **Autor invisível no explicador/notícia; primeira pessoa comedida na
  opinião.** Análise/opinião admite "acredito que" e "nosso" inclusivo —
  o formato pede dono da tese (corpus, texto 2). Nunca "eu testei"-ego nem
  "a gente" informal.
- **Precisão com qualificador honesto.** "Tende a", "praticamente", "em
  grande parte", "pode" — nunca afirmação absoluta onde cabe nuance.
- **Conclusão primeiro, frase curta.** Parágrafo abre com a afirmação
  principal; frase passando de ~25 palavras é candidata a virar duas.
  Conectivos formais ("Entretanto", "Por isso", "portanto").
- **Fecho-síntese.** A peça fecha com a tese condensada em 1–2 frases
  curtas ("A teoria fornece o mapa. A prática ensina a percorrer o
  caminho."); próximo passo concreto quando o formato pedir. Nunca fecho
  vazio.
- **Português absoluto.** O corpus tem zero anglicismo — nem os
  consagrados. Termo em PT sempre que existir ("implantação",
  "funcionalidade", "unidade geradora"); inglês só nome próprio de
  produto/sigla sem tradução em uso (SIN, API). Definir na 1ª ocorrência.
- **Leveza pontual, nunca piada.** Sem exclamação de entusiasmo, sem
  adjetivo de marketing — o dado carrega o texto.
- **Assinaturas permitidas com parcimônia (1–2 por peça):** a elevação
  "não apenas X. Significa/Mas Y" como fecho de seção, e a tríade de
  ênfase ("segurança, continuidade e confiabilidade") — são marca do
  autor, não tique, desde que não virem muleta automática.

## 2. Voz e tiques banidos (anti-AI-slop — banir + substituto obrigatório)

- Abertura de cenário ("Em um mundo/cenário cada vez mais...") → abrir com
  o problema do leitor ou o fato novo.
- "não é apenas X, é Y" **como muleta automática** → afirmar direto.
  (Como fecho de elevação deliberado, 1–2 por peça, é assinatura do autor
  — ver Voz do autor.)
- Adjetivo de marketing sem número ao lado ("revolucionário", "robusto",
  "poderoso", "disruptivo") → remover, ou acompanhar de métrica/exemplo.
- Tríade **automática em toda frase** → variar o ritmo. (Tríade de ênfase
  no fecho é marca do autor — ver Voz do autor.)
- Travessão como conector de frase → vírgula, dois-pontos ou ponto.
  Máximo 1 travessão por parágrafo (aposto ou diálogo; em título, o
  travessão de contraste é aceitável — uso real do autor).
- "você não vai acreditar", "muda tudo", "game changer", "vamos mergulhar",
  "desvendar" → banidas, sem substituto: cortar.
- Fecho vazio ("Em resumo... o futuro é promissor") → fecho-síntese da
  tese em 1–2 frases (padrão do autor) ou próximo passo concreto quando o
  formato pedir.
- Clickbait, medo e urgência fabricados → a promessa do título é entregue
  no primeiro terço do texto; lacuna de curiosidade só quando o texto a
  resolve de verdade. (Fonte única da regra de atenção honesta — as outras
  seções do SKILL.md referenciam esta.)

## 3. Diagnóstico ampliado de prosa artificial (H1)

Use estas famílias como sinais combinados de revisão, nunca como detector
de autoria. Para cada sinal encontrado, preserve a informação e reescreva
o parágrafo em torno da afirmação concreta:

- **Importância inflada ou fonte sem rosto** — troque legado, “momento
  decisivo” e tendência grandiosa pelo fato verificável; atribua a fonte
  pelo nome ou retire a alegação sem lastro.
- **Profundidade decorativa** — gerúndio de análise rasa, verbo pomposo e
  frase que promete uma “verdade mais profunda” voltam a sujeito, verbo
  simples e consequência demonstrada.
- **Relação fabricada** — intervalo “de X a Y” precisa ser uma escala real;
  rotação de sinônimos para o mesmo sujeito volta a um nome estável;
  aberturas repetidas só permanecem quando criam ritmo deliberado.
- **Resíduo de chatbot ou de estrutura** — retire saudação, concordância,
  oferta de continuação e anúncio do próximo tópico; após um subtítulo, a
  primeira frase já acrescenta informação em vez de repetir o título.
- **Ressalvas empilhadas** — mantenha somente a incerteza sustentada pela
  fonte e necessária ao significado; ressalva que apenas conserta um
  exagero anterior dá lugar a uma afirmação calibrada.
- **Diário de versão no texto atual** — documentação, comentário e página
  corrente descrevem o comportamento vigente. Histórico de mudança fica
  em changelog, nota de versão ou guia de migração.
- **Dramatização fabricada** — sequência de fragmentos, aforismo de efeito
  e abertura de falsa espontaneidade voltam a uma frase que diga o ponto e
  a evidência. Uma frase curta de ênfase isolada continua legítima.
- **Debate inventado** — objeção sem interlocutor e alternativa que ninguém
  consideraria saem do texto; objeção nomeada, opção plausível e limite de
  segurança permanecem e recebem resposta completa.

### Guardas contra falso positivo

- O corpus real de Jeremias prevalece sobre esta taxonomia; padrão isolado
  não basta. Procure famílias acumuladas no mesmo trecho e julgue a função
  que cumprem.
- Texto técnico, jurídico ou factual permanece neutro. Preserve avisos de
  segurança, limites reais, correções, alternativas plausíveis e termos
  formais exigidos pelo gênero.
- A revisão preserva fatos, links, código, frontmatter e intenção. Se o
  corte muda uma proposição, reverta e aplique o contrato semântico de
  `confiabilidade-e-revisao.md`.
- Travessão não recebe proibição global: vale a regra local de uso
  controlado e, acima dela, a frequência observada no corpus real.

*Proveniência H1: `blader/humanizer` @ `e2e92e7b4b8229253ed5c8e81dc65463fdeddda5` (MIT), `SKILL.md`, SHA-256 `14fc8a965b6e0a8dc100ba4dffeab55cb94bbac112abbde7e014d5c15a35c202` — taxonomia e testes adaptados ao PT-BR; laudo `garimpo-lote-5-repositorios-2026-08-26.md` §H1.*

## 4. Fronteira "assinatura × tique"

Dois padrões são **assinatura do autor** em dose pequena e **tique de
AI-slop** em dose grande — a diferença é frequência e intenção, não a
forma em si:

- **"não apenas X, é/Significa Y"** — assinatura como fecho de elevação
  deliberado (1–2 por peça); tique quando vira muleta automática em vários
  parágrafos. Na dúvida, contar as ocorrências: acima de 2, cortar as
  excedentes.
- **Tríade de ênfase** ("segurança, continuidade e confiabilidade") —
  assinatura no fecho; tique quando aparece em quase toda frase. Variar o
  ritmo no corpo, reservar a tríade para o ponto de ênfase.

Regra prática: se o padrão está trabalhando a favor da tese num momento de
clímax, é assinatura; se está preenchendo espaço, é tique — corte.
