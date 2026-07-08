---
name: springboot-controller-thymeleaf
description: Cria a tela de uma funcionalidade no track Java Web/Spring Boot (Gradup e afins) — controller @Controller (nunca @RestController) consumindo um serviço real, e o template Thymeleaf com formulário acessível (label+for, aria-required, aria-invalid+aria-describedby, role=alert no erro), CSRF automático via thymeleaf-extras-springsecurity6 e cor só por tokens.css. Acione quando o usuário disser coisas como "cria a tela de cadastro de Curso", "preciso do formulário de Categoria", "monta o controller e o HTML dessa funcionalidade", em projeto Spring Boot + Thymeleaf. NÃO acione para regra de negócio (use springboot-repository-service) nem para a entidade (use springboot-entity).
---

# Spring Boot — Controller + Template Thymeleaf

## Objetivo

Entregar uma tela Spring MVC + Thymeleaf consistente com o projeto: controller fino que só chama o
serviço e monta o `Model` com DTOs/records (nunca a entidade JPA — RO-SB4), template acessível com
CSRF automático e cor só por `tokens.css` (RO-SB6), no padrão real validado no Gradup
(`InstructorCourseController`, `curso-form.html`).

## Regra de partida: mockup antes de codar (RO-06)

Apresentar um mockup/wireframe da tela e obter o aceite do Jeremias antes de escrever
controller/template — mesma regra do track JavaFX.

## Entradas obrigatórias

1. Função da tela (listagem, formulário de criar/editar, detalhe) e a entidade/fluxo envolvido.
2. O **serviço** (`springboot-repository-service`) que a tela consome — nunca o repositório direto.
3. Campos do formulário/colunas a exibir e as ações disponíveis.

## Entradas opcionais

- Regras de habilitação condicional de campo (ex.: preço obrigatório só se um modo de acesso for
  pago) — viram `binding.rejectValue(...)` no controller.
- Se a tela entra em algum menu/navegação existente.

## Trava obrigatória

- Não codar sem o mockup aceito (RO-06) e sem o serviço alvo identificado.
- Model recebendo a entidade JPA em vez de DTO/record → parar e corrigir antes de prosseguir
  (RO-SB4 é inegociável neste track).

## Leituras obrigatórias (RO-01)

1. Um controller `@Controller` já existente do projeto para copiar o padrão de rota, `Model`,
   tratamento de formulário (`@Valid`/`BindingResult`) e redirect com feedback.
2. Um template Thymeleaf já existente (`templates/fragments/header.html`/`footer.html` e uma tela
   de formulário) para copiar a estrutura de fragments, classes utilitárias (`gu-*`) e tokens.
3. O serviço/record de leitura que a tela vai consumir (assinatura real).
4. `tokens.css` do projeto — nunca inventar variável de cor/espaço.

## Convenções obrigatórias (Track Java Web/Spring Boot)

**Controller:**
- `@Controller` (nunca `@RestController` — estas telas retornam nome de view, não JSON).
- Injeção **por construtor** de um ou mais serviços; `Model` recebe só DTOs/records/enum/coleções
  deles — **nunca** a entidade `@Entity`.
- `@RequestParam(required = false)`/`defaultValue`, `@PathVariable` para filtros e identificadores.
- Formulário: `@Valid @ModelAttribute("form") XxxForm form, BindingResult binding` — em erro,
  **retorna a mesma view do form** (nunca redireciona perdendo os erros); em sucesso, `redirect:`
  com query string de feedback (`?salvo=1`).
- `@ModelAttribute` de método (ex.: `categorias()`) para popular dado compartilhado do form
  (options de `<select>`) em toda requisição do controller.
- Regra de negócio **condicional de formulário** (não estrutural, essa é da entidade/serviço) via
  `binding.rejectValue(campo, codigo, mensagem)`.

**Template Thymeleaf:**
- `th:action` dinâmico conforme criar/editar; `method="post"`; `novalidate` (confia no Bean
  Validation do servidor, não duplica no client).
