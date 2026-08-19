---
name: java-jdbc-dao
description: "Cria ou completa um DAO/repositório JDBC de uma entidade em projeto Java desktop, espelhando o padrão de DAO real do projeto — SQL parametrizado, try-with-resources, colunas explícitas e a resiliência onde o projeto a coloca. Camada de PERSISTÊNCIA do pipeline desktop Java. Acione com \"cria o DAO de Cliente\", \"preciso do CRUD no banco pra essa entidade\", \"faz o repositório que salva e busca Funcionário\", \"monta as queries de Produto\", \"grava/lê no banco\", \"insere/atualiza/lista essa tabela\", \"salva no banco\", \"busca por id\", \"listar todos\", \"SQL de inserir/atualizar/excluir\", \"repositório da entidade X\". NÃO acione para criar a entidade (use java-javafx-entity), a tela (use javafx-screen-fxml) nem a regra de negócio (use java-service-usecase)."
argument-hint: [nome-da-entidade]
---

# Java — DAO / Persistência JDBC

📍 **No pipeline Java:** camada de persistência. Vem depois de `java-db-foundation` (provedor + retry/serialização) e `java-javafx-entity` (a entidade mapeada); é consumido por `java-service-usecase` e provado por `testador-real`.

## Objetivo

Implementar o acesso a dados de uma entidade **na forma que o projeto já usa** — o DAO novo tem que ser indistinguível dos DAOs existentes. O DAO só persiste e mapeia linha↔objeto; sem regra de negócio, sem UI.

## Entradas obrigatórias

1. Entidade alvo (ou o arquivo dela).
2. Operações desejadas (`inserir`, `atualizar`, `excluir`, `buscarPorId`, `listar`…).
3. Nome real da tabela e colunas, OU autorização para ler do schema/projeto.

## Trava obrigatória (RO-01)

- Não gerar sem a entidade e o mapeamento **real** tabela↔colunas. Colunas não confirmadas → **parar e pedir**, nunca adivinhar nome de coluna.
- Mais de uma tabela candidata → pedir a certa.

## Os invariantes inegociáveis (valem em qualquer projeto)

Estes não variam — são segurança e correção, não estilo:

- **RO-04 — toda ENTRADA vai parametrizada.** `PreparedStatement` com `?` para qualquer valor vindo de fora; **nunca** concatenar entrada na query (anti-injection). Query **sem entrada** (ex.: `SELECT COUNT(*)`, listar-tudo) pode usar `Statement` simples — é o que o gabarito SIGO faz; parametrizar não é banir `Statement`, é blindar a entrada.
- **RO-10 — recursos sempre fechados.** `try-with-resources` em `Connection`, `Statement`/`PreparedStatement` e `ResultSet`. Recurso vazado esgota o provedor único de conexão e trava o app.
- **Colunas explícitas.** `SELECT col1, col2, …` — nunca `SELECT *`, nunca trazer coluna sensível (`senha_hash`) para listagem.
- **Atomicidade QUANDO multi-passo (o QUE é invariante).** Gravou em 2+ tabelas num fluxo? A operação é atômica — `setAutoCommit(false)` + `commit()`/`rollback()`. Operação de passo único **não** abre transação. **ONDE mora a fronteira transacional (DAO × camada de serviço) VARIA** — se o projeto orquestra transação no serviço (ver `java-service-usecase`), o DAO expõe a operação e o serviço abre a transação; detecte a colocação do projeto, não force no DAO. **Em greenfield não há o que detectar:** sem projeto para espelhar, a transação abre **no DAO** e isso se declara como **SUPOSIÇÃO:** (RO-01) — é o precedente do gabarito SIGO, onde a operação multi-tabela usa transação explícita nos DAOs grandes (`OrcamentoItemDAO`/`ManifestacaoDAO`).
- **Concorrência da conexão única (UCanAccess/Access):** nunca duas consultas concorrentes — a serialização é responsabilidade do provedor (ver abaixo), não do DAO.

## O que VARIA por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto: **onde vivem a resiliência e o log.** Não há resposta única — há a decisão que **este** projeto tomou. Leia um DAO existente + o provedor de conexão e copie:

- **Retry e serialização:** vivem no **provedor de conexão** (ex.: uma classe `Database` com `ReentrantLock` + `FileLock` + retry) ou o DAO chama um `RetryDB.executar(...)`? Se o provedor já resolve, **o DAO fica limpo** — não recrie retry/lock nele.
- **Log de erro:** o DAO loga (Log4j2, `Throwable` como último argumento) ou **propaga `throws SQLException` limpo** e quem loga é a camada de cima? Copie a escolha do projeto.
- **Retorno das escritas:** `void`? `boolean`? id gerado (`RETURN_GENERATED_KEYS`)? Busca por id devolve `Optional`, `null` ou lança? Espelhe.
- **Forma do SQL:** String local por método ou constantes de classe? Alias de JOIN de exibição? Helper de data nula (`setNull(i, Types.DATE)`)? `mapear(rs)` privado? Copie.

