---
name: estado-projeto
description: "Mantém o estado das tarefas do projeto de forma persistente e retomável: um estado.json (estado-máquina, fonte única da verdade) e um TAREFAS.md (view legível regenerada dele), com transições de status controladas. Acione com \"onde a gente parou\", \"retoma o projeto\", \"o que falta fazer\", \"cria a tarefa X\", \"marca a tarefa 3 como implementada\", \"atualiza o estado\", \"sincroniza as tarefas\". NÃO acione para memoria-de-projeto (preferências, lições e costumes) nem para docs-projeto (documentação de produto)."
---

# Estado de Projeto (rastreio de tarefas retomável)

## Propósito

O Claude não lembra entre sessões, e um trabalho grande não cabe numa só. Esta skill dá ao projeto um **estado de tarefas durável**: onde cada tarefa está, o que já produziu e o que vem a seguir — para qualquer sessão (ou o `orquestrador-fable`) **retomar de onde parou** sem reconstruir tudo.

É a contraparte da `memoria-de-projeto`: aquela guarda *como* trabalhamos (preferências e lições); esta guarda *onde cada tarefa está*.

## Fronteira da família (estado × memória × docs × requisitos)

Quatro skills irmãs cobrem quatro perguntas diferentes — escolha pela **pergunta**, não pela palavra que apareceu:

- **requisitos-descoberta** → *o quê* construir e por quê (ideia → escopo/MVP), antes de qualquer código.
- **estado-projeto** → *onde cada tarefa está* agora: status retomável, progresso, próximo passo. **← você está aqui.**
- **memoria-de-projeto** → *como* trabalhamos: preferências, decisões e lições duráveis entre sessões.
- **docs-projeto** → *como usar/manter* o produto pronto: README, manual, técnica, changelog.

Sinal de que a coisa está no lugar errado: se um item envelhece numa semana (status, pendência, próximo passo), é **estado**, não memória; se é preferência/decisão durável, é **memória**, não estado.

## Os dois arquivos — um deriva do outro (fonte única)

Para os dois **nunca** divergirem de verdade, um é a fonte e o outro é derivado — não são co-iguais:

- **`estado.json`** — a **única fonte da verdade** (estado-máquina). Uma entrada por tarefa: `{numero, nome, status, prioridade, artefatos: [{tipo, caminho}], status_anterior, atualizado_em}` — mais o campo **opcional** `bloqueada_por: [numero, ...]` quando a tarefa tiver aresta de bloqueio (seção própria abaixo; ausência do campo = tarefa sem bloqueio, e estado antigo sem ele continua válido) —, mais `proximo_numero` no topo. Quando o `orquestrador-fable` conduz, guarda também `rodada_atual` e `placar[]` — cada item do placar no esquema mínimo `{rodada, frente, nota, veredito}`, **mais o campo `lente`, obrigatório quando a nota vier do Comitê** (seção própria abaixo) — (para a retomada continuar o orçamento de rodadas, não reiniciar) e, quando houver critério de parada executável, o `predicado_sucesso` (seção própria abaixo).
- **`TAREFAS.md`** — uma **view legível regenerada** do `estado.json` (para você ler e versionar no git). Nunca é editada à mão como fonte: quando o estado muda, ela é **reescrita a partir do JSON**. Assim a divergência deixa de existir por construção.

**Template do `TAREFAS.md` (fixo — mesma fonte gera sempre a mesma view):**
- Três seções por status, nesta ordem: **Fazendo** (`pesquisando`/`planejando`/`implementando`) → **Pendente** (`nao_iniciada`/`pesquisada`/`planejada`/`bloqueada`) → **Concluída** (`concluida`/`abandonada`).
- Em cada seção, uma tabela com colunas fixas `numero | titulo | status | dono | atualizado`, linhas ordenadas por `numero` crescente. Nada além disso — coluna extra ou ordenação livre quebra o diff entre regenerações.

Local sugerido: uma pasta `estado/` na raiz do projeto — descubra o caminho real em runtime, não chumbe. Um projeto tem o seu próprio estado.

