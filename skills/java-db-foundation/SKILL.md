---
name: java-db-foundation
description: "Cria a fundação de acesso a banco de um projeto Java desktop: provedor de conexão lendo config.properties (segredos fora do git) e o padrão de conexão segura com retry, que os DAOs consomem. PASSO 2 do pipeline desktop Java. Acione com \"fundação\", \"configura o acesso ao banco\", \"cria a conexão com o Access\", \"monta a base de conexão\", \"preciso do provedor de conexão / RetryDB e do config\", \"como o app conecta no banco\", \"lê as credenciais do config.properties\", \"onde ficam as credenciais do banco\", \"retry de conexão\", \"provedor único de Connection\", \"config.properties fora do git\", \"conexão thread-safe do Access/UCanAccess\". NÃO acione para criar um DAO de entidade (use java-jdbc-dao) — esta skill cria a infraestrutura que o DAO usa."
---

# Java — Fundação de Banco de Dados

📍 **No pipeline Java:** passo 2 de 7. Vem depois de `java-project-bootstrap` (pom com o driver declarado) e é consumida por `java-jdbc-dao` (cada DAO lê e imita esta fundação).

## Objetivo

Criar a infraestrutura de conexão que todo DAO do projeto vai reusar: um provedor de conexão que lê credenciais de `config.properties` (fora do versionamento), a resiliência (retry / serialização de acesso) necessária ao driver, e o padrão de uso seguro de conexão. É o que o `java-jdbc-dao` lê e imita — por isso o valor está em acertar a FORMA real do projeto, não numa forma canônica.

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
- Qualquer provedor de conexão já existente no projeto ou em projeto-irmão validado — reusar a forma real, inclusive onde ele resolve retry/serialização.
- O `config.properties.example` para alinhar as chaves esperadas.

## Os invariantes inegociáveis (valem em qualquer projeto)

> Divergência deliberada do template §5b ("Convenções obrigatórias" / "Regras de implementação", PADRAO-DE-AUTORIA.md): esta skill organiza o corpo em **invariante × o que varia** porque é exatamente essa fronteira — não nomes/paths — que resolve a fricção descrita no Histórico.

Estes não variam — são segurança e correção, não estilo:

- **Segredos fora do git.** URL/usuário/senha/caminho sensível SEMPRE fora do código-fonte — `config.properties` (ou equivalente) no `.gitignore`, com `*.example` versionado. **Nenhuma** credencial hardcoded (padrão universal, REGRAS-DE-OURO.md § Padrões universais). É o mesmo contrato que o `java-project-bootstrap` já deixou preparado.
- **Provedor único de conexão.** Uma classe central entrega a `Connection`; nenhum outro ponto do projeto abre conexão diretamente — é o que permite ao `java-jdbc-dao` ficar limpo (sem re-resolver retry/lock em cada DAO).
- **try-with-resources no consumo.** É o padrão de uso que a fundação impõe aos DAOs (RO-10 — try-with-resources obrigatório em `Connection`/`Statement`/`ResultSet`).
- **RO-08 — Log4j 2** para falhas de conexão; sem `System.out`.
- **RO-11 — Encoding/Locale** corretos ao montar a URL/params quando relevante.
- **Sem corrupção por acesso concorrente.** Se o driver/banco não é thread-safe para conexão única (ex.: UCanAccess/Access), a fundação GARANTE alguma serialização real do acesso, coordenada com `javafx-screen-fxml` para não travar a UI (RO-J1). O QUE é inegociável é não corromper dados por concorrência; COMO se implementa é o que varia — abaixo.

## O que VARIA por projeto — espelhe, não prescreva

