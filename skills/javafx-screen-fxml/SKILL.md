---
name: javafx-screen-fxml
description: "Cria ou evolui uma tela de feature JavaFX (FXML + controller) que consome um serviço ou DAO do projeto — cadastro, listagem, detalhe, formulário — com mockup visual antes do código, estados vazio/carregando/erro/sucesso e acesso a banco assíncrono via Task para não congelar a UI. Acione com \"cria a tela de cadastro de cliente\", \"preciso da janela de listagem de funcionários\", \"monta o FXML e o controller dessa funcionalidade\", \"faz a interface dessa operação\". Fronteira entre as skills-irmãs: aqui é UMA tela de feature; para a casca do app (janela, navegação, alertas) use javafx-app-shell; para um painel de KPIs/decisão use javafx-dashboard; para o tema por tokens de cor use javafx-theme-tokens. NÃO acione para regra de negócio (use java-service-usecase) nem persistência (use java-jdbc-dao)."
---

# JavaFX — Tela (FXML + Controller)

## Objetivo

Entregar uma tela de feature JavaFX consistente com o projeto: FXML para a estrutura, controller fino que chama o serviço, com todos os estados cobertos e acesso a banco fora da thread da UI. A tela não tem regra de negócio nem SQL — ela orquestra a interação e delega.

## Fronteira com as skills-irmãs (não confundir)

- **Aqui (`javafx-screen-fxml`):** **uma tela de feature** (cadastro/listagem/detalhe/formulário) e seu controller.
- **`javafx-app-shell`:** a **casca** onde esta tela encaixa — janela, navegação, alertas centrais.
- **`javafx-dashboard`:** um **painel de KPIs/decisão** (não CRUD) — instrumento de decisão, não operação.
- **`javafx-theme-tokens`:** o **tema por tokens** cujas cores esta tela consome (nunca hex fixo).
- **Fora do escopo da UI:** regra de negócio → `java-service-usecase`; SQL/persistência → `java-jdbc-dao`.

## Regra de partida (RO-06): mockup antes de codar

Antes de gerar FXML/controller, apresente um **mockup visual** da tela (imagem/HTML renderizado ou wireframe claro) e obtenha o aceite do Jeremias, que decide no visual. Só code a tela depois do "ok" — é barato iterar no mockup, caro iterar no FXML.

Dado de entrada faltando (campos a exibir, rótulos, ações disponíveis) **não** justifica bloquear a entrega até ter tudo: declare **SUPOSIÇÃO:** (RO-01) com um valor plausível, monte o mockup provisório em cima dela e siga. O aceite serve tanto para confirmar quanto para corrigir a suposição — "declare e proponha" vence "bloqueie até ter todos os dados". A trava real é pular direto para FXML/controller sem passar pelo mockup, não exigir todos os dados antes de desenhar algo. O que **não** se supõe é assinatura de serviço/DAO: essa continua exigida antes do **código** (RO-01), não antes do mockup.

## Entradas

**Obrigatórias:** (1) função da tela (cadastro, listagem, detalhe) e a entidade/fluxo; (2) o serviço/caso de uso ou DAO que a tela consome; (3) campos/colunas a exibir e ações disponíveis.

**Opcionais:** se entra num menu/navegação existente; regras de habilitação de botões; validação de formulário na UI.

**Trava:** não **escrever FXML/controller** sem o mockup aceito (RO-06) e sem o serviço/DAO alvo identificado — a trava é sobre o código, não sobre produzir algo: o mockup sai mesmo com dado faltando, com a SUPOSIÇÃO declarada (ver Regra de partida). Se a navegação ou o controller-base do projeto forem ambíguos, pergunte.

## Leituras obrigatórias (RO-01)

1. Um FXML + controller já existentes, para copiar o padrão (carregamento, injeção `@FXML`, navegação).
2. O controller-base/utilitário de alerta do projeto, se existir (ex.: `AlertaUtil`, `Dialogos`, classe base de controller).
3. O serviço/DAO que a tela vai chamar (assinaturas reais).
4. Os arquivos de tema/CSS do projeto (para usar tokens, não cor fixa).

## Os invariantes inegociáveis (valem em qualquer projeto)

