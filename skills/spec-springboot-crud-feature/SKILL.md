---
name: spec-springboot-crud-feature
description: "Orquestra a criação de UMA funcionalidade CRUD completa no track Java Web/Spring Boot que JÁ EXISTE, do domínio à tela — cobrindo entidade e migração Flyway, repositório e serviço, controller e template Thymeleaf — garantindo as Regras de Ouro do stack. Acione com \"cria a funcionalidade completa de Curso\", \"preciso do CRUD de Categoria ponta a ponta\", \"monta tudo dessa entidade: banco, serviço e tela\", \"faz a feature inteira de Matrícula\". NÃO acione fora disso — é para UMA feature num sistema existente — se o stack for desktop JavaFX, use spec-javafx-crud-feature; se o pedido é o SISTEMA/ciclo inteiro (arquitetura, deploy, release), use spec-projeto-completo; se é só o front consumindo a API, use spec-frontend-web. NÃO acione para uma única camada isolada — para isso use springboot-entity, springboot-repository-service ou springboot-controller-thymeleaf."
---

# Spec — Funcionalidade CRUD Spring Boot (orquestrador)

Orquestradora do track Java Web/Spring Boot: conduz, em ordem determinística, a criação de uma
funcionalidade completa num projeto **já existente**, aplicando o método das skills do track e validando cada etapa. Não
duplica o trabalho detalhado delas.

## Quando usar / Quando NÃO usar

Use **esta** para **uma** feature (uma entidade/módulo) num app Spring Boot **que já roda** (Flyway + Security prontos). Se a fronteira for outra:

- Mesmo papel, mas stack **desktop JavaFX** → `spec-javafx-crud-feature`.
- Pedido é o **sistema/ciclo inteiro** (arquitetura, testes, segurança, deploy, release) → `spec-projeto-completo`.
- Trabalho é só o **frontend web** consumindo a API → `spec-frontend-web`.
- Só **uma camada** (só a entidade+migração, só o repo+serviço, só o controller+template) → `springboot-entity`, `springboot-repository-service` ou `springboot-controller-thymeleaf`.

## Objetivo

Entregar, de ponta a ponta, uma funcionalidade de uma entidade — domínio + migração + repositório
+ serviço + tela — aderente às [[REGRAS-DE-OURO]] do track (RO-SB1…8).

## Entradas obrigatórias

1. Nome da entidade/módulo e seus atributos.
2. Relacionamentos (`@ManyToOne`) e tabela/colunas reais (ou autorização para propor).
3. Operações desejadas (criar, listar, editar, buscas/filtros).
4. Confirmação de que a funcionalidade inclui tela Thymeleaf.

## Entradas opcionais

- Regras de negócio específicas, DTO/record de leitura já definido, navegação/menu.

## Validação do catálogo

Confirmar que existem no catálogo as skills filhas:

- `springboot-entity`
- `springboot-repository-service`
- `springboot-controller-thymeleaf`

Se faltar uma skill crítica, **parar** e informar qual faltou e para qual papel.

## Sequência determinística

> **Invoque, não descreva.** Cada passo abaixo que cita um gerador exige
> **carregar a skill pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; validar cada etapa antes de seguir.

1. **Mockup primeiro (RO-06).** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva) → mockup da tela com os estados vazio/carregando/erro; obter aceite do Jeremias.
2. **Domínio.** Carregue a skill `springboot-entity` (ferramenta Skill — invoque, não descreva) e crie a entidade + migração Flyway (`V<N>__*.sql`).
3. **Persistência e regra de negócio.** Carregue a skill `springboot-repository-service` (ferramenta Skill — invoque, não descreva) e crie o repositório
   (com `join fetch` onde precisar) e o(s) serviço(s) que a tela vai chamar, com o record de
   leitura já definido.
4. **Tela.** Carregue a skill `springboot-controller-thymeleaf` (ferramenta Skill — invoque, não descreva) e crie o controller (`@Controller`, nunca
   `@RestController`) e o template (a11y completa, CSRF automático, tokens).
5. **Fechamento com prova.** Rodar `mvn test` (a suíte gated por `DB_URL` mais o `@WebMvcTest` sem
   banco); varredura de hex fora de `tokens.css`; quando existir bateria HTTP do testador do
   projeto, acioná-la para a funcionalidade nova. Carregue as lentes `especialista-seguranca`
   (CSRF, autorização por rota, exposição de dado) e `qa-usabilidade` (defeito de uso e a11y na
   tela nova) — **ferramenta Skill, invoque, não descreva**.

## Regras de coerência

- Nomes consistentes entre entidade, migração, repositório, serviço, controller e template
  (mesmo slug/rota em todas as camadas).
- Reaproveitar o padrão real do projeto (fragments, classes `gu-*`, `SecurityConfig`) — descobrir
  por leitura, nunca inventar (RO-01).
- A view **nunca** recebe a entidade JPA (RO-SB4) — só o record de leitura do serviço.
- Operação multi-passo = transação atômica (RO-SB3); dependência do módulo aponta para dentro.

