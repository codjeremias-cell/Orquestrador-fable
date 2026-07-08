---
name: java-jdbc-dao
description: Cria ou completa um DAO/repositório JDBC para uma entidade em projeto Java desktop (JavaFX + Access/UCanAccess ou outro banco), com SQL parametrizado, try-with-resources, colunas explícitas, transações atômicas e uso do utilitário de retry do projeto. Acione quando o usuário disser coisas como "cria o DAO de Cliente", "preciso do CRUD no banco pra essa entidade", "faz o repositório que salva e busca Funcionário", "monta as queries de Produto" ou pedir persistência/acesso a dados. NÃO acione para criar a entidade (use java-javafx-entity), a tela (use javafx-screen-fxml) nem a regra de negócio (use java-service-usecase).
---

# Java — DAO / Persistência JDBC

## Objetivo

Implementar o acesso a dados de uma entidade via JDBC seguindo o padrão real do projeto, com segurança (SQL parametrizado), recursos sempre fechados, colunas explícitas e transações atômicas em operações multi-passo. O DAO só persiste e mapeia linha↔objeto — não tem regra de negócio nem toca na UI.

## Entradas obrigatórias

1. Entidade alvo (ex.: `Cliente`) ou o arquivo da entidade.
2. Operações desejadas (ex.: `inserir`, `atualizar`, `excluir`, `buscarPorId`, `listar`).
3. Nome real da tabela e colunas, OU autorização para ler do schema/projeto.

## Entradas opcionais

- Filtros/buscas específicas (ex.: `buscarPorCidade`).
- Se a operação faz parte de um fluxo multi-passo que exige transação.

## Trava obrigatória

- Não gerar sem a entidade alvo e o mapeamento real tabela↔colunas. Se a tabela/colunas não forem confirmadas, **parar e pedir** — nunca adivinhar nomes de coluna (RO-01).
- Se houver mais de uma entidade/tabela candidata, pedir a correta.

## Leituras obrigatórias (RO-01 — nunca inventar o padrão)

Antes de escrever, ler do projeto real:

1. Um DAO já existente para copiar o padrão de conexão, mapeamento e nomes.
2. O provedor de conexão do projeto (ex.: classe de `Connection`/datasource) — **não instanciar conexão nova fora desse padrão**.
3. O utilitário de retry de banco do projeto, se existir (ex.: `RetryDB.executar(...)`), e como ele é chamado.
4. A entidade alvo (campos e tipos) e como datas/números são mapeados.

Se algum desses não existir, declarar a suposição de forma destacada antes de seguir.

## Convenções obrigatórias (Regras de Ouro do track)

- **RO-04 — SQL sempre parametrizado.** `PreparedStatement` com `?`; **nunca** concatenar entrada do usuário na query. Anti-injection.
- **RO-10 — JDBC seguro.** `try-with-resources` em `Connection`, `Statement`/`PreparedStatement` e `ResultSet`. Operações críticas dentro do `RetryDB.executar()` (ou equivalente real do projeto). Conexão única (UCanAccess) **não é thread-safe** — serializar o acesso, nunca disparar duas consultas concorrentes na mesma conexão.
- **Colunas explícitas.** `SELECT col1, col2, ...` — nunca `SELECT *`, e nunca trazer colunas sensíveis (ex.: `senha_hash`) para listagens.
- **Transação atômica em multi-passo.** `setAutoCommit(false)` + `commit()` no sucesso + `rollback()` no erro. Nunca deixar gravação parcial.
- **RO-08 — Log4j 2.** Erros via logger (`Throwable` como último argumento); nunca `printStackTrace`/`System.out`.
- **RO-11 — Encoding/Locale** explícitos quando relevante.

## Fluxo

1. Validar entrada e confirmar tabela↔colunas reais.
2. Ler DAO existente, provedor de conexão e utilitário de retry.
3. Implementar cada operação com `PreparedStatement` parametrizado e `try-with-resources`.
4. Mapear `ResultSet`↔entidade num método privado de mapeamento.
5. Envolver operação crítica/multi-passo em transação atômica e/ou `RetryDB`.
6. Tratar erro com logger; propagar exceção coerente com o projeto (sem engolir).
7. Rodar build/teste relevante e reportar arquivos e suposições.

## Regras de implementação

- DAO não contém regra de negócio (isso é do serviço) nem chama a UI.
- Reusar o provedor de conexão; não duplicar configuração de conexão.
- Buscas que retornam coleção devolvem lista; busca por id devolve `Optional`/`null` no padrão do projeto.

## Guardrails

- Nunca concatenar string em SQL (RO-04). Nunca `SELECT *` em listagem.
- Não inventar nome de tabela, coluna, método de conexão ou de retry (RO-01).
- Não abrir conexão fora do provedor do projeto. Não deixar `ResultSet`/`Statement` sem fechar.
- Não misturar acesso concorrente na conexão única do Access.

## Saída esperada

- DAO da entidade no pacote de persistência do projeto, com as operações pedidas.
- Mapeamento linha↔objeto, transações onde necessário, retry nas operações críticas.
- Nota com tabela/colunas usadas e suposições (RO-01).

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair SQL para constantes; paginar `listar`; índice na coluna de busca mais usada).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (RO-04, colunas sensíveis fora de listagem) · `dev-senior` (mapeamento e recursos sempre fechados).
- **Vem antes:** `java-db-foundation` (provedor + RetryDB) · `java-javafx-entity` (a entidade mapeada).
- **Vem depois:** `java-service-usecase` (consome o DAO) · `testador-real` (prova as operações contra o banco).
- **Não confundir com:** `java-db-foundation` (infraestrutura de conexão — aqui é o DAO da entidade).
