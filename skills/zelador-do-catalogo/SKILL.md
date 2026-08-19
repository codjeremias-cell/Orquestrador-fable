---
name: zelador-do-catalogo
description: "Mede a saúde do próprio acervo de skills em três modos: CUSTO (contexto permanente por componente, com cortes ranqueados), INVENTÁRIO (manter, melhorar, aposentar ou fundir, com motivo autossuficiente) e OBEDIÊNCIA (a skill é seguida com prompt neutro?). Também antes de adicionar skill nova, para saber se há espaço. Acione com \"audita o catálogo\", \"quanto isso custa de contexto?\", \"quais skills estão obsoletas?\", \"essa skill está sendo obedecida?\", \"tem skill duplicada aqui?\", \"o que dá pra aposentar?\", \"minha janela de contexto tá pesada\", \"o catálogo tá inchado?\", \"quantos tokens as descriptions comem?\", \"essa skill ainda serve?\", \"dá pra fundir essas duas?\", \"a skill dispara sozinha?\", \"o agente seguiu a skill até o fim?\". NÃO acione para auditar UMA entrega ou o processo de um trabalho (use auditor-responsabilidades), para propor melhoria de produto (inovacao-melhorias), nem para validar estrutura de arquivo — isso é o validar-skills.ps1, que este chama."
---

# Zelador do Catálogo (saúde do acervo de skills)

O catálogo é um sistema que envelhece: skill nova entra, skill velha fica, description cresce, e **ninguém mede**. Esta skill é o instrumento — e mede três coisas diferentes, que falham de formas diferentes:

| Modo | A pergunta | O que a falha parece |
|---|---|---|
| **Custo** | Quanto contexto permanente o acervo consome? | Sessão pesada, qualidade caindo sem causa aparente |
| **Inventário** | O que manter, melhorar, atualizar, aposentar ou fundir? | Duas skills fazendo a mesma coisa; skill citando ferramenta que não existe mais |
| **Obediência** | A skill é seguida quando o prompt não ajuda? | Skill linda no papel que nunca dispara, ou que o agente contorna na primeira pressa |

**Trava obrigatória:** um modo por rodada, declarado no começo. Rodar os três de uma vez produz um relatório que ninguém lê e nenhuma ação executada. Se o Jeremias não disser qual, **pergunte** — e na dúvida entre custo e inventário, comece pelo custo (é o mais barato e costuma explicar o resto).

## Fronteira

- **`auditor-responsabilidades`** audita **uma entrega e o processo dela**. Aqui o objeto auditado é **o acervo**.
- **`inovacao-melhorias`** propõe **a próxima melhoria**. Aqui se **mede o estado atual** — a medição vira o insumo dela.
- **`validar-skills.ps1`** valida **estrutura** (frontmatter, índice, metadata, `agents/openai.yaml`). É determinístico e complementar: o modo inventário **chama** o validador antes de julgar conteúdo, porque skill estruturalmente quebrada não merece julgamento de mérito.
- **`painel-de-juizes`** dá **nota comparando** artefatos. Aqui não se compara skill com skill para eleger vencedora; classifica-se cada uma contra a própria utilidade.
- **`departamento-evolucao-skills`** (vertente empresa) é o dono equivalente **sob `EXECUTIVE_MISSION` do `ceo-maestro`**. Este é o instrumento do regime avulso; quando a entrega precisar de contrato e juízo independente, o regime é aquele.

## Regra que vale nos três modos — peça FATO, não autoavaliação

Nenhum veredito desta skill sai de "parece bom". Todo item julgado carrega o **fato que o sustenta**: o número medido, o caminho aberto, o trecho citado, a saída colada. Redação e portão de três estágios: `auditor-responsabilidades`. E **motivo autossuficiente**, sempre — quem ler só aquela linha decide sem abrir mais nada:

- ❌ "Superada" · ✅ "superada pela seção X da skill Y, que cobre os mesmos casos mais a borda Z; não resta conteúdo único"
- ❌ "Longa demais" · ✅ "276 linhas; a seção W (L80–140) duplica a skill V; cortar leva a ~150"
- ❌ "Sem mudanças" (para item não alterado) · ✅ restate a evidência que sustentou o veredito original

---

## Modo 1 — CUSTO (quanto o acervo pesa em toda sessão)

**O que se mede:** o que é carregado **em todo turno**, dispare ou não. É a "carga de contexto" do [[PADRAO-DE-AUTORIA]] §4.

