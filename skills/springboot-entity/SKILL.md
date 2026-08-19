---
name: springboot-entity
description: "Camada de dados de um CRUD Spring, a primeira das três: cria a entidade JPA e a migração Flyway correspondente no track Java Web/Spring Boot, seguindo o padrão de versionamento de migração do projeto. Acione com \"V + número + duplo underscore + descrição\", \"cria a entidade Curso\", \"preciso da tabela de Categoria\", \"modela esse módulo no banco\", \"adiciona a migração Flyway pra essa entidade\", \"modela o Curso\". NÃO acione fora disso — para o repositório/serviço, use springboot-repository-service; para o controller/tela, use springboot-controller-thymeleaf."
---

# Spring Boot — Entidade JPA + Migração Flyway

**Camada no CRUD:** dados (domínio + schema). É a 1ª das três camadas — **esta** (entidade + tabela) →
`springboot-repository-service` (acesso a dados + regra) → `springboot-controller-thymeleaf` (tela).
Tudo o mais depende do que se decide aqui.

## Objetivo

Criar uma entidade JPA e a migração Flyway que cria/altera sua tabela, no padrão real validado no
Gradup (`com.portal.catalog.domain.Course`/`Category`, `V4__catalog.sql`): POJO sem framework de
geração de código, mutação só por método de domínio nomeado, schema e código sempre em sincronia
via migração versionada (RO-SB2 — Hibernate nunca cria/altera schema, `ddl-auto=validate`).

## Princípio: espelhar o projeto-alvo (Gradup = a casa validada)

As convenções abaixo são o padrão real do Gradup — se o projeto-alvo é o Gradup ou segue a mesma
casa, siga-as: é acerto, não escolha. Se for um Spring Boot de **outra casa** (ex.: usa Lombok, outra
estrutura de pacotes, outra política de exceção), leia um artefato existente do projeto e espelhe o
padrão dele, declarando onde diverge do Gradup (RI-04). Separe sempre o que é **invariante**
(segurança/correção — não varia porque quebrá-lo introduz bug ou dessincroniza schema e código) do
que é **estilo da casa** (varia — espelhe o que o projeto já usa).

- **Invariante (não varia):** schema e código em sincronia via migração versionada (Hibernate não
  altera schema, senão prod e código divergem); número de versão Flyway nunca reusado (a migração é
  imutável depois de aplicada — reusar corrompe o histórico); FK explícita.
- **Estilo da casa (espelhe):** sem-Lombok × Lombok, método-de-domínio × setter, nomes de pacote — o
  Gradup é sem-Lombok/sem-setter; outro projeto pode diferir, e aí você segue o dele.

## Entradas obrigatórias

1. Nome da entidade (ex.: `Curso`) e o módulo (`com.<app>.<modulo>`).
2. Atributos com tipo e obrigatoriedade (ex.: `titulo: String not null length 150`).
3. Relacionamentos `@ManyToOne` (ex.: `categoria: Category not null`) — se houver.
4. Se é migração **nova** (módulo inteiro) ou **incremento** sobre tabela existente.

## Entradas opcionais

- Enum de domínio (mapeado `@Enumerated(EnumType.STRING)`).
- Índices/unique adicionais além da PK.

## Trava obrigatória

- Não gerar sem o nome real da tabela/colunas confirmado, ou autorização para propô-lo seguindo o
  padrão do projeto. Relacionamento para entidade que ainda não existe → parar e perguntar.
- Evite `@OneToMany`: a lista inversa vem por query no repositório da filha (ver Convenções). Propor
  `@OneToMany` traz lazy-loading e cascade difíceis de controlar — por isso a skill não usa.

## Leituras obrigatórias (RO-01)

1. Uma entidade já existente do projeto (ex.: em outro módulo) para confirmar o estilo real
   (com/sem Lombok, como o construtor e os métodos de domínio estão nomeados).
2. A última migração Flyway (`src/main/resources/db/migration/V<último>__*.sql`) para saber o
   próximo número de versão e o estilo de constraint/index usado.
3. O `docs/02-ARQUITETURA.md` (ou equivalente) do projeto, se existir, para confirmar a estrutura
   de pacotes `web/application/domain/infrastructure`.

## Convenções obrigatórias (Track Java Web/Spring Boot)

> Estas são as convenções da **casa Gradup** — o default a espelhar. As de **segurança/correção**
> (migração versionada, `IDENTITY`, `@Enumerated(STRING)`, FK explícita) são **invariantes**; as de
> **forma** (sem-Lombok, método-de-domínio) você segue por padrão, mas espelha a casa-alvo se ela
> divergir (RI-04, `evals.json` caso 2). A **modelagem `@ManyToOne` / nunca `@OneToMany`** é ensino da
> skill — não é item espelhável (vale em qualquer casa, é decisão de modelagem, não gosto).

