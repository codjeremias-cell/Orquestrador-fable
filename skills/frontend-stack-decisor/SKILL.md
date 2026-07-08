---
name: frontend-stack-decisor
description: "Decide o stack de frontend web por gatilho — SEO/indexação pública, app atrás de login, conteúdo estático vs interatividade pesada, backend já existente — escolhendo entre React+Next.js, Vite SPA, Astro, Svelte/SvelteKit, Vue/Nuxt ou TanStack Start, e registra a decisão com o porquê num ADR curto (é um gerador-decisor, não escreve o app). Acione quando o usuário disser coisas como \"qual stack de frontend eu uso\", \"Next ou Vite\", \"preciso de SEO nessa tela\", \"SPA ou SSR\", \"que framework web escolho\", \"React, Astro ou Svelte\", \"o backend é Spring Boot, qual front combina\". NÃO acione para escolher stack de backend/arquitetura de servidor (use arquiteto-software) nem quando o stack já está decidido — aí vá direto a design-tokens-gen / web-component."
---

# Frontend Stack Decisor (gerador-decisor)

> (Track web-frontend, proposta 2026-07-07)

Decide, por gatilho, qual stack de frontend web serve o produto e **registra a decisão com o porquê**
(ADR curto). É **decisor**, não scaffolder: não escreve o app — escolhe o caminho e passa o bastão para
`design-tokens-gen` → `web-component` → `web-data-layer`. Vale a regra do Design Read (`designer-ux-ui`):
resolva primeiro a ambiguidade que **mais muda a arquitetura** — aqui, **SEO/indexação pública × app-logado**.

## Objetivo

Cruzar os sinais do produto numa matriz determinística, escolher o stack e emitir um ADR curto
(contexto, decisão, alternativas rejeitadas, consequências). O backend do Jeremias já é Spring Boot
(REST/JSON) — isso pesa na decisão: com API pronta, um **SPA Vite** evita uma 2ª camada de servidor Node.

## Entradas obrigatórias

1. **SEO/indexação pública importa?** A tela precisa ser achada no Google / ter preview ao compartilhar?
2. **App atrás de login ou conteúdo público?** (a variável que mais muda a arquitetura).
3. **Grau de interatividade e volume de client-state.**
4. **Já existe backend?** Aqui: Spring Boot expondo REST/JSON — muda muito a recomendação.

## Entradas opcionais

- Alvo de deploy (edge, estático/CDN, Node), budget de JS, i18n, streaming/RSC, qual stack o time domina.

## Trava obrigatória

- Não decidir sem resolver **SEO × app-logado** e o **grau de interatividade**. Na dúvida, **uma** pergunta
  (a que mais muda a arquitetura), nunca um dump de perguntas.
- Não impor **Next "por padrão"** — é o reflexo dos dados de treino (anti-slop de 1ª ordem); só se o gatilho justificar.

## Leituras obrigatórias (RO-01)

1. O **contrato real do backend** (o Spring Boot expõe REST? base URL, auth?) — não assumir.
2. O `package.json` se já houver algo — não trocar de stack no meio sem novo ADR (RI-01).
3. A **doc real do framework candidato** antes de afirmar recurso ("Astro tem X", "Next faz Y") — nunca
   alucinar capacidade de framework.

## Matriz de decisão (gatilho → stack → porquê)

| Gatilho dominante | Sinais | Stack | Porquê |
|---|---|---|---|
| Conteúdo público indexável (marketing/blog/docs), JS mínimo | SEO crítico, quase estático | **Astro** | HTML-first + islands; entrega quase-zero JS, hidrata só as ilhas interativas |
| App dinâmico **com** SEO + lógica de servidor + rotas full-stack | SEO importa E há RSC/ISR/SSR | **React + Next.js (App Router)** | Server Components + SSR/SSG/ISR; meta-framework maduro |
| App 100% atrás de login, SEO irrelevante, dashboard rico | Autenticado, muito client-state | **Vite + React SPA** | Sem overhead de Node/SSR; o **Spring Boot já entrega o JSON**, o front só consome (`web-data-layer`) |
| Full-stack type-safe, SSR sob demanda, sem meta-framework pesado | Quer TanStack Router/Query nativos, tipos ponta-a-ponta | **TanStack Start** | Roteamento type-safe + streaming SSR sem o peso do Next |
| Time já é Vue / prefere Vue | Ecossistema Vue | **Vue** — **Nuxt** se SSR/SEO, **Vite SPA** se app logado | Mesmo eixo de decisão, ecossistema Vue |
| Bundle mínimo, sem VDOM, interatividade pontual | Performance de bundle é requisito duro | **Svelte** — **SvelteKit** se SEO/rotas | Compila para JS mínimo, sem runtime de VDOM |

> **Escopo dos geradores atuais (track web-frontend, proposta 2026-07-07):** a matriz oferece Astro/Vue/Svelte/Next/TanStack Start, mas os geradores do track hoje (`design-tokens-gen`, `web-component`, `web-data-layer`) **miram React + Vite** (forwardRef, Radix/React Aria, hooks/react-hook-form). Uma escolha **não-React** é decisão válida e **fica registrada no ADR**, mas **exige track próprio** (futuro) — não é coberta pelos geradores de hoje. Não force React se o gatilho pedir outro stack; registre a decisão e sinalize a lacuna.

## Fluxo

1. Coletar os 4 sinais obrigatórios.
2. Cruzar na matriz; empate ⇒ desempatar pelo eixo secundário (interatividade/client-state) e pelo que o time domina.
3. Escrever o **ADR curto**: contexto · decisão · alternativas rejeitadas e por quê · consequências.
4. Handoff declarado: passar a decisão para `design-tokens-gen`.

## Regras de implementação

- Registra decisão (RI-04), não escreve código de app. ADR "Aceito" vira contrato (RI-01).

## Guardrails

- Nunca "Next por padrão" sem o gatilho justificar (anti-slop de 1ª ordem).
- Backend Spring Boot pronto + app logado ⇒ **não** adicionar camada Node SSR só por hábito; SPA Vite consome o REST direto.
- SEO público ⇒ precisa de HTML no servidor (Astro/Next/Nuxt/SvelteKit), **nunca** SPA pura.
- Trocar de stack depois exige **novo ADR declarado** (RI-01) — nada de divergir em silêncio.

## Saída esperada

- Um **ADR curto** (`docs/adr/NNNN-stack-frontend.md` ou o padrão real do projeto) com a decisão e o porquê,
  + handoff declarado para `design-tokens-gen` → `web-component` → `web-data-layer`.

## Referências reais (RO-01)

- shadcn/ui (base de componentes do track) — https://ui.shadcn.com/

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 (ex.: se o produto tem parte pública + área logada, avaliar arquitetura híbrida Astro+ilha React;
se surgir necessidade de SSR num SPA já entregue, registrar ADR de migração incremental antes de reescrever).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (trade-offs de stack, ADR) · `designer-ux-ui` (Design Read, natureza do produto).
- **Vem antes:** `requisitos-descoberta` (natureza do produto, SEO, público).
- **Vem depois:** `design-tokens-gen` → `web-component` → `web-data-layer`; `spec-frontend-web` orquestra a sequência.
- **Não confundir com:** `arquiteto-software` (decide a arquitetura de servidor/dados — aqui só o front) · `spec-frontend-web` (orquestra o track inteiro; este só decide o stack).
