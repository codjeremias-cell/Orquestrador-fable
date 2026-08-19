---
name: frontend-stack-decisor
description: "Decide o stack de frontend web por gatilho — SEO e indexação pública, app atrás de login, conteúdo estático versus interatividade pesada, backend já existente — entre React+Next.js, Vite SPA, Astro, Svelte/SvelteKit, Vue/Nuxt ou TanStack Start, e registra a decisão num ADR curto. É decisor, não escreve o app. Acione com \"qual stack de frontend eu uso\", \"Next ou Vite\", \"preciso de SEO nessa tela\", \"SPA ou SSR\", \"que framework web escolho\", \"React, Astro ou Svelte\", \"o backend é Spring Boot, qual front combina\"."
---

# Frontend Stack Decisor (gerador-decisor)

> Track web-frontend — medido com juiz cego em **2026-07-09** (0,14 → 1,00; `spec-frontend-web/evals/placar-baseline.md`) e roteado nominalmente por `spec-projeto-completo`.

Decide, por gatilho, qual stack de frontend web serve o produto e **registra a decisão com o porquê**
(ADR curto). É **decisor**, não scaffolder: não escreve o app — escolhe o caminho e passa o bastão para
`design-tokens-gen` → `web-component` → `web-data-layer`. Vale a regra do Design Read (`designer-ux-ui`):
resolva primeiro a ambiguidade que **mais muda a arquitetura** (o gate SEO × app-logado: Trava).

## Objetivo

Cruzar os sinais do produto numa matriz determinística, escolher o stack e emitir um **ADR curto**
(itemização: Fluxo, passo 3). O backend do Jeremias já é Spring Boot (REST/JSON) — API pronta
favorece **SPA Vite** sem 2ª camada de servidor Node (porquê completo: matriz).

## Entradas obrigatórias

1. **SEO/indexação pública importa?** A tela precisa ser achada no Google / ter preview ao compartilhar?
2. **App atrás de login ou conteúdo público?** (o gate da Trava).
3. **Grau de interatividade e volume de client-state.**
4. **Já existe backend?** Aqui: Spring Boot expondo REST/JSON — muda muito a recomendação.

## Entradas opcionais

- Alvo de deploy (edge, estático/CDN, Node), budget de JS, i18n, streaming/RSC, qual stack o time domina.

## Trava obrigatória

- Não decidir sem resolver **SEO × app-logado** e o **grau de interatividade**. Na dúvida, **uma** pergunta
  (a que mais muda a arquitetura), nunca um dump de perguntas.
- Não impor **Next "por padrão"** — é o reflexo dos dados de treino (anti-slop de 1ª ordem); só se o gatilho justificar.

## Leituras obrigatórias (RO-01)

Por que ler antes de decidir: afirmar recurso de framework de memória ("Astro tem X") ou assumir o contrato do backend leva a um ADR construído sobre alucinação — o erro só aparece na implementação.

1. O **contrato real do backend** (o Spring Boot expõe REST? base URL, auth?) — não assumir.
2. O `package.json` se já houver algo (troca de stack: novo ADR — RI-01, ver Guardrails).
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

> **Escopo dos geradores atuais (track web-frontend, medido em 2026-07-09):** a matriz oferece Astro/Vue/Svelte/Next/TanStack Start, mas os geradores do track hoje (`design-tokens-gen`, `web-component`, `web-data-layer`) **miram React + Vite** (forwardRef, Radix/React Aria, hooks/react-hook-form). Uma escolha **não-React** é decisão válida e **fica registrada no ADR**. A rota **vanilla + Supabase + PWA já tem executor no catálogo: `web-vanilla-supabase-pwa`**. Astro/Vue/Svelte/Next/TanStack Start seguem **sem gerador** — escolha válida, mas o track não existe hoje. Não force React se o gatilho pedir outro stack; registre a decisão e sinalize a lacuna quando ela for real.

**Caso real do Jeremias (few-shot):** carregue `referencia-caso-real-embalo.md` — o **Embalo** (app em produção, Vercel+Play Store) é a linha que FALTA nesta matriz: **vanilla JS + Supabase + PWA, sem build**. A matriz atual empurraria pra Vite+React SPA, mas o Jeremias shipou sem framework e deu certo — logo React SPA não é o piso automático de app logado. Quando os sinais baterem (dev solo, mobile-first, sem SEO, sem apetite de build), ofereça o caminho vanilla+BaaS+PWA como alternativa de 1ª classe — e ele **já tem executor**: `web-vanilla-supabase-pwa`. Expande o decisor, não os geradores React (RO-01/RI-01).

## Fluxo

1. Coletar os 4 sinais obrigatórios.
2. Cruzar na matriz; empate ⇒ desempatar pelo eixo secundário (interatividade/client-state) e pelo que o time domina.
3. Escrever o **ADR curto**: contexto · decisão · alternativas rejeitadas e por quê · consequências.
4. Handoff declarado: passar a decisão para `design-tokens-gen`.

## Exemplo de ADR (template mínimo)

