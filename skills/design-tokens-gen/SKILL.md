---
name: design-tokens-gen
description: "Gera um token-system NOMEADO em formato W3C DTCG (cor em OKLCH com neutros tingidos, escala tipográfica com papéis, radius, sombra) e o traduz para o bloco @theme do Tailwind v4, onde cada token vira utility + CSS var. Acione quando o usuário disser coisas como \"gera os design tokens\", \"cria o token system\", \"define a paleta em DTCG\", \"tokens pro Tailwind v4\", \"monta o @theme\", \"escala tipográfica e cores como tokens\", \"contrato de tokens design pra código\". Reusa o loop anti-slop e a estratégia de cor da lente designer-ux-ui (não os duplica). NÃO acione para decidir a experiência/estética em si (use designer-ux-ui) nem para o componente visual (use web-component)."
---

# Design Tokens Gen — W3C DTCG → Tailwind v4 @theme

> (Track web-frontend, proposta 2026-07-07)

Produz um **token-system nomeado** (nunca genérico) no formato **W3C DTCG** e o traduz para o `@theme` do
**Tailwind v4** — onde cada token vira utility + CSS var. É a materialização do "tokens = contrato entre
design e código" da lente `designer-ux-ui`: aquela **decide** a estética (estratégia de cor, cena light/dark,
ousadia concentrada); este **gera** o artefato. Não reexplica o anti-slop — **invoca-o**.

## Objetivo

Gerar `tokens.dtcg.json` (fonte da verdade) + o `@theme` correspondente, cobrindo paleta (OKLCH), escala
tipográfica **com papéis** (display/heading/body/label/caption), radius e sombra — em sincronia (uma fonte gera a outra).

## Entradas obrigatórias

1. A **decisão estética** do `designer-ux-ui` — estratégia de cor (restrained/committed/full/drenched), frase
   da cena (light/dark), vibe/público — OU autorização para propô-la (aí passa pelo Design Read antes).
2. Hue/base da marca. Light, dark ou ambos.
3. Papéis tipográficos e famílias.

## Entradas opcionais

- Motion, breakpoints, aliases semânticos extra (success/warning/danger), fonte fluida (clamp).

## Trava obrigatória

- Não gerar tokens **genéricos** ("blue-500 default", `#3b82f6`) — é AI slop de 1ª ordem. Exigir a
  **estratégia de cor** e a **frase da cena** do `designer-ux-ui` **antes**; se não vieram, rodar o loop
  anti-slop primeiro (**token-system nomeado → auto-crítica → só então codar**) — não pular.
- **Fonte única das leis de cor e tipografia (track web-frontend, proposta 2026-07-07):** OKLCH, neutro tingido (chroma 0.005–0.01), razão tipográfica ≥ 1.25 e as 4 estratégias (restrained/committed/full/drenched) são da lente `designer-ux-ui`/Impeccable — esta skill **não as redefine**, só as **operacionaliza** em DTCG→`@theme`. Ex.: "neutro nunca `#000`/`#fff` puro" entra no `$value` do token, não vira regra própria.

## Leituras obrigatórias (RO-01)

1. A spec real do **W3C DTCG** (formato `$value`/`$type`/`$description`, grupos, aliasing `{grupo.token}`) — não inventar a sintaxe.
2. A doc real do **Tailwind v4 `@theme`** (namespaces `--color-*`, `--font-*`, `--text-*`, `--radius-*`, `--shadow-*`
   viram utilities e CSS vars) — CSS-first, sem `tailwind.config.js`.
3. O `tokens.css`/tema já existente do projeto, se houver — evoluir, não recriar do zero.

## Convenções obrigatórias

- **DTCG:** cada token é `{ "$value": ..., "$type": "color|dimension|fontFamily|shadow|...", "$description": ... }`;
  agrupar por semântica; **aliasing** para tokens semânticos (`color.text.default` → `{color.neutral.900}`).
  Nomes **semânticos** (papel), não literais de cor.
- **Cor:** cada cor vira token DTCG `$type: color` com `$value` em **OKLCH** (escala por luminância, neutros tingidos) — operacionaliza a regra do `designer-ux-ui`, não a redefine.
- **Tipografia com papéis:** `font.role.display / heading / body / label / caption`, cada um com size + line-height + weight;
  a **razão ≥ 1.25 entre passos** é operacionalização da regra do `designer-ux-ui` (a lei mora na lente), aqui virando os tokens `--text-*`.
- **Tailwind v4:** cada token DTCG → uma CSS var em `@theme { --color-brand: oklch(...); --text-body: ...; --radius-md: ...; }`.
  DTCG é a fonte; o `@theme` é derivado — manter em sincronia (idealmente por script).

## Fluxo

1. Ler/confirmar a decisão estética (ou rodar o loop anti-slop).
2. Escrever `tokens.dtcg.json` nomeado (paleta OKLCH, tipografia com papéis, radius, sombra).
3. Traduzir para o `@theme` do Tailwind v4 (CSS vars/utilities).
4. Verificar contraste ≥ 4.5:1 (texto normal) / 3:1 (grande) nos pares texto/fundo.
5. Reportar arquivos + suposições.

## Regras de implementação

- O DTCG é a única fonte; o `@theme` nunca é editado à mão de forma que divirja do JSON.

## Guardrails

- **Sem hex solto** fora dos tokens (casa com o backend RO-SB6 e o universal "tokens de cor").
- **Respeita (não redefine) a lei de cor do `designer-ux-ui`:** sem `#000`/`#fff` puro, sem paleta adivinhável pela categoria (anti-slop de 1ª ordem).
- Contraste **medido**, não presumido.
- DTCG e `@theme` nunca divergem.

## Saída esperada

- `tokens.dtcg.json` (fonte) + bloco `@theme` no CSS de entrada do Tailwind v4 (ex.: `app.css`/`globals.css`),
  com contraste verificado como evidência.

## Referências reais (RO-01)

- W3C DTCG (rascunho/draft — a própria URL é `/drafts/`; confirmar status na data) — https://www.designtokens.org/tr/drafts/format/
- Tailwind v4 `@theme` (CSS-first, tokens viram utilities e CSS vars) — https://tailwindcss.com/docs/theme
- Loop anti-slop (não duplicar; mora no `designer-ux-ui`) — https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 (ex.: gerar dark mode por override de tokens semânticos, não nova paleta; script que valida
contraste no CI; camada de tokens de componente sobre os tokens semânticos quando o Design System crescer).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (decide estética, estratégia de cor e cena; dona do anti-slop) · `dev-senior` (tokens como contrato no código).
- **Vem antes:** `designer-ux-ui` (Design Read + decisão de cor/tipografia) · `frontend-stack-decisor` (o stack define onde o CSS de entrada mora).
- **Vem depois:** `web-component` (consome os tokens; nunca hex solto).
- **Não confundir com:** `designer-ux-ui` (aquela **decide** a estética; esta **gera** o JSON + CSS) · `javafx-theme-tokens` (mesmo papel no track desktop JavaFX — sem OKLCH/@theme, ver RO-12).
