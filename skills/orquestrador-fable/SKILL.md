---
name: orquestrador-fable
description: "Orquestrador multi-modelo: o modelo mais capaz da sessão (Fable 5) recebe a tarefa, analisa, planeja e delega a execução a subagentes (máximo 20 simultâneos) escolhendo o modelo por complexidade — Opus para o pesado/crítico, Sonnet para o intermediário, Haiku para o simples/volume — cada um aplicando as skills do catálogo. Depois roda o Comitê de Lentes (notas 0–10) e o testador-real (bateria executada de verdade), e repete o ciclo planejar→executar→avaliar até nota ≥ 9 em todas as lentes ou 10 rodadas, o que vier primeiro. Acione quando o usuário disser coisas como \"orquestra essa tarefa\", \"usa o orquestrador\", \"divide o trabalho entre os modelos\", \"libera os subagentes\", \"roda o ciclo completo até nota 9\", \"faz com o comitê avaliando\", inclusive quando pedir uma entrega grande \"com qualidade máxima\" sem nomear a skill. NÃO acione para etapa isolada (use a skill da etapa), nem para sequência determinística de geradores num stack (use spec-projeto-completo ou o spec- do track)."
---

# Orquestrador Fable (maestro multi-modelo com ciclo de qualidade)

O **maestro do conjunto**: o modelo orquestrador (Fable 5, ou o mais capaz disponível na sessão) **nunca executa — decide**. Ele analisa o pedido, planeja, decompõe, delega a execução a subagentes com o modelo certo para cada subtarefa, e submete o resultado ao **Comitê de Lentes** + **testador-real**. Se qualquer nota ficar abaixo de 9, usa as críticas como insumo e reinicia o ciclo — até a excelência ou o limite de 10 rodadas.

A diferença para os orquestradores `spec-`: eles encadeiam **skills** em ordem determinística; este orquestra **quem executa** (modelos/subagentes) e **quanta qualidade** sai (loop com nota de corte). Os dois se combinam: um subagente pode perfeitamente rodar um `spec-` inteiro como sua subtarefa.

## Objetivo

Entregar a tarefa com nota ≥ 9 em todas as lentes do Comitê, usando paralelismo de subagentes para velocidade e o loop planejar→executar→avaliar para qualidade, aderente às [[REGRAS-DE-OURO]] (RI-01…06 + RO aplicáveis).

## Entradas obrigatórias

1. A tarefa/pedido (mesmo em uma frase — o planejamento dá forma).
2. Acesso à pasta de skills do projeto/catálogo (runtime `.claude/skills/` ou equivalente — descobrir em runtime, não chumbar caminho).

## Entradas opcionais

- Restrições (prazo, orçamento de tokens, lentes prioritárias, nota de corte diferente de 9, limite de rodadas diferente de 10).
- Testador específico do projeto (ex.: `gradup-testador`) — quando existir, ele substitui o `testador-real` genérico.

## Validação do catálogo (antes do primeiro ciclo)

Confirmar que existem no runtime: as 7 lentes de revisão (`arquiteto-software`, `arquiteto-dados`, `designer-ux-ui`, `dev-senior`, `especialista-seguranca`, `qa-usabilidade`, `inovacao-melhorias`) + `auditor-responsabilidades` + `testador-real` (ou instância do projeto). Se faltar lente crítica, **parar e avisar** qual — nota simulada por lente ausente é violação da RI-04. Listar também as skills executoras aplicáveis à tarefa (geradores, `spec-`, `docs-projeto` etc.) para o plano referenciá-las.

## Papéis dos modelos

| Modelo | Papel | Quando |
|---|---|---|
| **Fable 5** (orquestrador) | Analisa, planeja, decompõe, delega, consolida, decide. **Não executa subtarefa.** | Sempre — é o maestro de todos os ciclos. |
| **Opus** | Subtarefas pesadas/críticas: arquitetura de solução, algoritmo complexo, refatoração grande, decisão com trade-off difícil. | Complexidade alta ou custo de erro alto. |
| **Sonnet** | Subtarefas intermediárias: implementar feature definida, escrever testes, documentação técnica, revisões das lentes. | O grosso do trabalho. Default quando em dúvida entre Sonnet e Haiku. |
| **Haiku** | Subtarefas simples e de volume: renomear, formatar, buscar, extrair, converter, tarefas mecânicas repetidas. | Simples, bem especificada, barata de refazer se errar. |

