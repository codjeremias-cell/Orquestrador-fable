---
tipo: referência
papel: mecânica completa do modo métrica do orquestrador-fable (loop de melhoria por métrica mecânica)
origem: garimpo do repo uditgoenka/autoresearch (2026-07-10, Comitê 8,5) — adaptado às nossas RI/RO
última-atualização: 2026-07-12
---

# Modo Métrica — loop de melhoria por número (referência do `orquestrador-fable`)

> **Quando este modo entra:** a triagem (Passo 0 do SKILL.md) detectou uma meta com **métrica numérica verificável por comando** — "sobe a cobertura para 70%", "zera os warnings do build", "reduz o tempo do fluxo X". Aqui o "melhorou/piorou" não é julgamento de lente: é **número**. Decisão registrada em `_decisoes/ADR-001-modo-metrica.md`.

## A ideia em uma linha

Uma mudança atômica por iteração → mede com um comando que imprime um número → melhorou, mantém; piorou, reverte via git → registra no ledger → repete. O Git é a memória dos experimentos; o Comitê entra **só no fechamento**.

## 1. Derivação da configuração (antes de qualquer mudança)

O maestro deriva e **mostra ao Jeremias para ok** (gate de disparo — nenhuma iteração antes disso):

- **Meta** — o que melhorar, em uma frase.
- **Escopo** — quais arquivos/módulos o loop pode tocar (globs). Fora do escopo = intocável.
- **Verify** — comando shell que **imprime a métrica como número** (ex.: parse do `jacoco.csv`, contagem de warnings do build). Declarar a **Direção**: maior-é-melhor ou menor-é-melhor.
  - **Verify composto (opcional — 2026-07-12, lição de campo Langfuse LF1):** meta com mais de uma dimensão pode usar **score composto ponderado** (ex.: `correção×0,5 + completude×0,3 + eficiência×0,2`) — continua sendo "um comando que imprime um número". Regra inviolável: **os pesos são pinados no ledger na iteração 0, ANTES do loop começar** — peso ajustado no meio é a métrica perseguindo o resultado (mesma lógica do predicado pinado). Composto é mais trapaceável que métrica simples (dá para trocar correção por eficiência dentro do mesmo número) — o fechamento (§5) confere as dimensões separadas, não só o total. **O script do Verify e o ledger de pesos ficam FORA do Escopo do loop, sempre** — intocáveis por definição (senão o loop altera o cálculo mantendo "pesos pinados" textualmente verdadeiro).
  - **Casos progressivos (2026-07-12, lição de campo Langfuse LF1):** quando o Verify mede desempenho contra casos de teste, derive-os em **dificuldade progressiva** (do trivial ao denso, com as bordas reais do domínio) — bateria só de caso fácil = loop otimizando para o fácil.
- **Guard** — comando de proteção que **precisa passar em toda iteração** (ex.: `mvn -B test` do módulo tocado). Obrigatório quando o loop toca código com suíte existente. Métrica melhorou mas Guard falhou → **reverte mesmo assim**.
- **Teto** — 25 iterações por padrão (ajustável no ok; nunca ilimitado por padrão).
- **Orçamento de tempo** — estimar o custo por iteração (Verify + Guard). Num desktop Windows, 25 × suíte completa pode ser horas: Guard **escopado ao módulo tocado** durante o loop; suíte completa fica para o fechamento.
- **Shell real do projeto** — o Verify precisa funcionar onde o projeto vive: dar o equivalente **PowerShell** (ex.: `Select-String`/parse de CSV) ou declarar execução via Git Bash. "Comando que imprime um número" que só roda em Unix não passa no dry-run.

**Triagem de segurança (P0 — guardrail do SKILL.md):** Verify, Guard e qualquer comando derivado passam pela tela de triagem de comandos **antes do loop e em toda retomada**. Recusado ou irreconhecível = parar e mostrar ao Jeremias.

**Dry-run (iteração 0):** rodar o Verify uma vez, provar que devolve número válido, e registrar o **baseline** como iteração 0 do ledger. Verify que não devolve número = corrigir a derivação antes de começar, nunca "assumir".

