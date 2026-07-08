---
name: web-data-layer
description: "Monta a camada de dados do frontend separando SERVER-STATE (TanStack Query: cache, refetch, invalidação) de CLIENT-STATE (Zustand/Jotai: UI local, filtros, modal), com UM schema Zod único que é ao mesmo tempo o contrato da API (valida a resposta e cai em error state se divergir), o schema do formulário e a fonte dos tipos (z.infer) — o que blinda o front contra o Spring Boot mudar. Acione quando o usuário disser coisas como \"cria a camada de dados\", \"integra com a API\", \"TanStack Query nesse endpoint\", \"estado global com Zustand\", \"valida a resposta com Zod\", \"schema do formulário\", \"contrato de API tipado\". NÃO acione para o componente visual (use web-component) nem para escolher o stack (use frontend-stack-decisor)."
---

# Web Data Layer — TanStack Query + Zustand/Jotai + Zod único

> (Track web-frontend, proposta 2026-07-07)

Separa **server-state** de **client-state** e usa **um schema Zod** como fonte única de verdade.
**Server-state** (dados que vivem no backend) é do **TanStack Query** — cache, refetch, invalidação.
**Client-state** (UI local: tema, modal aberto, filtros) é do **Zustand/Jotai**. O **schema Zod** é ao mesmo
tempo o **contrato da API** (valida a resposta), o schema do **formulário** e a fonte dos **tipos** (`z.infer`) —
o que **blinda o front contra o Spring Boot mudar**: resposta fora do contrato vira **error state explícito**,
não `undefined` silencioso.

> **Suposição de stack (track web-frontend, proposta 2026-07-07):** os hooks TanStack Query, o `zodResolver`/react-hook-form e o padrão de store miram **React + Vite**. Stack não-React exige track próprio (ver `frontend-stack-decisor`).

## Objetivo

Gerar, por recurso: `<recurso>.schema.ts` (Zod), os hooks TanStack Query (`use<Recurso>`) e — só se preciso —
a store de client-state.

## Entradas obrigatórias

1. O **contrato real** do endpoint Spring Boot — o shape do JSON (ler o **DTO/record de leitura** do backend, RO-SB4), método, auth.
2. Operações: leitura (query) e escrita (mutation) e o que invalida o quê.
3. O que é **server-state** (vem da API) × **client-state** (só UI).

## Entradas opcionais

- Paginação/filtros, optimistic update, `VITE_API_URL`, integração com react-hook-form.

## Trava obrigatória

- **Server-state nunca em store global** (Zustand/Jotai). Cache, loading, erro e invalidação são do TanStack
  Query; a store guarda **só** client-state (UI). Duplicar a resposta da API numa store global é bug de
  sincronização garantido.
- Não **inventar** o shape do JSON — ler o DTO real do backend (RO-01). Se não houver, pedir/declarar a suposição.

## Leituras obrigatórias (RO-01)

1. O **DTO/record de leitura real** do Spring Boot (`web-data-layer` é o par cliente do track `springboot-*`) — o schema Zod espelha esse contrato.
2. A doc real do **TanStack Query** (queryKey, `invalidateQueries`, mutation) e do **Zod** — não inventar API.
3. `.env`/config de baseURL (`import.meta.env.VITE_API_URL`) e o padrão de auth do projeto.

## Convenções obrigatórias

- **Um schema Zod por recurso** → `type X = z.infer<typeof xSchema>` (tipos), `xSchema.parse(res)` na `queryFn`
  (valida a resposta = contrato), o **mesmo** schema no `zodResolver` do form.
- **queryKey estruturado:** `['recurso', id]` / `['recurso', { filtros }]`; mutation invalida por key.
- **Zustand/Jotai só client-state:** tema, sidebar, filtros locais, passo de wizard.
- **baseURL** via `import.meta.env.VITE_API_URL`; segredo real fica no backend, nunca no bundle.

## Fluxo

1. Ler o DTO real do backend → escrever o `<recurso>.schema.ts` (Zod) que o espelha.
2. Escrever os hooks TanStack Query (query com `schema.parse`, mutations com invalidação por key).
3. Se houver form, reusar o schema no `zodResolver`.
4. Se houver UI-state, criar a store client-state (sem dados de servidor).
5. Reportar arquivos + suposições de contrato.

## Regras de implementação

- O parse do schema é a fronteira: resposta válida → tipos garantidos; resposta inválida → error state tratado.

## Guardrails

- **Server-state nunca em store global.**
- Nunca `any`; nunca `fetch` sem validar contra o schema (senão o Spring Boot muda e o front quebra em silêncio).
- Segredo nunca no bundle — só `VITE_` público; chave sensível fica no backend (casa com `especialista-seguranca`).
- Erro de contrato (parse falhou) → **error state tratado**, não crash.

## Saída esperada

- `<recurso>.schema.ts` (Zod), `use<Recurso>.ts` (hooks TanStack Query), store client-state opcional — com o
  schema validando a resposta como evidência do contrato.

## Referências reais (RO-01)

- **TanStack Query** (doc oficial: `queryKey`, `invalidateQueries`, mutations) — https://tanstack.com/query/latest/docs/framework/react/overview
- **Zod** (doc oficial: schema, `.parse`, `z.infer`) — https://zod.dev/
- Server×client state + Zod como contrato de API — **blog de comunidade** (joshkaramuth), não normativo; confirmar contra as docs oficiais acima — https://joshkaramuth.com/blog/tanstack-zod-dto/

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 (ex.: gerar os schemas Zod a partir do OpenAPI do Spring Boot para o contrato ser automático;
optimistic update nas mutations de alta frequência; camada fina de erro que traduz o parse-fail em mensagem de UI).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-dados` (contrato/fluxo de dados) · `dev-senior` (tipos, hooks) · `especialista-seguranca` (env `VITE_`, segredo fora do bundle, CORS/CSRF com o backend).
- **Vem antes:** os DTOs do track `springboot-*` (o contrato real) · `frontend-stack-decisor`.
- **Vem depois:** `web-component` (consome os hooks) · `testador-real` (mocka a API e testa o error state).
- **Não confundir com:** `web-component` (casca visual/a11y) · `springboot-repository-service` (o lado servidor do contrato — aqui é o cliente).