**Effort — o 2º eixo (proposta 2026-07-07, do artigo *Choosing a Claude model and effort level*).** O modelo escolhe a *capacidade*; o **effort** escolhe *quão a fundo* o subagente vai (quantos arquivos lê, quanto verifica, quantos passos dá antes de voltar). O maestro designa **modelo + effort** por subtarefa, não só o modelo. Comece no effort **padrão** do modelo e ajuste de propósito:

- **Effort alto** quando o que faltou foi *rigor* (releitura, rodar o teste, não abandonar no meio) — mesmo modelo, mais esforço.
- **Effort baixo** para trabalho mecânico e bem especificado — não pague thoroughness que a tarefa não pede.
- Combinações úteis: *Opus/effort baixo* = leitura rápida de especialista; *Sonnet/effort alto* = generalista que lê tudo e verifica antes de entregar.

## Passo 0 — Triagem (comece simples)

Antes de montar o ciclo completo, o Fable classifica o pedido e escolhe o **loop mais leve que resolve** (proposta 2026-07-07, do artigo *Getting started with loops*) — nem toda tarefa merece o comitê inteiro:

| Perfil da tarefa | Caminho |
|---|---|
| Etapa isolada, bem definida | a **skill direta** da etapa — a orquestração recusa (anti-burocracia). |
| Sequência determinística de geradores num stack | `spec-projeto-completo` ou o `spec-` do track. |
| Entrega com critério verificável e risco real de erro | **ciclo completo** abaixo (goal-loop com nota de corte). |
| Trabalho recorrente/agendado (roda sozinho no tempo) | ainda não coberto — ver ROADMAP (modo tempo/agendado, decisão pendente sobre auto mode). |

Escolhido o ciclo completo, o maestro ainda **enxuga o comitê** às lentes pertinentes (o `auditor-responsabilidades` dispensa as demais *declaradamente*, RI-06) — proporcionalidade sem abrir mão da cobertura obrigatória.

## O ciclo (máximo 10 rodadas)

Cada rodada executa as 6 etapas, em ordem. O gate entre etapas é obrigatório.

1. **Planejamento (Fable).** Analisar o pedido (na rodada 2+, também o placar e as críticas da rodada anterior). Decompor em subtarefas com: objetivo claro, skill(s) do catálogo a aplicar, modelo designado, entradas, formato de saída esperado e critério de aceite. Identificar o que roda em paralelo (sem dependência) e o que é sequencial. *Gate: nenhuma subtarefa ambígua — na dúvida entre dois caminhos, perguntar ao Jeremias antes de delegar (não adivinhar). Gate adicional (RI-01, proposta 2026-07-07): se alguma subtarefa mudaria a **decisão** de um ADR "Aceito" existente (não só um detalhe de execução dentro dele), parar e declarar o conflito ao Jeremias antes de incluir a subtarefa no plano — nunca delegar a mudança de decisão arquitetural em silêncio.*
   - **Persistência e retomada (proposta 2026-07-07, do repo avaliado).** Em trabalho de várias sessões, na rodada 1 carregar o estado via `estado-projeto` e **validar cada operação contra a tabela de transições dessa skill** (fonte única do vocabulário de status) antes de delegar — não replanejar `concluida`, não implementar `nao_iniciada`. Ao fim de cada rodada, com **escritor único** (só o maestro grava), persistir via `estado-projeto` o progresso — status + artefatos e também `rodada_atual` + `placar`, para a retomada continuar o orçamento de rodadas e a anti-estagnação, não reiniciar.
   - **Formato de plano por fases (opcional, do repo avaliado).** Para uma frente grande, o plano pode detalhar fases: cada fase = 1–3h, **independentemente verificável**, com objetivos, arquivos a tocar, passos, verificação e uma tabela Risco × Impacto × Mitigação.
   - **Nota de decisão (2026-07-07):** avaliamos e **rejeitamos** adotar a diretriz de terceiros "nunca pare para consultar o parceiro humano entre tarefas, execute tudo sem interrupção" (`subagent-driven-development`, `obra/superpowers`). Ela contradiz o gate acima. Condição-limite registrada: **não pausar seria aceitável** só quando a subtarefa é mecânica, sem ambiguidade real e dentro de um escopo que o Jeremias já aprovou explicitamente nesta mesma rodada — fora disso, o gate de consulta vale sempre.