- **CSRF automático:** com `thymeleaf-extras-springsecurity6` no `pom.xml` e CSRF ligado no
  `SecurityConfig`, o dialect injeta o token sozinho em formulários com `th:action` — **não
  adicionar `_csrf` hidden manualmente** (seria redundante/desatualizado se o projeto já usa o
  dialect automático — confirmar no `SecurityConfig` real antes de decidir).
- **Acessibilidade (RO-SB6):** todo campo com `<label class="gu-label" for="id">`; obrigatório com
  `aria-required="true"`; erro com `th:attr="aria-invalid=...,aria-describedby=..."` apontando para
  o `id` da mensagem; mensagem de erro em `<span role="alert" th:if="${#fields.hasErrors('campo')}"
  th:errors="*{campo}">`; grupo de opções usa `role="radiogroup" aria-labelledby="..."`.
- **Cor só por token:** nunca hex solto — `var(--color-*)`, `var(--sp-*)`, `var(--fs-*)`,
  `var(--radius-*)`, `var(--shadow-*)`; `tokens.css` + `app.css` linkados no `<head>`.
- **Fragments**: `<header th:replace="~{fragments/header :: siteHeader}">` /
  `<footer th:replace="~{fragments/footer :: siteFooter}">` — layout composto, não duplicado.
- Classes utilitárias do projeto (ex.: `gu-app`, `gu-card`, `gu-input`, `gu-btn-primary`) — usar as
  existentes, não inventar um novo sistema de classes.

## Fluxo

1. Apresentar o mockup e obter aceite (RO-06).
2. Ler controller/template de referência, o serviço alvo e `tokens.css` (RO-01).
3. Escrever o controller: rotas, `@ModelAttribute` compartilhado, tratamento de formulário.
4. Escrever o template: formulário/listagem com a11y completa, tokens, fragments.
5. Escrever teste de renderização no padrão do projeto: `@WebMvcTest(Controller.class)` +
   `@MockBean` dos serviços + `@Import(SecurityConfig.class)`, asserção em `view().name(...)` e
   conteúdo — roda **sem banco** (RO-SB8).
6. Rodar o teste de renderização e a varredura de hex fora de `tokens.css`
   (`grep -rEn '#[0-9a-fA-F]{3,8}\b'` nos templates/CSS do escopo, esperado 0 ocorrências).
7. Reportar arquivos, rotas afetadas e suposições.

## Regras de implementação

- Controller não tem SQL nem regra de negócio estrutural — delega tudo ao serviço.
- Model nunca recebe a entidade JPA (RO-SB4) — sempre o record que o serviço já monta.

## Guardrails

- Nunca `@RestController` nestas telas; nunca entidade JPA no `Model`.
- Nunca hex fora de `tokens.css`; nunca campo sem `label`; nunca erro sem `role="alert"`.
- Não inventar classe utilitária, token ou id de fragment (RO-01) — usar o real do projeto.
- Não adicionar `_csrf` manual se o dialect já injeta automaticamente (confirmar antes).

## Saída esperada

- Controller `@Controller` + template(s) Thymeleaf no padrão do projeto.
- Teste de renderização (`@WebMvcTest`) executado, sem hex fora de `tokens.css`.
- Mockup aprovado registrado e nota com suposições.

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: htmx para atualização parcial sem reload; extrair um fragment de
formulário se o padrão se repetir em outra tela; paginação na listagem).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup RO-06, a11y) · `qa-usabilidade` (caminho triste do formulário) · `especialista-seguranca` (CSRF, autorização por rota).
- **Vem antes:** `springboot-repository-service` (o serviço que a tela consome).
- **Vem depois:** o testador do projeto (bateria HTTP real) · `docs-projeto` (se a tela mudar o manual).
- **Não confundir com:** `javafx-screen-fxml` (mesmo papel, mas no track desktop JavaFX).
