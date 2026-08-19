---
name: docs-projeto
description: "Cria ou atualiza a documentação de um projeto no nível certo para cada leitor: README, guia de instalação e execução, manual do usuário em PT-BR didático, documentação técnica com arquitetura e ADR, e CHANGELOG. Sempre a partir do código e do comportamento reais. Acione com \"escreve o README\", \"documenta o projeto\", \"faz o manual do usuário\", \"como instala isso?\", \"gera o changelog/notas da versão\", \"documenta essa decisão\", \"gera/monta a wiki do projeto\". NÃO acione para comentários dentro do código (dev-senior cuida no ato) nem para registrar preferências entre sessões (use memoria-de-projeto)."
---

# Documentação de Projeto (README, manual, técnica, changelog)

Você é a skill que faz o projeto **explicável**: para quem chega (README), para quem usa (manual), para quem mantém (técnica) e para quem acompanha (changelog). Cada documento tem um leitor-alvo — escrever para o leitor errado é o defeito nº 1 de documentação.

## Fronteira da família (docs × requisitos × estado × memória)

Quatro skills irmãs cobrem quatro perguntas diferentes — escolha pela **pergunta**, não pela palavra que apareceu:

- **requisitos-descoberta** → *o quê* construir e por quê (ideia → escopo/MVP), antes de qualquer código.
- **estado-projeto** → *onde cada tarefa está* agora: status retomável, progresso, próximo passo.
- **memoria-de-projeto** → *como* trabalhamos: preferências, decisões e lições duráveis entre sessões.
- **docs-projeto** → *como usar/manter* o produto pronto: README, manual, técnica, changelog. **← você está aqui.**

Regra de bolso: documentação descreve o **produto pronto para os leitores dele**; se o que você quer registrar é preferência de trabalho (memória), progresso de tarefa (estado) ou o que ainda vai ser construído (requisitos), não é aqui.

## Entradas obrigatórias

1. O projeto alvo e **qual documento** (ou o conjunto, ex.: "prepara para entrega").
2. O leitor-alvo quando ambíguo (usuário leigo? dev que vai manter? avaliador?).

## Trava obrigatória

- **Ler antes de escrever (RO-01):** documentação sai do código, da config e do comportamento **reais** — rodar/inspecionar antes de afirmar. Nunca documentar feature, flag ou passo de instalação sem confirmar que existe e funciona.
- Se já existe documento, **evoluir** (patch cirúrgico — RO-02), não recomeçar do zero sem pedido explícito.

## Leituras obrigatórias (RO-01)

1. `README`/docs existentes, `pom.xml`/`package.json` (nome, versão, dependências reais), scripts de build/run.
2. Para manual do usuário: as telas/fluxos reais (abrir o app ou ler FXML/templates) — nunca descrever tela de memória.
3. Para changelog: o histórico git real (`git log`) entre as versões.

## Convenções por documento

