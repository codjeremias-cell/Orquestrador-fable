---
name: java-javafx-entity
description: Cria ou completa uma entidade/modelo de domínio Java (POJO com campos privados, construtor, getters e validação explícita) dentro de um projeto JavaFX, seguindo o padrão real do projeto e gerando o teste JUnit correspondente. Acione quando o usuário disser coisas como "cria a entidade Cliente", "preciso de um modelo de Funcionário com esses campos", "adiciona a classe de domínio Produto", "modela a tabela X como objeto" ou colar uma lista de atributos para virar classe Java. NÃO acione para criar o DAO/persistência (use java-jdbc-dao), a tela (use javafx-screen-fxml) nem a regra de negócio de serviço (use java-service-usecase).
---

# Java/JavaFX — Entidade de Domínio

## Objetivo

Criar uma classe de domínio Java (entidade/modelo) que representa um conceito do negócio, no padrão real do projeto, com validação explícita e teste JUnit. A entidade carrega dados e a regra de consistência do próprio objeto — não acessa banco, tela nem serviço.

## Entradas obrigatórias

1. Nome da entidade (ex.: `Cliente`).
2. Lista de atributos com tipos (ex.: `nome: String`, `idade: int`, `email: String`, `dataAdmissao: LocalDate`).

## Entradas opcionais

- Pacote de destino, se não puder ser inferido do projeto.
- Regras explícitas por campo (ex.: "email obrigatório e válido", "idade entre 18 e 75").
- Se a entidade tem identidade (`id`) e qual o tipo.

## Trava obrigatória

- Não gerar sem o nome da entidade e ao menos os atributos principais.
- Se houver ambiguidade sobre o pacote de destino ou já existir uma classe com o mesmo nome, parar e perguntar antes de escrever.

## Leituras obrigatórias (RO-01 — nunca inventar o padrão)

Antes de escrever, ler do projeto real:

1. Uma entidade/modelo já existente (ex.: em `src/main/java/**/model/` ou `**/entity/`) para copiar o padrão de campos, construtor, getters e validação.
2. A classe utilitária de validação/exceção do projeto, se existir.
3. Um teste de entidade já existente para reproduzir o estilo de teste.

Se o projeto ainda não tiver entidade nenhuma, propor o padrão abaixo e marcar como **suposição a confirmar** com o Mestre antes de espalhar.

## Convenções obrigatórias

- Classe em `PascalCase`; arquivo `NomeEntidade.java`; campos e métodos em inglês.
- Campos `private` (preferir `final` quando imutável); construtor que recebe os campos; getters explícitos; `equals`/`hashCode` por identidade quando houver `id`.
- Encoding/Locale: ao formatar datas/números, declarar `Locale.forLanguageTag("pt-BR")` (RO-11). Não confiar no default da JVM.
- Validação **explícita**, não no construtor por padrão: um método `validate()` que coleta os erros e os reporta de forma consistente com o projeto (lista de erros ou exceção de validação já usada). A entidade pode existir temporariamente inválida.
- Sem emoji em código (RO-05). Sem regra de negócio de serviço aqui (isso é do `java-service-usecase`).

## Fluxo

1. Validar entradas e resolver o pacote de destino pelo padrão real do projeto.
2. Ler as referências obrigatórias e descobrir o padrão concreto (validação, exceção, estilo de teste).
3. Escrever a classe da entidade com campos, construtor, getters e `validate()`.
4. Inferir as validações por nome/tipo do campo, reaproveitando utilitários do projeto; priorizar regra explícita do usuário.
5. Escrever o teste JUnit cobrindo: criação válida, leitura dos getters, validação com dado válido e inválido, e limites das regras aplicadas.
6. Rodar o teste do módulo/classe e reportar arquivos criados e suposições feitas.

## Regras de implementação

- Reaproveitar utilitário de validação do projeto antes de criar lógica nova.
- Não acessar `Connection`, `ResultSet`, FXML nem `System.out`. Entidade é pura.
- Comentar só o "porquê" de uma regra não óbvia, nunca o óbvio.

## Guardrails

- Não inventar utilitário, exceção ou assinatura que não foi confirmada no projeto (RO-01).
- Não criar DAO, tela, serviço ou migration.
- Não jogar `validate()` no construtor sem o padrão do projeto pedir.

## Saída esperada

- `NomeEntidade.java` no pacote correto, no padrão do projeto.
- Teste JUnit correspondente.
- Nota curta com as validações aplicadas e qualquer suposição (RO-01).

## Sugestões de evolução (RO-07)
Ao entregar, fechar com 2–3 sugestões (ex.: extrair um enum para um campo de domínio fechado; criar uma fábrica de teste da entidade).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (POJO limpo + teste) · `arquiteto-software` (pacote e limite do domínio).
- **Vem antes:** `requisitos-descoberta` (atributos e regras vêm da história aprovada).
- **Vem depois:** `java-jdbc-dao` (persiste a entidade) · `java-service-usecase` (orquestra a regra do fluxo).
- **Não confundir com:** `java-jdbc-dao` (persistência) e `java-service-usecase` (regra de negócio do fluxo).
