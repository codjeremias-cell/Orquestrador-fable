---
name: java-project-bootstrap
description: "Cria do zero o esqueleto de um projeto Java desktop JavaFX com Maven, pronto para compilar e empacotar: pom.xml, App e Launcher, estrutura de pastas, .gitignore, config.properties.example e log4j2.xml. PASSO 1 do pipeline desktop Java. Acione com \"bootstrap\", \"esqueleto\", \"cria um sistema novo\", \"começa um projeto JavaFX novo\", \"monta a base do app\", \"inicializa o projeto Maven com JavaFX\", \"quero começar um sistema desktop\", \"arma a estrutura do projeto\", \"cria o pom do zero\", \"estrutura de pastas do projeto\", \"configura o Maven com shade e JavaFX\", \"projeto que já compila e empacota\", \"scaffold do sistema desktop\". NÃO acione em projeto que já existe (para evoluir, use as skills específicas do pipeline)."
---

# Java — Bootstrap de Projeto (JavaFX + Maven)

📍 **No pipeline Java:** passo 1 de 7 (a fundação). Vem depois de `requisitos-descoberta`/`spec-javafx-new-system` (que decidem nome, pacote e banco) e habilita todo o resto: `java-db-foundation` → `java-logging-log4j2` → `java-javafx-entity` → `java-jdbc-dao` → `java-service-usecase` → telas → `java-package-desktop`.

## Objetivo

Materializar, numa pasta vazia, o esqueleto de um app desktop JavaFX com Maven que **compila e empacota** desde o primeiro minuto. É o alicerce sobre o qual `java-db-foundation`, `javafx-app-shell` e as features são construídos. Estabelece as convenções do projeto (encoding, logging, segredos fora do git, fat-jar para jpackage) que as skills seguintes vão herdar sem re-decidir.

## Entradas obrigatórias

1. Nome do app (ex.: `SIGCOT`).
2. Pacote raiz / coordenadas Maven (ex.: `br.com.sigo`, groupId/artifactId).
3. Banco alvo (padrão do mundo SIGO: Access via UCanAccess; pode ser outro — vem da Entrada, nunca por reflexo do gabarito).

## Entradas opcionais

- Versão do Java alvo, ícone `.ico`, fornecedor, nome de janela.

## Trava obrigatória

- Não executar se a pasta já contém um projeto (`pom.xml` presente) — para evoluir, usar as skills específicas. Só prosseguir do zero com pasta limpa ou pedido explícito de re-scaffold.
- Se o pacote raiz/coordenadas não vierem, pedir antes de gerar.

## Leituras obrigatórias (RO-01 — nunca inventar)

- Se houver um projeto-irmão do mesmo dono (ex.: SIGO/EscalaOper) acessível, ler o `pom.xml` e a `App`/`Launcher` dele para reproduzir versões e padrões **reais já validados** em vez de assumir.
- Sem referência real acessível: montar com práticas-padrão e **declarar cada versão/escolha sem fonte como `SUPOSIÇÃO:` (RI-04)** — o critério de confirmação é o build: rodar `mvn -q -DskipTests package` (Fluxo, passo 5) até ficar verde; build vermelho invalida a suposição, build verde é a evidência que a confirma. Nunca afirmar versão "de cor" sem essa prova.

## Os invariantes inegociáveis (valem em qualquer projeto)

Estes não variam — são a base técnica que faz o esqueleto compilar, empacotar e ficar seguro por padrão:

- **Estrutura de pastas.** `src/main/java/<pkg>/{app,model,dao,service,ui/controller}` e `src/main/resources/{fxml,css,log4j2.xml,config.properties.example}`. Espelha as camadas do pipeline: cada skill seguinte tem um lugar previsível para escrever.
- **`pom.xml` mínimo:** `javafx-controls`+`javafx-fxml`; `log4j-api`+`log4j-core` (RO-08); o driver do banco informado nas Entradas; `maven-compiler-plugin` com `release` (Java alvo confirmado, não chutado); `<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>` (RO-11).
- **`maven-shade-plugin` com `mainClass` neutro — nunca a classe que estende `Application`.** É técnica universal do JavaFX empacotado em fat-jar via shade, não peculiaridade do SIGO: apontar o `mainClass` para a classe `Application` produz "JavaFX runtime components are missing" em tempo de execução. A saída é uma classe `Launcher` final, que NÃO estende `Application`, cujo único trabalho é chamar `App.main(args)` — é o que o `jpackage` (RO-J2) empacota. Inclui `ServicesResourceTransformer` quando há driver JDBC via `META-INF/services` (ex.: UCanAccess) e exclui `module-info.class` + assinaturas (`*.SF`/`*.DSA`/`*.RSA`).
- **Classe `App` (extends `Application`) só carrega o FXML inicial** — o `main` (na `Launcher`) define `Locale.forLanguageTag("pt-BR")` e usa UTF-8.
- **Segredos fora do git.** `config.properties` no `.gitignore` + `config.properties.example` versionado — nenhuma credencial no código (padrão universal, REGRAS-DE-OURO.md § Padrões universais). É o mesmo contrato que `java-db-foundation` vai consumir logo depois.
- **`.gitignore`** cobrindo `target/`, `config.properties`, artefatos de build.
- **Sem emoji em código (RO-05)**; identificadores claros — sem regra de idioma universal para eles (o gabarito real do SIGO usa PT-BR; espelhar a referência do projeto-alvo quando houver, RO-01); textos de UI em PT-BR.
- **Build verde como prova (RI-04)** — ver Verificação de fechamento.

## O que VARIA por projeto — espelhe, não prescreva

- **Driver e stack de banco.** UCanAccess/Access é o padrão do mundo SIGO, não uma imposição — usar o banco informado nas Entradas obrigatórias; nunca substituir por Access "porque é o padrão do catálogo".
- **Dependências extras de domínio (bcrypt, tema, PDF…).** `jbcrypt` (hash de senha), `atlantafx-base` (tema) e `openhtmltopdf-pdfbox` (PDF) são escolhas REAIS do SIGO, não convenção universal de bootstrap — só entram se a Entrada pedir a capacidade correspondente (login com hash, tema pronto, relatório PDF). O esqueleto não antecipa feature.
- **Plugins auxiliares.** `javafx-maven-plugin` (`mvn javafx:run`) e `exec-maven-plugin` (utilitários headless) são convenientes no SIGO; o único plugin obrigatório é o `maven-shade-plugin` (fat-jar para o `jpackage`, RO-J2) — os outros dois entram só se o projeto quiser rodar sem empacotar a cada teste.
- **Ordem de boot em `App.start()`.** O SIGO carrega fontes → tema global → backup diário → `Database.inicializar()` → seed de admin → `login.fxml`. Isso é **regra de negócio de feature**, fora do escopo do bootstrap (ver Guardrails) — o esqueleto abre só o FXML placeholder.
- **Nome do pacote/app.** Vem das Entradas obrigatórias (coordenadas Maven, nome do app) — nunca herdar `br.com.cot`/`SistemaCOT` do gabarito.

**Gabarito SIGO (few-shot de código real):** projeto-alvo **SIGO/família JavaFX**, carregue `referencia-exemplos-reais-sigo.md` — `pom.xml`+`App.java`+`Launcher.java` verbatim (Java 21, JavaFX 21.0.4, deps canônicas ucanaccess/jbcrypt/atlantafx/openhtmltopdf/log4j). O padrão real vence o genérico (RO-01) nos pontos em que o projeto-alvo É o SIGO/família; fora dela, use-o só como referência técnica do padrão `Launcher` (invariante acima, universal) — desvio se declara (RI-04).

### 🚫 Checklist negativo — greenfield sem projeto-irmão (não importar do SIGO por reflexo)

Sem uma fonte real apontando para o SIGO/família, NÃO:
- acrescentar `jbcrypt`, `atlantafx-base` ou `openhtmltopdf-pdfbox` ao `pom.xml` — só entram se a Entrada pedir a capacidade;
- assumir UCanAccess/Access como banco — usar o banco confirmado nas Entradas obrigatórias, ou parar e pedir;
- criar `Database`, `Backup`, `Tema.aplicarTemaGlobal()`, `seedAdminInicial()` ou `login.fxml` — é feature, não esqueleto (ver Guardrails);
- nomear pacote `br.com.cot` nem o app `SistemaCOT` — usar as coordenadas informadas;
- copiar os três plugins (`javafx-maven-plugin`+`exec-maven-plugin`+shade) por padrão — só o shade é obrigatório (RO-J2).

