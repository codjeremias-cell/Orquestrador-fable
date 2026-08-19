# Formatos de code review (dev-senior)

Carregue este arquivo quando o pedido for **revisar código já escrito** (não implementar do zero). São formatos de saída opcionais que aceleram a leitura — não substituem a postura da lente, só a apresentam de forma terminável.

## Formato rápido — revisão geral por severidade
Quando o pedido for revisar código existente, pode fechar com uma tabela enxuta em vez de só prosa:

| Categoria | Achado | Severidade |
|---|---|---|
| Correctness | ... | crítica/alta/média/baixa |
| Segurança | ... | ... |
| Desempenho | ... | ... |
| Estilo/Clean Code | ... | ... |
| Tipos | ... | ... |
| Testes | ... | ... |

## Variante caça-complexidade
Quando o pedido for especificamente cortar excesso ("está inchado?", "o que dá pra deletar?"), não revisão geral:

- **Formato:** 1 linha por achado, ranqueada do maior corte pro menor: `<arquivo>:L<início>-<fim>: <tag> <o quê>. <substituto>.` (escopo de arquivo único pode omitir o prefixo).
- **Tags:** `delete:` (código morto/especulativo — substituto: nada) · `stdlib:` (reinventou a biblioteca padrão — nomeie a função) · `native:` (dependência fazendo o que a plataforma já faz — nomeie o recurso) · `yagni:` (abstração de implementação única, camada com um chamador só) · `shrink:` (mesma lógica em menos linhas — mostre a forma curta; conta as linhas poupadas).
- **Fecho:** `net: -<N> linhas possíveis` — cada linha de código conta **uma vez**: achado contido em outro (um `delete:` dentro de bloco `yagni:`) **permanece listado**, mas não soma de novo — o corte maior absorve o menor. Nada a cortar: "Enxuto — nada a cortar."
- **Fronteira:** a lista é **só complexidade** — achado de correctness, segurança ou desempenho visto no caminho **abre a resposta ANTES da lista, com severidade** (formato da tabela normal); nunca vira rodapé nem se perde no ranking.

## Variante dois eixos — Padrões × Especificação

Use quando a revisão for de **um conjunto de mudanças contra um ponto fixo** (branch, PR, "revisa desde o commit X") e existir uma especificação, issue ou requisito de origem. É o formato mais forte porque cobre a falha que os outros dois não veem: **código impecável que implementa a coisa errada**.

**Os dois eixos, e por que ficam separados:**

- **Padrões** — o código obedece ao que este repositório documenta e às regras da casa?
- **Especificação** — o código faz fielmente o que a issue/spec/requisito pediu?

Uma mudança passa num e falha no outro o tempo todo: segue todo padrão e constrói outra coisa (**Padrões passa, Especificação falha**); faz exatamente o que a issue pediu e atropela as convenções do projeto (**Especificação passa, Padrões falha**). Reportar separado é o que impede um eixo de mascarar o outro.

**Mecânica:**

1. **Fixe o ponto de comparação.** Commit, branch, tag, `main`, `HEAD~5` — o que o Jeremias disser. Capture o comando uma vez (`git diff <ponto>...HEAD`, três pontos, para comparar contra o ancestral comum) e a lista de commits (`git log <ponto>..HEAD --oneline`). **Confirme que a referência resolve e que o diff não está vazio antes de seguir** — referência errada ou diff vazio falha aqui, e não dentro de dois subagentes.
2. **Ache a especificação de origem**, nesta ordem: referência de issue nas mensagens de commit → caminho que o Jeremias passou → documento de requisitos/spec sob `docs/` ou na pasta do projeto → perguntar. Sem especificação, o eixo Especificação **é declarado ausente**, não improvisado.
   > **A mensagem de commit tem um uso só, e não é este** *(2026-08-10, garimpo codex-security · H4)*. Ela serve para **achar a spec** — é o primeiro degrau da ordem acima. Ela **não** é evidência do que o código faz: é a alegação do autor sobre a própria mudança, e revisar por ela é revisar a intenção declarada em vez do diff. Nos dois eixos, a fonte é sempre o código mudado; a mensagem entra como ponteiro para a origem, nunca como prova. *(Não confundir com a resolução de conflito por intenção do `dev-senior`, onde a mensagem é lida de propósito como fonte primária da intenção — lá o objeto é a intenção; aqui é o comportamento.)*