O porquê está em cada bullet — são correção, não estilo:

- **UI não pode travar perceptivelmente durante I/O de banco** — é o que a RO-J1 protege (o MECANISMO que garante isso varia, abaixo). Banco na thread da UI congela a janela e parece "travado".
- **RO-09 — FXML frágil:** `VBox.vgrow`/`HBox.hgrow` em **UMA linha** (quebrar corrompe o parser); comentário com `>` extra fecha a tag antes da hora; marque blocos editados com `★★★ INÍCIO/FIM V.X.Y ★★★`.
- **Estados sempre cobertos:** vazio (com `setPlaceholder(...)` em PT-BR — o default é "No content in table", em inglês), carregando, erro (mensagem amigável — o usuário nunca vê stack trace) e sucesso.
- **RO-12 — Cor só por token de tema** declarado no `.root`; hex fixo quebra no dark (a cor não acompanha a troca de tema).
- **RO-08 — Log4j 2** para erros; sem `System.out`, que some em produção.
- **Controller fino:** sem regra de negócio nem SQL — ele orquestra a interação e delega. Regra no controller não se testa nem se reusa.
- Sem emoji em código (RO-05); textos de UI em PT-BR.

## O que VARIA por projeto — espelhe, não prescreva

O ponto onde a prescrição genérica mais erra: **o mecanismo que impede a UI de travar.** RO-J1 prescreve `Task` (thread daemon) + atualização no `onSucceeded`/`onFailed` como a forma padrão do track — é o que se segue quando não há exemplo do projeto para copiar, e o que se usa em cargas/listagens mais pesadas (é o padrão que a `javafx-dashboard` segue à risca).

**Mas o próprio gabarito real do SIGO diverge disto para escrita de formulário:** `ComunicadoFormController.aoSalvar` chama `dao.inserir(c)`/`dao.atualizar(c)` **de forma síncrona, sem `Task`** — é a gravação de um único registro sobre conexão local, rápida o bastante para não travar perceptivelmente. Leia como o PROJETO trata a escrita de formulário simples: forms existentes chamam o DAO direto e síncrono (como o SIGO) → espelhe essa forma para escrita equivalente; o projeto usa `Task` mesmo em forms simples, ou a operação é uma listagem/consulta mais pesada → RO-J1 literal (`Task`+daemon).

**Gabarito SIGO (few-shot de código real):** projeto-alvo sendo o **SIGO/SIGCOT ou família** → carregue `referencia-exemplos-reais-sigo.md` — comunicado_form (FXML+controller) verbatim + 8 convenções reais (FXML em `view/<nome_snake>.fxml`; controller em `br.com.cot.ui`; handlers `ao...`; campos descritivos PT-BR sem húngaro — `data`, `campoTitulo`; validação no controller com `labelErro` inline; botão "Salvando..."; `configurar(entidade)` + `isSalvou()`; form simples fala com DAO direto, de forma síncrona). O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Fluxo

1. Apresentar o mockup e obter aceite (RO-06) — dado faltando vira **SUPOSIÇÃO:** declarada e mockup provisório, não bloqueio.
2. Ler FXML/controller existentes, controller-base, serviço/DAO e CSS de tema.
3. Escrever o FXML (estrutura + ids), respeitando as regras frágeis (RO-09).
4. Escrever o controller fino: injetar `@FXML`, ligar ações ao serviço, cobrir os estados.
5. Resolver o mecanismo anti-travamento **na forma detectada** (`Task`+daemon; ou síncrono para escrita simples de formulário, como o SIGO) com feedback de carga e tratamento de erro.
6. Aplicar tokens de tema; conferir contraste/teclado (a11y, casa com a lente Designer/QA).
7. Rodar a verificação de fechamento (RI-04, abaixo).
8. Reportar arquivos criados, navegação afetada e suposições.

## Guardrails

- Não inventar id de componente, método de serviço/DAO ou token de tema (RO-01).
- Não impor `Task` onde o padrão real do projeto (ex.: SIGO) resolve síncrono para escrita simples de formulário — nem o oposto: sem exemplo do projeto para copiar, ou em carga/listagem mais pesada, `Task` é o padrão seguro, não abra mão dele por economia.

