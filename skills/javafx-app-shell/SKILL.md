---
name: javafx-app-shell
description: "Cria o shell de uma aplicação JavaFX: a janela principal, a navegação que troca a tela central e a classe central de alertas em PT-BR, seguindo o padrão real do projeto. Aqui é a CASCA do app: tela de feature é javafx-screen-fxml, painel de KPIs é javafx-dashboard, tema por tokens é javafx-theme-tokens. Acione com \"AlertaUtil\", \"cria a janela principal do app\", \"monta a navegação entre telas\", \"preciso do menu e da estrutura base da interface\", \"cria o AlertaUtil e o controller base\", \"monta o esqueleto/a casca da UI\"."
---

# JavaFX — Shell da Aplicação

## Objetivo

Criar a casca da interface: a janela principal, o mecanismo de navegação que troca a tela central, e os utilitários compartilhados — a classe central de alertas (**"AlertaUtil"** é o nome genérico desta skill; o nome real varia por projeto, ver abaixo) e o controller-base — que matam duplicação e padronizam o comportamento. É onde as telas geradas por `javafx-screen-fxml` e os painéis de `javafx-dashboard` se conectam.

## Fronteira com as skills-irmãs (não confundir)

- **Aqui (`javafx-app-shell`):** a **casca** do app — janela principal, navegação, alertas centrais, controller-base.
- **`javafx-screen-fxml`:** uma **tela de feature** (CRUD/formulário/listagem) que encaixa no shell.
- **`javafx-dashboard`:** um **painel de KPIs/decisão** que encaixa no shell.
- **`javafx-theme-tokens`:** o **tema por tokens de cor** que o shell CONSOME — ele nunca define token nem cor aqui.

## Regra de partida (RO-06): mockup antes de codar

Apresente o mockup da janela principal e da navegação e obtenha o aceite do Jeremias (que decide no visual) antes de gerar FXML/código. Dado de entrada faltando (nome do app, itens de navegação) **não** justifica bloquear a entrega até ter tudo: declare **SUPOSIÇÃO:** (RO-01) com um valor plausível, monte o mockup provisório em cima dela e siga. O aceite serve tanto para confirmar quanto para corrigir a suposição — "declare e proponha" vence "bloqueie até ter todos os dados". A trava real é pular direto para FXML/código sem passar pelo mockup, não exigir todos os dados antes de desenhar algo.

## Entradas

**Obrigatórias:** (1) nome do app e título da janela; (2) itens de navegação iniciais (ex.: menu/abas: Clientes, Relatórios…). Faltando em greenfield, aplique a regra de partida acima (SUPOSIÇÃO + mockup provisório).

**Opcionais:** tema inicial (claro/escuro); identidade visual (versão + autor visíveis na UI — lição cross-projeto).

## Leituras obrigatórias (RO-01)

- A classe `App` e o FXML inicial criados pelo `java-project-bootstrap`.
- Um shell/classe-de-alerta/controller-base já existente em projeto-irmão validado, se houver — é dali que vem o **nome real**, não do genérico desta skill.
- O CSS de tema (para o shell consumir tokens, não cor fixa).

## Os invariantes inegociáveis (valem em qualquer projeto)

Estes não variam — são correção e consistência, não estilo. O porquê de cada um está no próprio bullet:

- **Um único ponto de alerta.** Toda mensagem ao usuário (info/erro/confirmação) passa por uma classe central; nenhuma tela monta `Alert` na mão — do contrário a mesma mensagem diverge de tela para tela e vira dívida. **O nome dessa classe varia por projeto** (abaixo); a centralização não.
- **Navegação sem regra de negócio.** O shell só troca a tela ativa; regra de negócio vive nos serviços (`java-service-usecase`). Misturar as duas amarra a navegação a domínio e impede reuso.
- **RO-09 — FXML frágil.** `VBox.vgrow`/`HBox.hgrow` numa linha só (quebrar a linha corrompe o parser); marcadores `★★★ INÍCIO/FIM V.X.Y ★★★` ao redor de blocos editados; comentário sem `>` extra (fecha a tag antes da hora).
- **RO-08 — Log4j 2.** Erro de boot ou de navegação vai para o log com `Throwable` como último argumento — nunca `printStackTrace`/`System.out`/`System.err`, que somem em produção.
- **RO-J1 — carregamento sem congelar.** Navegação que busca dados usa `Task` (thread daemon) e só atualiza a UI no `onSucceeded`; cursor de espera/placeholder "Carregando…" enquanto isso. Acesso a banco na thread da UI congela a janela.
- **Estados cobertos.** Vazio, carregando e erro tratados na navegação/telas iniciais. É distinto do RO-J1 (que só cobre "não congelar"): o placeholder de vazio e a mensagem de erro são responsabilidade própria, não decorrência automática do `Task`.
- **Tokens de tema, nunca cor fixa (RO-12).** O shell CONSOME os tokens que `javafx-theme-tokens` já declara em `.root` — nunca hex solto, nunca redefine a variável aqui. Se a variável não está declarada em `.root`, a regra é ignorada em silêncio (falha sutil, sem erro visível). **Nomeie explicitamente, na saída, quais tokens de tema o shell consome** — omitir essa menção é falha de cobertura tanto quanto usar hex fixo.
- **Identidade visível.** Versão + crédito do autor aparecem na UI (lição cross-projeto).

## O que VARIA por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto. Leia o shell existente e copie a forma real; não force o genérico desta skill sobre um projeto que já batizou o seu:

