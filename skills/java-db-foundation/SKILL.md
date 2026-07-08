---
name: java-db-foundation
description: Cria a fundação de acesso a banco de um projeto Java desktop — provedor de conexão lendo config.properties (segredos fora do git), utilitário de retry para operações críticas (RetryDB) e o padrão de conexão segura que os DAOs vão consumir. Acione quando o usuário disser coisas como "configura o acesso ao banco", "cria a conexão com o Access", "monta a base de conexão", "preciso do RetryDB e do config", "como o app conecta no banco". NÃO acione para criar um DAO de entidade (use java-jdbc-dao) — esta skill cria a infraestrutura que o DAO usa.
---

# Java — Fundação de Banco de Dados

## Objetivo

Criar a infraestrutura de conexão que todo DAO do projeto vai reusar: um provedor de conexão que lê credenciais de `config.properties` (fora do versionamento), um utilitário de retry para operações críticas, e o padrão de uso seguro de conexão. É o que o `java-jdbc-dao` lê e imita.

## Entradas obrigatórias

1. Banco/driver alvo (padrão SIGO: Access via UCanAccess; pode ser outro).
2. De onde vêm as credenciais/URL (padrão: `config.properties`).

## Entradas opcionais

- Política de retry (nº de tentativas, espera), pool de conexão se aplicável.

## Trava obrigatória

- Se já existe um provedor de conexão no projeto, **ler e evoluir**, não duplicar.
- Não prosseguir sem saber o driver/banco real.

## Leituras obrigatórias (RO-01)

- O `pom.xml` (driver/dependência de banco já declarados pelo `java-project-bootstrap`).
- Qualquer provedor de conexão ou `RetryDB` já existente no projeto ou em projeto-irmão validado — reusar o padrão real.
- O `config.properties.example` para alinhar as chaves esperadas.

## Convenções obrigatórias (Regras de Ouro do track)

- **Segredos fora do git:** ler URL/usuário/senha de `config.properties` (no `.gitignore`) com `*.example` versionado. **Nenhuma** credencial hardcoded (RO-04 / lição cross-projeto).
- **Provedor único de conexão:** uma classe central entrega `Connection`; ninguém abre conexão fora dela.
- **`RetryDB.executar(...)`** (ou equivalente real): envolve operações críticas com retry (RO-10).
- **try-with-resources** é o padrão de uso (documentar no cabeçalho da classe).
- **UCanAccess não é thread-safe** com conexão única — documentar a serialização do acesso e o uso de `Task` para não travar a UI (RO-J1, coordenado com `javafx-screen-fxml`).
- **RO-08 — Log4j 2** para falhas de conexão; sem `System.out`.
- **RO-11 — Encoding/Locale** ao montar a URL/params quando relevante.

## Fluxo

1. Validar driver/banco e a origem da config.
2. Ler `pom.xml`, config e provedor existente (se houver).
3. Criar o provedor de conexão lendo `config.properties`.
4. Criar o utilitário `RetryDB` (ou evoluir o existente).
5. Garantir `.gitignore`/`*.example` cobrindo os segredos.
6. Fazer um smoke test de obtenção de conexão (evidência — RI-04) e reportar.

## Guardrails

- Nunca hardcode credencial nem caminho de banco sensível.
- Não inventar a API do driver (RO-01) — confirmar no `pom.xml`/doc.
- Não permitir abertura de conexão fora do provedor central.

## Saída esperada

- Provedor de conexão + `RetryDB` + leitura de `config.properties`, com segredos fora do git.
- Smoke test de conexão como evidência.
- Base pronta para o `java-jdbc-dao` ler e imitar.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: pool de conexão; healthcheck de banco no start; separar config por ambiente).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (segredos fora do git) · `dev-senior` (retry e conexão legíveis).
- **Vem antes:** `java-project-bootstrap` (pom com o driver declarado).
- **Vem depois:** `java-jdbc-dao` (lê e imita esta fundação).
- **Não confundir com:** `java-jdbc-dao` (DAO de entidade — aqui é a infraestrutura que ele usa).