### Passos

1. **Inventarie as fontes de carga permanente**, cada uma com o seu número:
   - `description` + `when_to_use` de cada `SKILL.md` do catálogo (**a maior fonte, e a menos lembrada**)
   - `CLAUDE.md` e `AGENTS.md` da raiz e do projeto
   - Servidores MCP configurados: conte **ferramentas**, não servidores. ⚠️ **Confira antes se elas são diferidas** (`grep "deferred tools included"` no `--debug-file`): com carregamento diferido só o **nome** entra, e a estimativa de ~500 tokens de esquema por ferramenta **superestima ~19×** — medido em 2026-08-09: 19 ferramentas, fórmula 9.500, real **337–665**
   - Corpo de skill que é carregado por padrão em vez de ficar atrás de ponteiro
2. **Meça antes de converter. Só estime o que não dá para medir.** *(corrigido em 2026-08-09)*

   **A medição, e ela é barata:** o `usage` do `result` no `--output-format stream-json` devolve o tamanho **real** do prompt — `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`. Cada componente sai **por ablação de flag**, como diferença entre duas rodadas do mesmo prompt trivial:

   | Componente | Como isolar |
   |---|---|
   | MCP | `--strict-mcp-config --mcp-config '{"mcpServers":{}}'` |
   | skills de usuário + plugins | `--setting-sources project` |
   | orçamento da listagem | `--settings '{"skillListingBudgetFraction":0.02}'` |

   **Só então a fórmula**, para o que sobrou: prosa ≈ `palavras × 1,3`; arquivo com muito código ≈ `caracteres ÷ 4`. **Diga qual usou.** Número sem fórmula é chute com aparência de dado — e **fórmula onde havia medição disponível é chute com aparência de rigor**: em 2026-08-09 a fórmula do MCP errou por 19×, e quem a aplicasse teria "medido" 9.500 tokens que não existem.
3. **Classifique cada componente em três baldes**, e o balde é a ação:

   | Balde | Critério | Ação |
   |---|---|---|
   | **Sempre necessário** | citado no `CLAUDE.md`, sustenta gatilho ativo, ou casa com o tipo do projeto | fica |
   | **Às vezes** | específico de domínio/stack, sem citação no `CLAUDE.md` | candidato a carregamento sob demanda |
   | **Raramente** | sem gatilho real, conteúdo sobreposto, sem cliente | candidato a corte ou a ponteiro |

4. **Detecte os padrões de desperdício conhecidos:** description inflada além do ramo que ela abre (§4 — sinônimo que renomeia o mesmo ramo é ramo escrito duas vezes) · corpo pesado que devia estar em `referencia/` (§12.4, teste de revelação) · conteúdo duplicado entre skill e `CLAUDE.md` · servidor MCP embrulhando comando de CLI que já existe de graça.
5. **Relatório com economia ranqueada** — não uma lista de problemas, e sim os **três maiores cortes** com o número de cada um:

```
Relatório de custo — <data>
Carga permanente total: ~XX.XXX tokens (fórmula: palavras × 1,3)
  descriptions das N skills   ~XX.XXX
  CLAUDE.md + AGENTS.md        ~X.XXX
  ferramentas MCP (N)          ~XX.XXX

Três maiores cortes:
1. <ação concreta> → ~X.XXX tokens
2. <ação concreta> → ~X.XXX tokens
3. <ação concreta> → ~X.XXX tokens
```

**Critério de conclusão:** toda fonte de carga tem número **e fórmula**, todo componente está num balde, e existem pelo menos três cortes com economia estimada. Relatório sem ação ranqueada não fecha.

### 6. O teto — custo que vira ausência *(2026-08-08, garimpo cienciaedados R3)*

Os passos 1–5 medem **quanto pesa**. Falta o que muda o veredito: **existe um teto, e o que passa dele não fica caro — some.**

A listagem de skills injetada em todo turno tem orçamento governado por `skillListingBudgetFraction`: **o default é `0.01` (1% da janela), mas o que vale é o valor efetivo do `settings.json` — leia-o antes de calcular qualquer coisa.** Estourou, o runtime corta — e são **duas guilhotinas diferentes**:

| Guilhotina | Regra | Consequência |
|---|---|---|
| **Por entrada** | `description` + `when_to_use` juntos são truncados em **1.536 caracteres** | corta **pela cauda** |
| **Por orçamento** | estourou o total, o runtime **descarta a description inteira**, começando pelas skills **menos invocadas** | a skill vira **um nome sem semântica** na lista |

