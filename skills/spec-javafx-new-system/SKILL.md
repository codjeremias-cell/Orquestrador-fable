---
name: spec-javafx-new-system
description: Orquestra a criação de um sistema Java/JavaFX completo do zero — do projeto Maven vazio até o app rodando e empacotado — encadeando bootstrap, fundação de banco, logging, tema, shell, a primeira feature CRUD e o empacotamento. Acione quando o usuário disser coisas como "constrói um sistema novo do zero", "cria o app desktop inteiro do começo ao fim", "quero um sistema JavaFX novo pronto pra rodar", "monta tudo: projeto, banco, telas e instalador". NÃO acione para evoluir um projeto que já existe (use as skills específicas ou o spec-javafx-crud-feature).
---

# Spec — Sistema JavaFX do Zero (orquestrador-topo)

Esta skill é a **orquestradora de topo**. Leva uma pasta vazia até um app desktop JavaFX rodando e empacotado, delegando para as skills do track Java e validando cada etapa. Não duplica o trabalho detalhado delas.

## Objetivo

Entregar um sistema novo de ponta a ponta — projeto + fundação de banco + logging + tema + shell + primeira feature + empacotamento — aderente às [[REGRAS-DE-OURO]] do track Java/JavaFX.

## Entradas obrigatórias

1. Nome do app e pacote raiz/coordenadas Maven.
2. Banco alvo (padrão: Access/UCanAccess).
3. A primeira entidade/feature (nome + atributos + tabela/colunas) para já nascer com algo útil.

## Entradas opcionais

- Itens de navegação, tema inicial, ícone/fornecedor, regras de negócio da primeira feature.

## Validação do catálogo

Confirmar que existem as skills filhas (ajuste o caminho real de instalação); se faltar uma crítica, **parar** e dizer qual e para qual papel:

- `java-project-bootstrap`
- `java-db-foundation`
- `java-logging-log4j2`
- `javafx-theme-tokens`
- `javafx-app-shell`
- `spec-javafx-crud-feature`
- `java-package-desktop`

## Sequência determinística

Executar em ordem; validar cada etapa (compila? abre? teste passa?) antes de seguir.

1. **Visão e mockup (RO-06).** Alinhar as telas principais e apresentar o mockup do app; obter aceite.
2. **Esqueleto.** `java-project-bootstrap` — projeto Maven JavaFX que compila e gera fat-jar.
3. **Banco.** `java-db-foundation` — provedor de conexão + `RetryDB` + `config.properties` (segredos fora do git).
4. **Logging.** `java-logging-log4j2` — `log4j2.xml` e padrão de logger.
5. **Tema.** `javafx-theme-tokens` — base clara + escura por tokens.
6. **Shell.** `javafx-app-shell` — janela principal, navegação, `AlertaUtil`, controller-base.
7. **Primeira feature.** `spec-javafx-crud-feature` — entidade → DAO → serviço → tela, plugada no shell. Se a primeira feature for um painel de indicadores, quem conduz a tela é a `javafx-dashboard`.
8. **Empacotamento.** `java-package-desktop` — `.exe`/`.msi` que roda sem Java.
9. **Fechamento com prova.** Build + smoke do app; bateria do `testador-real` (ou testador do projeto) quando aplicável; veredito da lente `auditor-responsabilidades`.

## Regras de coerência

- Nomes consistentes entre projeto, pacote, entidade, DAO, serviço, controller, FXML e artefato final.
- Reaproveitar o que cada etapa criou (a feature lê a fundação de banco e o shell reais — RO-01).
- Operação multi-passo = transação atômica; UI nunca congela (RO-J1); segredos fora do git.

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Entradas ambíguas (pacote, banco, primeira feature).
- Mockup não aprovado.
- Falha em build/smoke obrigatório em qualquer etapa.

## Formato do relatório final (RI-05)

Resumo objetivo: skills usadas · arquivos/artefatos criados (com caminho exato — RO-03) · builds e smokes executados · o que foi validado · pendências/limitações · **2–3 sugestões de evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito de prontidão.

## Saída esperada

- Sistema JavaFX novo, do projeto vazio ao `.exe`/`.msi`, com banco, logging, tema, shell e a primeira feature funcionando — aderente às Regras de Ouro do track.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas as do comitê ao longo das etapas; `auditor-responsabilidades` fecha com o veredito.
- **Vem antes:** `requisitos-descoberta` (escopo e primeira feature definidos) ou `spec-projeto-completo` (que delega para cá quando a plataforma é desktop JavaFX).
- **Vem depois:** `testador-real` (bateria completa) · `docs-projeto` (README + manual acompanham a entrega).
- **Não confundir com:** `spec-projeto-completo` (universal, qualquer plataforma — este é o track JavaFX) · `spec-javafx-crud-feature` (uma feature num projeto existente).