- **Sem Lombok.** POJO explícito: campos privados, `@Column(name=..., nullable=..., length=...)`
  em cada um, `@Id @GeneratedValue(strategy = GenerationType.IDENTITY)`.
- **Sem setter público.** Construtor **protegido** sem argumentos (exigência do JPA) + construtor
  público completo para criação. Mutação por **método de domínio nomeado** (`update(...)`, ou um
  verbo específico como `assignCompany(...)`) — um `setX` genérico deixaria qualquer código mudar o
  estado sem passar pela regra do domínio.
- **`@ManyToOne(fetch = FetchType.LAZY, optional = false)` + `@JoinColumn(name=..., nullable=false)`**
  para toda referência a outra entidade. Sem `@OneToMany` — quem precisa da lista busca por query no
  repositório da entidade filha (evita carregar coleções inteiras por engano).
- Enum: `@Enumerated(EnumType.STRING)` + `@Column(length=20)` (não `EnumType.ORDINAL`, que quebra se
  a ordem do enum mudar).
- Getters simples (`getX()`); booleano usa `isX()`.
- **Migração Flyway:** arquivo `V<N>__<descricao_em_snake_case>.sql` em
  `src/main/resources/db/migration/`, `<N>` = próximo número livre (não reusar — migração aplicada é
  imutável).
  - PK: `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` (padrão SQL, em vez de `SERIAL`).
  - Índice único: prefixo `ux_` (ex.: `ux_courses_slug`). Índice comum: prefixo `ix_`.
  - Timestamp de criação: `NOT NULL DEFAULT now()`.
  - FK: `REFERENCES tabela (id)` inline na criação; em migração incremental sobre tabela já
    existente, `ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY ...`.
  - Migração nova de módulo pode incluir **seed de dados** de exemplo (`INSERT INTO ...`).
- Comentário de topo na entidade referenciando a migração (ex.: `/** Curso do catalogo. Mapeado
  para {@code courses} (ver V4__catalog.sql). */`) — liga código e schema para quem ler depois.

## Fluxo

1. Confirmar entidade, módulo, atributos e relacionamentos.
2. Ler a entidade de referência e a última migração (RO-01).
3. Escrever a entidade: campos + `@Column` explícito, construtor protegido + completo, getters,
   método(s) de domínio para mutação.
4. Escrever a migração Flyway com o próximo número de versão, PK identity, índices e FKs.
5. Rodar `mvn -q compile` para confirmar que a entidade compila; se houver ambiente de banco
   (`DB_URL` setado), rodar a migração e confirmar que aplica sem erro.
6. Reportar arquivos criados e suposições (RO-01).

## Regras de implementação

- Entidade não conhece repositório, serviço nem controller — é domínio puro.
- Não duplicar validação de formato (isso é do Bean Validation no DTO/form da camada web) — a
  entidade garante só a consistência estrutural dos seus próprios campos.

## Guardrails

- **Forma da casa Gradup (espelhe, não imponha como lei universal):** sem Lombok e sem setter público
  (mutação por método de domínio) é o default do Gradup e de quem o segue. Se a casa-alvo já adotou
  Lombok/setter, espelhe-a e declare a divergência (RI-04), como no `evals.json` caso 2, mantendo os
  invariantes intactos. Não invente divergência sem um artefato do projeto pedindo.
- **Modelagem `@ManyToOne`, não `@OneToMany`** (lista inversa por query): isto não é estilo
  espelhável — é a decisão de modelagem que a skill ensina, vale em qualquer casa.
- Prefira `GENERATED ALWAYS AS IDENTITY` a `SERIAL` na migração (é o padrão SQL e evita o descompasso
  de sequence do `SERIAL`).
- Não reuse número de versão Flyway já aplicado — migração é imutável depois de rodar em qualquer
  ambiente compartilhado, e reusar diverge o checksum.
- Não invente nome de tabela/coluna de outra entidade (RO-01) — leia o schema real.

## Saída esperada

- `<Entidade>.java` em `com.<app>.<modulo>.domain`.
- `V<N>__<descricao>.sql` em `src/main/resources/db/migration/`.
- Build (`mvn compile`) verde como evidência.

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: índice composto se a busca mais comum filtrar por duas colunas;
projeção de leitura já antecipada para o repositório; enum de status abrir espaço para máquina de
estados se a entidade crescer).

**Gabarito Gradup (few-shot de código real):** projeto-alvo sendo o **Gradup ou família Spring Boot**, carregue `referencia-exemplos-reais-gradup.md` — Category/Course + V4__catalog.sql verbatim + convenções reais (entidade em `com.portal.<modulo>.domain`; sem Lombok; construtor `protected` vazio + completo público; sem setter — mutação por método de domínio `update(...)`; `@Column(name,nullable,length)` explícito; `@ManyToOne(LAZY, optional=false)` nunca `@OneToMany`; javadoc citando tabela E migração; migração `V<N>__<modulo>.sql` com `BIGINT GENERATED ALWAYS AS IDENTITY`, índices `ux_`/`ix_` nomeados e seed no próprio arquivo). O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Verificação de fechamento (RI-04)