## Verificação da spec da feature (autossuficiência)

Antes do código (após o mockup), confira que a feature está especificada de forma autossuficiente — o porquê: sem escopo e critério de aceite, a feature vaza para operações não pedidas e "pronto" fica sem prova. A spec responde **sim** a:

- **Escopo** — entidade/módulo, atributos, relacionamentos, tabela/colunas e operações (criar/listar/editar/buscas) estão definidos?
- **Fora-de-escopo** — o que esta feature **não** faz (relatórios, outros módulos, endpoints REST) está declarado?
- **Critério de aceite ponta-a-ponta** — há um caminho verificável de fora — ex.: "POST cria o registro → GET lista mostra ele → editar persiste → excluir remove", coberto pelo `mvn test`/`@WebMvcTest` (RI-04)?

Faltando qualquer item, resolva antes de começar o domínio.

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Tabela/colunas ou regra de negócio ambíguas.
- Mockup não aprovado; feature sem escopo/fora-de-escopo/critério de aceite (ver acima).
- Falha em `mvn test`/`@WebMvcTest` obrigatório.

## Formato do relatório final (RI-05)

Resumo objetivo: skills usadas · arquivos criados/alterados (caminho exato — RO-03) · testes
executados (com/sem `DB_URL`) · o que foi validado · pendências/limitações · **2–3 sugestões de
evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito.

## Saída esperada

- Entidade + migração; repositório + serviço(s) + teste gated por `DB_URL`; controller + template
  Thymeleaf + teste `@WebMvcTest`. Funcionalidade CRUD funcional de ponta a ponta, aderente às
  Regras de Ouro do track (RO-SB1…8).

**Exemplo montado real (Gradup):** carregue `referencia-exemplo-montado-gradup.md` — o módulo **catalog** existe ponta a ponta e é o gabarito da sequência (entidade+migração→repo+serviço→controller+template), cada elo citando o arquivo real. Amarra as referências `referencia-exemplos-reais-gradup.md` das skills. O padrão real vence o genérico (RO-01).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup) · `especialista-seguranca` (CSRF, autorização) · `qa-usabilidade`/`auditor-responsabilidades` (fechamento e veredito).
- **Vem antes:** projeto Spring Boot já com Flyway/Security configurados (o Gradup já tem — RO-SB1…8 na [[REGRAS-DE-OURO]]).
- **Vem depois:** o testador do projeto (bateria HTTP) · `docs-projeto`.
- **Não confundir com:** `spec-javafx-crud-feature` (mesmo papel, track desktop JavaFX) · `spec-projeto-completo` (ciclo de vida inteiro, não só uma feature) · `spec-frontend-web` (só o front que consome a API).

### 📜 Histórico
- **2026-08-18 (2) — As três lentes declaradas ganham call site (T39; degrau §6.10: 1 — só edição).** A Rede desta skill declarava, no campo **"Lentes que ativam junto (RI-06)"**, quatro lentes; **três não eram chamadas por passo nenhum do Fluxo** — existiam só como declaração. A reanálise dos seis traços da bancada T9 (T15) mostrou o efeito disso medido: das quatro, **só o `auditor-responsabilidades` disparou** (5 de 6 rodadas), e é exatamente **a única que tinha call site** (passo de veredito). `designer-ux-ui`, `especialista-seguranca` e `qa-usabilidade`: **zero de 6**, nos dois braços da bancada — não é defeito do tratamento nem do controle, é da redação. Corrigido sem inventar passo: as três entraram nos passos que **já faziam aquele trabalho** — `designer-ux-ui` no passo 1, que já era o do mockup RO-06 e não carregava a lente que faz mockup; `especialista-seguranca` e `qa-usabilidade` no passo 5, o de fechamento com prova. Fórmula igual à dos geradores, que é o padrão que 5 dos 7 orquestradores já seguiam. **Declaração sem call site é promessa que o gate lê como cumprida** — mesma família de [[verificar-presenca-nao-e-verificar-efeito]], um degrau antes: aqui nem trava havia, só o anúncio dela. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.**
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), **n=3×3 medida nesta skill**, em bancada isolada fora do repositório. Com o texto da T29, os três geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas** (uma delas leu os três `SKILL.md` por `Read`); com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega nem de qualidade da saída. Jeremias decidiu aplicar. O texto aqui é **verbatim o braço de tratamento medido**. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **encadear/delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. Os passos passam a dizer *criar X — método em `gerador`*, que é o comportamento real; os geradores seguem existindo e invocáveis. Escolha do Jeremias entre alinhar a promessa e forçar a delegação — alinhar venceu porque a saída medida é boa. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- **2026-07-18 — Exemplo montado real (orquestrador):** criada `referencia-exemplo-montado-gradup.md` mapeando a feature/sistema real (SIGO/Gradup) através da sequência que este orquestrador encadeia — capstone que amarra os few-shots das skills do track. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
