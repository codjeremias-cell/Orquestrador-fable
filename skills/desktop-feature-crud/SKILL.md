---
name: desktop-feature-crud
description: "Gera uma entidade desktop fim-a-fim no track Tauri v2 a partir de um spec declarativo pequeno, de forma idempotente: migração SQLite up/down (tauri-plugin-sql), comando Rust fino sobre SQL parametrizado, binding tipado (tauri-specta) e tela. Substitui o par DAO+tela do JavaFX/JDBC. Acione com \"cria o CRUD de Cliente no app Tauri\", \"adiciona a entidade Produto ponta a ponta\", \"monta a feature de Pedido: banco, comando e tela\", \"preciso da migração SQLite dessa entidade no Tauri\". NÃO acione para o track JavaFX/JDBC (use spec-javafx-crud-feature) nem Spring Boot (use springboot-entity); nem para o scaffold inicial (use desktop-tauri-scaffold) ou o empacotamento (use desktop-packaging)."
argument-hint: "[entidade]"
---

# Desktop Tauri v2 — Feature CRUD de uma Entidade (track desktop, proposta 2026-07-07)

## Objetivo

A partir de um **spec declarativo pequeno** `{entidade, campos}`, produzir a **fatia vertical** de
uma entidade no app Tauri: **migração SQLite versionada up/down** (`tauri-plugin-sql`, sqlx),
**comando Rust fino** (só valida e envolve SQL parametrizado), **binding tipado** gerado
(`tauri-specta`) e a **tela**. Idempotente: rodar de novo com o mesmo spec não duplica migração nem
comando. Substitui o par DAO+tela do track JavaFX/JDBC.

## Entradas obrigatórias

1. **Spec declarativo:** `entidade` (nome singular) + `campos` (nome, tipo, obrigatoriedade — ex.:
   `nome: text not null`, `preco: real not null`, `ativo: bool default true`).
2. Operações desejadas (padrão: create/list/update/delete) e a chave de busca/ordenação, se houver.

## Entradas opcionais

- Relacionamento (FK para entidade já existente), índice único, validações de domínio.

## Trava obrigatória

- Sem `{entidade, campos}` inequívoco, **parar** e pedir o spec.
- FK para entidade que ainda não existe → parar (criar a referida antes).
- **Idempotência:** não gerar migração com número já aplicado — ler o diretório de migrações antes.

## Leituras obrigatórias (RO-01)