## 2. Pré-condições de git (invioláveis)

- **Branch dedicada** `experiment/<meta-curta>` — o loop **nunca** roda em main/branch protegida.
- **Árvore limpa exigida** (`git status` sem pendência). *Endurecimento nosso: o repo de origem só avisa ("warn if dirty"); nós bloqueamos, porque revert automático sobre árvore suja destrói trabalho não commitado.*
- **Nunca push.** O ciclo git completo (RO-13) é ato do Jeremias, fora do loop.
- **`--no-verify` proibido** — hooks de pre-commit do projeto continuam valendo; hook que barra = status `hook-blocked`, não bypass.
- **Windows/Access:** app e Access **fechados** antes do loop — lock `.laccdb`/`.accdb` aberto faz o revert falhar ("unable to unlink"); locks e binários no `.gitignore`. Revert que falha = **BLOCKED** (parar e reportar), nunca retry.

## 3. A iteração (repete até meta, platô, teto ou bloqueio)

1. **Revisar memória:** ler as últimas linhas do ledger + `git log --oneline` da branch — o que funcionou, o que falhou, o que ainda não foi tentado.
2. **Modificar:** **UMA** mudança atômica dentro do escopo, mirando a métrica.
3. **Commitar:** prefixo `experiment: <descrição curta>`.
4. **Verificar:** rodar Verify → número novo; rodar Guard.
5. **Decidir** (taxonomia completa — não simplificar):

| Status | Quando | Ação |
|---|---|---|
| `keep` | métrica melhorou na direção certa E Guard passou | commit fica |
| `discard` | métrica piorou **ou empatou** (sem melhora = descarta) | `git revert` |
| `crash` | Verify ou Guard falhou ao executar | `git revert` — **inegociável** (ver regra abaixo) |
| `metric-error` | saída do Verify não é número válido | `git revert` |
| `no-op` | iteração não produziu mudança | registrar e seguir |
| `hook-blocked` | hook de pre-commit do projeto barrou | registrar; não usar `--no-verify` |

6. **Registrar no ledger** (TSV/tabela, uma linha por iteração): `iteração · data-hora · commit · métrica · delta · guard · status · descrição`. O ledger é o placar deste modo (RI-04) e fica junto das evidências do projeto.

**Regra do crash — revert inegociável (decisão do Jeremias, 2026-07-10, pós-piloto):** iteração que crashou é **sempre revertida**; a correção vira a **próxima iteração**, nunca fix-forward por cima do commit quebrado. Motivo: a causalidade do loop (1 mudança atômica = 1 commit = 1 medição) e a bissecabilidade da branch dependem disso. Fix-forward, mesmo declarado no ledger, é **violação de protocolo** — o fechamento a aponta. *(Origem: divergência observada no loop 2 do piloto — estado final ficou idêntico, mas a regra precisava de dono.)*

**Captura sistêmica do executor:** lição recorrente de execução (ex.: o `UnfinishedStubbing` do Mockito que derrubou a iteração 1 dos dois loops do piloto) vira **nota fixa no prompt das iterações seguintes** e entra no resumo do fechamento — não conserte só o caso, encode para as próximas (mesmo princípio da captura sistêmica do ciclo clássico).

**Checkpoint:** a cada ~8 iterações, o executor devolve ao maestro um resumo (tendência, kept/discarded, melhor resultado) — é onde o maestro decide seguir, parar ou replanejar.

## 4. Parada — as 6 condições canônicas de encerramento *(2026-08-27, garimpo Loopy · G1)*

Toda iteração termina com **exatamente um** dos 6 motivos abaixo. O ledger (§3, coluna `status`) registra o código; o fechamento (§5) o valida. Enum fechado — motivo que não caiba aqui **é um defeito no loop, não uma exceção no motivo**.