## Como uma tarefa nasce — fatia vertical e aresta de bloqueio *(2026-08-06, garimpo mattpocock G11)*

O enum de status diz para onde a tarefa vai; esta seção diz **em que tamanho ela nasce** e **o que a segura**.

**Fatia vertical (bala traçante).** Cada tarefa corta um caminho **estreito mas completo** por todas as camadas envolvidas (dado → regra → tela → teste), nunca uma fatia horizontal de uma camada só. Três critérios de tamanho, todos checáveis:

- A tarefa concluída é **demonstrável ou verificável sozinha** — dá para ver funcionando sem esperar as irmãs.
- Ela cabe numa **janela de contexto fresca**: uma sessão que começa do zero consegue lê-la, executá-la e fechá-la. Tarefa que estoura a janela é tarefa mal cortada — divida, em vez de subir o esforço.
- **Preparação vem antes.** "Torne a mudança fácil, depois faça a mudança fácil": se o código precisa de um ajuste preparatório, ele é a **primeira** tarefa, não um pedaço escondido dentro da outra.

**Aresta de bloqueio.** Toda tarefa declara **quais tarefas precisam fechar antes dela** — campo opcional `bloqueada_por: [numero, ...]` no `estado.json`, ao lado de `status_anterior`. Tarefa sem bloqueio começa agora. Duas consequências operacionais: a **fronteira** (toda tarefa cujos bloqueios estão `concluida`) é o que se pode pegar em paralelo sem colidir; e o motivo do status `bloqueada` passa a apontar tarefa, não prosa. **O template do `TAREFAS.md` não muda** — a aresta vive no JSON e aparece no motivo do bloqueio; coluna nova quebraria o diff entre regenerações, que é contrato desta skill.

**A exceção do refactor largo.** Mudança mecânica cujo **raio de explosão** varre a base inteira — renomear uma coluna, retipar um símbolo compartilhado, trocar uma assinatura usada em todo lugar — **não cabe em fatia vertical**: um único commit quebra mil pontos de chamada e nenhuma fatia fecha verde. Sequencie **expandir–contrair**:

1. **Expandir** — adicione a forma nova **ao lado** da velha. Nada quebra, tudo continua verde. É uma tarefa.
2. **Migrar em lotes** dimensionados pelo raio (por pacote, por diretório, por módulo). Cada lote é uma tarefa **bloqueada pelo expandir**, e o verde se mantém de lote em lote porque a forma velha ainda existe.
3. **Contrair** — apague a forma velha quando nenhum chamador restar. Tarefa **bloqueada por todos os lotes**.

Quando nem os lotes conseguem ficar verdes sozinhos, mantenha a sequência mas deixe que compartilhem um branch de integração, e crie uma tarefa final de integrar-e-verificar bloqueada por todos — o verde fica prometido **ali**, declaradamente, e não em cada lote.

## Transições de status

Literais **em snake_case sem acento** (os dois lados — estado e orquestrador — usam a mesma string). Enum canônico (os 9 status): `nao_iniciada`, `pesquisando`, `pesquisada`, `planejando`, `planejada`, `implementando`, `concluida`, `bloqueada`, `abandonada`. Valide a transição **antes** de agir; operação incompatível com o status atual → parar e avisar, não forçar.

| Status atual | Operação | Vira |
|---|---|---|
| `nao_iniciada` | pesquisar | `pesquisando` → (ao concluir) `pesquisada` |
| `nao_iniciada` / `pesquisada` | planejar | `planejando` → (ao concluir) `planejada` |
| `planejada` / `implementando` | implementar | `implementando` → (ao concluir) `concluida` |
| `concluida` | reabrir (com motivo) | `implementando` |
| qualquer não-terminal **exceto `bloqueada`** | bloquear (com motivo) | `bloqueada` (grava `status_anterior`) |
| `bloqueada` | desbloquear | volta ao `status_anterior` |
| qualquer **não-terminal** | abandonar (com motivo) | `abandonada` |

Terminais: `abandonada` (fim de linha) e `concluida` (só sai por *reabrir*). Os estados de trabalho (`pesquisando`, `planejando`, `implementando`) são transitórios — se a sessão cair no meio, a retomada os trata como "retomar esta etapa".