- **Nome e forma da classe de alerta.** "AlertaUtil" é só o rótulo genérico (e o que a `description` nomeia na ausência de projeto-irmão). No SIGO é `Dialogos` (classe `final`, construtor privado, pacote `ui`: `alerta(tipo, titulo, msg)`, atalhos `erro`/`info`, `confirmar(titulo, msg)` → boolean, `placeholderVazio(msg)`). Copie o nome e a assinatura reais.
- **Controller-base: existe? com o quê?** Crie só se resolve duplicação **observada** nas telas (acesso ao shell, atalhos de UI). Sem duplicação real, não é obrigatório.
- **Onde vive a aplicação do tema.** No SIGO, `Tema.aplicarTemaGlobal()` roda no boot (`App.start()`, antes de qualquer FXML) e `Tema.cena(raiz)` empacota a `Scene` — o shell CONSOME essa API, não a define (escopo de `javafx-theme-tokens`). Se há alternância claro/escuro em runtime, o botão de troca costuma viver no shell, mas a lógica de troca vive no módulo de tema; confirme essa fronteira antes de misturar as pontas.
- **Mecanismo de navegação.** Trocar o `root` da `Scene`, um `StackPane` empilhado, ou um `BorderPane` com `setCenter(...)` — o projeto real dita a forma; não invente um mecanismo novo se um já existe.
- **Ordem de boot.** Fontes → tema → backup/infra → banco → seed → tela inicial é a ordem do `App.start()` do SIGO; outro projeto pode ter passos a mais/menos — leia o `App` real antes de assumir a sequência.

**Gabarito SIGO (few-shot de código real):** projeto-alvo **SIGO/família** → carregue `referencia-exemplos-reais-sigo.md` (`App.java` + `Dialogos.java` + `Carregar.java` verbatim). Confirma: `App.start()` com a ordem fixa de boot (erro em qualquer passo → `mostrarErroFatal`, Alert amigável + `Log.erro`, sem stack trace pro usuário); `Dialogos` é a classe de alerta real (não "AlertaUtil"); `Carregar.emPainel`/`emTabela`/`async` é a carga assíncrona real (thread daemon `"carregar-ui"`, placeholder "Carregando...", erro → `placeholderVazio` + `Log.erro`) — substituto obrigatório de `dao.listar()` direto no `initialize`. O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Fluxo

1. Mockup da janela e navegação → aceite (RO-06).
2. Ler `App`/FXML inicial e o shell/classe-de-alerta/controller-base de um projeto-irmão, se houver — extrair nome real da classe de alerta, existência de controller-base, mecanismo de navegação, ordem de boot e a fronteira com o tema.
3. Criar a janela principal + navegação central, na forma detectada (ou a mais simples em greenfield, com **SUPOSIÇÃO:** declarada — cobrindo nome do app e itens de navegação quando ainda não informados).
4. Criar a classe central de alerta (nome real do projeto) e o controller-base **só se** há duplicação real a resolver.
5. Ligar aos tokens de tema (consumir, não redefinir) e ao logging; cobrir vazio/carregando/erro.
6. Rodar a verificação de fechamento (abaixo) e reportar.

## Guardrails

- Mockup antes do código (RO-06); sem regra de negócio no shell (é dos serviços).
- Não inventar componente/token/identidade/nome de classe (RO-01) — usar o real do projeto ou declarar **SUPOSIÇÃO:**.
- Não quebrar RO-09 (FXML frágil); sem cor fixa (RO-12) nem redefinição de tema (escopo de `javafx-theme-tokens`).
- Não impor "AlertaUtil" se o projeto já tem a classe com outro nome — renomear o que já existe é erro, não zelo.

## Saída esperada

- Janela principal navegável + classe central de alerta (nome real) + controller-base (se resolve duplicação real), integrados a tema (consumido) e logging.
- Nota com: o nome real da classe de alerta, se há controller-base e por quê, **quais tokens de tema o shell consome**, e suposições declaradas (RO-01).
- Base pronta para encaixar as telas de feature.

## Verificação de fechamento (RI-04)

Antes de declarar pronto, responda com evidência:

1. **Compila?** O shell compila contra o projeto (`javac` + dependências reais).
2. **O app abre de fato?** Quando há ambiente gráfico na sessão, o `Stage` aparece e a navegação entre os itens iniciais é exercitada **sem exceção** (nenhuma `LoadException`/`NullPointerException` de FXML no boot). Evidência: print de tela, ou log confirmando o `Stage` exibido e a troca da tela central.
3. **Tema consumido?** A saída nomeia quais tokens de `.root` o shell usa (não hex fixo).

Sem display/ambiente gráfico executável na sessão, o item 2 vira **SKIP declarado** com o motivo — nunca "abriu" fingido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: barra de status com versão; atalhos de teclado globais; preferência de tema persistida).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06 e navegação) · `dev-senior` (controller-base sem duplicação).
- **Vem antes:** `java-project-bootstrap` (App/FXML inicial) · `javafx-theme-tokens` (tokens que o shell usa).
- **Vem depois:** `javafx-screen-fxml` e `javafx-dashboard` (telas que se encaixam no shell).
- **Não confundir com:** `javafx-screen-fxml` (tela de feature — aqui é a casca do app).

### 📜 Histórico
O changelog detalhado de evolução desta skill está em [referencia/historico.md](referencia/historico.md) (movido para fora do corpo para reduzir custo de token em cada turno — progressive disclosure).
