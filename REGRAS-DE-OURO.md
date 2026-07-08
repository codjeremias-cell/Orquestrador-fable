---
tipo: governança
papel: governança do conjunto único (multi-stack)
enforced-by: auditor-responsabilidades
última-atualização: 2026-07-07
versão: v2.4
---

# 🛡️ Regras de Ouro e Inquebráveis (multi-stack)

> Governança única do conjunto. Evolução multi-stack da nota original `Regras de Ouro e Inquebráveis.md` do cofre: as **RI** e as **RO universais** valem para qualquer linguagem; cada **track** (Java/JavaFX, Web/Supabase…) tem suas **RO específicas**.
> Quem faz cumprir é a lente [[skills/auditor-responsabilidades/SKILL|Auditor de Responsabilidades]]: violar uma **RI** ou **RO** aplicável = reprovação no gate.
> **Fonte normativa única:** a nota raiz `Regras de Ouro e Inquebráveis.md` do cofre passou a ser um **resumo-atalho** que aponta para cá (fim da duplicação).

---

## ⚔️ Camada 1 — Regras Inquebráveis (RI) · valem sempre, em qualquer stack

- **RI-01 — Co-responsabilidade pelo sucesso.** O resultado é responsabilidade coletiva de todas as lentes. Parceiro de trincheira, não consultor distante; nada cai no vão. **ADR aceito é contrato vinculante** *(reforço 2026-07-07, ver histórico)*: nenhuma lente ou subagente muda a **decisão** registrada num ADR "Aceito" (ex.: trocar de banco, de framework, de contrato público) sem antes **declarar o conflito por escrito** (nota datada, ADR de exceção, ou o placar de rodada do `orquestrador-fable`) e obter decisão do Jeremias — divergir em silêncio viola esta regra. Isso **não** trava detalhe de execução dentro da decisão já tomada (otimizar uma query, adicionar índice, refatorar método interno) — só a decisão em si.
- **RI-02 — Qualidade e usabilidade de nível excelente.** Excelência é o **piso, nunca o teto**. Código legível, testável, manutenível e seguro, sempre.
- **RI-03 — Cumprimento das Regras de Ouro.** Toda entrega é auditada quanto à aderência às RO aplicáveis; violação implica reprovação.
- **RI-04 — Rastreabilidade e evidência.** Decisões relevantes registradas (ex.: ADR); todo "pronto" precisa de evidência verificável.
- **RI-05 — Veredito explícito e fundamentado.** Toda auditoria termina com aprovado / aprovado com ressalvas / reprovado, com motivos e responsáveis nomeados.
- **RI-06 — Uso obrigatório das skills/lentes aplicáveis.** Toda skill, lente ou referência do catálogo (`Catalogo-Skills-Unificado/` → runtime `.claude/skills/`) cujo gatilho casar com a tarefa **DEVE** ser ativada e aplicada — em **todos os projetos**. Pular uma skill aplicável (ex.: não acionar a Designer UX-UI num trabalho de tela, ignorar a referência Impeccable em frontend) é violação e reprova no gate. Na dúvida sobre aplicabilidade, ativar.

### Princípios de conduta inegociáveis
- ❌ **Nunca gambiarra silenciosa.** Se for paliativo, AVISO na hora e proponho o definitivo. *(sustenta RI-02/RI-04)*
- ✅ **Honestidade sobre limites.** Não sei → pergunto; errei → mea culpa direto e corrijo. *(sustenta RI-04)*

---

## ⭐ Camada 2 — Regras de Ouro Universais (RO) · qualquer linguagem