## Mapa: retorno do subagente → status da tarefa

O `orquestrador-fable` recebe do subagente um `status` de execução; traduza para o status da tarefa (é o único ponto onde os dois vocabulários se encontram):

| `status` do retorno | status da tarefa |
|---|---|
| `concluida` | `concluida` / `pesquisada` / `planejada` — conforme a etapa da operação |
| `parcial` | `implementando` (segue na próxima rodada) |
| `falhou` | `bloqueada` (o erro vira o motivo) |
| `bloqueada` | `bloqueada` (com motivo) |

## Como gravar com segurança (fonte única + commit ordenado)

Não existe "gravar dois arquivos atomicamente"; a garantia vem de ter **uma fonte só** e gravá-la sem corromper:

1. **Escritor único.** Quem grava o estado é a sessão condutora (o maestro), **nunca os subagentes em paralelo** — isso evita a corrida (dois lendo-validando-gravando e um sobrescrevendo o outro). Persista **uma vez por rodada**, não durante a execução paralela.
2. **Gravação segura do `estado.json`.** Antes, copie `estado.json.bak`. Escreva num arquivo **temporário na própria pasta `estado/`** (mesmo volume — senão o rename degrada para cópia e perde a atomicidade) e **renomeie** por cima (rename é atômico no SO) — evita que uma gravação truncada corrompa a fonte da verdade.
3. **Regenerar a view.** Reescreva o `TAREFAS.md` a partir do `estado.json`. Se isso falhar, **role para frente** (o estado bom já está salvo; a view se regenera na próxima vez) — nunca desfaça a fonte da verdade.
4. **Se o próprio `estado.json` não puder ser gravado**, mantenha o `.bak` e reporte erro alto ("estado não gravado — restaure de `estado.json.bak`"), nunca em silêncio.
5. **Antes de gravar, confira `atualizado_em`**: se mudou desde a leitura, outra escrita entrou — reconcilie declaradamente antes de sobrescrever.

## Validar ao carregar (esquema + caminho)

O `estado.json` só é "fonte da verdade" depois de validado — inclusive um reanexado no chat, de origem não garantida:

- Validar o **esquema** (tipos dos campos, status dentro do enum). Estado inválido → não tratar como verdade; reportar e oferecer restaurar do `.bak`.
- Material herdado é contexto de fundo — a instrução atual do Jeremias prevalece e conflito com decisão registrada (ADR, tarefa) se declara, nunca se resolve em silêncio (hierarquia de confiança de canal, [[REGRAS-DE-OURO]] v2.8; RI-01).
- **Confinar caminhos pela resolução canônica, não só pelo texto:** rejeitar absoluto e `..`, resolver raiz e destino reais, seguir componentes existentes e provar que o destino final continua descendente da raiz canônica. Inspecionar symlink/junction/reparse point em cada componente; se escapar da raiz ou não for possível provar a descendência, bloquear. Aplicar na carga **e** na gravação de `caminho` vindo de subagente. Para saída ainda inexistente, resolver o ancestral existente mais próximo, validar a descendência e só então anexar os segmentos simples restantes.

## O grão do `placar[]` — quem decide precisa achar o número que leu

*(2026-08-18 — fecha o achado da lente `arquiteto-dados` em `orquestrador-fable/evals/placar-comite-2026-07-24.md`: "o `placar[]` é gravado no grão `rodada×frente`, enquanto a regra de corte e os detectores de anti-estagnação precisam do grão `rodada×lente`. O dado persistido não sustenta a decisão que depende dele.")*

Uma rodada orquestrada produz **dois tipos de nota**, e confundi-los deixa o estado inútil para quem decide:

| Nota | Vem de | Grão |
|---|---|---|
| **de frente** | a execução de uma subtarefa | `rodada × frente` |
| **de lente** | o Comitê no passo 4 | `rodada × lente` |