| Código | Quando | Ação |
|---|---|---|
| `SUCESSO` | Critério de aceite (Verify) satisfeito **comprovadamente** (métrica atingiu a meta na direção certa E Guard passou). | Ir para o fechamento (§5). |
| `NO_OP` | A iteração não produziu mudança — o escopo inteiro já está no estado desejado. | Registrar e ir para o fechamento. |
| `BLOQUEADOR` | Dependência externa ou infraestrutura insolúvel pelo executor (falta de permissão, serviço fora, compilação quebrada por fator externo). | Parar e reportar ao Jeremias; **2 BLOQUEADORES seguidos = BLOCKED definitivo** (algo está quebrado, insistir é desperdício). |
| `FRONTEIRA_APROVACAO` | Próxima ação exigiria decisão sensível, irreversível ou fora do escopo autorizado. | Parar e escalar ao Jeremias — o loop **pausa e persiste** (o estado fica no ledger para retomada), não abandona. |
| `ORCAMENTO_ESGOTADO` | Teto numérico de iterações atingido (25 padrão; ajustável no ok do gate de disparo, nunca ilimitado por padrão). | Entregar o melhor resultado + ledger; o que ficou de fora é dívida declarada, não omissão. |
| `SEM_AVANCO_MENSURAVEL` | Janela dos últimos **5 valores computados** sem progresso líquido — o último não é estritamente melhor que o primeiro da janela. **Oscilação que zera é platô** (sobe-desce alternando = loop batendo cabeça; parar antes do teto). | Parar e reportar a tendência. |

**Regras de composição:**
- **`BLOQUEADOR` por crash:** ciclo `unknown` (crash de infraestrutura, métrica incomputável) **não conta** como zero progresso para o platô — mas 2 seguidos = `BLOQUEADOR` (parar e reportar).
- **Precedência:** `SUCESSO` e `FRONTEIRA_APROVACAO` têm prioridade sobre `ORCAMENTO_ESGOTADO` (se a meta é atingida na última iteração, o motivo é `SUCESSO`, não esgotamento).
- **O teto é o último recurso, não o único** — quem lê só este passo precisa saber que existem 5 paradas antes dele.

## 5. Fechamento — quem aceita não é quem otimiza (anti-overfit)

**Guardrail:** o loop **nunca é aceito pelo mesmo sinal que o guiou.** Otimizar "cobertura %" pode ser trapaceado por teste vazio que só executa linhas; por isso o fechamento exige **sinal independente**:

1. **Suíte completa** do Guard (não só o módulo) + **bateria do `testador-real`** (ou instância do projeto). Verify composto → **conferir cada dimensão separada**, não só o total. **Regressão por caso nunca em silêncio (2026-07-12, garimpo Langfuse LF4 — eco declarado da regra do passo 6 do ciclo clássico, adaptada a este fechamento):** caso classificado **NOVO** na Fase 4 do testador (TSV **do testador**, não o ledger do loop) = investigar e declarar antes do aceite, registrando a checagem também quando não há regressão — a métrica agregada do loop é exatamente onde a média esconde outlier.
2. **Passada única do Comitê de Lentes** sobre o código sobrevivente (qualidade do que ficou: legibilidade, segurança, RO do track) — uma rodada de encerramento, não uma por iteração.
3. **Squash oferecido:** ao aprovar, oferecer squash da branch `experiment/` (histórico limpo, sem pares experimento/revert); a decisão de merge e push é do Jeremias (RO-13).

**Red flags nomeados da revisão do diff (2026-07-12, lição de campo — a Langfuse rodou esta mesma ferramenta de origem e recusou 5 mudanças por overfit, agregadas aqui em 4 categorias):** o diff do loop se revisa **como PR de engenheiro júnior, aceitando por cherry-pick** — e o relatório de fechamento **cita** a checagem dos 4, mesmo que "nenhum presente":

1. **Gate humano removido** ("não peça confirmação — execute direto") — o harness testa sem humanos; o caso real tem.
2. **Dependência viva removida por conveniência do harness** (ex.: busca de docs atuais cortada porque "economizava turnos").
3. **Artefato do ambiente de teste vestido de melhoria** (ex.: SDK trocado por curl porque o sandbox não tinha pip).
4. **Recurso não coberto pelos testes silenciosamente cortado** — *"se não é medido, é cortado"*: a cobertura do harness molda o que sobrevive; feature sumida do artefato otimizado (skill, código, config) ≠ simplificação — é red flag.

