---
tipo: roadmap
papel: pendências e próximos passos do conjunto único (radar)
última-atualização: 2026-08-18
versão: v1.9
---

# 🛰️ Radar — Pendências do Catálogo

> O que ficou combinado para **não esquecermos**. Cada item tem contexto suficiente para retomar do zero. Status: ➡️ migrado para o ledger · 🏗️ em andamento · ✅ feito.

> ⚠️ **Este arquivo deixou de ser a fila.** Em 2026-08-18 a **T24** triou as 12 marcas pendentes que
> nunca haviam migrado, e a fila do Catálogo passou a ser **`estado/TAREFAS.md`**, derivado de
> `estado/estado.json`. As marcas abaixo viraram **ponteiros ➡️** para a tarefa correspondente.
> Relatório da triagem: `estado/artefatos/triagem-roadmap-2026-08-18.md`.
>
> **Não abra pendência nova aqui.** Item novo nasce no ledger; este arquivo guarda o *contexto*
> histórico de cada frente, não o estado dela.

---

## ✅ 0. Evolução do catálogo a partir de repositórios de terceiros (concluído 2026-07-07)

> ✅ **Feito em 2026-07-07:** analisados 4 repositórios de terceiros (`ruvnet/ruflo`, `nexu-io/open-design`, `obra/superpowers`, `affaan-m/ECC`) em cópia isolada (`_arquivo-morto/novo-conceito-2026-07-09/`), com checagem de segurança prévia (sem código malicioso em nenhum) e avaliação do Comitê de Lentes rodada a rodada (críticas fechadas antes de promover, incluindo um erro factual real de numeração WCAG que o próprio Comitê pegou). Promovido ao catálogo oficial: **RO-14** (ledger de regressão) e reforço da RI-01 (ADR como trava) em `REGRAS-DE-OURO.md`; **§11** (baseline antes do eval) em `PADRAO-DE-AUTORIA.md`; atualizações em `testador-real`, `arquiteto-software` (ADR com data/decisores/substituição), `orquestrador-fable` (gate de ADR), `dev-senior` (depuração sistemática + Java moderno condicionado ao JDK), `especialista-seguranca` (checklist rápido), `designer-ux-ui` (Design Read, Modo Polish Pass, 3 proibições novas, 4 critérios WCAG 2.2). Registro completo da análise, das notas do Comitê e do que foi **rejeitado** (com motivo) em `_arquivo-morto/novo-conceito-2026-07-09/PROPOSTA-EVOLUCAO-v1.md` (mantido como registro histórico — RI-04). Achado incidental: `PADRAO-DE-AUTORIA.md` tinha o final truncado (perdeu a seção Histórico) antes mesmo desta rodada — pendente restaurar do Git.

**Próximo passo mecânico:** rodar `deploy-skills.ps1` para sincronizar `.claude/skills/` (runtime) com o catálogo agora atualizado.

---

## 🏗️ 1. Track Web / Supabase (Embalo) — montar o segundo track