**A segunda é um laço de realimentação:** a skill pouco usada perde a description → fica sem palavra-chave para casar → é invocada menos ainda → é a primeira a ser cortada na próxima. Ela não morre; fica invisível.

**Não estime isto — o runtime entrega o número exato.** Estimar com fórmula o que existe medido é o modo 0 de falha (§12) com outra roupa:

```bash
claude --debug-file log.txt -p "ok" < /dev/null
grep -i "listing over budget" log.txt
```

Resposta real, colada aqui como linha de base do teto:

```
[WARN] Skill listing over budget: 79 skills, 73049 chars > 30000 budget
       — descriptions will be truncated.
```

Diagnóstico complementar: **`claude plugin details <plugin>`** devolve o inventário do plugin **e o custo em tokens por sessão que ele acrescenta** — é o único jeito de medir a fatia dos plugins direto, em vez de deduzi-la subtraindo o catálogo do total (foi o que a auditoria de 2026-08-08 teve de fazer). Ele reporta **aquele plugin**, não a listagem inteira: some por plugin, não confunda com o total. **`/doctor`** estima o custo da listagem e os maiores contribuintes; a linha *Skills* do **`/context`** informa o tamanho **depois** do orçamento aplicado — é o que o modelo de fato recebe.

**A listagem não é a única carga permanente — o `CLAUDE.md` também entra, e por duas portas** *(2026-08-09, garimpo 3repos G12-17)*. **Ancestral:** ao abrir a sessão, o runtime sobe da pasta atual até a raiz do disco e carrega **todo** `CLAUDE.md` que encontrar no caminho — isso entra **no arranque**, em todo turno, e `~/.claude/CLAUDE.md` entra sempre. **Descendente:** `CLAUDE.md` em subpasta **não** carrega no arranque; entra só quando o modelo lê arquivo daquela subpasta. Ao medir custo permanente, some os ancestrais; os descendentes são custo condicional.

A distinção não é detalhe: **é a mesma engrenagem do campo `paths` de skill** — nenhum dos dois carrega no arranque, e os dois entram quando um arquivo do escopo é tocado. Confundir as duas portas já produziu uma afirmação errada nesta casa, publicada e corrigida no mesmo dia.

**A consequência que muda a autoria, e é desconfortável:** o corte por entrada vem **pela cauda**, e o modelo de `description` do [[PADRAO-DE-AUTORIA]] §4 põe a fronteira *"NÃO acione para…"* **no fim**. A linha que impede disparo indevido é a primeira a morrer. Ao medir custo, **reporte isso como achado**, não como detalhe — e cruze com o nível **alheio** do Modo 3, que é onde o efeito aparece.

**Alavancas, em ordem de preço:**

| Alavanca | O que faz | Custo |
|---|---|---|
| `skillOverrides: "name-only"` | você escolhe quem perde a description, em vez de o runtime escolher pela frequência | **não é zero** — quem fica só com o nome perde o **disparo espontâneo** e passa a depender de invocação nominal; nos geradores de track, medidos disparando **direto por semântica**, isso quebra o caminho de entrada. É escolher **onde** o dano cai, não evitá-lo *(inventário 2026-08-10)* |
| Encurtar `description`, caso-chave primeiro | **acima do teto, devolve ZERO contexto** — muda quem sobrevive ao corte, não o custo | trabalho de autoria, e não é alavanca de custo |
| `skillListingBudgetFraction` (ex.: `0.02`) | dobra o orçamento | **carga permanente maior** — troca um problema por outro |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | teto fixo em caracteres | idem |
| **`paths` na skill** *(2026-08-18)* | **filtra por contexto**: a skill sai da listagem de arranque e volta quando um arquivo do escopo é tocado — em vez de escolher *quem* perde a semântica, escolhe *quando* cada uma aparece | **medido, e a metade boa quase não foi:** de **9 formas** de glob testadas nesta casa, **só `**` devolve** a skill quando o caminho casa. Errar o glob remove a skill e **não a traz de volta** — e o modo de falha é silencioso, igual ao do teto. Só vale para skill de escopo geográfico claro (track, stack, pasta); em lente universal, remove sem devolver |