- **RO-01 — Nada de chute de API.** Antes de usar helper/método/lib que não vi, **PEÇO o código-fonte real** ou declaro a suposição. Memória de chat **não** é fonte da verdade. *(Casa com a lente Dev Sênior. É a regra mais importante dos geradores.)*
- **RO-02 — Patches cirúrgicos > reescrita.** Entrego `str_replace` (ANTES/DEPOIS). Mudança dispersa na mesma classe → entrego a **classe INTEIRA** marcada como versão definitiva que supersede as anteriores.
- **RO-03 — Cabeçalho com caminho EXATO** do arquivo em toda entrega (📁 + ⚠️ não confundir com arquivo parecido).
- **RO-04 — Acesso a dados sempre parametrizado** (`?`), nunca concatenar entrada na query — anti-injection. *(Casa com a lente Especialista de Segurança.)*
- **RO-05 — Sem emoji em código.** Emoji só em chat e em strings de UI quando combinado.
- **RO-06 — Mockup visual ANTES de codar tela.** O Jeremias é visual (processa print, não vídeo). *(Casa com a lente Designer UX-UI.)*
- **RO-07 — Toda entrega fecha com 💡 Sugestões de evolução** (2–3, sem implementar agora). *(Casa com a lente Inovação e Melhorias.)*

### Padrões universais (das lições cross-projeto — aplicar como RO de fato)
- **Segredos fora do versionamento:** `config.properties`/`.env` no `.gitignore` + `*.example`; nenhuma credencial hardcoded.
- **Operação multi-passo = transação atômica:** sem gravação parcial (commit/rollback).
- **Conteúdo do usuário em HTML/e-mail:** escapar + validar destinatário.
- **Estados sempre cobertos:** vazio, carregando, erro (além do sucesso) — em toda tela/listagem.
- **Prova executada > checklist:** antes de release/deploy, rodar a bateria do testador aplicável (`testador-real` ou a instância do projeto, ex.: `gradup-testador`). O que não der para executar vira **SKIP declarado com motivo** — sucesso simulado é violação (sustenta RI-04).
- **RO-14 (proposta 2026-07-07 — pendente de autorização, ver [[Novo Conceito/PROPOSTA-EVOLUCAO-v1|proposta]]) — Ledger de regressão de correções.** Projetos com `testador-real`/instância própria (`gradup-testador`, `testador-sigcot`, `sentinela-testador`...) podem manter `correcoes.json` **no próprio projeto** (nunca no catálogo compartilhado): uma entrada por bug corrigido — `{id, descrição, arquivo, marcador, data, status}`. `status` é `ativo` (o marcador deve existir no código) ou `obsoleto` (mudou legitimamente; motivo textual registrado, ex.: "reescrito na v2, ver ADR-00X"). O testador checa isso **automaticamente** na Fase 2 (bateria estática) de toda bateria — nunca opt-in manual; marcador `ativo` ausente é **FAIL de regressão** no relatório datado (RI-04), não aviso solto no chat. Projeto **sem** testador instanciado não cria o ledger (evita promessa fantasma). Revisar após 3 projetos-piloto: sucesso = capturou ao menos 1 regressão real ou zero fricção de falso positivo; só ruído → descontinuar.

---

## 📌 Camada 3 — Regras de Ouro por Track

> Cada stack acumula suas próprias cicatrizes. Aplicam-se **só** no contexto daquele stack.

### Track Java / JavaFX + JDBC (SIGO, EscalaOper, Sentinela)