2. **Execução (subagentes — máximo 20 simultâneos).** Delegar cada subtarefa ao subagente com o modelo designado. O prompt de cada subagente contém: contexto mínimo suficiente, a skill a seguir (caminho da `SKILL.md`), a saída esperada e a proibição de inventar API/lib (RO-01 vale dentro do subagente). Subtarefas independentes disparam **juntas**. *Gate: toda entrega de subagente confere com o critério de aceite; entrega ruim volta uma vez com feedback específico antes de escalar o modelo.*
   - **Contrato de retorno do subagente (proposta 2026-07-07, do repo avaliado).** Todo subagente devolve um retorno padronizado, para a consolidação e o placar não dependerem de formato improvisado: `status` (`concluida`/`parcial`/`falhou`/`bloqueada` — snake_case sem acento; a tradução para o status da tarefa vive na `estado-projeto`) · `resumo` (2–5 frases) · `artefatos[]` (tipo + caminho) · `métricas` (tokens, duração) · `erros[]` (tipo, se é recuperável, recomendação) · `próximos_passos`. Retorno fora do contrato conta como entrega incompleta. **Delegação plana:** por padrão o subagente **não** sub-delega (maestro→subagente); se em algum caso precisar, o maestro impõe *antes de disparar* uma profundidade máxima declarada (padrão: 1 nível) — eixo distinto do teto de 20, que é largura simultânea.
   - **Largura da onda: adaptativa e medida, não chutada (proposta 2026-07-07).** O teto de 20 é de **simultâneos**, não de total — acima disso, ondas sequenciais. O maestro dimensiona cada onda e declara o porquê no placar: (a) **piloto antes de onda grande** — em decomposição grande (heurística: mais de ~8 frentes), disparar 1-2 frentes representativas primeiro, ler a **tabela de tokens** (a que já existe) e projetar a onda antes de liberar o resto; (b) **largura por modelo** — larga para trabalho mecânico de Haiku (barato de consolidar), **estreita (2-4)** para julgamento de Opus/Fable, porque modelo caro não paraleliza bem na consolidação (RI-01, "nada cai no vão"). "Uma frente por agente" escala pelo **total** (ondas), não subindo o teto de simultâneos.
3. **Consolidação (Fable).** Integrar as entregas num resultado coeso: resolver conflitos entre partes, garantir consistência de nomes/estilo, verificar que nada caiu no vão (RI-01). *Gate: resultado integrado compila/abre/roda no nível básico.*
4. **Comitê de Lentes (subagentes, dentro do limite de 20).** As 7 lentes de revisão avaliam o resultado consolidado **em paralelo**, cada uma pela sua ótica e cada uma emitindo **nota 0–10 + críticas acionáveis** (o que exatamente impede o 10). Depois o `auditor-responsabilidades` consolida: confere RI/RO, evidências e emite o placar da rodada. Lente sem pertinência real à tarefa (ex.: `designer-ux-ui` numa tarefa sem UI) é dispensada **declaradamente** pelo auditor — nunca em silêncio. *Contexto limpo (proposta 2026-07-07): cada lente e o auditor recebem só o **artefato consolidado + o critério de aceite** — nunca o rastro de raciocínio do maestro nem o de outra lente. Revisor com contexto fresco é menos enviesado e não é contaminado pela justificativa de quem produziu.*
   - **Juiz de visão para resultado visual (proposta 2026-07-07, do harness GAN / `auto-improve`).** Quando a entrega tem UI ou artefato visual, a avaliação inclui um **juiz de visão**: tira screenshot do resultado real e critica contra a rubrica (design, craft, estados, a11y visual) — um **juiz separado**, nunca quem gerou (contexto limpo). Para não regredir por "slop confiante", usar o **portão pareado**: o candidato disputa contra o **campeão atual** (a melhor versão até aqui) em **duas ordens embaralhadas**, e só promove se vencer nas duas; empate ou derrota mantém o campeão. O placar por rodada é o log de melhoria (RI-04). Casa com o passo "Audit" do Modo Polish Pass (`designer-ux-ui`) e entra como evidência no `testador-real`. O juiz de visão é o próprio `designer-ux-ui` em **modo visão** — não é lente extra (não muda as 7 nem infla o teto de 20). Quando o campeão é mantido, o placar registra a nota do **campeão** (não a do candidato derrotado), e rodada sem troca de campeão conta para a anti-estagnação. O **campeão vigente persiste no `estado-projeto`** (junto de `rodada_atual`/`placar`), para a retomada não perder a melhor versão.