> 🔄 **A inversão, medida em 2026-08-09.** Enquanto a listagem estourar o teto, ela é enviada
> **truncada até caber** — logo o custo permanente das skills **é o teto**, não o tamanho do acervo.
> Medido: a compressão de 65.379 → 44.140 caracteres (−32,5%) devolveu **zero token**; mudou só a
> taxa de truncamento, de 59% para 41%.
>
> **Só duas coisas devolvem contexto de verdade:** (a) **baixar** o teto — e não subi-lo, que é o
> instinto — ou (b) levar o acervo para **abaixo** do teto, cortando skills inteiras. Antes de
> propor compressão como economia, confira de que lado do teto você está.

**Critério de conclusão deste passo:** o aviso do runtime está **colado** no relatório (ou a declaração de que não houve aviso), com a razão `total ÷ orçamento`, e a proposta de `name-only` nomeia **quais** skills e por quê.

> **Linha de base desta casa — carga.** 2026-08-06: `description` + `when_to_use` das 57 skills somavam **60.223 caracteres**. **2026-08-08: 65.379 caracteres em 61 skills** — delta de **+5.156**, explicado pelas 4 skills novas; nenhuma description existente inchou. Toda medição futura compara contra o número mais recente e explica o delta; contagem que muda sem mudança declarada no acervo é achado, não ruído.
>
> **Linha de base — teto (2026-08-11).** O `~/.claude/settings.json` desta casa traz `skillListingBudgetFraction: 0.005` — **metade do default**. Efeito conferido contando a listagem de skills recebida numa sessão de 1M: das **61 skills do catálogo, 12 chegam com `description`; as outras 49 chegam só com o NOME**. Elas continuam invocáveis por nome — o que se perde é o **disparo espontâneo**, e é por isso que a alavanca `name-only` acima não custa zero.
>
> **Delta contra a linha de base anterior (2026-08-08), e a causa.** Naquela rodada a listagem completa somava **73.049 caracteres** (as 61 do catálogo mais 18 de plugins e bundled) contra orçamento de **30.000**: **59% cortado**, com o catálogo respondendo por **90%** da carga, média de **1.071 caracteres** por skill contra os **~440** que caberiam. O acervo não mudou — continuam 61. **O que mudou foi o teto, que foi baixado**, e baixar o teto é exatamente a alavanca que a inversão acima aponta como a única que devolve contexto: o preço dela aparece aqui, nas 49 sem semântica. Em janela menor que 1M o orçamento cai na mesma proporção e o corte piora — meça na janela em que a sessão vai rodar, não na maior que você tem.

---

## Modo 2 — INVENTÁRIO (o que fica, o que sai, o que funde)

**O que se mede:** utilidade e vigência de cada skill, uma a uma.

### Passos

1. **Rode o `validar-skills.ps1` primeiro.** Estrutura quebrada é achado próprio e bloqueia o julgamento de mérito daquela skill.
2. **Escolha o alcance e declare:** *varredura rápida* (só o que mudou desde a última rodada — compare por data de modificação contra o relatório anterior) ou *inventário completo*. **Salve resultado parcial a cada lote** e registre onde parou: inventário grande morre no meio, e recomeçar do zero é o que faz ele nunca acontecer.
3. **Julgue cada skill contra quatro dimensões**, com evidência citada em cada uma:
   - **Acionabilidade** — tem passo, comando ou exemplo que permite agir agora, ou é prosa?
   - **Ajuste de escopo** — nome, gatilho e conteúdo apontam para a mesma coisa?
   - **Unicidade** — o valor é substituível por outra skill, pelo `CLAUDE.md` ou pela memória?
   - **Vigência** — o que ela afirma sobre ferramenta, versão ou API ainda vale? **Confira quando houver nome de ferramenta ou flag** (RO-01: não julgue vigência de memória).
4. **Emita um dos cinco vereditos**, com o motivo autossuficiente:

   | Veredito | Quando |
   |---|---|
   | **Manter** | útil e vigente |
   | **Melhorar** | vale ficar, com mudança específica nomeada (que seção, que ação, tamanho-alvo) |
   | **Atualizar** | o que ela afirma envelheceu — diga o que mudou no mundo e a fonte |
   | **Aposentar** | (1) qual defeito específico **e** (2) o que cobre a mesma necessidade no lugar |
   | **Fundir em X** | nomeie o alvo **e** o que exatamente migra |

5. **Consolide com o Jeremias antes de qualquer remoção.** Aposentar e fundir **exigem "ok" explícito**, com o impacto declarado (quem depende, que índice cita, que fluxo quebra). Melhorar e atualizar viram proposta.