1. Doc do **`tauri-plugin-sql`** (https://v2.tauri.app/plugin/sql/) — API de `Migration`/
   `MigrationKind` e como o plugin registra e aplica as migrações no boot.
2. O registro de migrações atual em `src-tauri/src/` (onde `.add_migrations(...)` é chamado) e a
   última versão usada — o próximo número é o livre seguinte.
3. Um comando Rust já existente no projeto e o `bindings.ts` — espelhar assinatura/estilo, não
   inventar tipos.
4. As **capabilities** atuais — manter **default-deny** e escopo por janela (RO-DT1; nuance
   escopo-vs-obrigatoriedade do comando próprio: Convenções).

## Convenções obrigatórias (Track desktop Tauri v2, proposta 2026-07-07)

- **Migração up/down (RO-DT3):** dois SQLs versionados — `V<n>__<entidade>.up.sql` e `..._<entidade>.down.sql`.
  O `tauri-plugin-sql` aplica **só o Up** no boot (via sqlx); o **Down** é **artefato manual de
  dev/rollback** — **não** é auto-aplicado pelo plugin, roda à parte (sqlite3 CLI / cópia do banco)
  quando se precisa reverter em dev. Migração é **imutável** depois de aplicada em ambiente
  compartilhado — mudança nova = migração nova (nunca reeditar).
  - PK: `INTEGER PRIMARY KEY` (rowid). Timestamp: `created_at ... DEFAULT (datetime('now'))`.
    Único: índice `ux_<tabela>_<col>`; comum: `ix_<tabela>_<col>`.
  - **Alteração destrutiva** (drop/rename de coluna) segue o padrão seguro do SQLite: **criar tabela
    nova, copiar os dados, dropar a antiga, renomear** (temp+rename) — nunca mutar a tabela viva no
    lugar.
- **Comando Rust fino:** `#[tauri::command]` que só valida a entrada e chama SQL **parametrizado**
  (RO-04). Sem regra de negócio pesada nem UI no Rust. Anotado para `specta`.
- **Binding tipado (Pepita P-e):** re-exportar via `tauri-specta` para `src/bindings.ts`; o front
  chama a função tipada e o compilador valida o contrato.
- **Tela:** formulário + lista consumindo **só** o binding tipado; estados carregando/vazio/erro
  cobertos; a11y básica.
- **Capabilities (escopo, não obrigatoriedade — RO-DT1):** capabilities governam comandos de **plugin/core** e
  restrições **multi-janela** — um comando próprio no `generate_handler!` já é invocável sem entrada de
  capability por janela. Manter o **default-deny** como postura de segurança: não abrir permissions de
  plugin/core além do necessário e escopar por janela quando houver mais de uma.

## Fluxo

1. Ler o spec; ler doc do SQL plugin, registro de migrações, comando/binding de referência e
   capabilities (RO-01).
2. Escrever `V<n>__<entidade>.up.sql` + `.down.sql` (próximo `n` livre).
3. Escrever o comando Rust fino (SQL parametrizado); registrar no builder + specta.
4. Revisar as capabilities — **default-deny** e escopo por janela (RO-DT1; nuance: Convenções).
5. Regenerar `bindings.ts` (tauri-specta).
6. Escrever a tela (form + lista) sobre o binding tipado.
7. Rodar `cargo build` + `npm run tauri dev`; criar/listar/editar/excluir um registro `[QA-AUTO]`
   como smoke (RI-04).
8. Reportar arquivos criados e suposições.

## Few-shot (entra → sai)

**Entra** (spec): `entidade: Produto` · `campos: nome text not null, preco real not null, ativo bool default true`.

**Sai** (fatia vertical, próximo `n` livre = `3`):
- **Migração up** `V3__produto.up.sql` (+ `.down.sql` pareado — regime na Convenção de migração):
  ```sql
  CREATE TABLE produto (
    id         INTEGER PRIMARY KEY,
    nome       TEXT    NOT NULL,
    preco      REAL    NOT NULL,
    ativo      INTEGER NOT NULL DEFAULT 1,
    created_at TEXT    NOT NULL DEFAULT (datetime('now'))
  );
  ```
- **Comando fino** (Rust, SQL parametrizado, anotado p/ specta):
  ```rust
  #[tauri::command] #[specta::specta]
  async fn criar_produto(db: State<'_, Db>, nome: String, preco: f64) -> Result<i64, String> {
      let r = sqlx::query("INSERT INTO produto (nome, preco) VALUES (?1, ?2)")
          .bind(nome).bind(preco).execute(&db.pool).await.map_err(|e| e.to_string())?;
      Ok(r.last_insert_rowid())
  }
  ```
- **Binding** (gerado por `tauri-specta`, consumido tipado no front):
  ```ts
  import { commands } from "./bindings";
  await commands.criarProduto("Café", 12.5); // o TS valida o contrato
  ```
- **Tela:** form (nome/preço/ativo) + lista sobre o binding, com estados carregando/vazio/erro e a11y básica.

## Guardrails

- **Nunca** SQL interpolado — sempre parametrizado (RO-04).
- **Nunca** aplicar/testar migração destrutiva direto no banco de produção/uso real — **cópia temp**
  primeiro, só então promover (RO-DT3; mecânica temp+rename: Convenções).
- Manter o **default-deny** — não abrir permission de plugin/core além do necessário (RO-DT1;
  nuance do comando próprio: Convenções).

## Saída esperada

- Migração up/down; comando Rust registrado; `bindings.ts` atualizado; tela CRUD. Smoke
  create/list/update/delete verde como evidência (RI-04).

## Verificação / Checklist final

- **Compila e abre:** `cargo build` e `npm run tauri dev` verdes.
- **Migração idempotente:** usou só o próximo `n` **livre** (nada de número já aplicado); `bindings.ts` regenerado e os tipos batem no front.
- **Smoke `[QA-AUTO]`:** criar → listar → editar → excluir um registro — os quatro passos verdes (RI-04).
- **SQL parametrizado:** nenhuma interpolação de string no comando (RO-04).
- **Segurança/segurança do dado:** migração destrutiva provada em **cópia temp** antes de promover; capabilities ainda **default-deny** (nenhuma permission ampla nova).

## Sugestões de evolução (RO-07)

Fechar com 2–3 (ex.: paginação/filtro no comando de list; índice composto para a busca mais comum;
teste do comando com SQLite em memória).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-dados` (modelo local, migração, chaves/índices) · `especialista-seguranca` (SQL parametrizado, capabilities/escopo default-deny) · `dev-senior` (comando fino idiomático) · `designer-ux-ui` (tela e estados).
- **Vem antes:** `desktop-tauri-scaffold` (projeto com `tauri-plugin-sql` + `tauri-specta` já ligados).
- **Vem depois:** outra `desktop-feature-crud` (próxima entidade) · `desktop-packaging` · `testador-real`.
- **Não confundir com:** `springboot-entity` / `java-javafx-entity` (entidades de outros tracks) · `desktop-tauri-scaffold` (a base, não a feature).

### 📜 Histórico
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens C12, C13, C14, C15, C16, C17; −7 linhas.
- **2026-07-20 — Polimento de autoria:** `when_to_use` + `argument-hint`; +checklist de Verificação consolidando o smoke `[QA-AUTO]`, a idempotência da migração e o SQL parametrizado. Spec, convenções e todo o código do few-shot (SQL/Rust/TS) preservados verbatim.
