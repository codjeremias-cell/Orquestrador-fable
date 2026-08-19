---
name: springboot-controller-thymeleaf
description: "Camada de apresentação de um CRUD Spring MVC, a última das três: cria o controller anotado como @Controller, que devolve nome de view e não JSON, e os templates Thymeleaf da entidade, consumindo o serviço já existente. Acione com \"cria a tela de cadastro de Curso\", \"preciso do formulário de Categoria\", \"monta o controller e o HTML dessa funcionalidade\", \"faz a página de listagem de X\", \"faz a tela\". NÃO acione fora disso — para a regra de negócio/serviço, use springboot-repository-service; para a entidade + migração, use springboot-entity."
---

# Spring Boot — Controller + Template Thymeleaf

**Camada no CRUD:** apresentação (view). É a 3ª e última camada — `springboot-entity` (dados) →
`springboot-repository-service` (regra de negócio) → **esta** (tela). O controller aqui só orquestra:
chama o serviço da camada de baixo e monta a view.

## Objetivo

Entregar uma tela Spring MVC + Thymeleaf consistente com o projeto: controller fino que só chama o
serviço e monta o `Model` com DTOs/records (RO-SB4), template acessível com CSRF automático e cor
só por `tokens.css` (RO-SB6), no padrão real validado no Gradup
(`InstructorCourseController`, `curso-form.html`).

## Princípio: espelhar o projeto-alvo (Gradup = a casa validada)

As convenções abaixo são o padrão real do Gradup — se o projeto-alvo é o Gradup ou segue a mesma
casa, siga-as: é acerto, não escolha. Se for um Spring Boot de **outra casa** (ex.: usa Lombok, outra
estrutura de pacotes, outra política de exceção), leia um artefato existente do projeto e espelhe o
padrão dele, declarando onde diverge do Gradup (RI-04). Separe sempre o que é **invariante**
(segurança/correção — não varia porque quebrá-lo introduz bug ou brecha) do que é **estilo da casa**
(varia — espelhe o que o projeto já usa).

- **Invariante (não varia):** `@Controller` e não `@RestController` nestas telas (a view precisa de
  HTML, não JSON); entidade JPA nunca no `Model` (só DTO/record — evita vazar lazy-loading e expor o
  domínio à camada web); acessibilidade (label+for, aria no erro, role=alert) e CSRF ligados.
- **Estilo da casa (espelhe):** nomes das classes utilitárias (`gu-*` × outro prefixo), estrutura de
  fragments, rota PT-BR × inglês — o Gradup usa `gu-*`/rotas PT-BR; leia o template real e copie o
  que o projeto usa em vez de impor o do Gradup.

## Entradas obrigatórias

1. Função da tela (listagem, formulário de criar/editar, detalhe) e a entidade/fluxo envolvido.
2. O **serviço** (`springboot-repository-service`) que a tela consome — nunca o repositório direto
   (a tela não conhece persistência; isso mantém a regra de negócio em um só lugar).
3. Campos do formulário/colunas a exibir e as ações disponíveis.

## Entradas opcionais

- Regras de habilitação condicional de campo (ex.: preço obrigatório só se um modo de acesso for
  pago) — viram `binding.rejectValue(...)` no controller.
- Se a tela entra em algum menu/navegação existente.

## Trava obrigatória

- Não codar sem o mockup aceito (RO-06) e sem o serviço alvo identificado.
- `Model` recebendo entidade JPA em vez de DTO/record → parar e corrigir (RO-SB4 — ver Convenções).

## Leituras obrigatórias (RO-01)

1. Um controller `@Controller` já existente do projeto para copiar o padrão de rota, `Model`,
   tratamento de formulário (`@Valid`/`BindingResult`) e redirect com feedback.
2. Um template Thymeleaf já existente (`templates/fragments/header.html`/`footer.html` e uma tela
   de formulário) para copiar a estrutura de fragments, classes utilitárias (`gu-*`) e tokens.
3. O serviço/record de leitura que a tela vai consumir (assinatura real).
4. `tokens.css` do projeto — para não inventar variável de cor/espaço.

## Convenções obrigatórias (Track Java Web/Spring Boot)

**Controller:**
- `@Controller` (não `@RestController` — estas telas retornam nome de view, não JSON).
- Injeção **por construtor** de um ou mais serviços; `Model` recebe só DTOs/records/enum/coleções
  deles, não a entidade `@Entity` (RO-SB4).
- `@RequestParam(required = false)`/`defaultValue`, `@PathVariable` para filtros e identificadores.
- Formulário: `@Valid @ModelAttribute("form") XxxForm form, BindingResult binding` — em erro,
  retorna a **mesma view do form** (redirecionar aqui perderia os erros e o que o usuário digitou);
  em sucesso, `redirect:` com query string de feedback (`?salvo=1`) para evitar reenvio no F5.
- `@ModelAttribute` de método (ex.: `categorias()`) para popular dado compartilhado do form
  (options de `<select>`) em toda requisição do controller.
- Regra de negócio **condicional de formulário** (não estrutural, essa é da entidade/serviço) via
  `binding.rejectValue(campo, codigo, mensagem)`.