3. **Rode os dois eixos em subagentes paralelos**, para um não contaminar o contexto do outro. Cada um recebe o comando de diff, a lista de commits, as suas fontes (padrões documentados + o baseline de smells abaixo; ou o texto da spec) e devolve no máximo ~400 palavras.
4. **Agregue sem reranquear.** Apresente sob `## Padrões` e `## Especificação`, e feche com uma linha: total de achados por eixo e o pior achado **dentro de cada eixo**. **Não eleja um vencedor entre eixos** — esse reranqueamento é exatamente o que a separação existe para impedir.

### Baseline de smells (Fowler, *Refactoring* cap. 3)

O eixo Padrões carrega este baseline **mesmo quando o repositório não documenta nada**. Duas regras o amarram: **o repositório sobrepõe** (padrão documentado do projeto sempre vence; onde ele endossa algo que o baseline reprovaria, o smell é suprimido) e **todo smell é julgamento** ("possível inveja de recurso"), nunca violação dura. Pule o que a ferramenta já pega sozinha (linter, formatador, análise estática).

Cada um se lê como *o que é → como corrigir*:

- **Nome misterioso** — função, variável ou tipo cujo nome não revela o que faz ou guarda. → renomeie; se nenhum nome honesto aparece, o projeto está turvo.
- **Código duplicado** — a mesma forma lógica em mais de um hunk ou arquivo da mudança. → extraia a forma comum e chame dos dois lados.
- **Inveja de recurso** — método que mexe mais nos dados de outro objeto do que nos próprios. → mova o método para junto dos dados que ele inveja.
- **Aglomerado de dados** — os mesmos poucos campos/parâmetros viajando sempre juntos (um tipo querendo nascer). → junte num tipo só e passe ele.
- **Obsessão por primitivo** — primitivo ou string fazendo o papel de um conceito de domínio que merece tipo próprio. → dê ao conceito o seu tipo pequeno.
- **Switch repetido** — o mesmo `switch`/cascata de `if` sobre o mesmo tipo reaparecendo na mudança. → polimorfismo, ou um mapa compartilhado pelos dois pontos.
- **Cirurgia com espingarda** — uma mudança lógica obriga a editar espalhado por muitos arquivos. → junte num módulo o que muda junto.
- **Mudança divergente** — um arquivo/módulo editado por vários motivos não relacionados. → separe, para cada módulo mudar por um motivo só.
- **Generalidade especulativa** — abstração, parâmetro ou gancho para necessidade que a spec não tem. → apague; volte a inlinear até uma necessidade real aparecer.
- **Cadeia de mensagens** — navegação longa `a.b().c().d()` da qual quem chama não devia depender. → esconda a caminhada atrás de um método do primeiro objeto.
- **Homem do meio** — classe ou função que quase só delega adiante. → corte, chame o alvo direto.
- **Herança recusada** — subclasse que ignora ou sobrescreve quase tudo que herda. → largue a herança, use composição.

## Proveniência
- Formato rápido de code review: proposta 2026-07-07, inspirado no checklist do Ruflo.
- Variante caça-complexidade: garimpo `DietrichGebert/ponytail` (MIT, auditado limpo), 2026-07-18.
- Variante dois eixos + baseline de smells: garimpo `mattpocock/skills` G5 (MIT, auditado limpo), 2026-08-06, de `skills/engineering/code-review/`. A regra "não reranqueie entre eixos" e o "repositório sobrepõe o baseline" são da fonte e foram mantidas por serem a parte que muda comportamento.
- A fronteira de uso da mensagem de commit no passo 2: garimpo `openai/codex-security` H4 (Apache-2.0, varrido limpo), 2026-08-10, de `finding-discovery/SKILL.md` §Hard Rules ("focus on the actual changes, not the commit message"). **Não entrou como proibição**, porque o passo 2 depende da mensagem de propósito: entrou como separação entre os dois usos. Laudo em `garimpo-codex-security-2026-08-10.md`, Rodada 2. **O que a rodada 2 NÃO mudou aqui, e é o resultado que importa:** a mecânica dos quatro passos foi confrontada com o pipeline de 5 fases da fonte e **saiu superior** — rodar os eixos em subagentes paralelos protege contra contaminação sem depender da disciplina de quem lê, e por isso a separação de fases deles foi cortada como já coberta.