- **Onde vive o retry.** Utilitário separado (`RetryDB.executar(...)` ou nome equivalente) OU embutido no próprio provedor de conexão (o método de abrir conexão já tenta N vezes sozinho). Leia o provedor existente e copie a forma — não crie uma segunda camada de retry se o provedor já resolve.
- **Mecanismo de serialização quando o driver exige.** Pode ser um lock simples + `Task` para não travar a UI, uma serialização em 2 níveis (lock reentrante na JVM + lock de arquivo entre máquinas), ou nem existir — bancos cliente-servidor (PostgreSQL, MySQL) com pool próprio raramente precisam disso. Copie o mecanismo real do projeto; só proponha um novo em greenfield, e declare **SUPOSIÇÃO:** (RO-01).
- **Política de retry.** Número de tentativas e espera fixa vs. progressiva — o projeto real dita o número; não inventar (RO-01).
- **Origem do caminho/URL do banco.** Se o projeto já lê pasta de rede via properties sem recompilar, replicar essa leitura; senão é decisão de greenfield — declarar **SUPOSIÇÃO:** (RO-01).

**Gabarito SIGO (few-shot de código real):** projeto-alvo **SIGO/família**, carregue `referencia-exemplos-reais-sigo.md` — `Database.java` verbatim, com o mecanismo completo (retry, trava em 2 níveis, leitura de `config.properties`). No SIGO **não existe uma classe `RetryDB` separada**: retry e serialização vivem dentro da própria `Database`. É esta a infra que os DAOs consomem pronta — o corpo genérico que manda criar um `RetryDB` à parte perde para o padrão real; desvio se declara (RO-01).

## Fluxo

1. Validar driver/banco e a origem da config.
2. Ler `pom.xml`, config e provedor existente (se houver) — extrair onde vive retry/serialização e a forma real.
3. Criar o provedor de conexão lendo `config.properties`.
4. Resolver a resiliência **na forma detectada** (embutida no provedor ou utilitário separado) — ou, greenfield, a decisão mais simples, declarada **SUPOSIÇÃO:**.
5. Garantir `.gitignore`/`*.example` cobrindo os segredos.
6. Rodar a verificação de fechamento (abaixo) e reportar.

## Guardrails

- Nunca hardcode credencial nem caminho de banco sensível.
- Não inventar a API do driver (RO-01) — confirmar no `pom.xml`/doc.
- Não permitir abertura de conexão fora do provedor central.
- Não impor uma segunda camada de retry/lock se o provedor já resolve (recriar é erro, não zelo).

## Saída esperada

- Provedor de conexão com a resiliência necessária (na forma real do projeto) + leitura de `config.properties`, com segredos fora do git.
- Nota com onde vivem retry/serialização neste projeto e suposições (RO-01).
- Base pronta para o `java-jdbc-dao` ler e imitar.

## Verificação de fechamento (RI-04)

A fundação só fecha quando o build prova que ela compila e, quando possível, conecta de verdade:

1. **Compila:** `mvn -q -DskipTests compile` (ou `./gradlew compileJava` no Gradle) roda verde contra o projeto — o provedor referencia a API real do driver, sem método inventado.
2. **Smoke test de conexão (quando há banco acessível):** um teste real obtém e fecha uma `Connection` pelo provedor (arquivo local do Access alcançável, ou servidor de rede alcançável). Prova que URL, credenciais e driver batem.
3. **Segredos fora do git:** `config.properties` está no `.gitignore` e só o `*.example` é versionado.

Quando não há banco disponível na sessão, o passo 2 vira **SKIP declarado** com o motivo (o próprio SIGO não tem teste automatizado do provedor), nunca "passou" fingido — mas o passo 1 (compila) e o passo 3 (segredos) permanecem sempre executáveis.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: pool de conexão; healthcheck de banco no start; separar config por ambiente).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (segredos fora do git) · `dev-senior` (retry e conexão legíveis).
- **Vem antes:** `java-project-bootstrap` (pom com o driver declarado).
- **Vem depois:** `java-jdbc-dao` (lê e imita esta fundação).
- **Não confundir com:** `java-jdbc-dao` (DAO de entidade — aqui é a infraestrutura que ele usa).

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-19 — Rodada 2 (destravamento, decisões D-A..D-D)** (description descongelada removendo a promessa fixa de `RetryDB`, correção de citações RO-01/RO-10, evals com origem/fonte).
