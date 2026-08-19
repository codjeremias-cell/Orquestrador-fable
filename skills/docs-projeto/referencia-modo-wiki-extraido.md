# Referência — Mecânica do modo wiki (docs-projeto)

> Extraído do corpo da `SKILL.md` em 2026-07-13 (Evolução R1→R2, onda transversal). O corpo mantém o gatilho do modo + as 4 salvaguardas em 1 linha cada; a mecânica completa vive aqui. Nenhuma regra foi removida — só realocada. Proveniência: 2026-07-10, garimpo autoresearch P10.

## Estrutura da wiki

Pasta `wiki/` do projeto: `index.md` (porta de entrada com ordem de leitura) · `arquitetura.md` (visão geral, com diagrama quando ajudar) · **uma página por módulo** (visão, arquivos-chave, padrões) — e, desde 2026-08-18 (garimpo oh-my-opencode · G2), mais dois campos que faltavam para a página servir a quem chega sem contexto: **fluxo de dados e de controle** (o que entra, o que sai, quem chama quem) e **pontos de integração** (com que módulo, serviço ou tabela este conversa, e por qual contrato). Visão e arquivos-chave dizem *o que existe*; estes dois dizem *como participa* · `glossario.md` (termos do domínio extraídos do código real) · `onboarding.md` (por onde começar, setup, primeiras contribuições, pegadinhas). Todas as travas da skill valem (RO-01: só documentar o confirmado no código; apontar para as RO, não copiar).

## Salvaguarda 1 — Manifesto write-ahead

Antes de gerar qualquer página, gravar `wiki/wiki-manifest.json` com o plano completo (páginas previstas, status `pendente`); ao terminar cada página, virar seu status para `gerada`. Status possíveis: `pendente` · `gerada` · `pulada-humana` (ver salvaguarda 2). Interrupção no meio **não perde trabalho**: a retomada lê o manifesto e continua só das `pendente`. Regras da retomada:

- (a) página `gerada` que **não existe mais em disco** (humano apagou) = avisar e perguntar, nunca regenerar por conta;
- (b) manifesto de corrida antiga com plano novo diferente (ex.: módulo novo) = **mesclar** adicionando as páginas novas como `pendente`, nunca sobrescrever o manifesto inteiro;
- (c) manifesto corrompido = parar e avisar, nunca adivinhar.

## Salvaguarda 5 — Invalidação por deriva *(2026-08-18, garimpo oh-my-opencode · G2)*

O manifesto rastreava **estado de escrita** (`pendente` → `gerada`) e não rastreava **deriva**: página
`gerada` continua `gerada` para sempre, mesmo depois de o módulo que ela descreve ser reescrito. É
assim que derivado envelhece calado — ninguém mente, ninguém avisa, e um dia a wiki descreve um
sistema que não existe mais.

Correção, **reusando a receita que já existe em** `testador-real/referencia-tecnicas-extraido.md`
(nada de mecanismo novo): cada entrada do `wiki-manifest.json` passa a carregar dois campos —
`cobre: [<caminhos dos arquivos que a página descreve>]` e `hash: <git hash-object dos arquivos de
`cobre`, na ordem>`. Entra um status novo: **`desatualizada`**.

A cada corrida da wiki, antes de qualquer geração: recomputar o hash de `cobre` de cada página
`gerada`; **hash diferente do registrado ⇒ a página vira `desatualizada`**, com o motivo (que arquivo
mudou). A retomada continua tratando `pendente`; `desatualizada` **não se regenera sozinha** — ela é
listada ao Jeremias, porque regenerar é sobrescrever, e a Salvaguarda 2 já decidiu que sobrescrever
pede decisão.

Três guardrails, todos comprados caro:

- **`git hash-object`, não `sha256` do arquivo cru.** O primeiro normaliza pelo `.gitattributes`; o
  segundo muda de valor quando o checkout troca o fim de linha, e produziria `desatualizada` em massa
  no dia em que ninguém tocou em nada. Digest de arquivo não é identidade.
- **`desatualizada` é pergunta, não veredito.** Ela diz "o código mudou desde que isto foi escrito",
  jamais "isto está errado" — o texto pode continuar correto depois de uma refatoração interna.
- **Página sem `cobre` não é página ruim; é página não rastreável.** `index.md`, `glossario.md` e
  `onboarding.md` legitimamente não cobrem arquivo específico: declaram `cobre: []` e ficam fora da
  checagem, **explicitamente**, para que ausência de aviso não seja lida como garantia de frescor.

## Salvaguarda 2 — Proteção de colisão

Toda página gerada leva `generated_by: docs-projeto` no frontmatter. Antes de sobrescrever qualquer página existente, conferir esse marcador — **página sem ele foi escrita por humano e é pulada com aviso**, marcada `pulada-humana` no manifesto (para a retomada não insistir nela), nunca sobrescrita (regenerar do zero exige pedido explícito do Jeremias).

## Salvaguarda 3 — Varredura de segredo pós-geração

Ao final, varrer `wiki/` procurando padrões de credencial (chave de API, senha em texto, URL de banco com usuário/senha). Achado = **remover, substituir por placeholder de exemplo** (`<SUA_CHAVE_AQUI>`) e avisar **citando página e linha** — a regra "sem segredo em documento" da skill ganha verificação mecânica (RI-04).

## Salvaguarda 4 — Caps de tamanho

~300 linhas por página e diagramas de até ~15 nós — página que estoura é sinal de módulo que merece divisão, não de página maior. Ao estourar: **dividir em subpáginas**, registrá-las como `pendente` no manifesto e anotar a divisão no `index.md` — nunca truncar em silêncio.