**Gabarito SIGO (código real):** projeto-alvo sendo o **SIGO/SIGCOT ou família**, carregue `referencia-exemplos-reais-sigo.md` — `ViagemDAO.java` + `Database.java` verbatim. No SIGO: pacote `br.com.cot.db`; colunas snake_case com data prefixada (`data_viagem`); métodos PT-BR; **escritas `void`**; SQL local por método; `setData`/`mapear` privados; e **retry + dupla trava (JVM + arquivo) + log vivem na `Database`, o DAO fica limpo, `throws SQLException`**. Seguir isso é acerto — o corpo genérico não manda logar nem dar retry dentro do DAO.

## Fluxo

1. Confirmar tabela↔colunas reais.
2. **Ler um DAO existente + o provedor de conexão** — extrair: onde vive retry/log, retorno das escritas, forma do SQL, mapeamento.
3. Implementar cada operação parametrizada, `try-with-resources`, colunas explícitas, **na forma detectada**.
4. `mapear(ResultSet)↔entidade` num método privado.
5. Transação atômica só se multi-passo. Erro tratado como o projeto trata (logar OU propagar limpo — não as duas).
6. Rodar build/teste e reportar arquivos + suposições.

## Guardrails

- Nunca concatenar **entrada** em SQL (RO-04) — literais de query montados em blocos de `String` são ok, o que não pode é valor vindo de fora fora do `?`; nunca `SELECT *` em listagem.
- Não inventar tabela, coluna, método de conexão/retry (RO-01).
- Não deixar `ResultSet`/`Statement` sem fechar; não abrir conexão fora do provedor único.
- **Não impor retry/log dentro do DAO se o projeto os coloca na infraestrutura** — recriar o que a `Database` já faz é erro, não zelo.

## Saída esperada

- DAO no pacote de persistência do projeto, operações pedidas, mapeamento, na forma real.
- Nota com tabela/colunas usadas, onde vivem retry/log neste projeto, e suposições (RO-01).

## Verificação de fechamento (RI-04)

O DAO fecha quando compila e, quando há banco, as operações rodam de verdade:

1. **Compila:** `mvn -q -DskipTests compile` (ou `./gradlew compileJava`) verde — o DAO bate com a entidade, o provedor e a API do driver reais.
2. **Operações rodam (quando há banco de teste acessível):** um round-trip real (inserir → buscarPorId → listar → excluir) via `testador-real`, provando o mapeamento coluna↔campo e o SQL. Sem banco na sessão, vira **SKIP declarado** com o motivo, nunca "passou" fingido.
3. **Checklist de segurança:** toda entrada passa por `?` (grep por concatenação em SQL no arquivo novo); nenhum `SELECT *` em listagem; nenhuma coluna sensível numa lista.

## Sugestões de evolução (RO-07)
Feche com 2–3 (ex.: extrair SQL para constantes; paginar `listar`; índice na coluna de busca mais usada).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (RO-04, colunas sensíveis fora de listagem) · `dev-senior` (mapeamento e recursos sempre fechados).
- **Vem antes:** `java-db-foundation` (provedor + retry/serialização) · `java-javafx-entity` (a entidade mapeada).
- **Vem depois:** `java-service-usecase` (consome o DAO) · `testador-real` (prova as operações contra o banco).
- **Não confundir com:** `java-db-foundation` (infraestrutura de conexão — aqui é o DAO da entidade).

### 📜 Histórico
- **2026-08-11 — Ponteiro circular de transação quebrado no ramo greenfield (inventário do catálogo, `_auditoria/zelador-inventario-2026-08-10.md`, grupo "regra que precisa migrar"):** o bullet "Atomicidade QUANDO multi-passo" mandava detectar a colocação e apontava para `java-service-usecase`, que aponta de volta para cá — em greenfield não há o que detectar. Acrescentado o default explícito (transação no DAO, declarada como SUPOSIÇÃO), ancorado no precedente já escrito em `referencia-exemplos-reais-sigo.md` (multi-tabela com transação explícita em `OrcamentoItemDAO`/`ManifestacaoDAO`). `description` intocada.

Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-18 — Evolução ao 9,5 (núcleo SIGO)** (corpo em invariantes × o que varia; verificação de fechamento RI-04; evals com 2 casos).
