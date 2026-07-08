---
name: spec-javafx-crud-feature
description: Orquestra a criação de uma funcionalidade CRUD completa em projeto Java/JavaFX, do domínio à tela, encadeando as skills do track Java (entidade, DAO JDBC, serviço, tela FXML, logging) e garantindo as Regras de Ouro do stack. Acione quando o usuário disser coisas como "cria a funcionalidade completa de Cliente", "preciso do CRUD de Funcionário ponta a ponta", "monta tudo dessa entidade: domínio, banco e tela", "faz a feature inteira de Produto". NÃO acione para uma única camada isolada — para isso use a skill específica do track.
---

# Spec — Funcionalidade CRUD JavaFX (orquestrador)

Esta skill é uma **orquestradora**. Conduz, em ordem determinística, a criação de uma funcionalidade CRUD completa num projeto Java/JavaFX, delegando para as skills especializadas do track e validando cada etapa. Não duplica o trabalho detalhado delas.

## Objetivo

Entregar, de ponta a ponta, uma funcionalidade de uma entidade: domínio + persistência + regra de negócio + tela, respeitando as [[REGRAS-DE-OURO]] do track Java/JavaFX.

## Entradas obrigatórias

1. Nome da entidade e seus atributos.
2. Tabela/colunas reais (ou autorização para descobrir no projeto).
3. Operações desejadas (criar, listar, editar, excluir, buscas).
4. Confirmação de que a funcionalidade inclui tela.

## Entradas opcionais

- Regras de negócio específicas, navegação/menu, validações de formulário.

## Validação do catálogo

Antes de começar, confirmar que existem no catálogo as skills filhas (ajuste o caminho real de instalação):

- `java-javafx-entity`
- `java-jdbc-dao`
- `java-service-usecase`
- `javafx-screen-fxml`
- `java-logging-log4j2`

Se faltar uma skill crítica, **parar** e informar qual faltou e para qual papel.

## Sequência determinística

Executar em ordem; validar cada etapa antes de seguir.

1. **Mockup primeiro (RO-06).** Apresentar o mockup da tela e obter aceite do Mestre antes de qualquer código.
2. **Entidade.** Acionar `java-javafx-entity` para a entidade + teste.
3. **Persistência.** Acionar `java-jdbc-dao` para o DAO (SQL parametrizado, try-with-resources, colunas explícitas, transação onde precisar, retry nas operações críticas).
4. **Regra de negócio.** Acionar `java-service-usecase` para os casos de uso que a tela vai chamar.
5. **Tela.** Acionar `javafx-screen-fxml` para FXML + controller (estados vazio/carregando/erro, banco em `Task`, tokens de tema, FXML frágil respeitado).
6. **Logging.** Garantir, via `java-logging-log4j2`, que erros usam Log4j 2 (sem `printStackTrace`/`System.out`).
7. **Fechamento com prova.** Rodar build/testes relevantes; conferir a feature de ponta a ponta. Quando existir bateria aplicável, acionar `testador-real` (ou o testador do projeto) — a evidência do gate é teste **executado**, não checklist (RI-04).

## Regras de coerência

- Manter nomes consistentes entre entidade, DAO, serviço, controller e FXML.
- Reaproveitar o padrão real do projeto (controller-base, AlertaUtil, provedor de conexão, RetryDB, CSS de tema) — descobrir por leitura, nunca inventar (RO-01).
- Operação multi-passo = transação atômica; UI nunca congela (RO-J1).

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Tabela/colunas ou regra de negócio ambíguas.
- Mockup não aprovado.
- Falha em build/teste obrigatório.

## Formato do relatório final (RI-05)

Ao concluir, entregar resumo objetivo: skills usadas · arquivos criados/alterados (com caminho exato — RO-03) · testes executados · o que foi validado · pendências/limitações · **2–3 sugestões de evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito.

## Saída esperada

- Entidade + teste; DAO; serviço(s) + teste; FXML + controller; logging padronizado.
- Funcionalidade CRUD funcional de ponta a ponta, aderente às Regras de Ouro do track.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06) · `qa-usabilidade` e `auditor-responsabilidades` (fechamento e veredito).
- **Vem antes:** projeto com fundação pronta (`java-db-foundation`, `javafx-app-shell`, tema por tokens).
- **Vem depois:** `testador-real` (bateria da feature) · `docs-projeto` (se a feature muda o manual).
- **Não confundir com:** `spec-javafx-new-system` (sistema inteiro do zero) · `javafx-dashboard` (se a "feature" for um painel de KPIs, é ele quem conduz a tela).