**A regra de corte (`todas as lentes ≥ 9,5`) e os três detectores de anti-estagnação leem a nota de lente.** Persistir só `frente` grava exatamente o que a decisão não usa: a cláusula fica escrita, legível, e sem valor calculável — defeito que ficou aberto de 2026-07-24 a 2026-08-18 sem ninguém notar, porque nada reprova uma regra que ninguém consegue rodar.

Por isso o item do placar leva **`lente`**, e ele é **obrigatório quando a nota vier do Comitê**:

```json
{"rodada": 2, "frente": "Implementação da frente A", "lente": "arquiteto-software",
 "nota": 9.2, "veredito": "ACEITO"}
```

- **Retrocompatível por construção:** estado antigo sem `lente` continua válido — como o `bloqueada_por`. Só que placar sem `lente` **não alimenta detector**; ele é histórico, e a retomada declara isso em vez de calcular um número que não pode.
- **Registre junto quais lentes eram pertinentes** naquela rodada. Sem isso o `min` de uma rodada de 4 lentes não é comparável com o de outra de 7, e a janela deslizante passa a comparar coisas diferentes.
- A regra de agregação (`placar(rodada) = min(...)`) e suas bordas vivem na fonte única do assunto: `orquestrador-fable/referencia/contabilidade-e-placar.md`. Aqui fica só o **grão do dado**; lá, o que se calcula com ele.

## Predicado de sucesso + contexto pinados — fail-closed na retomada

Quando o trabalho orquestrado tem um critério de "pronto" **executável** (ex.: modo métrica do `orquestrador-fable`), ele é **pinado** no estado, para "pronto" ser reproduzível entre sessões — o alvo não anda de lugar:

- Campo opcional `predicado_sucesso` guarda um contrato estruturado: `executable_resolved`, `args[]`, `shell`, `cwd_canonical`, `script_path_canonical` + `script_sha256` quando houver, `allowed_env_names[]`, `endpoint_identity`, `saida_esperada`, `derivado_em` e `hash`. **Nunca** persistir valor secreto; nomes permitidos e identidade não sensível bastam.
- O `hash` cobre a serialização canônica de **todos** esses campos, não só a string do comando. Uma cópia fica também no placar/ledger para detectar corrupção acidental; como ambos são mutáveis, isso não é assinatura contra adulteração maliciosa e nunca substitui a revalidação do contexto vivo.
- **Fail-closed na retomada:** resolver novamente executável, script, `cwd`, reparse points, shell, argumentos, nomes de ambiente e endpoint. Qualquer divergência, campo ausente, executável ambíguo, script com hash novo ou contexto não comprovado = bloquear, mostrar a diferença ao Jeremias e exigir novo contrato/autorização aplicável.
- O predicado deve ser **somente leitura/idempotente** e passar pela triagem positiva do `orquestrador-fable`. Produção/dado real, host remoto aceito só por sufixo `_test`/`_ci`, shell indireto, download+execução e credencial embutida são recusados.

## O que guardar — e o que NÃO guardar

Guarde só o que serve para **retomar**: status, artefatos `{tipo, caminho}`, o que falta e (quando orquestrado) `rodada_atual` + `placar`. **Nunca** grave segredo (senha, token, chave, dado pessoal) no estado — e lembre que o estado é **versionado no git, que preserva histórico**: um segredo vazado fica permanente. Por isso a regra vale também para o **conteúdo dos artefatos** referenciados — artefato com dado sensível vai para o `.gitignore`, não para dentro do estado.

## Exemplo (entra → sai)

Entra: *"a tarefa 3 terminou de implementar, o testador passou"*.

Sai: valido que a 3 estava em `implementando` (se estivesse `nao_iniciada`, paro e aviso — transição inválida); operação `implementar` → `status: concluida`; adiciono `{tipo: evidencia, caminho: estado/artefatos/t3-testador.md}` (caminho dentro do projeto); `atualizado_em` = agora; gravo o `estado.json` (`.bak` antes, temp+rename); regenero o `TAREFAS.md` a partir dele; confiro que a view bate com a fonte (`{numero, status, artefatos, proximo_numero}`); nada mais é tocado.

## Verificação (antes de dar a gravação por fechada)