O ADR não é burocracia: sem "alternativas rejeitadas e por quê" não há registro de decisão, só uma escolha sem rastro que ninguém consegue revisar depois.

```markdown
# ADR 0007 — Stack de frontend: Vite + React SPA

- Status: Aceito · Data: 2026-07-20
- Contexto: App 100% atrás de login, sem SEO. Backend Spring Boot já expõe REST/JSON (auth por JWT).
  Dashboard com muito client-state.
- Decisão: Vite + React SPA (sem camada Node/SSR).
- Alternativas rejeitadas:
  - Next.js — SSR/RSC não agregam sem SEO e adicionam uma 2ª camada de servidor desnecessária.
  - Astro — foco em conteúdo estático; não é o perfil de dashboard interativo.
- Consequências: front consome o JSON via web-data-layer; sem custo de servidor Node;
  se surgir necessidade pública/SEO, registrar novo ADR (Guardrails).
```

## Regras de implementação

- Registra decisão (RI-04), não escreve código de app. ADR "Aceito" vira contrato (RI-01).

## Guardrails

- Backend pronto + app logado ⇒ **não** adicionar camada Node SSR por hábito — **SPA Vite** (célula da matriz).
- SEO público ⇒ precisa de HTML no servidor (Astro/Next/Nuxt/SvelteKit), **nunca** SPA pura.
- Trocar de stack depois exige **novo ADR declarado** (RI-01) — nada de divergir em silêncio.

## Verificação / Checklist final

Antes de fechar, confira — um ADR incompleto é uma decisão que não se sustenta na revisão:
- [ ] **Gate resolvido:** SEO × app-logado decidido explicitamente (não deixado no ar).
- [ ] **Backend confirmado**, não presumido: contrato REST/base URL/auth checados (Leituras obrigatórias 1).
- [ ] **Célula da matriz justificada:** o stack escolhido corresponde ao gatilho dominante real dos 4 sinais.
- [ ] **Não é Next por hábito:** se caiu em Next, há gatilho de SEO/RSC que o justifique (senão, anti-slop).
- [ ] **ADR completo:** contexto · decisão · **alternativas rejeitadas com porquê** · consequências.
- [ ] **Lacuna de track sinalizada** só se a escolha for não-React **e sem executor** (Astro/Vue/Svelte/Next/TanStack); vanilla+Supabase+PWA não é lacuna — o handoff é `web-vanilla-supabase-pwa`.
- [ ] **Handoff declarado** para `design-tokens-gen` → `web-component` → `web-data-layer`.

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
- **Vem depois:** rota React+Vite → `design-tokens-gen` → `web-component` → `web-data-layer`; rota vanilla+Supabase+PWA → `web-vanilla-supabase-pwa`; `spec-frontend-web` orquestra a sequência.
- **Não confundir com:** `arquiteto-software` (decide a arquitetura de servidor/dados — aqui só o front) · `spec-frontend-web` (orquestra o track inteiro; este só decide o stack).

### 📜 Histórico
- **2026-08-11 — Epígrafe alinhada ao track (T36, conferência do lote).** A skill ainda dizia "proposta 2026-07-07" em dois pontos depois que `spec-frontend-web` já havia passado ao estado medido (juiz cego, 2026-07-09), deixando **o mesmo track com dois estados no catálogo**. Achado da conferência final do lote, fora do escopo dos dois agentes que editaram cada lado — que é justamente o defeito que esta campanha existe para matar. Proveniência: `_auditoria/zelador-inventario-2026-08-10.md`.
- **2026-08-11 — Ponteiro morto: o "track futuro" já existe (inventário do zelador, `_auditoria/zelador-inventario-2026-08-10.md`, ação ATUALIZAR 15).** `web-vanilla-supabase-pwa` está no disco e na listagem — verificado. A nota "Escopo dos geradores atuais" e o few-shot do Embalo deixaram de mandar a rota vanilla+Supabase+PWA para um track inexistente e passaram a nomear o executor; a ressalva de que Astro/Vue/Svelte/Next/TanStack Start seguem sem gerador foi preservada. "Vem depois" ganhou a rota vanilla, e o item de checklist sobre lacuna passou a exigir "não-React **e sem executor**" — antes marcava lacuna falsa. Matriz de decisão intacta.
- **2026-07-20 — Verificação + exemplo:** adicionados seção "Verificação / Checklist final" e "Exemplo de ADR (template mínimo)"; fronteira reforçada na description; leituras obrigatórias com o porquê. +~30 linhas (sem references — matriz e caso Embalo permanecem no corpo por serem critério de decisão).
- **2026-07-18 — Caso real (few-shot do stack REAL do Jeremias):** criada `referencia-caso-real-embalo.md` — o Embalo (vanilla+Supabase+PWA, em produção) adiciona à matriz a linha no-build+BaaS+PWA que faltava; prova que React SPA não é piso automático de app logado. Sinaliza a lacuna de track próprio (candidato: skill `web-vanilla-supabase-pwa`). Degrau §6.10: 2 (referência nova). Notas em `rodadas/onda-fewshots-2026-07-18-notas.md`.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens C24, C25, C26, C27, C28; −1 linha.
