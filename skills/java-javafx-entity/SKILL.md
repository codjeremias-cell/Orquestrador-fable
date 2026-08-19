---
name: java-javafx-entity
description: "Cria ou completa uma entidade/modelo de domínio Java num projeto JavaFX, espelhando o formato real das entidades que o projeto já usa e inclusive se e como ele testa entidades. Peça de MODELO do pipeline desktop Java. Acione com \"entidade\", \"cria a entidade Cliente\", \"preciso de um modelo de Funcionário com esses campos\", \"adiciona a classe de domínio Produto\", \"modela a tabela X como objeto\", \"vira classe essa lista de campos\", \"POJO de X\", \"objeto de domínio\", \"modelo com esses atributos\". NÃO acione para criar o DAO/persistência (use java-jdbc-dao), a tela (use javafx-screen-fxml) nem a regra de negócio de serviço (use java-service-usecase)."
argument-hint: [nome-da-entidade]
---

# Java/JavaFX — Entidade de Domínio

📍 **No pipeline Java:** peça de modelo. Vem depois de `requisitos-descoberta` (os atributos saem da história aprovada) e antes de `java-jdbc-dao` (persiste a entidade) e `java-service-usecase` (orquestra a regra do fluxo).

## Objetivo

Criar uma classe de domínio (entidade/modelo) que **parece escrita pela mesma mão** que o resto do projeto. Não existe UMA forma canônica de entidade — existe a forma que **este projeto** usa. Sua tarefa é detectá-la e reproduzi-la exatamente, não impor um estilo. A entidade carrega dados; não acessa banco, tela nem serviço.

## Entradas obrigatórias

1. Nome da entidade (ex.: `Cliente` / `Viagem`).
2. Atributos com tipos (ex.: `nome: String`, `data: LocalDate`).

## Trava obrigatória

- Não gerar sem o nome e ao menos os atributos principais.
- Ambiguidade de pacote, ou já existir classe de mesmo nome → **parar e perguntar** antes de escrever.

## O princípio central: espelhar, não impor (RO-01)

**Antes de escrever, leia uma entidade existente do projeto e copie a forma dela** — é a decisão que mais define a nota da entrega, porque uma entidade fora do padrão do projeto obriga todo mundo depois (DAO, serviço, controller) a tratar dois estilos. Detecte e reproduza:

- **Pacote** (`br.com.<proj>.model`? `entity`?).
- **Mutabilidade:** POJO com **setters** ou imutável com **construtor**? (não misture os dois estilos no mesmo projeto).
- **Validação:** existe `validate()` na entidade, ou a validação vive no **FormController** da tela? Copie o que o projeto faz.
- **`equals`/`hashCode`:** o projeto usa por `id`, ou não usa? Copie.
- **Idioma dos identificadores:** PT-BR ou inglês? Copie o do projeto (não force inglês).
- **Campo de exibição vindo de JOIN** (ex.: `colaboradorNome`) e **domínio fechado documentado em comentário** (ex.: `// "Planejado" ou "Realizado"`), se o projeto usa.

**Gabarito SIGO (código real):** projeto-alvo sendo o **SIGO/SIGCOT ou família** (EscalaOper, Sentinela), carregue `referencia-exemplos-reais-sigo.md` — `Viagem.java` verbatim: POJO simples PT-BR, **setters**, **sem** `validate()`/`equals`/construtor custom (validação vive no FormController), campo de JOIN com comentário. Esse É o padrão do projeto; segui-lo é acerto, não desvio.

## Só quando o projeto NÃO tem entidade nenhuma (default a confirmar)

Sem nada para espelhar, proponha um default **e marque como suposição a confirmar (RI-04)**: campos `private` (`final` quando imutável), construtor que recebe os campos, getters, `equals`/`hashCode` por `id`, e um `validate()` que **coleta** os erros numa lista (a entidade pode existir temporariamente inválida). Nunca jogue `validate()` no construtor. Assim que o projeto ganhar 2–3 entidades, o padrão delas passa a mandar.

## Convenções que valem em qualquer estilo

- Classe `PascalCase`; arquivo `NomeEntidade.java`. Sem emoji em código (RO-05).
- A entidade é **pura**: não toca `Connection`/`ResultSet`, FXML nem `System.out`. É o que mantém o modelo reusável por DAO, serviço e telas sem arrastar dependência de camada.
- Comentar só o **porquê** de uma regra não óbvia (ex.: o domínio fechado de um campo).

## Fluxo

1. Resolver o pacote pelo padrão real; **ler uma entidade existente** (ou o gabarito SIGO) e extrair a forma (mutabilidade, validação, equals, idioma).
2. Escrever a entidade **na forma detectada** — não na forma genérica.
3. **Teste — espelhe a prática do projeto:** se o projeto **testa** entidades (há testes de modelo), escreva o teste no estilo dele (criação válida + getters +, se valida na entidade, dado válido/inválido e limites). Se o projeto **não** testa POJO puro (ex.: SIGO — `Viagem.java` não tem teste), **não gere teste** — só se o usuário pedir (aí, declarado).
4. Rodar o teste **(quando gerado)** e reportar arquivos criados, forma espelhada + suposições (RO-01).

## Guardrails

- **Não impor estilo:** se o projeto usa setters e não usa `validate()`/`equals` (ex.: SIGO), **não** adicione construtor imutável, `validate()` nem `equals` "porque é boa prática" — isso quebra a consistência. Espelhe.
- Não inventar utilitário, exceção ou assinatura não confirmada (RO-01).
- Não criar DAO, tela, serviço ou migration.

## Saída esperada

- `NomeEntidade.java` no pacote e na forma do projeto — **e teste JUnit no estilo do projeto SÓ se o projeto testar entidades** (senão, sem teste; ex.: SIGO).
- Nota curta: forma espelhada (de qual entidade), validações aplicadas (ou onde a validação vive), suposições (RO-01).

## Verificação de fechamento (RI-04)

A entidade fecha quando compila e o teste (quando o projeto testa) roda verde:

1. **Compila:** `mvn -q -DskipTests compile` (ou `./gradlew compileJava` no Gradle) roda verde — a classe bate com o `target/classes` do projeto, sem tipo/import inventado.
2. **Teste espelha o projeto:** se o projeto testa entidades (há testes de modelo), gere o teste no estilo dele e rode-o verde (`mvn -q test` / `./gradlew test`). Se o projeto **não** testa POJO puro (ex.: o SIGO — `Viagem.java` não tem teste), o fechamento é a compilação limpa, e um teste só entra se o usuário pedir (declarado).

Não imponha teste onde o projeto não usa — isso também é espelhar. "Compilou e está no padrão do projeto" é o critério; "parece pronto" não basta.

## Sugestões de evolução (RO-07)
Feche com 2–3 (ex.: extrair enum para um campo de domínio fechado; fábrica de teste da entidade).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (POJO limpo + teste) · `arquiteto-software` (pacote e limite do domínio).
- **Vem antes:** `requisitos-descoberta` (atributos e regras vêm da história aprovada).
- **Vem depois:** `java-jdbc-dao` (persiste a entidade) · `java-service-usecase` (orquestra a regra do fluxo).
- **Não confundir com:** `java-jdbc-dao` (persistência) e `java-service-usecase` (regra de negócio do fluxo).

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-18 — Evolução ao 9,5 (núcleo SIGO)** (corpo reescrito para espelhar-não-impor; verificação de fechamento RI-04; evals com 3 casos).