Rode este checklist e diga **por quê** cada item importa — "parece salvo" não basta quando a próxima sessão depende disso:

- [ ] **A transição era válida?** O status de origem permitia a operação; caso contrário, parei e avisei — forçar transição inválida corrompe a máquina de estados e a retomada passa a mentir.
- [ ] **A view bate com a fonte?** Reabra o `TAREFAS.md` regenerado e confira contra o `estado.json` (`numero`, `status`, `artefatos`, `proximo_numero`) — divergência silenciosa é exatamente o defeito que a fonte única existe para eliminar.
- [ ] **Os caminhos de artefato estão canonicamente confinados ao projeto?** Além de rejeitar absoluto/`..`, resolvi raiz, destino/ancestral e reparse points e provei descendência na carga e na gravação.
- [ ] **`atualizado_em` foi conferido antes de sobrescrever?** Se mudou desde a leitura, houve escrita concorrente — reconciliei em vez de sobrescrever cego.
- [ ] **Backup íntegro + gravação atômica?** `estado.json.bak` existe e a escrita usou temp+rename no mesmo volume — sem isso, uma gravação truncada mata a fonte da verdade.
- [ ] **Nenhum segredo** entrou no estado nem no conteúdo do artefato referenciado (o git preserva para sempre).
- [ ] **(orquestrado) O orçamento e o contexto foram preservados?** `rodada_atual`/`placar` continuam; o contrato do predicado teve hash conferido e `cwd`, executável, script, shell, argumentos, ambiente permitido e endpoint foram revalidados antes da execução.

## Bordas e guardrails

- Tarefa não existe no estado → erro claro, não criar pela metade.
- View divergindo da fonte → **regenerar o `TAREFAS.md` do `estado.json`** (a fonte manda), declarando a correção — nunca escolher um lado em silêncio.
- `estado.json` ilegível/inválido → parar e restaurar do `.bak`, nunca "adivinhar" o estado.
- Trabalho pontual, de uma sessão só, sem `estado/` → **não crie** o estado (evita cerimônia sem dono); ofereça criar apenas se o trabalho for continuar em outra sessão.
- **Adoção legada:** projeto com `TAREFAS.md` manual e sem `estado.json` → importar cada linha como tarefa com o status que ela declara e preservar o original como `TAREFAS-legado.md` — a view passa a ser regenerada; o manual nunca é sobrescrito sem cópia.
- **Adoção a partir de memória misturada:** se `MEMORY.md` ou `MEMORIA-PROJETO.md` contém "estado atual", pendências ou próximos passos, importe somente os itens ainda ativos para `estado.json`; preserve o texto antigo como snapshot histórico datado e substitua, no índice de memória, o painel operacional por um único ponteiro para `estado/TAREFAS.md`. Decisões e lições permanecem na memória.

## Adaptação por ambiente

- **Com sistema de arquivos** (Claude Code, Cowork): grave/atualize o `estado.json`, regenere o `TAREFAS.md` e informe o caminho para versionar.
- **Chat sem arquivos** (claude.ai comum): apresente o `estado.json` atualizado e a view para o usuário salvar, deixando claro que ele reanexa o `estado.json` na próxima sessão — é o que mantém a retomada funcionando.

## 🔗 Rede da skill

- **Lentes que ativam junto (RI-06):** `auditor-responsabilidades` (o estado é evidência de progresso — RI-04) · `inovacao-melhorias` (tarefa que emperra vira insumo de melhoria).
- **Quem a rege / aciona:** `orquestrador-fable` — carrega o estado para retomar trabalho de várias sessões e grava o progresso (com escritor único) ao fim de cada rodada.
- **Alimenta-se de:** `testador-real` (o PASS/FAIL/SKIP vira artefato e muda o status da tarefa) e dos geradores/`spec-` (artefatos produzidos entram na tarefa).
- **Não confundir com:** `memoria-de-projeto` (preferências e lições — *como* trabalhamos) nem `docs-projeto` (documentação de produto). Aqui o assunto é *onde cada tarefa está* (ver "Fronteira da família").