- **RO-08 — Log4j 2 sempre.** ❌ Nada de `printStackTrace` / `System.out` / `System.err`. `Throwable` como último argumento.
- **RO-09 — FXML frágil.** `VBox.vgrow` / `HBox.hgrow` em **UMA linha** (quebrar corrompe o parser). Marcadores `★★★ INÍCIO/FIM V.X.Y ★★★` ao redor de blocos. Comentário com `>` extra quebra o parser.
- **RO-10 — JDBC seguro.** `try-with-resources` obrigatório em `Connection`/`Statement`/`ResultSet` + `RetryDB.executar()` em operações críticas. Conexão única (UCanAccess) **não é thread-safe** — serializar acesso.
- **RO-11 — Encoding explícito.** `UTF-8` + `Locale.forLanguageTag("pt-BR")` declarados — não confiar no default da JVM.
- **RO-12 — CSS JavaFX.** `-fx-border-color` com 4 valores = **TOP, RIGHT, BOTTOM, LEFT**. Variável de tema (`-sigo-xxx`/`-color-xxx`) deve estar DECLARADA em `.root` antes de usar — senão a regra é ignorada em silêncio. Sem hex fixo (quebra no dark).
- **RO-13 — Git, ciclo completo.** Sempre o ciclo com paths explícitos: `git status → git add <paths> → git status → git commit → git push → git status`. No CMD Windows: múltiplos `-m` (não `\n`).
- **RO-J1 — UI nunca congela.** I/O de banco em `Task` (thread daemon); atualizar a UI no `onSucceeded`; cursor de espera + placeholder "Carregando…".
- **RO-J2 — Empacotamento.** `jpackage` sobre fat-jar (maven-shade): `app-image` (`.exe`) e `.msi` (WiX). ⚠️ não renomear o `.exe` (deriva o nome do `.cfg`); copiar a pasta `dist/<App>/` inteira.

### Track Java Web / Spring Boot (Gradup)

> Stack: Spring Boot 3.x + Thymeleaf + htmx + PostgreSQL (Neon), monolito modular. Convenções **extraídas e validadas** no Gradup (não inventadas).

- **RO-SB1 — Segredos por ambiente.** `DB_URL`/`DB_USER`/`DB_PASSWORD` (+ `APP_BASE_URL`) via variáveis de ambiente; `application.properties` só com defaults de dev. `application-local.properties` e `run-local.ps1` no `.gitignore`. Nenhuma credencial no git.
- **RO-SB2 — Schema por Flyway, engine único.** Migrações versionadas (`V1__`, `V2__`…) + `spring.jpa.hibernate.ddl-auto=validate` (Hibernate **nunca** cria/altera; quem manda é a migração). **Mesmo engine dev=prod (PostgreSQL)** — não desenvolver em SQLite/H2 e "subir depois": trocar de engine quebra o "só migrar". Postgres→Postgres é trivial.
- **RO-SB3 — Dados parametrizados + transação.** Acesso via Spring Data JPA (RO-04); operação multi-passo em `@Transactional`. Organização por contexto: `com.portal.<modulo>` com `web/application/domain/infrastructure`.
- **RO-SB4 — Não vazar entidade JPA na view.** A web retorna **DTO/record de leitura** ao template (evita expor hash de senha e acoplar o Thymeleaf ao ORM). Dependência aponta pra dentro (web→application→domain/infra).
- **RO-SB5 — Auth endurecida.** Senha **BCrypt**; `UserDetailsService` próprio; conta inativa = desabilitada; **respostas neutras anti-enumeração** (não revelar se o e-mail existe); **rate limiting + anti-bot OBRIGATÓRIOS antes de publicar** endpoints públicos (cadastro/login).
- **RO-SB6 — Thymeleaf + a11y.** CSRF ligado (forms com `th:action`); WCAG AA: `label` + `aria-describedby` + `role="alert"` no erro + `required`/`aria-required`; estados vazio/carregando/erro; tokens de cor (sem hex solto fora do `tokens.css`; texto semântico com contraste ≥ 4.5:1).
- **RO-SB7 — Mídia pesada fora do app.** Vídeo por embed/CDN externo, não streaming próprio no MVP.
- **RO-SB8 — Verificar de verdade.** `mvn test` roda Flyway + Hibernate `validate` + fluxo; teste de integração que exige banco fica guardado por env var (`@EnabledIfEnvironmentVariable(named="DB_URL")`) para o `mvn test` sem banco não quebrar.

### Track Web / Supabase (Embalo — pendente)
> Reservado para as RO do **backend Supabase** (RLS, Auth, Storage) quando o track for construído (ROADMAP item 1). *(Cabeçalho restaurado em 2026-07-07 — a linha estava truncada aqui, mesmo corte que atingiu outras skills; conteúdo original era só placeholder.)*

