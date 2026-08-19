---
tipo: roadmap
papel: pendências e próximos passos do conjunto único (radar)
última-atualização: 2026-07-07
versão: v1.1
---

# 🛰️ Radar — Pendências do Catálogo

> O que ficou combinado para **não esquecermos**. Cada item tem contexto suficiente para retomar do zero. Status: 🔲 pendente · 🏗️ em andamento · ✅ feito.

---

## ✅ 0. Evolução do catálogo a partir de repositórios de terceiros (concluído 2026-07-07)

> ✅ **Feito em 2026-07-07:** analisados 4 repositórios de terceiros (`ruvnet/ruflo`, `nexu-io/open-design`, `obra/superpowers`, `affaan-m/ECC`) em cópia isolada (`Novo Conceito/`), com checagem de segurança prévia (sem código malicioso em nenhum) e avaliação do Comitê de Lentes rodada a rodada (críticas fechadas antes de promover, incluindo um erro factual real de numeração WCAG que o próprio Comitê pegou). Promovido ao catálogo oficial: **RO-14** (ledger de regressão) e reforço da RI-01 (ADR como trava) em `REGRAS-DE-OURO.md`; **§11** (baseline antes do eval) em `PADRAO-DE-AUTORIA.md`; atualizações em `testador-real`, `arquiteto-software` (ADR com data/decisores/substituição), `orquestrador-fable` (gate de ADR), `dev-senior` (depuração sistemática + Java moderno condicionado ao JDK), `especialista-seguranca` (checklist rápido), `designer-ux-ui` (Design Read, Modo Polish Pass, 3 proibições novas, 4 critérios WCAG 2.2). Registro completo da análise, das notas do Comitê e do que foi **rejeitado** (com motivo) em `Novo Conceito/PROPOSTA-EVOLUCAO-v1.md` (mantido como registro histórico — RI-04). Achado incidental: `PADRAO-DE-AUTORIA.md` tinha o final truncado (perdeu a seção Histórico) antes mesmo desta rodada — pendente restaurar do Git.

**Próximo passo mecânico:** rodar `deploy-skills.ps1` para sincronizar `.claude/skills/` (runtime) com o catálogo agora atualizado.

---

## 🔲 1. Track Web / Supabase (Embalo) — montar o segundo track

**O quê:** criar o conjunto de geradores do stack web do Embalo (HTML + CSS + JS vanilla + Supabase: PostgreSQL/RLS, Auth, Storage), espelhando o que o track Java faz para o JavaFX.

**Por quê:** o Embalo é 1 dos 4 projetos e hoje não tem nenhum gerador. Fecha o "multi-código" de verdade.

**Como (seguir o [[PADRAO-DE-AUTORIA]] §8 — adicionar um track):**
1. **Extrair as convenções reais da memória do Embalo** — RLS, políticas, Auth, Storage, estrutura de pastas, padrão de fetch/estado. **Não inventar** (RO-01).
2. Registrar as **RO específicas do stack Web/Supabase** na seção reservada de [[REGRAS-DE-OURO]].
3. Criar os geradores com prefixo `web-` / `supabase-`, p.ex.: `web-page`, `web-component`, `supabase-table-rls`, `supabase-auth`, `web-api-client`, `web-form`.
4. Criar o orquestrador `spec-web-feature` (e, se fizer sentido, `spec-web-new-system`).
5. As lentes do método **não mudam** — passam a auditar o track novo automaticamente.
6. **Testador web (pepita 2026-07-07, do harness GAN/ECC):** a instância de testador do track web deve usar **Playwright** na bateria dinâmica E2E — interagir com o app vivo (clicar, preencher formulário, testar estado de erro), não só checar código. Modo de avaliação por tipo de artefato: `playwright` (app com UI), `screenshot` (estático/design), `code-only` (API/CLI). Guardado aqui até o track web existir — não vira skill fantasma antes disso.

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

## 🏗️ 4. Instâncias de testador por projeto (SIGCOT ✅, Sentinela ✅, EscalaOper ✅, Embalo 🔲)