### 📜 Histórico
- **2026-08-18 — Grão do `placar[]`: `lente` ao lado de `frente` (T35; degrau §6.10: 1 — só edição).** Fecha o achado da lente `arquiteto-dados` em `orquestrador-fable/evals/placar-comite-2026-07-24.md`, aberto havia **25 dias**: *"o `placar[]` é gravado no grão `rodada×frente`, enquanto a regra de corte e os detectores de anti-estagnação precisam do grão `rodada×lente`"*. Uma rodada orquestrada produz **dois tipos de nota** — a de frente (execução) e a de lente (Comitê) —, e a decisão lê a segunda: persistir só `frente` gravava exatamente o que a decisão não usa, e a cláusula ficava legível e **sem valor calculável**. Entrou o campo `lente`, **obrigatório quando a nota vier do Comitê**, com seção própria explicando os dois grãos, a exigência de registrar quais lentes eram pertinentes (senão o `min` de rodadas diferentes não é comparável) e a retrocompatibilidade: estado antigo sem `lente` continua válido, como o `bloqueada_por`, mas não alimenta detector — e a retomada declara isso em vez de calcular um número que não pode. A regra de agregação vive na fonte única do assunto (`contabilidade-e-placar.md`); aqui fica só o grão do dado. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 1** — o `**opcional**` de `bloqueada_por`, pré-existente e opcional de verdade (retrocompatibilidade); nenhum alterado, e o único modificador novo desta edição é reforço (`obrigatório quando`), não enfraquecimento.
- **2026-08-06 — Garimpo `mattpocock/skills` (G11; degrau §6.10: 1 — só edição):** nova seção **Como uma tarefa nasce**, cobrindo o que o enum de status não cobria: **fatia vertical (bala traçante)** com três critérios de tamanho checáveis (demonstrável sozinha · cabe numa janela de contexto fresca · preparação é a primeira tarefa), **aresta de bloqueio** via campo **opcional** `bloqueada_por` no `estado.json` — retrocompatível por construção, e o template do `TAREFAS.md` fica intacto porque coluna nova quebraria o contrato de diff determinístico — e a **exceção do refactor largo** (expandir → migrar em lotes por raio de explosão → contrair, cada etapa uma tarefa bloqueada pela anterior; branch de integração com tarefa final quando nem os lotes fecham verdes). Proveniência: `skills/engineering/to-tickets/` de `github.com/mattpocock/skills` @ `6acc160` (MIT) — relatório em `garimpo-mattpocock-2026-08-06.md`.
- **2026-07-23 — Homologação de retomada segura:** confinamento passa a ser canônico com bloqueio de symlink/junction/reparse point; `predicado_sucesso` pina executável, argumentos, shell, `cwd`, script/hash, ambiente permitido e endpoint e revalida o contexto vivo. O hash duplicado fica explicitamente limitado a detecção acidental, não assinatura.
- **2026-07-20:** Adicionados o bloco "Fronteira da família" (estado × memória × docs × requisitos, escolha pela pergunta) no topo e a seção "Verificação" com checklist de fechamento (transição válida, view↔fonte, caminhos confinados, `atualizado_em`, backup/rename, sem segredo, orçamento de rodadas) explicando o porquê de cada item; conteúdo, templates e formatos preservados.
- **2026-07-20:** Adicionada a migração explícita de memória misturada: tarefas ativas vão para o estado, o texto anterior vira snapshot histórico e o índice durável fica apenas com um ponteiro.
- **2026-07-13 — Evolução R1→R2 (onda transversal):** template do `TAREFAS.md` especificado em bloco curto (colunas fixas `numero | titulo | status | dono | atualizado`, ordenação por numero, seções fazendo→pendente→concluída) para regeneração determinística; esquema mínimo do `placar[]` (`{rodada, frente, nota, veredito}`) em 1 linha; borda de adoção legada (`TAREFAS.md` manual sem `estado.json` → importar linhas como tarefas + preservar `TAREFAS-legado.md`); −0/+6 linhas.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); item E11; −0 linhas físicas (poda dentro de linha).
