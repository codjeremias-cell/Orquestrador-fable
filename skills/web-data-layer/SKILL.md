---
name: web-data-layer
description: "Monta a camada de dados do frontend separando SERVER-STATE (TanStack Query: cache, refetch, invalidação) de CLIENT-STATE (Zustand ou Jotai: UI local, filtros, modal), com UM schema Zod único que é ao mesmo tempo contrato da API, schema do formulário e tipo. Acione com \"cria a camada de dados\", \"integra com a API\", \"TanStack Query nesse endpoint\", \"estado global com Zustand\", \"valida a resposta com Zod\", \"schema do formulário\", \"contrato de API tipado\". NÃO acione para o componente visual (use web-component) nem para escolher o stack (use frontend-stack-decisor)."
argument-hint: "[recurso]"
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
- **Formato de string é chamada de topo:** `z.email()`, `z.uuid()`, `z.url()` — é o que a doc corrente
  documenta. A forma encadeada (`z.string().email()`) é do Zod 3 e **não aparece mais** na doc; se o
  projeto-alvo ainda estiver no 3, espelhe o que o `package.json` dele diz (RO-01, confira não lembre).
- **queryKey estruturado:** `['recurso', id]` / `['recurso', { filtros }]`; mutation invalida por key.
- **Zustand/Jotai só client-state:** tema, sidebar, filtros locais, passo de wizard.
- **baseURL** via `import.meta.env.VITE_API_URL`; segredo real fica no backend, nunca no bundle.

## Fluxo

1. Ler o DTO real do backend → escrever o `<recurso>.schema.ts` (Zod) que o espelha.
2. Escrever os hooks TanStack Query (query com `schema.parse`, mutations com invalidação por key).
3. Se houver form, reusar o schema no `zodResolver`.
4. Se houver UI-state, criar a store client-state (sem dados de servidor).
5. Reportar arquivos + suposições de contrato.

## Exemplo (entra → sai)

> Entra (DTO de leitura real do Spring Boot): `ClienteDTO { id: Long, nome: String, email: String, ativo: boolean }`; operações: listar + criar; criar invalida a lista.
>
> Sai — `cliente.schema.ts` (o schema **espelha** o DTO):

```ts
import { z } from "zod";

export const clienteSchema = z.object({
  id: z.number(),
  nome: z.string(),
  email: z.email(),
  ativo: z.boolean(),
});
export type Cliente = z.infer<typeof clienteSchema>; // tipos = schema (sem duplicar)
```

`useClientes.ts` (a `parse` é a fronteira do contrato):

```ts
const base = import.meta.env.VITE_API_URL;

export function useClientes() {
  return useQuery({
    queryKey: ["cliente"],
    queryFn: async () => {
      const res = await fetch(`${base}/clientes`).then((r) => r.json());
      return z.array(clienteSchema).parse(res); // resposta fora do shape → erro tratado, não undefined
    },
  });
}

export function useCriarCliente() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (novo: Omit<Cliente, "id">) =>
      fetch(`${base}/clientes`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(novo),
      }).then((r) => r.json()),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["cliente"] }), // invalida por key → lista refaz
  });
}
```

O form reusa o **mesmo** `clienteSchema` no `zodResolver`. Se houver filtro/modal, ele mora numa store Zustand
— nunca a lista de clientes (isso é server-state, fica no cache do Query).

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

## Verificação / Checklist final

- **`tsc --noEmit` limpo** — os tipos saem do `z.infer` (sem `any`, sem tipo escrito à mão).
- **Caminho feliz:** rodar a query real → dados na tela.
- **Contrato:** forçar (mock) uma resposta fora do shape → cai em **error state**, não em crash nem `undefined`.
- **Invalidação:** disparar a mutation → a lista se refaz sozinha (item aparece sem reload).
- **Fronteira de estado:** nenhum dado de servidor na store global (só UI-state) e nenhum segredo no bundle (só `VITE_*`).

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

### 📜 Histórico
- **2026-09-23 — O few-shot deixou de ensinar API que a doc não tem mais (inventário `_auditoria/zelador-inventario-as-45-2026-09-22.md`, veredito `ATUALIZAR`; RI-04; degrau §6.10: 1 — só edição).** O exemplo escrevia `email: z.string().email()`. **Conferido em `zod.dev` antes de editar (RO-01):** a seção *String formats* lista `z.email()`, `z.uuid()` e `z.url()` como chamadas de **topo**, e a busca na página pela forma encadeada devolve **zero** ocorrências. O defeito era duplo, e a segunda metade é a que dói: as **Leituras obrigatórias** mandam, em imperativo, *"a doc real do TanStack Query e do **Zod** — não inventar API"*, e o few-shot trinta linhas abaixo mostrava a API que a doc real não tem. Quem copiasse o exemplo desobedecia a instrução da própria skill. **O conserto não foi só trocar a linha:** entrou uma convenção que delega a checagem ao `package.json` do projeto-alvo, porque fixar a forma nova envelheceria de novo no próximo major — é o mesmo desenho que a `auditor-responsabilidades` recebeu em 2026-09-22 ao **retirar** o número de versão em vez de incrementá-lo. **Fica declarado e NÃO foi feito:** a generalização da L27 (*"contrato real do backend"* em vez de *"endpoint Spring Boot"*), que a mesma pendência pedia — aquilo é decisão de **escopo** (a skill declara na L18 uma suposição de stack), não conserto de vigência, e não se resolve em silêncio junto. **Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0** — a convenção que entrou é imperativa (*"espelhe o que o `package.json` dele diz"*), e o *"se o projeto-alvo ainda estiver no 3"* é condição de fato, não abrandamento.
- **2026-07-20 — Polimento de autoria:** gatilho `when_to_use` (consolidado na `description` em 2026-08-08) + `argument-hint`; +few-shot (entra→sai) com schema Zod espelhando o DTO, hooks Query e o *porquê* da `parse` como fronteira; +checklist de Verificação (tsc, error state, invalidação). Descrição e convenções preservadas.
