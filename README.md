# Orquestrador Fable — catálogo de skills para Claude Code

> **TL;DR (EN):** A battle-tested, PT-BR catalog of **60 Agent Skills** for Claude Code — senior "review lenses", per-stack code generators, spec orchestrators, a real test-runner, and a multi-model **maestro** (`orquestrador-fable`) that plans, delegates to sub-agents, reviews with a committee of lenses, and iterates until quality ≥ 9/10. MIT licensed.

Um conjunto único de **60 skills** para o [Claude Code](https://claude.com/product/claude-code), pensado para construir software de verdade — do desktop ao mobile e web — com **qualidade auditável**. Em vez de uma skill gigante que "faz tudo", o catálogo separa responsabilidades em camadas:

- **🔬 Lentes de método (9)** — posturas sênior, poliglotas, que *decidem e revisam* (arquitetura, dados, código, UX/UI, segurança, QA, inovação, auditoria, negócio). Formam o **Comitê de Lentes**.
- **⚙️ Geradores por track (25)** — scaffolders determinísticos e precisos por stack: **Java/JavaFX**, **Spring Boot**, **Flutter**, **Web Frontend** e **Desktop/Tauri**.
- **🎼 Orquestradores (8)** — os sete `spec-*` encadeiam a sequência de um track; o **`orquestrador-fable`** é o maestro multi-modelo que rege *quem executa* e *quanta qualidade sai*.
- **🛠️ Método e governança (7)** — planejamento com custo, prazo e Plano B; garimpo de fonte externa; zeladoria do próprio acervo; painel de juízes; mapa de decisões; descoberta de requisitos; documentação.
- **💼 Domínio (6)** — conteúdo e conselho fora do código: finanças pessoais, trading, redação técnica, e-mail marketing.
- **🧪 Testadores (2)** — executam baterias de teste de verdade e trazem evidência PASS/FAIL/SKIP (nunca "sucesso" fingido).
- **🧠 Memória e estado (2)** — contexto e progresso de tarefas retomáveis entre sessões.
- **🧩 Blueprint (1)** — subsistema offline reutilizável.

> As camadas **somam 60**: 9 + 25 + 8 + 7 + 6 + 2 + 2 + 1. Se um dia não somarem, o número errado é o do topo.

O guia completo, com a função de cada uma das 60 e o passo a passo do maestro, está em **[GUIA.md](GUIA.md)**.

## A ideia em uma frase

> As **lentes** decidem e revisam · os **geradores** produzem no stack certo · os **`spec-`** encadeiam a sequência de um track · o **testador** prova com evidência · **memória/estado** dão continuidade — e o **`orquestrador-fable`** rege quem faz o quê, com qual modelo, e itera até nota ≥ 9.

## Como o `orquestrador-fable` trabalha

1. **Triagem** — escolhe o loop mais leve que resolve (skill direta, um `spec-`, ou o ciclo completo).
2. **Planeja** — decompõe em subtarefas (qual skill × qual modelo × critério de aceite).
3. **Executa** — delega a subagentes que aplicam os geradores/skills, em ondas paralelas de largura adaptativa (piloto antes de onda grande; até 20 simultâneos).
4. **Consolida** e submete ao **Comitê de 7 lentes + auditor** (nota 0–10; juiz de visão para telas).
5. **Testa** com o `testador-real` (evidência executada).
6. **Decide** — nota ≥ 9 em tudo → entrega; senão, replaneja (escala modelo *ou* effort) e repete, até a excelência ou 10 rodadas.

## Instalação

Requer o [Claude Code](https://claude.com/product/claude-code). As skills carregam de `~/.claude/skills` (global) ou `<projeto>/.claude/skills`.

**Windows (PowerShell):**

```powershell
# global (todos os projetos)
powershell -ExecutionPolicy Bypass -File .\deploy-skills.ps1

# ou para um projeto específico
.\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto"
```

**Ou manualmente:** copie a pasta `skills/` para `~/.claude/skills/` (ou `<projeto>/.claude/skills/`) e reinicie a sessão do Claude Code. Depois é só pedir em linguagem natural — as skills disparam por gatilho (ex.: *"orquestra essa tarefa com o ciclo completo"*, *"cria o DAO de Cliente"*, *"testa o sistema de verdade"*).

## Estrutura

```
skills/                 as 60 skills (cada uma numa pasta com SKILL.md)
REGRAS-DE-OURO.md       governança: regras inquebráveis (RI) + regras de ouro (RO) por track
PADRAO-DE-AUTORIA.md    como criar/editar qualquer skill (inclui o "Selo Lendário")
ROADMAP.md              pendências e próximos passos
GUIA.md                 as 60 skills com função + como o maestro as rege
deploy-skills.ps1       sincroniza o catálogo para o runtime do Claude Code
referencia/             referências de apoio
docs/INDICE-OBSIDIAN.md índice navegável (formato Obsidian)
```

## Notas

- **Idioma:** as skills são em **PT-BR** (instruções); código e identificadores em inglês.
- **Tracks Mobile/Web/Desktop** entram marcados como **proposta** — fundamentados em fontes oficiais, a refinar contra código real de cada projeto (RO-01).
- **Exemplos concretos** citam projetos reais do autor apenas como contexto de exemplo.

## Créditos e atribuição

- A referência de design **Impeccable** em `skills/designer-ux-ui/referencia/impeccable/` é de **Paul Bakaus** ([`pbakaus/impeccable`](https://github.com/pbakaus/impeccable), Apache-2.0) — o `NOTICE.md` original está preservado nessa pasta.
- Conceitos incorporados de artigos oficiais do Claude Code (loops, model/effort, harness design) e de repositórios públicos avaliados (creditados nos arquivos onde aparecem).

## Licença

[MIT](LICENSE) © 2026 Jeremias ([@codjeremias-cell](https://github.com/codjeremias-cell)). Use, adapte e compartilhe à vontade — se ajudar, deixe uma ⭐.
