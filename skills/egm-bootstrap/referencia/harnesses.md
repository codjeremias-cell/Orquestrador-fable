# Harnesses — como o EGM roda nesta casa

> Adaptação local de `docs/harnesses.md` do upstream **Elephant & Goldfish Model** (Apache-2.0,
> https://github.com/google/elephant-goldfish-model). O guia original cobre instalação de plugin;
> aqui interessa o que o método exige para rodar dentro do Catálogo Unificado.

O EGM não é um conjunto de prompts que roda sozinho: ele exige **subagentes de contexto limpo**
(os Goldfish). Um revisor que enxerga o histórico da conversa não é Goldfish — é eco.

## Mapa de delegação

| Harness | Ferramenta de subagente | Personas nomeadas | Observação |
|---|---|---|---|
| Grok | `spawn_subagent` | Não | Spawnar general-purpose e mandar ler a persona; o subagente não abre outro subagente |
| Claude Code | Agent/Task | Sim | Até 3 níveis de aninhamento por padrão |
| Codex | ferramenta nativa de spawn/wait | Não | Spawnar general-purpose e mandar ler a persona |
| OpenCode | `subagent` / task | Sim | Declarar o agente e passar o caminho da persona |
| Antigravity | `invoke_subagent` | Sim | App e extensão; a IDE standalone não expõe a ferramenta |
| ChatGPT Work | spawn/wait quando exposto | Não | Sem ferramenta nativa, parar em vez de simular |

## Personas

Cada revisor vive em `referencia/personas/<arquivo>.md`. O frontmatter `name` da persona
(e.g. `egm-zoom-out`) é o tipo de subagente a pedir quando o harness registra personas nomeadas.
Quando não registra, spawne um subagente general-purpose e mande-o ler o arquivo primeiro.

## Sem subagente, não há Goldfish

Se o harness não oferece delegação em contexto limpo, a skill **para** e diz isso ao usuário.
Rodar a revisão na mesma conversa seria teatro: o revisor herdaria as premissas que deveria
desafiar. Vale para a IDE standalone do Antigravity e para modos do ChatGPT sem delegação nativa.

## Diretório de artefatos

Briefs, drafts e laudos vão para o diretório de trabalho ou para o diretório de artefatos do
harness. Nesta casa, o padrão é `.dev/docs` (relativo à raiz do projeto), salvo instrução
diferente no `AGENTS.md`/`CLAUDE.md` do projeto. Arquivos de projeto (design docs, READMEs)
não mudam de lugar.

## Instalação upstream

Para instalar o plugin original em Antigravity, Claude Code, Codex, ChatGPT ou omp, siga o
`docs/harnesses.md` do upstream. A cópia do Catálogo não instala plugin: ela é a fonte da
verdade local, deployada por `deploy-skills.ps1`.