Sem evidência, não está pronto. Esta skill entrega **entidade + migração, sem teste de POJO** —
pergunte-se e comprove:

1. **A entidade compila?** `mvn -q compile` verde — o mapeamento JPA (anotações, tipos, construtores)
   está bem-formado.
2. **O contexto sobe e a migração aplica?** Quando há banco (`DB_URL` setada), o boot com
   `ddl-auto=validate` sobe sem erro — ou seja, a **migração Flyway aplica limpa** e o Hibernate
   confere que a tabela criada bate com a entidade (é a prova de que schema e código estão em
   sincronia). Sem `DB_URL`, aplicar a migração vira **SKIP declarado com o motivo** (o compile ainda
   vale), nunca "passou" fingido.

Não gere `@Test` de POJO puro só para ter o que rodar — o Gradup não testa POJO, e espelhar vale aqui
também.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (limite do módulo, `domain` não depende de `web`/`infrastructure`) · `dev-senior` (POJO legível).
- **Vem antes:** `requisitos-descoberta` (atributos vêm da história aprovada).
- **Vem depois:** `springboot-repository-service` (repositório e serviço que usam esta entidade) · `testador-real`/instância do projeto.
- **Não confundir com:** `java-javafx-entity` (mesmo papel, mas no track desktop JavaFX/JDBC puro — não Spring/JPA).

### 📜 Histórico
- **2026-08-08 — Conformidade de frontmatter (garimpo cienciaedados 2026-08-08 · G03a):** a `description` continha `V<N>__<descricao>.sql`, e colchete angular é **proibido no frontmatter** por restrição de segurança da plataforma — o frontmatter entra no system prompt, onde `<` e `>` abrem vetor de injeção (guia oficial *The Complete Guide to Building Skills for Claude*, pág. 11 e 31). Trocado por descrição em prosa do mesmo padrão Flyway; a `description` caiu para 912 caracteres. **O corpo não mudou:** as 3 ocorrências do padrão literal em §Passos, §Saídas e §Gabarito continuam lá, porque é delas que o gerador aprende a nomear o arquivo — a proibição vale só no frontmatter. Degrau §6.10: 1 (edição de skill existente). Checagem `E11` criada no `validar-skills.ps1` na mesma rodada para impedir reincidência.
- **2026-07-20 — Polimento de disparo e verificação:** descrição reescrita para nomear a **camada** (dados/domínio + schema, 1ª de 3) e a **fronteira** com as skills irmãs logo no gatilho; caixa alta rígida (`NÃO`, `NUNCA`) trocada por forma explicativa com o **porquê** de cada invariante (Hibernate não altera schema para não divergir de prod; sem `@OneToMany` para não carregar coleções por engano; `IDENTITY` em vez de `SERIAL`); fechamento reorganizado em 2 perguntas concretas (compila? o contexto sobe e a migração aplica limpa?). `GENERATED ALWAYS AS IDENTITY` e demais palavras-chave SQL/JPA preservadas. Sem mudança de código ou convenção.
- **2026-07-18 — Evolução ao 9,5 (núcleo Gradup):** princípio **espelhar-o-projeto** explicitado (Gradup = casa validada; Spring de outra casa → leia e espelhe, RI-04) + separação **invariante × estilo-da-casa** + seção de fechamento RI-04 consolidada + **eval executável** (`evals/evals.json`, 2 casos: Gradup × outra casa Spring — prova o espelho). Mesma receita que levou o núcleo SIGO ao 9,5. **Auto-verificada** contra os defeitos convergentes do painel SIGO (sem seção "Tensão" velha; teste de fechamento condicional com SKIP declarado; corpo↔referência coerentes — a referência reforça o corpo, não o contradiz). **Painel de 3 juízes adiado por limite de budget semanal**; promovida por ser estritamente melhor que a versão live (teto honesto ~9,2), sem regressão.
- **2026-07-18 — Few-shot de código real (onda Gradup/Spring Boot):** criada `referencia-exemplos-reais-gradup.md` (fonte: `catalog/domain/Category.java`+`Course.java`+`V4__catalog.sql`). Baseline §11: geração sem gabarito acertou o essencial (JPA sem Lombok, method de domínio) mas divergiu em nomes de tabela em inglês vs. o padrão real, versão de migração adivinhada e ausência do cabeçalho/seed no .sql. Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens A8; −0 linhas (poda de texto na Trava, sem redução de linha física).
