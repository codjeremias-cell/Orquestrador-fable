---
name: java-project-bootstrap
description: Cria do zero o esqueleto de um projeto Java desktop JavaFX com Maven, pronto para compilar e empacotar — pom.xml (JavaFX, Log4j2, driver de banco, maven-shade), classe App, estrutura de pastas, .gitignore, config.properties.example e log4j2.xml. Acione quando o usuário disser coisas como "cria um sistema novo do zero", "começa um projeto JavaFX novo", "monta a base do app", "inicializa o projeto Maven com JavaFX", "quero começar um sistema desktop". NÃO acione em projeto que já existe (para evoluir, use as skills específicas).
---

# Java — Bootstrap de Projeto (JavaFX + Maven)

## Objetivo

Materializar, numa pasta vazia, o esqueleto de um app desktop JavaFX com Maven que **compila e empacota** desde o primeiro minuto. É o alicerce sobre o qual `java-db-foundation`, `javafx-app-shell` e as features são construídos. Estabelece as convenções do projeto (encoding, logging, segredos fora do git, fat-jar para jpackage).

## Entradas obrigatórias

1. Nome do app (ex.: `SIGCOT`).
2. Pacote raiz / coordenadas Maven (ex.: `br.com.sigo`, groupId/artifactId).
3. Banco alvo (padrão do mundo SIGO: Access via UCanAccess; pode ser outro).

## Entradas opcionais

- Versão do Java alvo, ícone `.ico`, fornecedor, nome de janela.

## Trava obrigatória

- Não executar se a pasta já contém um projeto (`pom.xml` presente) — para evoluir, usar as skills específicas. Só prosseguir do zero com pasta limpa ou pedido explícito de re-scaffold.
- Se o pacote raiz/coordenadas não vierem, pedir antes de gerar.

## Leituras obrigatórias (RO-01 — nunca inventar)

- Se houver um projeto-irmão do mesmo dono (ex.: SIGO/EscalaOper) acessível, ler o `pom.xml` e a `App` dele para reproduzir versões e padrões **reais já validados** em vez de assumir.
- Quando nenhuma referência real estiver disponível, montar com práticas-padrão e **declarar as versões/escolhas como confirmáveis**, validando pelo build (não afirmar versão de cor).

## Convenções obrigatórias (Regras de Ouro do track)

- **Estrutura:** `src/main/java/<pkg>/{app,model,dao,service,ui/controller}` e `src/main/resources/{fxml,css,log4j2.xml,config.properties.example}`.
- **`pom.xml`** com: `javafx-controls` + `javafx-fxml`; `log4j-api` + `log4j-core` (RO-08); driver do banco (UCanAccess para Access); `maven-shade-plugin` gerando fat-jar com `mainClass` (base do jpackage — RO-J2); `maven-compiler-plugin` com `release`; `<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>` (RO-11).
- **Classe `App` (extends `Application`)** carregando o FXML inicial; `main` define `Locale.forLanguageTag("pt-BR")` e usa UTF-8.
- **Segredos fora do git:** `config.properties` no `.gitignore` + `config.properties.example` versionado (nenhuma credencial no código).
- **`.gitignore`** cobrindo `target/`, `config.properties`, artefatos de build.
- Sem emoji em código (RO-05); identificadores em inglês; textos de UI em PT-BR.

## Fluxo

1. Validar entradas e confirmar pasta limpa.
2. Ler projeto-irmão de referência, se houver (RO-01).
3. Criar a estrutura de pastas e o `pom.xml`.
4. Gerar `App`, `log4j2.xml`, `.gitignore`, `config.properties.example` e um FXML+CSS placeholder mínimo (com token de tema, não cor fixa).
5. Rodar `mvn -q -DskipTests package` para provar que compila e gera o fat-jar (evidência — RI-04).
6. Reportar estrutura criada, versões usadas e próximos passos (`java-db-foundation`).

## Guardrails

- Não sobrescrever projeto existente.
- Não chumbar caminho de banco nem credencial — usar `config.properties.example`.
- Não afirmar versões de cor; validar pelo build.
- Não criar regra de negócio, DAO real, telas de feature ou conexão aqui — só o esqueleto.

## Saída esperada

- Projeto Maven JavaFX que compila e empacota, com logging, encoding, segredos e fat-jar configurados.
- Build verde como evidência.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: seguir com `java-db-foundation`; adicionar `javafx-app-shell`; configurar o `java-package-desktop`).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (estrutura de pacotes) · `dev-senior` (pom e App legíveis).
- **Vem antes:** `requisitos-descoberta` / `spec-javafx-new-system` (nome, pacote e banco já decididos).
- **Vem depois:** `java-db-foundation` → `java-logging-log4j2` → `javafx-theme-tokens` → `javafx-app-shell`.
- **Não confundir com:** `spec-javafx-new-system` (o orquestrador que chama esta e as demais).