## Saída esperada

- `Tela.fxml` + `TelaController.java` no padrão do projeto.
- Estados vazio/carregando/erro/sucesso cobertos; mecanismo anti-travamento na forma do projeto; tokens de tema.
- Mockup aprovado registrado e nota com suposições.

## Verificação de fechamento (RI-04)

Antes de declarar pronto, responda com evidência:

1. **Compila?** O controller compila contra o projeto (`javac` + dependências reais) — nomear o comando é o que separa "compila" verificável de "compila" declarado.
2. **Binding FXML↔controller confere?** Todo `fx:id` referenciado tem campo `@FXML` do tipo certo; todo `onAction`/handler existe; `fx:controller` aponta para a classe certa. Isso se faz **sem abrir a tela** — é o mesmo padrão que a `javafx-dashboard` já pratica no track.
3. **A tela renderiza sem exceção de FXML?** Quando há projeto rodável na sessão, carregue a tela (`FXMLLoader.load(...)`) e confirme que ela sobe **sem `LoadException`** (nenhum `fx:id`/handler/tipo divergente do FXML) e exercite os estados vazio/carregando/erro/sucesso via `testador-real`.

O que não dá para executar (sem projeto acessível na sessão) vira **SKIP declarado** com o motivo, nunca "passou" fingido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair `AlertaUtil`/controller-base se ainda não existir; componente reutilizável de tabela com estados; atalhos de teclado).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06, estados, a11y) · `qa-usabilidade` (caminho triste e estados) · `dev-senior` (controller fino).
- **Vem antes:** `java-service-usecase` (o que a tela consome) · `javafx-app-shell` (onde se encaixa) · `javafx-theme-tokens` (tokens).
- **Vem depois:** `java-logging-log4j2` (erros logados) · `testador-real` (prova o fluxo de ponta a ponta).
- **Não confundir com:** `javafx-dashboard` (painel de KPIs/decisão — aqui é tela de operação/CRUD).

### 📜 Histórico
- **2026-08-18 — "Compila?" passa a nomear o ato (T29, item P2 do backlog da auditoria de notas; degrau §6.10: 1 — só edição).** A auditoria de 2026-07-13 acusava esta skill como o **pior caso** dos ~6 de evidência frouxa (nota 7,9: *"entrega tela sem compilar nada"*). Remedido em 2026-08-18: o bloco de evidência **já existia** — as ondas de 18–19/07 o trouxeram —, mas o item 1 dizia só *"O controller compila contra o projeto"*, enquanto a `javafx-dashboard` e a `javafx-app-shell` do mesmo track dizem **`javac` + dependências reais**. Nomear o comando é o que separa "compila" verificável de "compila" declarado, que é a distância entre RI-04 cumprida e RI-04 alegada. Os outros 6 casos frouxos da auditoria foram remedidos no mesmo ato e **todos já fechavam**, cada um pela régua do seu tipo — `java-jdbc-dao` com `mvn compile` e round-trip, `java-package-desktop` executando o `.exe`, `web-data-layer` com `tsc --noEmit`, e `arquiteto-dados`, que é lente e não compila nada, por campos declarados. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-11 — Calibração "declare SUPOSIÇÃO e siga" importada de `javafx-app-shell` (inventário do catálogo, `_auditoria/zelador-inventario-2026-08-10.md`, grupo "regra que precisa migrar"):** a irmã do mesmo track recebeu essa calibração em 2026-07-19 e esta ficou sem — a Regra de partida (RO-06), a Trava e o passo 1 do Fluxo mandavam bloquear até ter tudo. Agora: dado de entrada faltando declara SUPOSIÇÃO e vira mockup provisório; a Trava proíbe **escrever FXML/controller** antes do aceite, não produzir nada. **RO-01 preservado onde importa** — assinatura de serviço/DAO continua exigida antes do código, e essa exceção é acréscimo desta casa sobre o texto da irmã. `description` intocada.

O changelog detalhado de evolução desta skill está em [referencia/historico.md](referencia/historico.md) (movido para fora do corpo para reduzir custo de token em cada turno — progressive disclosure).