**Critério de conclusão:** toda skill do alcance declarado tem veredito **e** motivo autossuficiente; nenhuma remoção executada sem "ok"; o relatório diz **quantas** ficaram de fora do alcance e por quê.

**Julgamento cego:** a mesma régua vale para skill nossa, importada ou herdada. Origem não muda o critério — e "é nossa" não é evidência de utilidade.

---

## Modo 3 — OBEDIÊNCIA (a skill é seguida quando o prompt não ajuda?)

**O que se mede:** acionamento e aderência sob **três níveis de pressão**, conforme o [[PADRAO-DE-AUTORIA]] §11.7. É o modo mais caro e o único que responde "essa skill muda comportamento ou é decorativa?".

### Passos

1. **Derive o comportamento esperado do próprio `SKILL.md`** — a sequência de passos que o agente deveria executar, com os pontos observáveis (que ferramenta ele deve chamar, em que ordem, que artefato deve nascer). Se a skill não permite derivar isso, **esse é o primeiro achado**: skill sem comportamento observável não tem como ser medida nem cobrada.
2. **Gere quatro prompts** para o mesmo caso, e **em outra sessão** ou antes de afinar a description — senão você mede a description contra frases derivadas dela mesma (§11.6):

   | Nível | Como se escreve | Acerto |
   |---|---|---|
   | **Apoiador** | pede explicitamente o que a skill faz, com o vocabulário dela | acionar |
   | **Neutro** | descreve a tarefa sem citar a skill nem o jargão dela | acionar |
   | **Concorrente** | empurra contra ("é rapidinho, deixa o teste pra depois", "não precisa de tanto rigor agora") | acionar |
   | **Alheio** *(2026-08-08)* | descreve tarefa **vizinha**, que pertence a outra skill ou a nenhuma — escrita com o vocabulário que a fronteira "NÃO acione para" da §4 tenta afastar | **não** acionar |

   Os três primeiros medem a mesma direção: *dispara quando deveria?* O **alheio** mede a direção oposta — *fica quieta quando não é dela?* — e é o único que mede o risco da nossa própria prática de encher a `description` de sinônimos (§4, conflito declarado). Vizinho de verdade, não absurdo: "qual o clima em SP?" não testa nada; o caso da skill irmã, sim.

3. **Rode em sessão nova de verdade** (`claude -p`, que descobre as skills do zero) e **capture o traço**, não o relato. A skill se auto-relatar como seguida não é evidência — o que vale é a invocação visível e a sequência de chamadas.
4. **Classifique cada rodada:** `acionou` S/N · `aderiu` S/parcial/N (fronteiras no §11.5: `S` = zero contorno · `parcial` = contorno pontual com o fluxo ainda na skill · `N` = abandono) · **ordem** respeitada S/N — a ordem se confere de forma determinística, comparando a sequência capturada com a esperada do passo 1. **No nível alheio a leitura inverte:** `acionou N` é **acerto**, e só `acionou` e a fronteira entram na conta — `aderiu` e `ordem` não se aplicam e se marcam `n/a`. Ler a coluna do alheio como as outras três transforma quatro acertos em quatro falhas.
5. **Leia o resultado como defeito da skill, não do modelo.** Contorno é corpo confuso ou description fraca. E o padrão diagnóstico:

   | Falhou em… | O que isso diz |
   |---|---|
   | apoiador | a skill está quebrada, não fraca — conserte antes de medir o resto |
   | neutro | o gatilho não venceu a resposta direta (ver [[instrucao-vence-description]]: instrução no `CLAUDE.md` vence description) |
   | **concorrente** | a skill é **decorativa** — aparece quando não custa nada e some quando custa |
   | **alheio** *(2026-08-08)* | a `description` está **larga demais** e invade a vizinha. A correção é a fronteira "NÃO acione para" da §4, apontando a skill dona do caso — **não** cortar sinônimo, que é o que sustenta os 157/159 do nível neutro |

**Critério de conclusão:** os quatro níveis rodados em sessão nova, com traço capturado, e cada falha atribuída a uma causa nomeada no corpo ou na description. Rodada sem o nível concorrente é **rodada incompleta declarada** — é justamente o nível que separa skill de enfeite. Rodada sem o nível **alheio** mede só metade do gatilho: uma skill que dispara sempre passa nos outros três com nota cheia.

**Custo declarado:** este modo gasta sessões de verdade. Rode nas skills que importam (as que sustentam entrega, as que acabaram de mudar, as suspeitas), não no acervo inteiro por varredura.