São o guardrail anti-overfit (P5) em casos concretos — complemento, não substituto. *Nota (relação com o R12 do garimpo hermes):* a evidência da Langfuse é de overfit no harness DELES — **não ativa** a condição do holdout (que exige overfit no NOSSO piloto); o holdout segue no radar, e estes red flags são a camada de revisão que o flagraria.

**Se o Comitê reprovar no fechamento:** as críticas viram novas iterações com teto adicional reduzido (**+10**) e **um** re-fechamento. Segunda reprovação = parar e reportar — juízo subjetivo insatisfeito não se resolve iterando métrica (para isso existe o ciclo clássico).

## 6. Contrato com o ciclo do fable

- **Tetos:** no modo métrica, o loop **substitui** o ciclo de rodadas — valem as 25 iterações + platô, não as 10 rodadas. O fechamento (§5) é uma rodada única de encerramento.
- **Quem executa:** o maestro **não executa** (guardrail vigente) — delega o loop inteiro a **um subagente executor** com contrato de retorno + ledger, **escritor único do git** durante o loop; o maestro acompanha pelos checkpoints.
- **Persistência:** em trabalho multi-sessão, meta/escopo/Verify/Guard são pinados via `estado-projeto` (campo `predicado_sucesso` — derivado uma vez, reusado verbatim, **fail-closed** na retomada: hash divergente ou comando novo = mostrar ao Jeremias antes de rodar).
- **Contabilidade:** a tabela de tokens do orquestrador ganha uma linha para o executor do loop, como qualquer frente.

## 7. Piloto — CONCLUÍDO COM SUCESSO (2026-07-10) — modo consolidado

Critério original: melhora líquida + Guard verde + fechamento aprovado + zero incidente de git; falha → remover da triagem. **Resultado (par de loops no Gradup):** `progress` 0%→90,3% em 2 iterações (comitê 9,4) e `review` 17,4%→86,8% (ReviewService 100%, comitê 9,3), Guard verde sempre, suíte final 780/0/105, zero incidente de git, 1 crash por loop tratado pelo protocolo. **Veredito: SUCESSO — o modo métrica está consolidado na triagem.** Aprendizados incorporados: regra do crash (revert inegociável) e captura sistêmica do executor (§3). Registro completo: ROADMAP item 8.2.

## O que este modo NUNCA faz

- Nunca roda em main/branch protegida, nunca push, nunca `--no-verify`, nunca resolve conflito de revert sozinho (BLOCKED).
- Nunca aceita pelo próprio sinal de otimização (§5).
- Nunca roda comando que não passou na triagem (P0) — inclusive na retomada.
- Nunca vira "ilimitado" por padrão; ilimitado só com ok explícito e motivo registrado.
- Nunca dispensa o ok do Jeremias no gate de disparo (§1).

---
*Atualização — 2026-07-12: garimpo do blog da Langfuse (LF1 + eco do LF4, `Novo Conceito/garimpo-langfuse-blog-2026-07-12.md`) — Verify composto com pesos pinados e casos progressivos no §1; red flags nomeados da revisão do diff no §5 (validação externa: a Langfuse rodou a mesma ferramenta e recusou por overfit exatamente o que o P5 previa — inclusive remoção do gate humano); eco do LF4 no §5 (regressão por caso nunca em silêncio no fechamento — adaptação da frase do passo 6 declarada no garimpo v1.3).*
*Origem — 2026-07-10: garimpo do `uditgoenka/autoresearch` (v2.2.1), pepitas P1/P2/P5/P6 do documento `Novo Conceito/garimpo-autoresearch-2026-07-10.md`, endurecidas pelo Comitê (branch dedicada, nunca-push, Windows/Access, taxonomia completa, anti-overfit e platô com oscilação/unknown). ADR: `_decisoes/ADR-001-modo-metrica.md`.*