5. **Testador Real (última etapa da avaliação).** O `testador-real` (ou a instância do projeto) executa a bateria estática + dinâmica contra o resultado de verdade, com evidência PASS/FAIL/SKIP. A trava de acionamento dele fica satisfeita porque a ordem parte deste ciclo, mas as **permissões de ambiente** (build pesado, banco, escrita de evidência) sobem para o Jeremias na primeira rodada e valem para as seguintes — mas, como o loop **replaneja**, se o escopo de ambiente mudar materialmente numa rodada seguinte (operação mais ampla que a aprovada), **reconfirmar** antes; aprovação de escopo pequeno não se estende sozinha. O relatório do testador entra no placar: FAIL crítico = nota da lente afetada não pode ser ≥ 9.
6. **Decisão (Fable).** Ler o placar consolidado: **todas as notas ≥ 9 e sem FAIL crítico → entrega final.** Caso contrário, registrar o placar da rodada, transformar cada crítica em insumo de replanejamento e voltar ao passo 1. Parar em: nota atingida **ou** 10 rodadas — o que vier primeiro.
   - **Escalonamento em 2 eixos (proposta 2026-07-07, do artigo *model e effort*).** Ao replanejar uma frente que falhou, diagnosticar *por quê* antes de escalar: falhou por **não saber o bastante** (confidentemente errada, domínio novo, decisão de arquitetura, ambiguidade) → **sobe o modelo** (Haiku→Sonnet→Opus→Fable); falhou por **não tentar o bastante** (pulou arquivo, não rodou o teste, abandonou no meio) → **sobe o effort do mesmo modelo**, não o modelo. Mexer só no eixo certo evita pagar Opus quando o que faltou foi rigor.
   - **Captura sistêmica (proposta 2026-07-07, do artigo *loops*).** Quando a crítica aponta uma lacuna **recorrente** (que voltaria em outras tarefas, não pontual), além de corrigir esta rodada, rascunhar a melhoria do sistema — nova RO, correção de skill do catálogo, ou entrada no ledger `correcoes.json` do projeto. "Não conserte só o caso; encode para todas as iterações futuras" (sustenta RO-07 e RI-04).

## Contabilidade de tokens (por modelo)

Ao concluir, cada subagente devolve seu consumo (`total_tokens`) e a duração junto com a resposta — **anotar na hora**, no fechamento de cada subagente (o dado não fica disponível depois). O relatório final traz a tabela detalhada, **uma linha por frente de trabalho**, incluindo o próprio orquestrador (Fable):

| Rodada | Frente | Modelo | Status | Tokens | Ferramenta | Duração | Nota |
|---|---|---|---|---|---|---|---|
| 1 | Planejamento + consolidação | Fable | ✅ | … | — | … | — |
| 1 | DAO de Cliente | Sonnet | ✅ | … | `java-jdbc-dao` | … | 9,2 |
| 1 | Lente segurança | Sonnet | ✅ | … | `especialista-seguranca` | … | 8,5 |
| 1 | Bateria de testes | Sonnet | ✅ | … | `testador-real` | … | — |
| 2 | … | … | … | … | … | … | … |

Colunas: **Frente** = a subtarefa/lente/testador; **Status** = ✅ concluída / 🔁 refeita / ❌ falhou; **Tokens** = `total_tokens` reportado (ou **não reportado** — declarado, nunca estimado em silêncio, RI-04); **Ferramenta** = skill do catálogo aplicada ("—" se nenhuma); **Duração** = tempo reportado do subagente; **Nota** = nota 0–10 recebida na avaliação da rodada (lentes: a nota que emitiram sobre o resultado; frentes de execução: a nota da lente correspondente à sua entrega; "—" quando não se aplica).

Fechar com o **resumo consolidado — sempre com os 4 modelos**, mesmo que algum não tenha sido usado (linha zerada):

| Modelo | Frentes | Tokens | % do total |
|---|---|---|---|
| Fable | … | … | … |
| Opus | … | … | … |
| Sonnet | … | … | … |
| Haiku | … | … | … |
| **Total da tarefa** | **…** | **…** | 100% |