---

## Guardrails

- **Um modo por rodada**, declarado. Relatório dos três juntos não é lido nem executado.
- **Nenhuma remoção sem "ok" do Jeremias**, com impacto declarado.
- **Estimativa é estimativa:** todo número de token vem com a fórmula. Nunca apresente estimativa como medição exata.
- **Declare o limite do próprio instrumento.** O modo custo mede o que é carregado, não o que é *útil*. O modo inventário mede a skill, não o resultado dela no mundo. O modo obediência mede os casos que você escreveu, não todos. Portão que não diz o que não cobre é lido como garantia que ele não dá.
- **RO-01:** vigência de ferramenta, versão ou API se **confere**, não se lembra.
- **Não canonize durante a medição.** Editar o acervo enquanto ele está sendo medido invalida o relatório — a lição já custou caro aqui. Congele o alvo ou serialize as frentes.

## Formato de entrega

Relatório datado em `_auditoria/` do catálogo, nomeado pelo modo (`zelador-custo-AAAA-MM-DD.md`, `zelador-inventario-...`, `zelador-obediencia-...`), contendo: **modo e alcance declarados** · a medição com fórmula/evidência · a tabela de vereditos ou de cortes ranqueados · **o que ficou fora do alcance e por quê** · as ações que dependem de "ok".

**Evidência (RI-04):** relatório sem número medido, sem caminho aberto ou sem traço capturado não é entrega — é impressão.

## Verificação (antes de fechar a rodada)

- [ ] **O modo foi declarado no início?** Rodada sem modo vira as três coisas pela metade.
- [ ] **Todo veredito tem motivo autossuficiente?** Quem ler a linha sozinha decide sem abrir mais nada.
- [ ] **Todo número tem fórmula ou fonte?** Sem isso é chute com cara de dado.
- [ ] **O alcance está declarado, inclusive o que ficou de fora?** Cobertura silenciosa é lida como cobertura total — é o defeito de [[busca-truncada-vira-falso-negativo]].
- [ ] **O delta contra a rodada anterior está explicado?** Contagem que muda sem causa declarada é achado.
- [ ] **Nenhuma remoção foi executada sem "ok" explícito?**
- [ ] **O limite do instrumento está escrito no relatório?**

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `auditor-responsabilidades` (a régua do fato forçado e do motivo autossuficiente é dele — fonte única) · `especialista-seguranca` (vetting de skill externa e varredura de primeira passada, em `referencia/seguranca-agentica.md`) · `inovacao-melhorias` (recebe a medição e propõe a ação).
- **Vem antes:** `validar-skills.ps1` no modo inventário (estrutura antes de mérito).
- **Vem depois:** `inovacao-melhorias` (a medição vira proposta com hipótese, métrica e rollback) · `memoria-de-projeto` (a lição durável do que a medição revelou).
- **Não confundir com:** `auditor-responsabilidades` (audita uma entrega — aqui, o acervo) · `painel-de-juizes` (compara artefatos e elege — aqui, classifica cada skill contra a própria utilidade) · `validar-skills.ps1` (estrutura — aqui, mérito, custo e obediência).

---

### Regras de Ouro compartilhadas
- Comunicação em PT-BR; código e identificadores em inglês.
- **RO-01:** nunca inventar número, versão ou estado de ferramenta — medir, abrir a fonte, ou declarar a suposição.
- **RI-04:** ausência de evidência permanece ausência; relatório é a prova, não o relato.
- Princípios comuns: clareza acima de esperteza · tudo é trade-off · comece simples · humildade técnica ("não sei → meço").