### Track Mobile / Flutter (proposta 2026-07-07 — validar contra o EscalaOper real, RO-01)

> Stack: Flutter + Firebase (Auth/Firestore/Storage). Baseado na arquitetura **oficial** do Flutter; refinar contra o código real do EscalaOper quando acessível.

- **RO-FL1 — Camadas com repositório abstrato.** UI (View + ViewModel) e Data (Repository + Service); repositório é **interface** (permite fake/mock); domain/use-case só quando a lógica for complexa. **Nada de lógica no widget.**
- **RO-FL2 — Estado com Riverpod (code-gen) por padrão.** `@riverpod`/`AsyncNotifier` (loading/erro nativos); Bloc só em domínio regulado que exija trilha de eventos. Modelo imutável (`freezed`).
- **RO-FL3 — Firebase desacoplado + rules com o modelo.** O ViewModel consome a interface de repositório, nunca o Firestore direto; as **security rules default-deny nascem junto do modelo** (são o firewall). `flutterfire configure`, nunca config manual.
- **RO-FL4 — Navegação e testes oficiais.** `go_router` (+ builder type-safe); unit para Service/Repository/ViewModel + widget para as Views, com `mocktail` e `integration_test` (`flutter_driver` está deprecado — reconfirmar na data de uso).

### Track Web Frontend (proposta 2026-07-07 — complementa o Spring Boot)

> Stack: React/Vue/Svelte/Astro + Tailwind v4 + TanStack. Convenções de fontes oficiais/comunidade; validar no primeiro projeto real.

- **RO-FE1 — Server-state × client-state separados.** Server-state só via **TanStack Query** (cache/revalidação), **nunca** em store global; client-state em Zustand/Jotai.
- **RO-FE2 — Um schema Zod = contrato único.** O mesmo schema valida a resposta da API (parse-fail → error state), valida o formulário e **infere os tipos TS**. Blinda o front contra o backend mudar.
- **RO-FE3 — Componente com fronteira a11y invariável.** Comportamento por primitiva headless (Radix/Base UI/React Aria); **nunca** trocar `button` por `div`, sempre espalhar `{...props}`, contraste ≥ 4,5:1 (WCAG 2.2).
- **RO-FE4 — Tokens são a fonte única de estilo.** Design tokens (W3C DTCG) → Tailwind v4 `@theme`/CSS vars; **zero hex fora dos tokens**. No bundle, só var pública (`VITE_`/`NEXT_PUBLIC_`) — nunca chave privada.
- **RO-FE5 — Prova por Playwright + axe.** Bateria dinâmica E2E com Playwright + `@axe-core` (WCAG 2.2); crítico falha o build.

### Track Desktop / Tauri (proposta 2026-07-07 — moderno multiplataforma)

> Stack: Tauri v2 (flagship) ou Avalonia (.NET, menor atrito vindo de JavaFX). Validar no primeiro projeto real.

- **RO-DT1 — Segurança default-deny.** Capabilities/permissions explícitas por janela + CSP estrita (scripts hasheados/nonce, sem CDN). Nunca liberar tudo por padrão (erro do Tauri v1).
- **RO-DT2 — Bridge tipada de ponta a ponta.** Tipos gerados do backend (tauri-specta/TauRPC) para o front — o compilador valida o contrato UI↔dados do código gerado.
- **RO-DT3 — Banco local com migração versionada.** `tauri-plugin-sql` (SQLite) com migrações **versionadas** — o plugin aplica o **up** no boot; o **down** é artefato manual de dev para rollback (não é auto-aplicado pelo plugin). Gravação segura (temp+rename); teste nunca contra dados reais.
- **RO-DT4 — Distribuição assinada com auto-update.** Instalador assinado (code signing/notarização) + updater com par de chaves próprio via GitHub Releases (ou Velopack no caminho .NET).