- **README:** o que é (1 parágrafo) · screenshot quando houver UI · requisitos · como rodar (comandos copiáveis testados) · como buildar/empacotar · estrutura de pastas em 1 nível · licença/autor. Curto: README é porta, não enciclopédia.
- **Manual do usuário:** PT-BR didático, orientado a **tarefas** ("Como lançar férias"), um passo por linha, com print de cada tela relevante (RO-06: o Jeremias e usuários processam visual). Incluir a seção "Problemas comuns" com erro → causa → solução. Borda: sem como abrir o app/tirar print na sessão → manual sai com passos textuais + placeholders de print marcados "[capturar: tela X]", declarado no relatório.
- **Documentação técnica:** visão de arquitetura (C4 nível contêiner em texto/diagrama) · decisões relevantes como **ADR** (herdar formato do `arquiteto-software`) · convenções do projeto (as RO do track aplicável) · como rodar os testes. Borda: projeto sem ADR/decisão registrada → derivar do código real, marcando "derivada do código, sem registro de decisão" — nunca inventar o porquê histórico.
- **CHANGELOG:** por versão, datado, agrupado em Adicionado/Corrigido/Alterado; linguagem de usuário, não de commit ("Tela de escala agora carrega 3× mais rápido", não "refactor DAO"). Borda: sem histórico git utilizável (repo novo, squash, import) → changelog inicial "a partir desta versão", declarando o limite.
- **GLOSSÁRIO (`GLOSSARIO.md` na raiz do projeto)** *(2026-08-06, garimpo mattpocock G10)* — **é glossário e nada mais.** Um termo por entrada: o nome canônico, o que ele significa no domínio deste projeto, e o que ele **não** é quando houver confusão real com um vizinho. Fica **livre de detalhe de implementação**: não é spec, não é rascunho, não é depósito de decisão técnica (decisão vai para ADR; preferência de trabalho vai para a memória). Leitor-alvo duplo — o Jeremias e o agente —, e é aí que ele se paga: com o glossário no lugar, *"tem um problema quando uma aula dentro de uma seção de um curso vira 'real', ganhando um lugar no sistema de arquivos"* vira *"tem um problema na cascata de materialização"*. Menos palavra por ideia, nome consistente em variável, função e arquivo, e o código fica mais navegável para quem chega. **Crie de forma preguiçosa** — o arquivo nasce quando o primeiro termo é resolvido, não antes — e **escreva o termo na hora em que ele é acordado**, sem represar para o fim da sessão. Quem **desafia** um termo (conflito com o glossário, palavra vaga, contradição com o código) é a lente `arquiteto-software`, dona da linguagem ubíqua; aqui é a mecânica do arquivo.
- Sem segredo/credencial em nenhum documento; caminhos e URLs como exemplo quando forem de máquina local.

## Fluxo

1. Confirmar documento(s) e leitor-alvo.
2. Ler as fontes reais (código, scripts, git, telas).
3. Escrever/atualizar com cabeçalho de caminho exato (RO-03).
4. **Testar o que o documento afirma:** cada comando de instalação/execução do README é executado antes de entrar (evidência — RI-04). O que não puder testar, marcar "não verificado".
5. Reportar arquivos e o que ficou pendente de print/confirmação.

## Modo wiki — base de conhecimento navegável

Para projeto grande, **só sob pedido explícito** ("gera a wiki" — wiki é investimento, não subproduto): gerar a pasta `wiki/` (index com ordem de leitura, arquitetura, uma página por módulo, glossário, onboarding), com todas as travas desta skill valendo (RO-01; apontar para as RO, não copiar). Mecânica completa — estados do manifesto, regras de retomada, padrões de varredura, divisão por cap: `referencia-modo-wiki-extraido.md`.

**As 5 salvaguardas de robustez (obrigatórias — o modo não roda sem elas):**

1. **Manifesto write-ahead:** `wiki/wiki-manifest.json` gravado antes de gerar; a retomada continua só das `pendente` — página apagada por humano nunca é regenerada sem perguntar.
2. **Proteção de colisão:** página sem `generated_by: docs-projeto` no frontmatter é de humano — pular com aviso (`pulada-humana` no manifesto), nunca sobrescrever.
3. **Varredura de segredo pós-geração:** varrer `wiki/` por credenciais; achado = substituir por placeholder e avisar citando página e linha.
4. **Caps de tamanho:** ~300 linhas/página, diagramas ≤15 nós; estourou = dividir em subpáginas no manifesto, nunca truncar em silêncio.
5. **Invalidação por deriva:** cada página `gerada` registra `cobre[]` + `hash` (`git hash-object`); hash diferente na corrida seguinte ⇒ status `desatualizada`, listada ao Jeremias e **nunca regenerada sozinha** — é pergunta, não veredito *(2026-08-18, garimpo oh-my-opencode · G2)*.

## Exemplo (entra → sai)

Entra: *"gera o changelog e confere o README"* num projeto pequeno com git real. Sai — bloco datado no `CHANGELOG.md`, gerado do `git log` entre as tags:

> **[1.2.0] — 2026-07-13**
> **Adicionado:** exportação da escala do mês em PDF (botão na tela de escala).
> **Corrigido:** salvar férias sem data fim não trava mais a tela.
> **Alterado:** o login agora lembra o último usuário.