**O quê:** na primeira bateria de cada projeto, preencher o Perfil do `testador-real` e salvar como testador específico, project-local (`<projeto>\.claude\skills\<projeto>-testador\`), como foi feito com o `gradup-testador`.

**Por quê:** a instância guarda as rotas/telas, credenciais de QA e limites reais do projeto — a bateria fica reproduzível e mais rápida a cada release.

**Estado em 2026-07-05:**
- ✅ **SIGCOT** — já tinha `testador-sigcot` (`sigo-app.vs\.claude\skills\testador-sigcot\`), construído antes desta rodada e mais maduro que o template: checklist com invalidação por hash, cópia-sandbox do `.accdb`, smoke headless de FXML, snapshots por tema. As técnicas boas foram **retro-incorporadas** ao `testador-real` (seção "Técnicas avançadas").
- ✅ **Sentinela** — criado `sentinela-testador` (`projetos-dev\Sentinela\.claude\skills\sentinela-testador\`), adaptado à realidade real do projeto (sem FXML, MySQL/Azure via HikariCP, nunca acessa o site real da ONS nem chama LLM real durante a bateria). Lacuna encontrada: não existe `config.properties.example` no repositório — registrada como melhoria no `ACHADOS.md` da primeira rodada.
- ✅ **EscalaOper** — havia dois diretórios candidatos divergentes (`Sistemas Prontos\escalaope`, congelado em 2026-06-11; `Escala de trabalho -Designer novo`, com mobile/Flutter+Firebase e commits até 2026-06-28); o Jeremias confirmou **`Sistemas Prontos\escalaope`** como fonte da verdade. Criado `escalaoper-testador` ali (`.claude\skills\escalaoper-testador\`), com técnica de cópia-sandbox do `.accdb` (mesmo padrão do SIGCOT — Access via UCanAccess, conexão única não thread-safe) e achados já registrados (cobertura de teste quase nula fora de `service/`, divergência README×código sobre envio de e-mail SMTP vs. Outlook local).
- 🔲 **Embalo** — ainda não explorado (depende também do item 1, track Web/Supabase).

---

## ✅ 5. Geradores do track Java Web / Spring Boot (Gradup) (concluído 2026-07-05)

> ✅ **Feito em 2026-07-05:** criados `springboot-entity` (entidade JPA + migração Flyway), `springboot-repository-service` (repositório Spring Data + serviço transacional), `springboot-controller-thymeleaf` (controller + template acessível) e o orquestrador `spec-springboot-crud-feature`. Convenções extraídas por leitura real do Gradup (entidade `Course`, migração `V4__catalog.sql`, `CourseRepository`, `CourseAuthoringService`, `InstructorCourseController`, `curso-form.html`) — RO-01 respeitada, nada suposto.

**O quê:** os geradores `springboot-*` (entidade + migração Flyway, repositório/serviço, controller + Thymeleaf com a11y) espelhando o track JavaFX, a partir das convenções **reais** do Gradup (RO-SB1…8 já registradas na [[REGRAS-DE-OURO]]).

**Por quê:** o track já tinha governança e testador, mas não tinha geradores — a construção era manual via lentes.

---

## ✅ 6. Arquivar `javafx-dashboard-workspace` do runtime (concluído 2026-07-05)

> ✅ **Feito em 2026-07-05** (ok do Jeremias): a pasta `~\.claude\skills\javafx-dashboard-workspace\` (não era skill — workspace de benchmark/eval, sem `SKILL.md`) foi movida para `_arquivo-morto/javafx-dashboard-workspace/` no cofre. Runtime `.claude/skills/` agora contém só skills reais.

---

### 📜 Histórico
- **2026-07-05 (parte 3):** Jeremias confirmou `Sistemas Prontos\escalaope` como fonte da verdade do EscalaOper; criado `escalaoper-testador`. Item 4 agora só falta o Embalo.
- **2026-07-05 (parte 2):** Item 5 (geradores Spring Boot) concluído. Item 4 avançado (SIGCOT e Sentinela ✅; EscalaOper bloqueado por ambiguidade de diretório, aguardando o Jeremias; Embalo ainda não iniciado). `testador-real` enriquecido com técnicas do `testador-sigc