---
name: javafx-screen-fxml
description: Cria ou evolui uma tela JavaFX (FXML + controller) consumindo um serviço/DAO do projeto, com mockup visual antes do código, estados vazio/carregando/erro, acesso a banco assíncrono (Task) para não congelar a UI e respeito às regras frágeis do FXML. Acione quando o usuário disser coisas como "cria a tela de cadastro de cliente", "preciso da janela de listagem de funcionários", "monta o FXML e o controller dessa funcionalidade", "faz a interface dessa operação". Comece SEMPRE pelo mockup (RO-06). NÃO acione para regra de negócio (use java-service-usecase) nem persistência (use java-jdbc-dao).
---

# JavaFX — Tela (FXML + Controller)

## Objetivo

Entregar uma tela JavaFX consistente com o projeto: FXML para a estrutura, controller fino que chama o serviço, com todos os estados cobertos e acesso a banco fora da thread da UI. A tela não tem regra de negócio nem SQL — ela orquestra a interação e delega.

## Regra de partida (RO-06): mockup antes de codar

Antes de gerar FXML/controller, apresentar um **mockup visual** da tela (imagem/HTML renderizado ou wireframe claro) e obter o aceite do Mestre, que é visual. Só codar a tela depois do "ok".

## Entradas obrigatórias

1. Função da tela (ex.: cadastro, listagem, detalhe) e a entidade/fluxo envolvido.
2. O serviço/caso de uso ou DAO que a tela consome.
3. Campos/colunas a exibir e ações disponíveis.

## Entradas opcionais

- Se entra num menu/navegação existente.
- Regras de habilitação de botões, validação de formulário na UI.

## Trava obrigatória

- Não gerar a tela sem o mockup aceito (RO-06) e sem o serviço/DAO alvo identificado.
- Se a navegação ou o controller-base do projeto forem ambíguos, perguntar.

## Leituras obrigatórias (RO-01)

1. Um FXML + controller já existentes para copiar o padrão (carregamento, injeção `@FXML`, navegação).
2. O controller-base/utilitário de alerta do projeto, se existir (ex.: `AlertaUtil`, classe base de controller).
3. O serviço/DAO que a tela vai chamar (assinaturas reais).
4. Os arquivos de tema/CSS do projeto (para usar tokens, não cor fixa).

## Convenções obrigatórias (Regras de Ouro do track)

- **RO-09 — FXML frágil:** `VBox.vgrow`/`HBox.hgrow` em **UMA linha** (quebrar corrompe o parser); não usar comentário com `>` extra; marcar blocos editados com `★★★ INÍCIO/FIM V.X.Y ★★★`.
- **RO-J1 — UI nunca congela:** toda chamada de banco roda em `Task` (thread daemon); atualizar a UI só no `onSucceeded`/`onFailed`; mostrar cursor de espera + placeholder "Carregando…" e desabilitar o botão durante a carga.
- **Estados sempre cobertos:** vazio (com `setPlaceholder(...)` em PT-BR — nunca o "No content in table" padrão), carregando, erro (alerta amigável) e sucesso.
- **RO-12 — Cor só por token de tema** declarado no `.root`; nada de hex fixo (quebra no dark).
- **RO-08 — Log4j 2** para erros; sem `System.out`. Controller **fino**: sem regra de negócio nem SQL.
- Sem emoji em código (RO-05); textos de UI em PT-BR.

## Fluxo

1. Apresentar o mockup e obter aceite (RO-06).
2. Ler FXML/controller existentes, controller-base, serviço/DAO e CSS de tema.
3. Escrever o FXML (estrutura + ids), respeitando as regras frágeis (RO-09).
4. Escrever o controller fino: injetar `@FXML`, ligar ações ao serviço, cobrir os estados.
5. Rodar o banco em `Task` com feedback de carga e tratamento de erro (RO-J1).
6. Aplicar tokens de tema; conferir contraste/teclado (a11y, casa com a lente Designer/QA).
7. Reportar arquivos criados, navegação afetada e suposições.

## Guardrails

- Não codar a tela antes do mockup aceito.
- Não acessar banco na thread da UI; não bloquear a interface.
- Não inventar id de componente, método de serviço ou token de tema (RO-01).
- Não colocar regra de negócio ou SQL no controller.
- Não quebrar as regras frágeis do FXML (RO-09).

## Saída esperada

- `Tela.fxml` + `TelaController.java` no padrão do projeto.
- Estados vazio/carregando/erro/sucesso cobertos; banco assíncrono; tokens de tema.
- Mockup aprovado registrado e nota com suposições.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair `AlertaUtil`/controller-base se ainda não existir; componente reutilizável de tabela com estados; atalhos de teclado).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06, estados, a11y) · `qa-usabilidade` (caminho triste e estados) · `dev-senior` (controller fino).
- **Vem antes:** `java-service-usecase` (o que a tela consome) · `javafx-app-shell` (onde se encaixa) · `javafx-theme-tokens` (tokens).
- **Vem depois:** `java-logging-log4j2` (erros logados) · `testador-real` (prova o fluxo de ponta a ponta).
- **Não confundir com:** `javafx-dashboard` (painel de KPIs/decisão — aqui é tela de operação/CRUD).