### 📜 Histórico
- **2026-08-18 — A quinta alavanca do teto: `paths`, filtro por contexto (T21, observação devolvida pelo garimpo `oh-my-opencode` 2026-08-18 · G9; degrau §6.10: 1 — só edição).** O mapa de alavancas do Modo 1 listava quatro e **omitia a única que muda a dimensão do problema**: as quatro escolhiam *quem* perde a description ou *quanto* cabe no orçamento; o `paths` escolhe **quando** a skill aparece — ela sai do arranque e volta ao tocar arquivo do escopo. O campo já era citado **duas vezes** nesta skill (L115 e no Histórico de 2026-08-09), mas só como *analogia de engrenagem* com o carregamento descendente do `CLAUDE.md` — nunca como alavanca de teto, que é onde ele decide. A observação veio de fora: a fonte garimpada filtra a listagem por agente no seu próprio encanamento, e o equivalente portável desta casa é o `paths`. **A ressalva entra junto com a alavanca, e é o que faz dela uma linha honesta:** medido nesta casa que de **9 formas de glob apenas `**` devolve** a skill quando o caminho casa — a metade "remove" foi medida com rigor e a metade "devolve" quase não foi, e é dela que a adoção dependia. Errar o glob produz remoção silenciosa, o mesmo modo de falha do teto. Guardrail declarado: só serve para skill de escopo geográfico claro (track, stack, pasta); em lente universal, remove sem devolver. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-11 — Linha de base do teto reposta, e o preço do `name-only` (inventário `_auditoria/zelador-inventario-2026-08-10.md`, ação ATUALIZAR 5; RI-04; degrau §6.10: 1 — só edição).** Três correções no passo 6 do Modo 1, todas conferidas antes de escrever: **(a)** o texto afirmava "orçamento de **1%** da janela" como se fosse fixo — 1% é o **default**; o `~/.claude/settings.json` desta casa está em `skillListingBudgetFraction: 0.005`, e agora a skill manda ler o valor efetivo antes de calcular. **(b)** A linha de base do teto ainda era a de 2026-08-08 (73.049 caracteres contra 30.000, 59% cortado); a vigente foi contada na listagem recebida numa sessão de 1M — **12 das 61 chegam com description, 49 chegam só com o nome**. O número antigo ficou como delta explicado, com a causa nomeada: o acervo não mudou (61 então, 61 agora), **o teto é que foi baixado**. **(c)** A alavanca `skillOverrides: "name-only"` custava "zero — só decisão"; é falso — ela troca description por nome, e quem perde a description perde o disparo espontâneo, o que nos geradores de track (medidos disparando direto por semântica) quebra o caminho de entrada. Passou a dizer que a alavanca escolhe **onde** o dano cai, não que ele não existe.
- **2026-08-09 — Medição por ablação substitui a fórmula, e a inversão do teto (rodada própria do Modo 1; degrau §6.10: 1 — só edição).** Três correções nascidas de executar o próprio modo 1 (`_auditoria/zelador-custo-2026-08-09.md`): **(a)** o passo 2 mandava converter por fórmula e afirmava que *"estimativa com fórmula declarada é medição"* — falso, e caro: a fórmula do MCP (~500 tokens de esquema × 19 ferramentas = 9.500) errou **19×** contra os **337–665** medidos, porque o runtime passou a **diferir** o carregamento e só o nome entra. Entrou a receita de **ablação por flag** lendo o `usage` da API, que mede em vez de estimar. **(b)** O passo 1 ganhou a checagem `deferred tools included` antes de contar ferramenta MCP. **(c)** A alavanca *"encurtar description"* passou de **devolve orçamento a todos** para **devolve zero acima do teto**: como a listagem é truncada até caber, o custo permanente **é o teto** — a compressão de 65.379 → 44.140 (−32,5%) devolveu **zero token**, mudando só a taxa de truncamento (59% → 41%). Só **baixar** o teto, ou levar o acervo para baixo dele, devolve contexto.
- **2026-08-09 — Carregamento ancestral × descendente do `CLAUDE.md` (garimpo 3repos 2026-08-08 · G12-17; degrau §6.10: 1 — só edição).** O Modo 1 media a listagem de skills e **não contava o `CLAUDE.md`** como carga permanente. Agora distingue ancestral (sobe até a raiz, entra no arranque) de descendente (só ao tocar arquivo da subpasta), e registra que é a mesma engrenagem do `paths` — o que explicou por que o `paths` foi refutado. Proveniência: `best-practice/claude-memory.md` de `github.com/shanraisshan/claude-code-best-practice` (MIT) — laudo em `garimpo-3repos-2026-08-08.md`.
- **2026-08-09 — `claude plugin details` no Modo 1 (garimpo 3repos 2026-08-08 · G12-2; degrau §6.10: 1 — só edição).** O Modo 1 media o custo do catálogo e **estimava o dos plugins por subtração**; agora aponta o comando que o reporta direto, com o guardrail de que ele mede um plugin e não a listagem. Proveniência: `best-practice/claude-settings.md` de `github.com/shanraisshan/claude-code-best-practice` (MIT) — laudo em `garimpo-3repos-2026-08-08.md`.
- **2026-08-08 — O teto (garimpo cienciaedados 2026-08-08 · R3; degrau §6.10: 1).** O Modo 1 media *quanto pesa* e não sabia que existe **um teto que corta**: a listagem de skills tem orçamento de **1% da janela**, e o que passa dele não fica caro — **some**. Entrou o passo 6 com as **duas guilhotinas** (por entrada, 1.536 caracteres cortados pela cauda; por orçamento, a description inteira descartada começando pelas skills **menos invocadas**), o **laço de realimentação** que isso cria, o **comando que arranca o fato do runtime** em vez de estimar por fórmula — que era o modo 0 de falha vestido de medição —, os diagnósticos `/doctor` e `/context`, e as quatro alavancas em ordem de preço. **Achado que muda a autoria:** o corte por entrada vem pela cauda e o modelo do [[PADRAO-DE-AUTORIA]] §4 põe a fronteira *"NÃO acione para"* no fim — **a linha que impede disparo indevido é a primeira a morrer**, e isso se cruza com o nível *alheio* do Modo 3, criado no mesmo dia. Linha de base do teto medida e colada: **73.049 caracteres contra orçamento de 30.000, 59% da listagem cortada**, com o catálogo respondendo por 90% da carga. Origem: documentação oficial da Anthropic (`code.claude.com/docs/en/skills`), aberta depois que um apêndice de engenharia reversa levantou a suspeita — **a doc primária confirmou e corrigiu o número**, e o aviso do runtime provou o fato.
- **2026-08-08 — 4º nível de pressão no Modo 3 (garimpo cienciaedados 2026-08-08 · G03c; degrau §6.10: 1 — edição de skill existente).** Entrou o nível **alheio**: prompt de tarefa vizinha em que o acerto é **não** disparar. Motivo: os três níveis herdados do ECC — apoiador, neutro, concorrente — medem todos a mesma direção (*dispara quando deveria?*), e uma `description` que dispara para tudo tirava nota cheia nos três. O nível novo mede o risco natural da prática de sinônimos declarada no §4, que tem evidência a favor (157/159 no neutro) mas cujo disparo indevido nunca tinha sido medido aqui. Vieram junto a inversão de leitura no passo 4 (`acionou N` é acerto; `aderiu` e `ordem` marcam `n/a`), a linha do diagnóstico (fronteira larga se corrige no "NÃO acione para" da §4, **não** cortando sinônimo) e o critério de conclusão. Fonte única atualizada no mesmo ato: [[PADRAO-DE-AUTORIA]] §11.7 passou de três para quatro níveis. Origem: guia oficial *The Complete Guide to Building Skills for Claude* (pág. 15 e 25–26), que lista "Doesn't trigger on unrelated topics" no teste de acionamento. **Cortada da mesma fonte, como contraindicada:** a técnica de perguntar ao modelo "quando você usaria a skill X?" — é o modo 0 de falha (autoavaliação no lugar de fato), e o passo 3 deste modo já manda capturar traço, não relato.
- **2026-08-06 — Criação (garimpo `affaan-m/ECC` v2.1.0, N2; degrau da escada de pegada §6.10: 3 — skill nova).** Une três skills da fonte num só dono: `context-budget` (modo custo), `skill-stocktake` (modo inventário, incluindo a regra do motivo autossuficiente) e `skill-comply` (modo obediência, incluindo os três níveis de pressão do prompt). MIT, Affaan Mustafa — repo auditado com profundidade declarada, absorção por leitura, nada instalado. **Por que os degraus 1 e 2 não bastaram:** o `auditor-responsabilidades` audita uma entrega e o seu processo, não o acervo; a `inovacao-melhorias` propõe a próxima melhoria e consome esta medição em vez de produzi-la; `referencia/` de skill existente só é lida por quem já foi acionado, e isto precisa de gatilho e cadência próprios; o `validar-skills.ps1` cobre estrutura e é chamado por aqui; e o `departamento-evolucao-skills` é o dono equivalente **na vertente empresa**, operando só sob `EXECUTIVE_MISSION` — não há instrumento no regime avulso, que é onde o catálogo é trabalhado no dia a dia. **Por que os três modos numa skill só:** respondem à mesma pergunta, agem sobre o mesmo alvo e produzem o mesmo tipo de artefato; três descriptions separadas custariam carga permanente — o que seria irônico, já que medi-la é o modo 1. Linha de base do modo custo (60.223 caracteres / ~15 mil tokens) medida em 2026-08-06 no garimpo `mattpocock/skills`. Relatório em `garimpo-ecc-2026-08-06.md`.
