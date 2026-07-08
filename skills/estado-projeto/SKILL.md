---
name: estado-projeto
description: "Mantém o estado das tarefas do projeto de forma persistente e retomável — um estado.json (estado-máquina, fonte única da verdade) e um TAREFAS.md (view legível regenerada dele), com transições de status controladas. Acione quando o usuário disser coisas como \"onde a gente parou\", \"retoma o projeto\", \"o que falta fazer\", \"cria a tarefa X\", \"marca a tarefa 3 como implementada\", \"atualiza o estado\", \"sincroniza as tarefas\", ou ao conduzir um trabalho grande em várias sessões que precise lembrar o progresso. Acione TAMBÉM quando o orquestrador-fable precisar persistir e retomar o estado entre rodadas/sessões. NÃO acione para memoria-de-projeto (preferências, lições e costumes) nem para docs-projeto (documentação de produto)."
---

# Estado de Projeto (rastreio de tarefas retomável)

## Propósito

O Claude não lembra entre sessões, e um trabalho grande não cabe numa só. Esta skill dá ao projeto um **estado de tarefas durável**: onde cada tarefa está, o que já produziu e o que vem a seguir — para qualquer sessão (ou o `orquestrador-fable`) **retomar de onde parou** sem reconstruir tudo.

É a contraparte da `memoria-de-projeto`: aquela guarda *como* trabalhamos (preferências e lições); esta guarda *onde cada tarefa está*.

## Os dois arquivos — um deriva do outro (fonte única)

Para os dois **nunca** divergirem de verdade, um é a fonte e o outro é derivado — não são co-iguais:

- **`estado.json`** — a **única fonte da verdade** (estado-máquina). Uma entrada por tarefa: `{numero, nome, status, prioridade, artefatos: [{tipo, caminho}], status_anterior, atualizado_em}`, mais `proximo_numero` no topo. Quando o `orquestrador-fable` conduz, guarda também `rodada_atual` e `placar[]` (para a retomada continuar o orçamento de rodadas, não reiniciar).
- **`TAREFAS.md`** — uma **view legível regenerada** do `estado.json` (para você ler e versionar no git). Nunca é editada à mão como fonte: quando o estado muda, ela é **reescrita a partir do JSON**. Assim a divergência deixa de existir por construção.

Local sugerido: uma pasta `estado/` na raiz do projeto — descubra o caminho real em runtime, não chumbe. Um projeto tem o seu próprio estado.

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
- **Confinar os caminhos de artefato à pasta do projeto**: rejeitar caminho absoluto ou com `..` (anti path traversal) — o caminho é seguido depois, não pode apontar para fora. Aplique a mesma rejeição **na hora de gravar** um `caminho` vindo do retorno de um subagente, não só ao carregar — um subagente com bug não deve conseguir injetar caminho fora do projeto.

## O que guardar — e o que NÃO guardar

Guarde só o que serve para **retomar**: status, artefatos `{tipo, caminho}`, o que falta e (quando orquestrado) `rodada_atual` + `placar`. **Nunca** grave segredo (senha, token, chave, dado pessoal) no estado — e lembre que o estado é **versionado no git, que preserva histórico**: um segredo vazado fica permanente. Por isso a regra vale também para o **conteúdo dos artefatos** referenciados — artefato com dado sensível vai para o `.gitignore`, não para dentro do estado.

## Exemplo (entra → sai)

Entra: *"a tarefa 3 terminou de implementar, o testador passou"*.

Sai: valido que a 3 estava em `implementando` (se estivesse `nao_iniciada`, paro e aviso — transição inválida); operação `implementar` → `status: concluida`; adiciono `{tipo: evidencia, caminho: estado/artefatos/t3-testador.md}` (caminho dentro do projeto); `atualizado_em` = agora; gravo o `estado.json` (`.bak` antes, temp+rename); regenero o `TAREFAS.md` a partir dele; confiro que a view bate com a fonte (`{numero, status, artefatos, proximo_numero}`); nada mais é tocado.

## Bordas e guardrails

- Tarefa não existe no estado → erro claro, não criar pela metade.
- View divergindo da fonte → **regenerar o `TAREFAS.md` do `estado.json`** (a fonte manda), declarando a correção — nunca escolher um lado em silêncio.
- `estado.json` ilegível/inválido → parar e restaurar do `.bak`, nunca "adivinhar" o estado.
- Trabalho pontual, de uma sessão só, sem `estado/` → **não crie** o estado (evita cerimônia sem dono); ofereça criar apenas se o trabalho for continuar em outra sessão.

## Adaptação por ambiente

- **Com sistema de arquivos** (Claude Code, Cowork): grave/atualize o `estado.json`, regenere o `TAREFAS.md` e informe o caminho para versionar.
- **Chat sem arquivos** (claude.ai comum): apresente o `estado.json` atualizado e a view para o usuário salvar, deixando claro que ele reanexa o `estado.json` na próxima sessão — é o que mantém a retomada funcionando.

## 🔗 Rede da skill

- **Lentes que ativam junto (RI-06):** `auditor-responsabilidades` (o estado é evidência de progresso — RI-04) · `inovacao-melhorias` (tarefa que emperra vira insumo de melhoria).
- **Quem a rege / aciona:** `orquestrador-fable` — carrega o estado para retomar trabalho de várias sessões e grava o progresso (com escritor único) ao fim de cada rodada.
- **Alimenta-se de:** `testador-real` (o PASS/FAIL/SKIP vira artefato e muda o status da tarefa) e dos geradores/`spec-` (artefatos produzidos entram na tarefa).
- **Não confundir com:** `memoria-de-projeto` (preferências e lições — *como* trabalhamos) nem `docs-projeto` (documentação de produto). Aqui o assunto é *onde cada tarefa está*.