**Template Thymeleaf:**
- `th:action` dinâmico conforme criar/editar; `method="post"`; `novalidate` (confia no Bean
  Validation do servidor em vez de duplicar a validação no client, que divergiria com o tempo).
- **CSRF automático:** com `thymeleaf-extras-springsecurity6` no `pom.xml` e CSRF ligado no
  `SecurityConfig`, o dialect injeta o token sozinho em formulários com `th:action`. Não adicione
  `_csrf` hidden à mão: seria redundante e desatualizaria se o dialect já cuida disso — confirme no
  `SecurityConfig` real antes de decidir.
- **Acessibilidade (RO-SB6):** todo campo com `<label class="gu-label" for="id">`; obrigatório com
  `aria-required="true"`; erro com `th:attr="aria-invalid=...,aria-describedby=..."` apontando para
  o `id` da mensagem; mensagem de erro em `<span role="alert" th:if="${#fields.hasErrors('campo')}"
  th:errors="*{campo}">`; grupo de opções usa `role="radiogroup" aria-labelledby="..."`. Isto é
  invariante porque leitor de tela e teclado dependem disso — não é enfeite.
- **Cor só por token:** use `var(--color-*)`, `var(--sp-*)`, `var(--fs-*)`, `var(--radius-*)`,
  `var(--shadow-*)` em vez de hex solto, para que trocar o tema num só arquivo (`tokens.css`) valha
  para a tela toda; `tokens.css` + `app.css` linkados no `<head>`.
- **Fragments:** `<header th:replace="~{fragments/header :: siteHeader}">` /
  `<footer th:replace="~{fragments/footer :: siteFooter}">` — layout composto, não duplicado.
- Classes utilitárias do projeto (ex.: `gu-app`, `gu-card`, `gu-input`, `gu-btn-primary`) — reutilize
  as existentes em vez de inventar um novo sistema de classes.

## Fluxo

1. Apresentar o mockup e obter aceite (RO-06).
2. Ler controller/template de referência, o serviço alvo e `tokens.css` (RO-01).
3. Escrever o controller: rotas, `@ModelAttribute` compartilhado, tratamento de formulário.
4. Escrever o template: formulário/listagem com a11y completa, tokens, fragments.
5. Escrever teste de renderização no padrão do projeto: `@WebMvcTest(Controller.class)` +
   mock dos serviços + `@Import(SecurityConfig.class)`, asserção em `view().name(...)` e
   conteúdo — roda **sem banco** porque só a camada web sobe, sem `DataSource` (RO-SB8).
   **A anotação de mock espelha a versão real do projeto (RO-10), não a minha preferência:**
   `@MockitoBean` (`org.springframework.test.context.bean.override.mockito`) a partir do Spring
   Boot 3.4, onde `@MockBean` está depreciado; `@MockBean` (`org.springframework.boot.test.mock.mockito`)
   nos projetos anteriores. **Confira no `pom.xml`/`build.gradle` antes de escrever** — RO-01: não
   se decide versão de API de memória. Se o projeto já tem teste de `@WebMvcTest`, copie a forma dele.
6. Rodar o teste de renderização e a **varredura de hex fora de `tokens.css`**:
   `grep -rEn '#[0-9a-fA-F]{3,8}\b' --include='*.html' --include='*.css' . | grep -v 'tokens\.css'`
   — esperado **0 ocorrências** (todo hex de cor vive só em `tokens.css`).
7. Reportar arquivos, rotas afetadas e suposições.

## Regras de implementação

- Controller não tem SQL nem regra de negócio estrutural — delega tudo ao serviço.

## Guardrails

- Não use `@RestController` nestas telas nem passe entidade JPA para o `Model` — o motivo está nos
  invariantes acima (HTML × JSON; não vazar o domínio/lazy-loading para a view).
- Não deixe hex fora de `tokens.css`, campo sem `label`, nem erro sem `role="alert"` — cada um quebra
  respectivamente o tema centralizado, o rótulo acessível e o anúncio do erro por leitor de tela.
- Não invente classe utilitária, token ou id de fragment (RO-01) — use o real do projeto, senão a
  tela referencia algo que não existe.

## Saída esperada

- Controller `@Controller` + template(s) Thymeleaf no padrão do projeto.
- Teste de renderização (`@WebMvcTest`) executado, sem hex fora de `tokens.css`.
- Mockup aprovado registrado e nota com suposições.

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: htmx para atualização parcial sem reload; extrair um fragment de
formulário se o padrão se repetir em outra tela; paginação na listagem).

**Gabarito Gradup (few-shot de código real):** projeto-alvo sendo o **Gradup ou família Spring Boot**, carregue `referencia-exemplos-reais-gradup.md` — CatalogController verbatim + convenções reais (controller em `com.portal.<modulo>.web`, form/views de tela junto; `@Controller` sempre; injeção por construtor de todos os services — cruza módulos por service, nunca repo alheio; rotas PT-BR `/cursos/{slug}`; templates por área `catalog/`,`admin/`,`fragments/`; `@RequestParam(required=false)` com parse tolerante = no-op no inválido; decisões dimensionadas comentadas `PAGE_SIZE`). Complementa (não substitui) as regras de acessibilidade/CSRF do corpo. O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Verificação de fechamento (RI-04)