Regras: tokens, não moeda — preço muda, tabela chumbada envelhece; quem converte é o Jeremias com o preço vigente. A tabela também é insumo de otimização: rodada seguinte pode rebaixar para Haiku o que Sonnet resolveu com folga.

## Regras do placar

- Nota é **por lente**, 0–10, sempre acompanhada do motivo e do que falta para subir — nota sem crítica acionável não vale.
- O placar de cada rodada é registrado (rodada, notas, FAILs abertos, o que mudou) — é ele que prova a evolução (RI-04).
- **Anti-estagnação:** se duas rodadas seguidas não melhoram nenhuma nota, parar antes do limite, reportar o impasse e perguntar ao Jeremias — insistir no mesmo plano é desperdício, não persistência.
- **Calibração da nota (faixas, proposta 2026-07-07, do harness GAN/ECC):** 1–3 = quebrado/genérico ("AI slop") · 4–6 = funciona mas cru, inconsistente · 7–8 = polido e coeso · 9–10 = excelente, à prova de borda (o piso do conjunto, RI-02). Serve para as lentes pontuarem consistente: lente que dá 9 num resultado que "só funciona" está calibrando frouxo — o auditor sinaliza.

## Guardrails (o que este orquestrador NUNCA faz)

- **Nunca executa subtarefa no próprio orquestrador** — nem "só essa rapidinha". Executor executa, maestro rege.
- **Nunca passa de 20 subagentes simultâneos por padrão** (execução + lentes + testador somados; até ~30 só em onda **Haiku-pura mecânica**, onde a consolidação é trivial — julgamento nunca alarga). Se o plano pedir mais, dividir em ondas sequenciais — cada onda respeita o teto vigente e é dimensionada pela regra de "largura da onda" do passo 2.
- **Nunca simula nota, teste ou evidência.** Lente que não rodou = declarada; teste que não executou = SKIP com motivo (sustenta RI-04).
- **Nunca roda bateria dinâmica contra produção nem contra dados reais do usuário.** A bateria do testador roda em ambiente de teste ou cópia-sandbox (ex.: cópia do `.accdb`, banco de QA); o que não der para rodar sem tocar produção vira **SKIP declarado com motivo** (prova executada, RI-04). *(cauda reconstruída em 2026-07-07 — o texto original truncou exatamente aqui; confira se casa com sua intenção.)*

## 🔗 Rede da skill

- **O que rege (chama como subagentes):** as 7 lentes de revisão + `auditor-responsabilidades` + `testador-real` (ou a instância do projeto) na avaliação; os geradores e `spec-*` do track na execução.
- **Não confundir com os `spec-*`:** eles encadeiam skills em ordem determinística; este decide **quem executa** e **quanta qualidade sai** (loop com nota de corte). Um `spec-` inteiro pode ser a subtarefa de um subagente.
- **Vem depois de:** `requisitos-descoberta` quando o pedido ainda é vago — defina *o que* construir antes de orquestrar *como*.
- **Persiste em:** `estado-projeto` — carrega o estado no início e grava o progresso ao fim de cada rodada, para retomar trabalho de várias sessões.
- **Governado por:** [[REGRAS-DE-OURO]] (RI-01…06 + RO aplicáveis), auditadas pelo `auditor-responsabilidades` a cada rodada.

---
*Histórico — 2026-07-07: cauda restaurada (o arquivo estava truncado em "Regras do placar") e adicionadas 4 evoluções vindas dos artigos do Claude Code — Passo 0 (triagem/comece simples), effort como 2º eixo, escalonamento diagnóstico modelo×effort, captura sistêmica e contexto limpo para as lentes. Ver `Novo Conceito/analise-loops-x-orquestrador-fable.md`.*
*Histórico — 2026-07-07 (2): incorporados conceitos do repo de dotfiles avaliado (skill-creator) — contrato de retorno de subagente (B2), gate de validação de status + retomada via `estado-projeto` (B1/B3) e formato de plano por fases (B4). Ver `Novo Conceito/avaliacao-repo-benjamin-dotfiles.md`.*
*Histórico — 2026-07-07 (3): juiz de visão no passo 4 (screenshot → crítica, do harness GAN/`auto-improve`); Comitê passou a 7 lentes de revisão (entrou `arquiteto-dados`); largura de onda adaptativa + piloto antes de onda grande, com teto ~30 só para onda Haiku-pura (passo 2 + guardrail). Ver `Novo Conceito/pesquisa-github-joias-diamantes-pepitas.md`.*
