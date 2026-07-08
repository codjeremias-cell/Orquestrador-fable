---
name: springboot-entity
description: Cria uma entidade JPA + a migração Flyway correspondente para o track Java Web/Spring Boot (Gradup e afins) — POJO sem Lombok, sem setter público (mutação por método de domínio), @ManyToOne nunca @OneToMany, e o SQL de criação da tabela no padrão V<N>__<descricao>.sql. Acione quando o usuário disser coisas como "cria a entidade Curso", "preciso da tabela de Categoria", "modela esse módulo no banco", "adiciona a migração Flyway pra essa entidade", em projeto Spring Boot + PostgreSQL + Flyway. NÃO acione para o repositório/serviço (use springboot-repository-service) nem para o controller/tela (use springboot-controller-thymeleaf).
---

# Spring Boot — Entidade JPA + Migração Flyway

## Objetivo

Criar uma entidade JPA e a migração Flyway que cria/altera sua tabela, no padrão real validado no
Gradup (`com.portal.catalog.domain.Course`/`Category`, `V4__catalog.sql`): POJO sem framework de
geração de código, mutação só por método de domínio nomeado, schema e código sempre em sincronia
via migração versionada (RO-SB2 — Hibernate nunca cria/altera schema, `ddl-auto=validate`).

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
  padrão do projeto. Relacionamento para entidade que não existe ainda → parar e perguntar.
- Nunca propor `@OneToMany` — o padrão do track é navegação inversa via query no repositório.

## Leituras obrigatórias (RO-01)

1. Uma entidade já existente do projeto (ex.: em outro módulo) para confirmar o estilo real
   (com/sem Lombok, como o construtor e os métodos de domínio estão nomeados).
2. A última migração Flyway (`src/main/resources/db/migration/V<último>__*.sql`) para saber o
   próximo número de versão e o estilo de constraint/index usado.
3. O `docs/02-ARQUITETURA.md` (ou equivalente) do projeto, se existir, para confirmar a estrutura
   de pacotes `web/application/domain/infrastructure`.

## Convenções obrigatórias (Track Java Web/Spring Boot)

- **Sem Lombok.** POJO explícito: campos privados, `@Column(name=..., nullable=..., length=...)`
  em cada um, `@Id @GeneratedValue(strategy = GenerationType.IDENTITY)`.
- **Sem setter público.** Construtor **protegido** sem argumentos (exigência do JPA) + construtor
  público completo para criação. Mutação por **método de domínio nomeado** (`update(...)`, ou um
  verbo específico como `assignCompany(...)`) — nunca um `setX` genérico.
- **`@ManyToOne(fetch = FetchType.LAZY, optional = false)` + `@JoinColumn(name=..., nullable=false)`**
  para toda referência a outra entidade. **Nunca `@OneToMany`** — quem precisa da lista busca por
  query no repositório da entidade filha.
- Enum: `@Enumerated(EnumType.STRING)` + `@Column(length=20)` (nunca `EnumType.ORDINAL`).
- Getters simples (`getX()`); booleano usa `isX()`.
- **Migração Flyway**: arquivo `V<N>__<descricao_em_snake_case>.sql` em
  `src/main/resources/db/migration/`, `<N>` = próximo número livre (nunca reusar).
  - PK: `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` (não `SERIAL`).
  - Índice único: prefixo `ux_` (ex.: `ux_courses_slug`). Índice comum: prefixo `ix_`.
  - Timestamp de criação: `NOT NULL DEFAULT now()`.
  - FK: `REFERENCES tabela (id)` inline na criação; em migração incremental sobre tabela já
    existente, `ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY ...`.
  - Migração nova de módulo pode incluir **seed de dados** de exemplo (`INSERT INTO ...`).
- Comentário de topo na entidade referenciando a migração (ex.: `/** Curso do catalogo. Mapeado
  para {@code courses} (ver V4__catalog.sql). */`).

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

- Nunca `@OneToMany`, nunca Lombok, nunca setter público genérico.
- Nunca `SERIAL` na migração (usar `GENERATED ALWAYS AS IDENTITY`).
- Nunca reusar número de versão Flyway já aplicado — migração é imutável depois de rodar em
  qualquer ambiente compartilhado.
- Não inventar nome de tabela/coluna de outra entidade (RO-01) — ler o schema real.

## Saída esperada

- `<Entidade>.java` em `com.<app>.<modulo>.domain`.
- `V<N>__<descricao>.sql` em `src/main/resources/db/migration/`.
- Build (`mvn compile`) verde como evidência.

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: índice composto se a busca mais comum filtrar por duas colunas;
projeção de leitura já antecipada para o repositório; enum de status abrir espaço para máquina de
estados se a entidade crescer).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (limite do módulo, `domain` não depende de `web`/`infrastructure`) · `dev-senior` (POJO legível).
- **Vem antes:** `requisitos-descoberta` (atributos vêm da história aprovada).
- **Vem depois:** `springboot-repository-service` (repositório e serviço que usam esta entidade) · `testador-real`/instância do projeto.
- **Não confundir com:** `java-javafx-entity` (mesmo papel, mas no track desktop JavaFX/JDBC puro — não Spring/JPA).