O único elemento do gabarito SIGO que **é** universal e deve entrar mesmo em greenfield é o padrão `Launcher` do invariante acima — é técnica de shade+JavaFX, não convenção de casa.

## Fluxo

1. Validar entradas e confirmar pasta limpa (Trava obrigatória).
2. Ler projeto-irmão de referência, se houver (Leituras obrigatórias).
3. Criar a estrutura de pastas e o `pom.xml` (invariantes acima; banco e dependências extras conforme "o que varia").
4. Gerar `App`, `Launcher`, `log4j2.xml`, `.gitignore`, `config.properties.example` e o FXML+CSS placeholder mínimo: uma tela com um `Label` e o `app.css` referenciado na cena, mas **sem nenhum hex fixo** — só um comentário `/* tokens de tema: definidos por javafx-theme-tokens (vem depois na Rede) */`. O esqueleto só garante que o arquivo existe e está ligado, não define paleta.
5. Rodar a Verificação de fechamento (abaixo).
6. Reportar estrutura criada, versões usadas (reais ou `SUPOSIÇÃO:` declaradas) e próximos passos (`java-db-foundation`).

## Guardrails

- Não sobrescrever projeto existente sem pedido explícito de re-scaffold (reforça a Trava).
- Não criar regra de negócio, DAO real, telas de feature, `Database`, `Backup` ou conexão aqui — só o esqueleto (ver checklist negativo acima); isso é `java-db-foundation` e as skills de feature.
- Não copiar dependências/plugins extras do SIGO por padrão — ver checklist negativo acima.

## Saída esperada

- Projeto Maven JavaFX que compila e empacota (fat-jar com `Launcher` como `mainClass`), com logging, encoding, segredos e shade configurados.
- Nota com versões usadas (reais ou `SUPOSIÇÃO:` declaradas) e onde ficaram as escolhas específicas de banco/dependências.
- Build verde (ou SKIP declarado) como evidência.

## Verificação de fechamento (RI-04)

O esqueleto só está pronto quando o build prova que ele compila e empacota — "parece completo" não fecha a entrega. Confira, nesta ordem:

1. **Compila e empacota (Maven):** `mvn -q -DskipTests package` roda verde e produz o fat-jar (`target/*.jar`). Se o projeto usa Gradle, o equivalente é `./gradlew build` (ou `shadowJar`) verde. Build vermelho invalida qualquer versão suposta (RO-01) — corrija antes de reportar.
2. **O fat-jar aponta para o `Launcher`, não para a `App`:** confirme o `mainClass` no `maven-shade-plugin` — apontar para a classe `Application` compila mas quebra em runtime com "JavaFX runtime components are missing".
3. **Roda (opcional, quando há GUI na sessão):** `java -jar target/<app>.jar` abre a janela placeholder sem erro. Sem display disponível, isto vira **SKIP declarado** com o motivo, nunca "abriu" fingido.
4. **Segredos fora do git:** `config.properties` está no `.gitignore` e só o `*.example` é versionado.

Quando o ambiente da sessão não tem Maven/JDK acessível para rodar o build, toda a verificação vira **SKIP declarado** com o motivo (ex.: "sem Maven no ambiente desta sessão"), nunca um "compila" fingido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: seguir com `java-db-foundation`; adicionar `javafx-app-shell`; configurar o `java-package-desktop`).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (estrutura de pacotes) · `dev-senior` (pom e App legíveis).
- **Vem antes:** `requisitos-descoberta` / `spec-javafx-new-system` (nome, pacote e banco já decididos).
- **Vem depois:** `java-db-foundation` → `java-logging-log4j2` → `javafx-theme-tokens` → `javafx-app-shell`.
- **Não confundir com:** `spec-javafx-new-system` (o orquestrador que chama esta e as demais).

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-19 — Correção pós-painel C1/Onda B** (poda de duplicação checklist↔guardrails, remoção de regra de idioma sem lastro, correção de citações RI-04, evals com origem/fonte).