Sem evidência, não está pronto. Esta skill entrega **controller + template** — pergunte-se e comprove:

1. **O contexto web sobe?** O código compila e o teste `@WebMvcTest` carrega o controller + o
   `SecurityConfig` importado sem estourar (falha aqui costuma ser bean faltando ou rota duplicada).
2. **O endpoint responde?** No teste, o `MockMvc` retorna 200 ao abrir o form/listagem e um 3xx de
   `redirect:` no submit válido; a asserção bate em `view().name(...)` e no conteúdo esperado. Este
   teste roda **sem banco** (RO-SB8 — só a camada web, sem `DataSource`), então é sempre executável e
   não depende de `DB_URL`.
3. **O invariante token-only vale?** A varredura de cor
   `grep -rEn '#[0-9a-fA-F]{3,8}\b' --include='*.html' --include='*.css' . | grep -v 'tokens\.css'`
   dá **0 ocorrências** — a prova-assinatura de que todo hex de cor vive só em `tokens.css`.

Nada aqui usa `DB_URL`; se por algum motivo um passo não puder rodar, registre um **SKIP com o
motivo** em vez de dar "passou" fingido.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06, a11y) · `qa-usabilidade` (caminho triste do formulário) · `especialista-seguranca` (CSRF, autorização por rota).
- **Vem antes:** `springboot-repository-service` (o serviço que a tela consome).
- **Vem depois:** o testador do projeto (bateria HTTP real) · `docs-projeto` (se a tela mudar o manual).
- **Não confundir com:** `javafx-screen-fxml` (mesmo papel, mas no track desktop JavaFX).

### 📜 Histórico
- **2026-08-18 — A anotação de mock deixa de ser chumbada (T37; inventário `_auditoria/zelador-inventario-2026-08-10.md`, ação ATUALIZAR 7; degrau §6.10: 1 — só edição).** O passo 5 do Fluxo prescrevia `@MockBean` **fixo**, e `@MockBean` está depreciado desde o Spring Boot 3.4 em favor de `@MockitoBean` (`org.springframework.test.context.bean.override.mockito`). Era a **última das 15 ações ATUALIZAR do inventário ainda aberta** — as outras 14 foram conferidas no mesmo ato e estavam fechadas. Em vez de trocar um chumbo por outro, o texto passou a **espelhar o projeto (RO-10)**: `@MockitoBean` a partir do 3.4, `@MockBean` antes, com a ordem explícita de conferir no `pom.xml`/`build.gradle` e de copiar a forma do teste que já existe — porque decidir versão de API de memória é o que a RO-01 proíbe, e a própria auditoria tinha listado esta ação entre as que exigiam **confirmação externa antes de aplicar**. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-09 — `description` comprimida (campanha das 61; degrau §6.10: 1).** Registro retroativo: a compressão foi aplicada e **não foi anotada aqui na época**, contra o §6 princípio 9 do [[PADRAO-DE-AUTORIA]], que exige o patch na fonte **com** registro. Achado do inventário de 2026-08-10, padrão transversal 5. Frases-gatilho e fronteira preservadas.
- **2026-07-20 — Polimento de disparo e verificação:** descrição reescrita para nomear a **camada** (apresentação/view, 3ª de 3) e a **fronteira** com as skills irmãs logo no gatilho; caixa alta rígida (`NÃO acione`, `SEM banco`) reduzida e cada invariante passou a trazer o **porquê** em vez de só a proibição; seção de fechamento reorganizada em 3 perguntas concretas (sobe o contexto web? o endpoint responde? token-only?). Sem mudança de código, rota ou convenção.
- **2026-07-18 — Evolução ao 9,5 (núcleo Gradup):** princípio **espelhar-o-projeto** explicitado (Gradup = casa validada; Spring de outra casa → leia e espelhe, RI-04) + separação **invariante × estilo-da-casa** + seção de fechamento RI-04 consolidada + **eval executável** (`evals/evals.json`, 2 casos: Gradup × outra casa Spring — prova o espelho). Mesma receita que levou o núcleo SIGO ao 9,5. **Auto-verificada** contra os defeitos convergentes do painel SIGO (sem seção "Tensão" velha; teste de fechamento condicional com SKIP declarado; corpo↔referência coerentes — a "Nota de fronteira" da referência reforça o corpo, não o contradiz). **Painel de 3 juízes adiado por limite de budget semanal**; promovida por ser estritamente melhor que a versão live (teto honesto ~9,2), sem regressão.
- **2026-07-18 — Few-shot de código real (onda Gradup/Spring Boot):** criada `referencia-exemplos-reais-gradup.md` (fonte: `catalog/web/CatalogController.java`+`templates/catalog/`). Baseline §11: geração sem gabarito acertou @Controller/CSRF/aria mas divergiu no pacote `web` do módulo, rotas PT-BR, parse tolerante de query param e organização de templates por área. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens A1-A4; −8 linhas.