> 🏗️ **Avanço até 2026-07-19:** as **RO-W1..W8** do track foram ratificadas (commit `53cdff0`) e o catálogo já tem as skills do stack: `web-vanilla-supabase-pwa` (skill #54, garimpo Embalo), `web-component`, `web-data-layer`, `spec-frontend-web` e `frontend-stack-decisor` (com `referencia-caso-real-embalo.md`). **O que segue faltando:** a instância de testador web com Playwright + regra do console (passo 6 abaixo — guardada até existir app para testar) e o `embalo-testador` (item 4).

**O quê:** criar o conjunto de geradores do stack web do Embalo (HTML + CSS + JS vanilla + Supabase: PostgreSQL/RLS, Auth, Storage), espelhando o que o track Java faz para o JavaFX.

**Por quê:** o Embalo é 1 dos 4 projetos e hoje não tem nenhum gerador. Fecha o "multi-código" de verdade.

**Como (seguir o [[PADRAO-DE-AUTORIA]] §8 — adicionar um track):**
1. **Extrair as convenções reais da memória do Embalo** — RLS, políticas, Auth, Storage, estrutura de pastas, padrão de fetch/estado. **Não inventar** (RO-01).
2. Registrar as **RO específicas do stack Web/Supabase** na seção reservada de [[REGRAS-DE-OURO]].
3. Criar os geradores com prefixo `web-` / `supabase-`, p.ex.: `web-page`, `web-component`, `supabase-table-rls`, `supabase-auth`, `web-api-client`, `web-form`.
4. Criar o orquestrador `spec-web-feature` (e, se fizer sentido, `spec-web-new-system`).
5. As lentes do método **não mudam** — passam a auditar o track novo automaticamente.
6. **Testador web (pepita 2026-07-07, do harness GAN/ECC):** a instância de testador do track web deve usar **Playwright** na bateria dinâmica E2E — interagir com o app vivo (clicar, preencher formulário, testar estado de erro), não só checar código. Modo de avaliação por tipo de artefato: `playwright` (app com UI), `screenshot` (estático/design), `code-only` (API/CLI). **Regra do console (2026-07-12, garimpo hermes-agent P14):** a instância web lê o console do navegador após **cada navegação e interação significativa** — erro JS silencioso é achado com severidade própria, mesmo com a tela "funcionando". Guardado aqui até o track web existir — não vira skill fantasma antes disso.

**Pré-requisito / bloqueio:** a memória do Embalo está no junction `memoria-embalo/`, que **não abre no Cowork** (resolve fora da pasta conectada). Para extrair as convenções: rodar pelo Claude Code, ou o Mestre cola o conteúdo dos arquivos-chave do Embalo aqui.

---

## ✅ 2. Limpar a duplicação — fonte única (concluído 2026-06-15)

> ✅ **Feito em 2026-06-15:** fonte única = `Catalogo-Skills-Unificado/`; runtime `.claude/skills/` sincronizado com as 20 skills (método + track Java); `skills/` e `backup/` movidos para `_arquivo-morto/` + snapshot de segurança `seguranca-pre-limpeza-2026-06-15.tar.gz`; `CLAUDE.md` atualizado (fonte vs runtime). Reversível: basta restaurar de `_arquivo-morto/`.

**O quê:** aposentar as cópias espalhadas das lentes agora que `Catalogo-Skills-Unificado/` é a fonte canônica:
- `.claude/skills/` (8 lentes)
- `skills/` (7 lentes, versão navegável)
- `backup/*.zip` (zips antigos das lentes)

**Por quê:** hoje a mesma lente existe em 3–4 lugares; manter sincronia manual é fonte de erro.

**Cuidado / dependência (não apagar às cegas):**
- O `CLAUDE.md` do cofre declara que **a fonte de runtime é `.claude/skills/`**. Então, antes de remover, decidir o modelo: ou (a) o catálogo vira o novo runtime (apontar `CLAUDE.md` para `Catalogo-Skills-Unificado/skills/`, ou fazer deploy/junction de lá para `.claude/skills/`), ou (b) manter `.claude/skills/` como runtime e gerar de `skills/` por cópia.
- `backup/*.zip` pode ir para um arquivo morto, não precisa apagar.
- **Operação destrutiva → exige "ok" explícito do Mestre** (apagar arquivos). Fazer com Git limpo para reversão (RO-13).

**Passos sugeridos quando for executar:**
1. Confirmar o modelo de runtime (a ou b acima).
2. Atualizar `CLAUDE.md` e `LEIA-PRIMEIRO.md`/índice para apontar para a fonte única.
3. Remover as cópias redundantes (com Git, em commit dedicado e reversível).
4. Validar que as lentes ainda carregam por gatilho na sessão.

---

## ✅ 3. Reforma Lendária do catálogo (concluída 2026-07-05)

> ✅ **Feito em 2026-07-05:** todas as skills refatoradas para o **Selo Lendário** ([[PADRAO-DE-AUTORIA]] §10) com o bloco Rede da skill; absorvidas `javafx-dashboard` e `gradup-testador` do runtime; criadas `testador-real`, `requisitos-descoberta`, `docs-projeto` e `spec-projeto-completo`; índices e governança atualizados; deploy ressincronizado. Total: 28 skills.

---

## ✅ 4. Unificação dos testadores no testador-real universal (concluído 2026-09-04)

> ✅ **Feito em 2026-09-04 (decisão do Jeremias):** O modelo de instâncias locais fragmentadas por projeto foi formalmente descontinuado. Em vez de manter e sincronizar cópias separadas (`gradup-testador`, `testador-sigcot`, `sentinela-testador`, `escalaoper-testador`, `embalo-testador`), todo o ecossistema passou a ser atendido pela skill canônica única **[`testador-real`](skills/testador-real/SKILL.md)** com auto-detecção polimórfica de stack no Pré-voo. As tarefas **C-26** e **C-30** foram concluídas por unificação e absorção no ledger.

**Por quê:** Manter cópias separadas gerava débito perpétuo de sincronização a cada evolução do template canônico e travava tarefas no ledger por dependências externas desnecessárias. O executor universal inspeciona dinamicamente o repositório atual e roda a bateria adequada (Spring Boot, JavaFX Desktop, Web/Playwright, Mobile/Flutter, CLI).

---

## ✅ 5. Geradores do track Java Web / Spring Boot (Gradup) (concluído 2026-07-05)

> ✅ **Feito em 2026-07-05:** criados `springboot-entity` (entidade JPA + migração Flyway), `springboot-repository-service` (repositório Spring Data + serviço transacional), `springboot-controller-thymeleaf` (controller + template acessível) e o orquestrador `spec-springboot-crud-feature`. Convenções extraídas por leitura real do Gradup (entidade `Course`, migração `V4__catalog.sql`, `CourseRepository`, `CourseAuthoringService`, `InstructorCourseController`, `curso-form.html`) — RO-01 respeitada, nada suposto.

**O quê:** os geradores `springboot-*` (entidade + migração Flyway, repositório/serviço, controller + Thymeleaf com a11y) espelhando o track JavaFX, a partir das convenções **reais** do Gradup (RO-SB1…8 já registradas na [[REGRAS-DE-OURO]]).

**Por quê:** o track já tinha governança e testador, mas não tinha geradores — a construção era manual via lentes.

---

## ✅ 6. Arquivar `javafx-dashboard-workspace` do runtime (concluído 2026-07-05)

> ✅ **Feito em 2026-07-05** (ok do Jeremias): a pasta `~\.claude\skills\javafx-dashboard-workspace\` (não era skill — workspace de benchmark/eval, sem `SKILL.md`) foi movida para `_arquivo-morto/javafx-dashboard-workspace/` no cofre. Runtime `.claude/skills/` agora contém só skills reais.

---

## ✅ 7. Domínio Riqueza & Finanças — trio de lentes (concluído 2026-07-10 — deploy rodado)

> 🏗️ **Criado em 2026-07-10:** trio `conselheiro-financeiro` / `plano-riqueza` / `conteudo-riqueza`, a partir de 13 análises cobrindo 20 livros/e-books de riqueza (projeto em `livros e dicas, como ficar rico com a internet\analises-livros\`). Passaram por painel de 3 juízes (fidelidade/engenharia/segurança) com correções aplicadas, e foram reescritas no padrão "Lente" deste catálogo (`referencia/`, bloco 🔗 Rede da skill, Regras de Ouro compartilhadas) — ver entrada v2.7 no [[README]].

> ✅ **Auditoria concluída em 2026-07-10:** passagem formal pela lente `auditor-responsabilidades` (RACI, checagem RI-01…06, não-conformidades) — veredito **aprovado com ressalvas**. Relatório completo em `_auditoria/2026-07-10-auditor-riqueza-financas.md`. Achado incidental relevante: a primeira gravação dos SKILL.md no dispositivo via `device_commit_files` retornou sucesso mas gravou arquivos corrompidos (truncamento/bytes nulos) — detectado só porque a auditoria conferiu o conteúdo byte a byte; corrigido via `device_bash` (grafia direta por base64) e reverificado. Lição: para entregas grandes por esse caminho neste ambiente, conferir tamanho em bytes e trecho final em vez de confiar no retorno "written".

**O que falta (1 passo mecânico, não feito ainda por esta sessão):**
1. ✅ **Rodar `deploy-skills.ps1`** — **feito em 2026-07-10** (deploy do garimpo levou junto: 52 skills no runtime, trio Riqueza no ar). Item 7 concluído.

**Observação:** este domínio é o primeiro do catálogo que não gera código — é conteúdo/conselho. Se surgir um segundo domínio não-código no futuro, vale generalizar a categoria "Domínio" na tabela de camadas do [[README]] em vez de tratar caso a caso.

---

## 🏗️ 8. Garimpo autoresearch — aplicado (Lotes 1+2), pendências declaradas (2026-07-10)

> 🏗️ **Feito em 2026-07-10:** repo `uditgoenka/autoresearch` avaliado pelo rito do item 0 (clone isolado + varredura de segurança limpa + Comitê 8,5 com ressalvas fechadas) — registro completo, pepitas e rejeitados com motivo em `Novo Conceito/garimpo-autoresearch-2026-07-10.md`. Lotes 1+2 aplicados na fonte com ok do Jeremias (ver histórico v2.8 do [[README]] e `_decisoes/ADR-001-modo-metrica.md`).

**O que falta:**
1. ✅ **Rodar `deploy-skills.ps1`** — **feito em 2026-07-10** (52 skills no runtime; o número conferiu: 48 Reforma + `painel-de-juizes` + trio Riqueza — a contagem antiga "51" não incluía a painel no índice, corrigido no README). ✅ **T26 — Unificação dos testadores no testador-real universal (concluído 2026-09-04):** Em vez de manter e sincronizar instâncias locais (`gradup-testador`, `testador-sigcot`, `sentinela-testador`, `escalaoper-testador`), todo o ecossistema passou a ser atendido pelo `testador-real` polimórfico universal, encerrando a necessidade de sincronização manual.
2. ✅ **Piloto do modo métrica — SUCESSO (2026-07-10): modo consolidado na triagem.** Par de loops no Gradup: `progress` 0%→**90,3%** em 2 iterações (11 testes, comitê **9,4**) e `review` 17,4%→**86,8%** (26 testes, ReviewService 100%, comitê **9,3**); Guard verde sempre (suíte final 780/0/105); zero incidente de git; 1 crash por loop (`UnfinishedStubbing`) tratado pelo protocolo. Custo: ~35s/iteração, fechado em 2 iterações úteis por loop. Aprendizados incorporados à referência: **regra do crash = revert inegociável** (decisão do Jeremias — fix-forward declarado do loop 2 registrado como divergência, não como precedente) e **captura sistêmica do executor** (lição recorrente vira nota fixa no prompt). Backlog não-bloqueante registrado no Gradup (assert de ordem no showcase, setId por reflection, Clock injetável).
   - ✅ **Primeira validação de campo (2026-07-10, Gradup):** "zera os warnings do build" acionou o modo corretamente — triagem, gate de disparo e baseline (iteração 0) todos conforme a referência. O dry-run revelou **meta já no alvo** (zero warning real de compilador/dependência; os 30 `[WARNING]` eram marcadores de skip dos testes DB-gated — arquitetura proposital) e o loop foi **recusado honestamente no gate** (regra: não iterar número que já está no alvo; "consertar" os marcadores desmontaria o padrão DB-gated). O ruído real (avisos LF/CRLF do git) morreu com `.gitattributes` em 2 commits pontuais, sem loop — anti-desperdício funcionando.
   - ➡️ **T27** — **Falta o loop girar de verdade** (iterar→verify→keep/discard→ledger→fechamento seguem não exercitados): próxima meta com gordura real — cobertura de testes do Gradup (via JaCoCo, que o gate pode propor) ou warnings do SIGCOT quando ele desocupar.
3. ✅ **Lote 3 — aplicado em 2026-07-10** (aprovação do Jeremias "1, 2 e 3 na sequência"): P10 — **modo wiki** no `docs-projeto` (manifesto write-ahead com vocabulário `pendente/gerada/pulada-humana`, colisão por `generated_by`, varredura de segredo com placeholder, caps com divisão declarada); P12 — rigor de desempenho no `testador-real` §3h (amostra independente **por TIPO**: novo processo no desktop/CLI, nova sessão no web; banda ≤5% = ruído; coluna `tempo_ms` no TSV). Rodada de aplicação: auditor **9,1** · segurança **8,5** · qa **8,4** — ressalvas incorporadas (registro no garimpo §6). Falta o redeploy (`deploy-skills.ps1`) para levar ao runtime. **Prova de escopo (ressalva do auditor):** antes de commitar, conferir no `git status` do cofre que a rodada tocou só docs-projeto, testador-real, ROADMAP, garimpo e o estudo novo.
4. 🏗️ **P11 — estudo de hooks REDIGIDO em 2026-07-10:** `Novo Conceito/estudo-hooks-governanca-mecanica-2026-07-10.md` — 4 hooks desenhados (destrutivos, segredos com auto-proteção, contexto, produção), modelo de ameaças sobre os anti-padrões A1–A4 do repo garimpado, enquadramento "quebra-molas anti-deriva" (não trava física), plano de piloto no Gradup com critério de reversão. Revisado pela `especialista-seguranca` (8,5). **Decisão pendente do Jeremias → ➡️ T18 no ledger:** (a) ok para construir os 4 hooks + testes, (b) projeto-piloto. **(c) respondida em 2026-08-18: Node v24.15.0 presente** (medido por `node --version`).
5. ✅ **RO-15 e anti-estagnação v2 — REVISADAS em 2026-08-18 (T28).** RO-15: corte **2/2 mantido** — 8 dos 16 garimpos declaram saturação, e ela discrimina nos dois sentidos. Falta a norma do encerramento **por orçamento** → **T34**. Anti-estagnação: **não revisável** — o detector não é computável do dado persistido (grão `rodada×frente` × `rodada×lente`) → **T35**, que vem **antes** da T27. _Texto original:_ **revisar calibração** após 3 usos reais (2 itens/2 rodadas e >3 trocas/5 rodadas foram calibrações nossas — ajustar com a prática).

---

## 🏗️ 9. Garimpo hermes-agent — aplicado (Lotes 1+2+3), pendências declaradas (2026-07-12)

> 🏗️ **Feito em 2026-07-12:** repo `nousresearch/hermes-agent` (v0.18.2, MIT) avaliado pelo rito do item 0 (clone isolado + varredura de segurança limpa, incluindo unicode/bidi + Comitê **8,7** com ressalvas fechadas) — registro completo, 14 pepitas e 14 rejeitados com motivo em `Novo Conceito/garimpo-hermes-agent-2026-07-12.md`. **Lotes 1+2+3 aplicados na fonte com ok do Jeremias** ("podemos implementar", 2026-07-12): REGRAS-DE-OURO v2.7 (anti-fabricação + hierarquia de canal), PADRAO-DE-AUTORIA v2.2 (§12 escrita do corpo + 10 princípios + DoD), `memoria-de-projeto` (declarativa/7 dias/roteamento + herdado=referência), `dev-senior` (premissa, laço vermelho-verde, Regra dos Três, Chesterton, anti-snapshot), `especialista-seguranca` (canal por origem + âncora), `inovacao-melhorias` (degrau da escada), `orquestrador-fable` (higiene de delegação + gate de conformidade), `painel-de-juizes` (veredito fail-closed), `qa-usabilidade` (filtro de pragmatismo 4 cores), `arquiteto-software`+`requisitos-descoberta` (spike), `estado-projeto` (herdado=referência), estudo de hooks (A5 + detecção×ação + âncora) e **estudo novo** `Novo Conceito/estudo-modo-agendado-2026-07-12.md` (P12 — construção pendente de decisão, §8 do estudo).

**O que falta:**
1. ✅ **Rodar `deploy-skills.ps1`** — **feito em 2026-07-19** (deploy da sessão de manutenção: 55 skills no runtime global + local do cofre).
2. ✅ **T26 — Unificação dos testadores no testador-real universal (concluído 2026-09-04):** Concluída pela decisão de unificação do ecossistema no `testador-real` universal.
3. ➡️ **T19** (já estava no ledger antes desta triagem) — **Decisão do estudo do modo agendado** (§8 do estudo): construir mecânica + piloto, ou arquivar no radar.
4. ✅ **Revisões de calibração — EXECUTADAS em 2026-08-18 (T28).** Dos 11 critérios do §5: **passaram** P6 (degrau em **16/16** garimpos), P1 (60 skills, média **137** linhas, nenhuma acima de 500), P2/P3 (hierarquia de canal em 15 arquivos) e P4/P11 (**9** consolidações, zero imperativo). **Ausência declarada** em P7, P8 e P10. P5/P9, P12, P13 e P14 seguem sem gatilho. _Texto original:_ **Revisões de calibração** conforme §5 do garimpo (P1 após 5 edições de skill; P2/P3 após 5 entregas auditadas ou 30 dias; demais na primeira exercitação real).
5. ➡️ **T31** (candidato mais forte a abandono — facultativo e sem caso real desde 07/2026) — **Aviso de sedimento no `validar-skills.ps1`** (facultativo do P1): heurística "skill que só cresce entre versões = candidata a sedimento" — decidir fazer/não fazer na próxima manutenção do script (o `.ps1` fica fora da cópia das sessões Cowork).
6. ✅ **Microadição RATIFICADA pelo Jeremias em 2026-07-12:** campo "canal de instrução verificado: sim/não/n-a" no mapa de cobertura da `especialista-seguranca` (coerente com o P3; mesma classe do precedente "API Top 10 x/10").

---

## 🏗️ 10. Garimpo Langfuse — Lote 1 aplicado, Lote 2 aguardando (2026-07-12)

> 🏗️ **Feito em 2026-07-12:** blog da Langfuse avaliado pelo rito adaptado a fonte-blog (leitura como DADO — 1º caso real da hierarquia de canal; reconferência 6/6 com responsáveis; Anexo A de disciplina de canal). Comitê: proposta **8,3** · aplicação **8,7**, ressalvas fechadas. Registro: `Novo Conceito/garimpo-langfuse-blog-2026-07-12.md`. **Lote 1 aplicado com ok do Jeremias:** LF1 (lições de campo no `referencia/modo-metrica.md` + anotação no ADR-001 — red flags nomeados, Verify composto com pesos pinados e fora do Escopo, casos progressivos), LF2+LF6 (PADRAO §11: acionamento/aderência com fronteiras + sintéticos com origem registrada + placar-exemplo), LF3 (PADRAO §12: modificadores de obrigatoriedade + régua de escalada com exceção de risco nomeado), evidência externa no Selo §10.1. PADRAO agora v2.3.

**O que falta:**
1. ✅ **Lote 2 (LF4, LF5) — aplicado em 2026-07-12** com ok do Jeremias (rodada de aplicação 8,2: auditor 8,4 · arquiteto 8,4 · qa 7,9, ressalvas incorporadas): regressão por caso no passo 6 do fable (taxonomia ancorada na Fase 4 do testador, ausência declarada, desfecho por rodada × entrega final) + eco declarado no fechamento do modo métrica; categorias de falha no COMO-COLHER v1.1 (bootstrap, endereço, bloco de propostas) + 1 linha na `memoria-de-projeto` (a casa da lista — destino do §2 da proposta). **Garimpo 100% aplicado (6/6).**
2. ✅ **Revisão de 60 dias — EXECUTADA em 2026-08-18 (T25), 25 dias antes do alvo.** **Nenhuma das 6 pepitas removida.** LF2+LF6 têm caso real forte (11 dos 22 placares com a coluna `acionou`; em `java-db-foundation` o caso 3 com `aderiu = não` **pegou defeito real da skill**). LF3a cumprida; **LF3b reprovada** — zero skills declararam N, gatilho disparou dezenas de vezes → **T32** (travar no validador ou remover). LF1 e LF4: gatilho nunca disparou (o loop do modo métrica não girou — T27), relógio reancorado ao evento. LF5 travada na ratificação das categorias → **T33**. Achado sobre a própria regra: 4 das 6 pepitas têm gatilho de **evento**, e a revisão mediu **calendário** — ao pé da letra teria removido três pepitas boas. Laudo: `estado/artefatos/revisao-60-dias-langfuse-2026-08-18.md`. _Texto original da marca:_ **Revisão de 60 dias (data-alvo ~2026-09-12):** pepita sem caso real até lá = remover com motivo (dono: quem conduzir a sessão de manutenção da data; critérios por pepita no §5 do garimpo). Inclui a nota da rodada L2: tensão temporal "insumo do pareado" (anotada pelo auditor) reavaliada aí.
3. ✅ **`deploy-skills.ps1`** — **feito em 2026-07-19** junto do redeploy do item 9.1.

---

## 🏗️ 11. Evolução das 52 skills a partir da auditoria de notas (2026-07-13) — PONTO DE PARTIDA DA SESSÃO DE EVOLUÇÕES

> 📊 **Feito em 2026-07-13:** auditoria individual das **52 skills** com nota, pela rubrica do PADRAO v2.3 (6 avaliadores paralelos, leitura integral de cada SKILL.md). **Média geral 8,45** — "polido e coeso"; zero skill quebrada (nenhuma < 7,5); elite na excelência (`testador-real` 9,2 · `qa-usabilidade`/`estado-projeto`/`spec-mobile-app`/`conteudo-riqueza` 9,0). Relatório completo — ranking, notas, forças/fraquezas por skill, 6 achados sistêmicos e backlog: [[2026-07-13-notas-52-skills]] (demais relatórios de auditoria: [[_indice-auditoria|índice de Auditoria]]).

**👉 Handoff para a sessão de evoluções (nova, possivelmente em outra conta):** conecte a pasta do cofre e comece por `LEIA-PRIMEIRO.md` → este item. A auditoria é **diagnóstico — nada foi editado**; toda melhoria segue o rito (proposta → Comitê de Lentes → ok do Jeremias por lote → aplicação → gravação verificada), como os garimpos dos itens 8-10. O backlog abaixo é a fila sugerida (o "ok" é POR item, não global).

**Backlog priorizado (do §6 do relatório):**
1. ✅ **P1 — Poda de duplicação — CONCLUÍDO em 2026-07-13:** mapa fino (5 analistas) confirmou **85 duplicações** nos 20 SKILL.md; proposta v1.1 pelo Comitê (arquiteto 8,5 · auditor 8,4 · qa 6,5, ressalvas incorporadas — regras U1-U7: gloss inline obrigatório, guardrail de segurança literal, descriptions intocadas); Jeremias aprovou os 5 lotes + correção da Rede da `plano-riqueza` + 2 emendas ao PADRAO (v2.4). **75 itens aplicados** (~70 linhas de duplicação removidas), gate do auditor pós-aplicação: todos os lotes aprovados. Bônus: bloco RI do `auditor-responsabilidades` realinhado à governança v2.7 (divergência silenciosa eliminada). Registro completo: `_auditoria/2026-07-13-P1-poda-aplicacao.md`. **Pendências geradas:** colisão RO-02 rodapé×governança (decisão do Jeremias), P1.b (eco corpo↔`referencia/`), redeploy.
2. ✅ **P2 — Evidência mínima — FECHADO em 2026-08-18 (T29).** Dos 7 candidatos da auditoria, **6 já fechavam**, cada um pela régua do seu tipo (`mvn compile` + round-trip · executar o `.exe` · `tsc --noEmit` · `javac` + deps · seção "prova executada" · e `arquiteto-dados`, que é lente e fecha por campos declarados). Sobrou 1: a `javafx-screen-fxml` tinha o bloco mas não nomeava o ato — passou a dizer `javac` + dependências reais. _Texto original:_ **P2 — Evidência mínima** nos ~6 casos frouxos (RI-04). **Escopo reduzido em 2026-08-18:** o caso-cabeça `javafx-screen-fxml` **já tem** o bloco “Antes de declarar pronto, responda com evidência: 1. Compila?” — falta só aprofundá-lo ao nível da `javafx-dashboard` (`javac` + dependências reais, binding `fx:id`↔`@FXML`, SKIP declarado). Os outros ~5 casos **não foram medidos**.
3. ✅ **P3 — "NÃO acione" simétrico — FECHADO 6/6 em 2026-08-18 (T29).** Faltava só a `memoria-de-projeto`, e era exatamente a assimetria que o item nomeava: a `estado-projeto` apontava para ela e ela não apontava de volta. _Texto original:_ **P3 — "NÃO acione" simétrico**. **Medido em 2026-08-18: 5 das 6 colisões já estão fechadas** (arquiteto-software, arquiteto-dados, designer-ux-ui, qa-usabilidade, estado-projeto); 54 das 60 skills têm a cláusula. **Falta uma:** `memoria-de-projeto` — e é exatamente a assimetria memória↔estado, porque a `estado-projeto` aponta para ela e ela não aponta de volta.
4. ✅ **P4 — Few-shots §5b** — **onda rodada em 2026-07-18**: referências de código real criadas nas skills (`referencia-exemplos-reais-sigo.md` nos geradores Java/JavaFX, `referencia-exemplos-reais-gradup.md` no track Spring, `referencia-padroes-universais-flutter.md` no mobile, exemplos montados nos `spec-*`) — RO-01 respeitada, tudo extraído dos projetos reais. Notas: `_evolucao-skills/rodadas/onda-fewshots-2026-07-18-notas.md`.
5. ✅ **P5 — Contrato de temas do track JavaFX** + desSIGOtização do `javafx-dashboard` — **CONFERIDO FEITO em 2026-08-18** (a marca estava desatualizada e contradizia a linha do “Estado do programa” logo abaixo). `javafx-theme-tokens` existe; as 6 menções a SIGO que restam no `javafx-dashboard` são o checklist **negativo** (“nunca importe o mecanismo do SIGCOT por reflexo”), ou seja, são o conserto e não o resíduo.
6. ✅ **P6 — Elevar as 3 mais fracas** — **atingido pelas ondas de evolução** (tracker do PLANO-EVOLUCAO): `inovacao-melhorias` 7,6→**9,5 PROMOVIDA**, `consultor-negocios-apps` 7,7→9,3, `assistente-deterministico` 7,8→9,2 — todas muito acima da meta ≥8,3.
7. ✅ **P7 — Frases-gatilho reais nas descriptions** — **primeira onda completa em 2026-07-18**: eval das 53 skills contra as 159 frases aprovadas do GUIA-DE-CHAMADAS (baseline 157/159 = 98,7%; única correção real: alias "portal" no `gradup-testador`). O **GUIA-DE-CHAMADAS-SKILLS v1.1** virou o gabarito oficial de disparo. Segue contínuo: frases novas colhidas nas sessões entram no guia. Notas: `_evolucao-skills/rodadas/onda-descriptions-2026-07-18-notas.md`.

> Nota de medição: a auditoria mede o **texto** das skills; o desempenho em uso é papel dos evals §11 (que agora medem acionamento/aderência — LF2). Reavaliar a média após um lote de poda para medir o ganho real.

**📈 Estado do programa em 2026-07-19 (pós-campanha C1)** (fonte única do tracker: `_evolucao-skills/PLANO-EVOLUCAO.md`): **23/53 promovidas ao canônico** — a campanha C1 (mesma data, via orquestrador-fable, decisões do Jeremias por lote) promoveu 10 skills do track Java/JavaFX como melhor-que-live com prova executada, reescreveu a **RO-10** (espelhar-não-impor), padronizou 81 citações RI-01→RI-04 e instituiu o **placar-baseline executado** (`evals/placar-baseline.md`, runners cegos vermelho→verde) como padrão — 11 skills já o têm. Catálogo com **55 skills**. Pendências da C1: `spec-javafx-crud-feature` (caso greenfield vermelho após 2 curas — fix diagnosticado: excetuar o ramo greenfield nas "Condições de parada"). Do backlog antigo restam: P2 (evidência mínima) e P3 ("NÃO acione" simétrico) — P1, P4, **P5 (entregue na Onda A: contrato de temas + desSIGOtização do dashboard)**, P6 e P7 concluídos. Registros: `_evolucao-skills/rodadas/R-*-2026-07-19.md`.

---

### 📜 Histórico
- **2026-08-18 (T24 — triagem e reconciliação com o ledger):** as 12 marcas pendentes distintas
  (14 ocorrências do símbolo, menos a legenda e menos a duplicata do Embalo) foram triadas e migraram:
  **7 viraram tarefa** (T25–T31), com **duas fusões** — 8.1+9.2 eram a mesma obra contada duas
  vezes, e 8.5+9.4 são a mesma natureza de revisão de calibração — e **três baixas**: 9.3 e 8.4 já
  estavam no ledger (T19 e T18), e **11.5 (P5) já estava feito**. Três marcas mudaram de destino por
  **medição, não por leitura**: o P5 estava feito, o P3 estava 5/6 (falta só `memoria-de-projeto`) e
  o P2 tinha o caso-cabeça já resolvido. Este arquivo deixou de ser fila: a fila é
  `estado/TAREFAS.md`. Relatório: `estado/artefatos/triagem-roadmap-2026-08-18.md`.
- **2026-07-19 (reconciliação + deploy):** sessão de manutenção (Claude Code, mecânicas A1-A3): rodado o `deploy-skills.ps1` pendente dos itens 9.1/10.3 (runtime global `~\.claude\skills` + local do cofre, 55 skills); ROADMAP reconciliado com os fatos de 2026-07-18 que ainda não constavam — item 1 avançado a 🏗️ (RO-W1..W8 ratificadas `53cdff0` + 5 skills web no catálogo), P4/P6/P7 do item 11 fechados (ondas de few-shots e descriptions de 18/07, GUIA-DE-CHAMADAS v1.1 como gabarito, bottom-3 elevadas), estado do programa (13/53 promovidas, 55 skills) registrado; cofre commitado (a rodada de 18/07 estava toda fora do git — garimpos ponytail/lote-ferramentas/lote-arquitetura, núcleos SIGO e Gradup, referências de código real). Pendências de decisão seguem abertas: plano-riqueza (vínculo×renda), colisão RO-02, estudo de hooks (8.4), modo agendado (9.3), gems G7/G2/G3.
- **2026-07-14 (parte 2):** Garimpo do repo externo `ui-ux-pro-max-skill` avaliado (1 precondição bloqueante, 6 inserções, zero skills novas) + adoção do gem G6 (Master+Overrides) na `plano-riqueza` como rodadas R7→R9 no banco de evolução (teto honesto 9,3, ainda não promovido ao canônico). Registro completo: [[garimpo-uiuxpromax-2026-07-14]]; handoff da sessão: [[MEMORIA-SESSAO-GARIMPO-2026-07-14]].
- **2026-07-14 (parte 1):** Skill `trader-de-elite` concluiu o Selo Lendário (ciclo ultracode, placar 9,6 unânime) — ver [[relatorio-final-ultracode]] e o subprojeto completo em [[Projeto-Bot-Trader-Elite/README|Projeto Bot Trader de Elite]].
- **2026-07-13 (parte 3):** Skill nova do Jeremias avaliada e revisada: **`testador-jogos`** (criada como `game-tester`; nota 8,3 na criação → revisão com ok por item: renomeada para a família testador-*, `referencia/`, bloco Rede, fixtures dos evals internalizadas com 8/8 bugs plantados verificados por execução). Parecer e registro: `_auditoria/2026-07-13-avaliacao-testador-jogos.md`. Catálogo passa a **53 skills**. Pendências: rodar o baseline dos evals (§11), incluir no índice do README (52→53) e redeploy.
- **2026-07-13 (parte 2):** P1 do item 11 aplicado (poda de duplicação, 75 itens em 20 skills + PADRAO v2.4; comitê + gate do auditor; checkpoint git `e100ee7` antes, commit da poda depois). Pendência nova registrada: **colisão RO-02** (rodapé das lentes "coesão/acoplamento" × governança "patches cirúrgicos" — mesma numeração, regras diferentes; os "princípios comuns" do rodapé não têm casa na governança) — decisão do Jeremias pendente; por isso a poda dos rodapés ficou FORA do P1.
- **2026-07-13:** Criado o item 11 — auditoria de notas das 52 skills (média 8,45, relatório em `_auditoria/2026-07-13-notas-52-skills.md`) registrada como ponto de partida da sessão de evoluções, com backlog P1-P7. Nada editado nas skills (diagnóstico).
- **2026-07-12 (parte 3):** Item 10 — Lote 2 do garimpo Langfuse aplicado (rodada 8,2, ressalvas incorporadas); garimpo 100% aplicado. Edições: fable passo 6, modo-metrica §5 (eco declarado), COMO-COLHER v1.1, memoria-de-projeto (casa da lista).
- **2026-07-12 (parte 2):** Criado o item 10 — garimpo do blog da Langfuse: Lote 1 aplicado (rodada de aplicação 8,7: auditor 8,7 · arquiteto 8,8 · segurança 8,6 · qa 8,5, ressalvas incorporadas); Lote 2 e revisão de 60 dias registrados como pendência.
- **2026-07-12:** Criado o item 9 — garimpo do `nousresearch/hermes-agent` aplicado (Lotes 1+2+3, Comitê 8,7 na proposta; rodada de aplicação registrada no garimpo §6). Regra do console (P14) adicionada ao item 1.
- **2026-07-10 (parte 8):** `gradup-testador` sincronizado com o template (P3 classificação de regressão + P12 desempenho, adaptados ao perfil HTTP; auditor 9,4, ressalvas incorporadas — 3h roda antes do 3g, exceção de re-execução para caso com dado [QA-AUTO]). Demais instâncias: frase de sincronização na próxima bateria (item 8.1).
- **2026-07-10 (parte 7):** **Piloto do modo métrica concluído com SUCESSO** (par progress+review no Gradup, comitês 9,4/9,3, zero incidente de git) — modo consolidado na triagem (item 8.2 ✅). Regra do crash decidida pelo Jeremias (revert inegociável) e captura sistêmica do executor incorporadas à `referencia/modo-metrica.md`; ADR-001 anotado com o pós-piloto. Pendente de redeploy junto com o Lote 3.
- **2026-07-10 (parte 6):** Jeremias aprovou "1, 2 e 3 na sequência": piloto do modo métrica redirecionado para cobertura no Gradup (JaCoCo sob profile, gate em andamento na sessão Claude Code); **Lote 3 aplicado** (P10 modo wiki + P12 desempenho, rodada 9,1/8,5/8,4 com ressalvas incorporadas); **estudo P11 redigido** com revisão da segurança (8,5) — decisão de construção pendente (item 8.4).
- **2026-07-10 (parte 5):** Primeira validação de campo do modo métrica (Gradup): triagem/gate/baseline corretos e recusa honesta de loop com meta já no alvo; loop completo ainda não exercitado — piloto segue aberto (item 8.2). Cofre commitado (`7760dc2`, 226 arquivos) — rodada do garimpo versionada.
- **2026-07-10 (parte 4):** Jeremias rodou o `deploy-skills.ps1` — **52 skills no runtime** (fechou o item 7 e o passo 1 do item 8). A contagem revelou que o "51" do README não incluía a `painel-de-juizes` (ausente do índice desde 2026-07-09) — índice e contagens corrigidos (README v2.8, CLAUDE.md). Ratificada a microadição "API Top 10 x/10" no mapa de cobertura da `especialista-seguranca` (P8). Piloto do modo métrica liberado pelo Jeremias.
- **2026-07-10 (parte 3):** Criado o item 8 — garimpo do `uditgoenka/autoresearch` aplicado (Lotes 1+2, Comitê 8,5); pendentes: deploy, piloto do modo métrica, Lote 3, estudo de hooks (P11) e revisão de calibração. Criada a pasta `_decisoes/` com o ADR-001.
- **2026-07-10 (parte 2):** Auditoria formal (`auditor-responsabilidades`) do trio Riqueza & Finanças — aprovado com ressalvas, relatório em `_auditoria/2026-07-10-auditor-riqueza-financas.md`. Corrigida corrupção silenciosa de arquivo detectada durante a auditoria (ver item 7).
- **2026-07-10:** Criado o trio de lentes do domínio Riqueza & Finanças (item 7) e feita uma rodada de organização do catálogo pelo Cowork — arquivos das 3 skills movidos para dentro de `skills/<nome>/` (antes eram pacotes `.skill` avulsos na raiz), `README.md` restaurado de uma sobrescrita acidental e reindexado com o novo trio, `.skill` avulsos e o `GUIA-MESTRE-RIQUEZA.md` solto da raiz movidos para `_to_delete/` (aguardando remoção manual — Cowork não apaga arquivo em pasta conectada).
- **2026-07-05 (parte 3):** Jeremias confirmou `Sistemas Prontos\escalaope` como fonte da verdade do EscalaOper; criado `escalaoper-testador`. Item 4 agora só falta o Embalo.
- **2026-07-05 (parte 2):** Item 5 (geradores Spring Boot) concluído. Item 4 avançado (SIGCOT e Sentinela ✅; EscalaOper bloqueado por ambiguidade de diretório, aguardando o Jeremias; Embalo ainda não iniciado). `testador-real` enriquecido com técnicas do `testador-sigcot`.
- **2026-07-05:** Itens 3 e 6 concluídos (Reforma Lendária; arquivamento do workspace). Adicionados itens 4 e 5 (instâncias de testador, geradores Spring Boot). Cofre inicializado como repositório git para versionar o catálogo.
- **2026-06-15 (v1):** Criado. Registrados o track Web/Supabase (Embalo) e a limpeza de duplicação como pendências combinadas.
- **2026-06-15:** Item 2 (limpeza/fonte única) concluído. Resta o item 1 (track Web/Supabase).