E no relatório: `mvn -B verify` executado antes de entrar no README (verde) · passo "instalar no Windows 11" marcado **não verificado** (sem máquina Windows na sessão).

## Guardrails

- Nunca documentar o que não foi confirmado rodando/lendo (documentação que mente custa mais que a ausência dela).
- Não duplicar a fonte da verdade: convenções moram nas REGRAS-DE-OURO/skills — a doc técnica **aponta**, não copia.
- Manual sem print de tela com UI = incompleto por definição.

## Verificação final (o documento cobre?)

Para cada documento gerado, responda sim/não — e lembre **por quê** cada item importa; "parece pronto" é o modo como documentação passa a mentir:

- [ ] **Leitor certo?** README serve quem chega, manual quem usa, técnica quem mantém, changelog quem acompanha — escrever para o leitor errado é o defeito nº 1 desta skill.
- [ ] **Saiu do real?** Cada afirmação veio de código/config/git/tela **inspecionados** (RO-01), não de memória — feature, flag ou passo não confirmado não entra.
- [ ] **Comandos testados?** Todo comando de instalação/execução foi executado ou explicitamente marcado "não verificado".
- [ ] **UI tem print?** Manual de tela com UI traz print de cada tela relevante (ou placeholder "[capturar: tela X]" declarado) — sem isso é incompleto por definição.
- [ ] **Fonte de cada decisão/versão?** Changelog datado e com fonte (`git log` ou "a partir desta versão"); doc técnica com ADR ou marcada "derivada do código, sem registro de decisão".
- [ ] **Sem segredo/credencial** em nenhum documento (inclusive URLs/caminhos de máquina local como exemplo).
- [ ] **(modo wiki) Manifesto sem `pendente` restante** e sem página `pulada-humana` sobrescrita. Nenhuma página `gerada` com hash divergente por conferir — as `desatualizada` estão **listadas**, e listar é o fechamento: regenerar exige pedido.

Documento que não fecha o critério = **incompleto declarado**, não entregue como pronto.

## Saída esperada

- Documento(s) no repositório com comandos testados, prints onde há UI e nota do que ficou "não verificado".
- **Critério de conclusão checável, por documento:** README — todo comando executado ou marcado "não verificado" · manual — todo fluxo do escopo com passos + print (ou placeholder "[capturar: tela X]") · changelog — toda versão datada e com fonte (`git log` ou "a partir desta versão") · doc técnica — toda decisão citada tem fonte (ADR ou código) ou é marcada "derivada do código, sem registro de decisão" · **glossário — todo termo com significado no domínio deste projeto e zero detalhe de implementação** · modo wiki — manifesto sem `pendente` restante. Documento que não fecha o critério = incompleto declarado, não entregue como pronto.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (manual é interface: hierarquia, linguagem do usuário) · `dev-senior` (precisão técnica do que se afirma).
- **Vem antes:** o sistema pronto/estável (documentar o que ainda muda toda hora é retrabalho) · `arquiteto-software` (ADRs que a doc técnica consolida).
- **Vem depois:** `java-package-desktop` ou o release do track (o manual acompanha a distribuição) · `memoria-de-projeto` (decisões de doc viram costume).
- **Não confundir com:** `memoria-de-projeto` (contexto entre sessões) nem `estado-projeto` (progresso de tarefas) — aqui é documentação do produto para quem o lê (ver "Fronteira da família").

### 📜 Histórico

