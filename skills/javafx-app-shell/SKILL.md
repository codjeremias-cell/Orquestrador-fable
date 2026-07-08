---
name: javafx-app-shell
description: Cria o shell de uma aplicação JavaFX — janela principal, navegação entre telas, AlertaUtil (alertas padronizados PT-BR) e um controller-base reutilizável — onde as telas das features se encaixam. Acione quando o usuário disser coisas como "cria a janela principal do app", "monta a navegação entre telas", "preciso de um menu e a estrutura base da interface", "cria o AlertaUtil e o controller base", "o esqueleto da UI". Comece pelo mockup (RO-06). NÃO acione para uma tela de feature específica (use javafx-screen-fxml).
---

# JavaFX — Shell da Aplicação

## Objetivo

Criar a casca da interface: a janela principal, o mecanismo de navegação que troca a tela central, e os utilitários compartilhados (`AlertaUtil`, controller-base) que matam duplicação e padronizam o comportamento. É onde as telas geradas por `javafx-screen-fxml` se conectam.

## Regra de partida (RO-06): mockup antes de codar
Apresentar o mockup da janela principal e da navegação e obter o aceite do Mestre (visual) antes de gerar FXML/código.

## Entradas obrigatórias

1. Nome do app e título da janela.
2. Itens de navegação iniciais (ex.: menu/abas: Clientes, Relatórios…).

## Entradas opcionais

- Tema inicial (claro/escuro), identidade visual (versão + autor na UI — lição cross-projeto).

## Trava obrigatória

- Não recriar um shell que já existe — ler e evoluir.
- Não gerar sem mockup aprovado.

## Leituras obrigatórias (RO-01)

- A classe `App` e o FXML inicial criados pelo `java-project-bootstrap`.
- Um shell/`AlertaUtil`/controller-base já existente em projeto-irmão validado, se houver.
- O CSS de tema (para a janela usar tokens, não cor fixa).

## Convenções obrigatórias (Regras de Ouro do track)

- **Janela principal** (`Stage`/`Scene`) com layout raiz; **navegação** que carrega o FXML da tela ativa na região central.
- **`AlertaUtil`** — alertas de info/erro/confirmação padronizados em PT-BR (evita o `mostrarAlerta` duplicado por controller).
- **Controller-base** reutilizável — concentra o comum (acesso ao shell, helpers de UI), reduzindo duplicação (item do seu backlog).
- **RO-12 — tema por tokens** aplicado no shell; troca claro/escuro; **RO-09 — FXML frágil** respeitado.
- **RO-J1 — UI nunca congela:** navegação que carrega dados usa `Task` + feedback; **estados** (vazio/carregando/erro) cobertos por padrão.
- **RO-08 — Log4j 2**; **identidade visível:** versão + crédito do autor na UI.

## Fluxo

1. Mockup da janela e navegação → aceite (RO-06).
2. Ler `App`/FXML inicial, shell de referência e CSS de tema.
3. Criar a janela principal + navegação central.
4. Criar `AlertaUtil` e o controller-base.
5. Ligar tema (tokens) e logging; cobrir os estados.
6. Abrir o app para validar a navegação (evidência — RI-04) e reportar.

## Guardrails

- Mockup antes do código.
- Sem regra de negócio no shell (isso é dos serviços).
- Não inventar componente/token/identidade (RO-01); usar o real do projeto.
- Não quebrar as regras frágeis do FXML (RO-09); sem cor fixa (RO-12).

## Saída esperada

- Janela principal navegável + `AlertaUtil` + controller-base, integrados a tema e logging.
- App abrindo como evidência.
- Base pronta para encaixar as telas de feature.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: barra de status com versão; atalhos de teclado globais; preferência de tema persistida).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06 e navegação) · `dev-senior` (controller-base sem duplicação).
- **Vem antes:** `java-project-bootstrap` (App/FXML inicial) · `javafx-theme-tokens` (tokens que o shell usa).
- **Vem depois:** `javafx-screen-fxml` e `javafx-dashboard` (telas que se encaixam no shell).
- **Não confundir com:** `javafx-screen-fxml` (tela de feature — aqui é a casca do app).