- **2026-08-18 — A wiki passa a saber que envelheceu (garimpo oh-my-opencode 2026-08-18 · G2; degrau §6.10: 1 — só edição).** O `wiki-manifest.json` rastreava **estado de escrita** (`pendente` → `gerada`) e não rastreava **deriva**: página `gerada` continuava `gerada` para sempre, mesmo depois de o módulo que ela descreve ser reescrito. Entrou a **Salvaguarda 5 — Invalidação por deriva**, reusando a receita que já existia em `testador-real/referencia-tecnicas-extraido.md` em vez de inventar mecanismo: cada entrada ganha `cobre[]` + `hash` (`git hash-object`), e hash divergente na corrida seguinte vira o status novo `desatualizada`. A página por módulo ganhou os dois campos que faltavam para servir a quem chega sem contexto — **fluxo de dados e de controle** e **pontos de integração**. Guardrails: `git hash-object` e **não** `sha256` do arquivo cru, porque o segundo muda com o fim de linha e produziria `desatualizada` em massa sem ninguém tocar em nada; `desatualizada` é **pergunta, não veredito**, e não se regenera sozinha (a Salvaguarda 2 já decidiu que sobrescrever pede decisão); e página sem `cobre` declara `cobre: []` **explicitamente**, para ausência de aviso não ser lida como garantia de frescor. Proveniência: `docs/codemap.md` de `github.com/alvinunreal/oh-my-opencode-slim` (MIT) — laudo em `garimpo-oh-my-opencode-2026-08-18.md`.
- **2026-08-06 — Garimpo `mattpocock/skills` (G10; degrau §6.10: 1 — só edição):** convenções ganharam o documento **GLOSSÁRIO** (`GLOSSARIO.md` na raiz) — glossário e nada mais, sem detalhe de implementação, criado de forma preguiçosa e escrito no ato em que o termo é acordado, com leitor-alvo duplo (Jeremias + agente) e o ganho de concisão como razão de existir. O critério de conclusão ganhou a linha do glossário. Quem **desafia** termo é a `arquiteto-software` (dona da linguagem ubíqua, fonte única da regra); aqui fica só a mecânica do arquivo — anti-duplicação §12.5. Proveniência: `skills/engineering/domain-modeling/` de `github.com/mattpocock/skills` @ `6acc160` (MIT) — relatório em `garimpo-mattpocock-2026-08-06.md`.
- **2026-07-20:** Adicionados o bloco "Fronteira da família" (docs × requisitos × estado × memória) no topo e a seção "Verificação final (o documento cobre?)" — checklist sim/não de leitor certo, saiu do real, comandos testados, print de UI, fonte de decisão/versão, sem segredo e manifesto de wiki, com o porquê de cada item; a "Saída esperada" e seu critério checável por documento foram mantidos intactos; conteúdo, exemplos e formatos preservados.
- **2026-07-13 — Evolução R4→R5 (onda 4, micro):** critério de conclusão checável completado com simetria — doc técnica (toda decisão citada tem fonte ADR/código ou é marcada "derivada do código, sem registro de decisão") e modo wiki (manifesto sem `pendente` restante); borda da doc técnica nas convenções (projeto sem ADR → derivar do código real declarando a ausência, nunca inventar o porquê histórico); −0/+1 linhas (84→85).
- **2026-07-13 — Evolução R3→R4 (onda 3, finos):** exemplo entra→sai completo e compacto (projeto pequeno → bloco de CHANGELOG datado de 4 linhas do git real + 1 comando testado + 1 "não verificado" de amostra); "Saída esperada" ganhou critério de conclusão checável por documento (README: todo comando testado ou marcado · manual: todo fluxo com passos + print/placeholder · changelog: toda versão datada com fonte); −0/+13 linhas (71→84).
- **2026-07-13 — Evolução R2→R3 (onda 2, pontuais):** bordas com dono nas convenções — changelog sem histórico git utilizável → changelog inicial "a partir desta versão" com o limite declarado; manual sem como abrir o app/tirar print na sessão → passos textuais + placeholders "[capturar: tela X]" declarados no relatório; −0/+1 linhas (70→71).
- **2026-07-13 — Evolução R1→R2 (onda transversal):** mecânica do modo wiki (manifesto write-ahead, colisão `generated_by`, varredura de segredo, caps) extraída para `referencia-modo-wiki-extraido.md`; no corpo ficaram o gatilho do modo + as 4 salvaguardas em 1 linha cada; proveniência do modo (2026-07-10, garimpo autoresearch P10) migrada do título para cá; −10/+13 linhas físicas (corpo 67→70, +3 só do Histórico novo; economia real de texto ~20 linhas, realocadas na referência).
