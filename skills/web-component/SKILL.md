---
name: web-component
description: "Gera um componente de UI cujo COMPORTAMENTO de acessibilidade vem de uma primitiva headless (Radix / Base UI / React Aria), estilizado só por tokens (DTCG→Tailwind v4/CSS vars), com variantes via CVA e uma fronteira a11y invariável (nunca troca button por div, sempre espalha {...props}, contraste ≥4.5:1). Segue o padrão shadcn/ui: você copia e possui o código; puxa props reais via shadcn MCP (anti-alucinação). Acione quando o usuário disser coisas como \"cria o componente Button/Dialog/Select\", \"faz um componente acessível\", \"componente com variantes e CVA\", \"componente shadcn\", \"monta esse input com Radix\", \"componente com forwardRef e tokens\". NÃO acione para definir os tokens (use design-tokens-gen) nem para o data-fetching/estado (use web-data-layer)."
---

# Web Component — a11y headless + tokens + CVA

> (Track web-frontend, proposta 2026-07-07)

Um componente aqui é a soma de três coisas: **comportamento de a11y** de uma primitiva headless
(**Radix** / **Base UI** / **React Aria**), **estilo** só por **tokens** (DTCG→Tailwind v4/CSS vars, de
`design-tokens-gen`) e **variantes** por **CVA** — dentro de uma **fronteira a11y invariável**. Segue o padrão
**shadcn/ui**: você **copia o código e o possui** (Radix + Tailwind + CVA), não instala um pacote fechado.

> **Suposição de stack (track web-frontend, proposta 2026-07-07):** os geradores atuais miram **React + Vite** — `forwardRef`, Radix/Base UI/React Aria e o padrão shadcn são do ecossistema React. Stack não-React exige track próprio (ver `frontend-stack-decisor`).

## Objetivo

Gerar `<Component>.tsx` onde a lógica de teclado/foco/ARIA é da primitiva, o estilo é 100% token, as variantes
são CVA e a **fronteira a11y** é preservada.

## Entradas obrigatórias

1. Qual componente e seu padrão de interação (botão, overlay/dialog, menu, select, tabs, tooltip).
2. Variantes/tamanhos/estados (ex.: `variant: default|destructive|ghost`, `size: sm|md|lg`).
3. Qual primitiva cobre o padrão de a11y (**Radix** p/ overlays/menus/select; **React Aria** p/ casos ricos;
   **Base UI** como alternativa).

## Entradas opcionais

- `asChild`/composição, ícones, RTL, dados reais de props via **shadcn MCP**.

## Trava obrigatória

- **Não escrever à mão** teclado/foco/ARIA quando existe primitiva — usá-la (ela já resolve tab order, focus
  trap, `aria-*`, Esc).
- Não trocar o elemento semântico para "estilizar mais fácil".
- Na dúvida sobre a prop real da primitiva, **consultar o shadcn MCP** (dados reais) — nunca inventar prop (RO-01).

## Leituras obrigatórias (RO-01)

1. O **registry/doc real** da primitiva e do componente shadcn — de preferência via **shadcn MCP** (props reais, anti-alucinação).
2. Os **tokens** do projeto (`design-tokens-gen`) — o estilo sai deles, nunca hex/px de cor solto.
3. Um componente já existente do projeto para casar estilo (variantes, `forwardRef`).

## Convenções obrigatórias

- **shadcn copy-paste:** o código vive no projeto (você o possui e edita); Radix/Base UI/React Aria entram como dependência headless.
- **CVA** para variantes (`cva(base, { variants, defaultVariants })`); classes só com utilities dos tokens do Tailwind v4.
- **`forwardRef` + `{...props}`** sempre; `asChild` quando a primitiva suporta composição.

## Fronteira a11y invariável (nunca cruzar)

Radix/Base UI/React Aria cuidam de **teclado, foco e ARIA**; ao customizar você muda **estilo, nunca a lógica**:

- **Nunca** trocar `<button>` por `<div>` (perde role, foco e teclado nativos).
- **Sempre** espalhar `{...props}` e encaminhar `ref` — engolir `aria-*`/`onKeyDown` quebra o leitor de tela.
- **Contraste ≥ 4.5:1** (texto normal) / 3:1 (grande e ícone); foco **visível** (`focus-visible`), nunca `outline:none` sem substituto.
- **WCAG 2.2 (lei na lente `designer-ux-ui`, fonte única — track web-frontend, proposta 2026-07-07):** alvo de toque **≥ 24×24px CSS** (SC 2.5.8 Target Size Minimum) e **foco não obscurecido** por header/barra fixa ao navegar por teclado (SC 2.4.11 Focus Not Obscured) — garanta-os no componente; numeração e nível AA vivem na lente.
- Estilizar o estado que a primitiva expõe (`data-state`, `data-disabled`), não recriar a máquina de estados.

> **Composição — proibições do Impeccable (via `designer-ux-ui`, proposta 2026-07-07):** modal como **primeira** ideia (esgote inline/progressivo antes) e **grid de cards idênticos** são vetados pela lente; ao gerar overlays/listas, respeite-os — a lei mora no `designer-ux-ui`, não se redefine aqui.

## Fluxo

1. Confirmar componente, variantes, primitiva.
2. Consultar props reais (shadcn MCP) e os tokens.
3. Escrever o componente: primitiva + CVA + tokens, `forwardRef`, `{...props}`.
4. Verificar a fronteira a11y (teclado + axe + contraste).
5. Reportar arquivo + evidência a11y.

## Regras de implementação

- O componente não busca dados nem guarda server-state — isso é do `web-data-layer`. Aqui é a casca visual + a11y.

## Guardrails

- Nunca `div` clicável no lugar de `button`/`a`; nunca `{...props}` omitido; nunca `outline:none` sem foco alternativo.
- Nenhum hex/px de cor solto — só tokens.
- Não reimplementar a11y que a primitiva já dá (fonte de bugs).

## Saída esperada

- `<Component>.tsx` (primitiva + CVA + tokens) com evidência a11y: navegação por teclado + **axe** sem violações + contraste medido.

## Referências reais (RO-01)

- shadcn/ui (copia o código, você o possui) — https://ui.shadcn.com/
- shadcn MCP (props reais, anti-alucinação) — https://ui.shadcn.com/docs/registry/mcp
- **Radix Primitives — Accessibility** (doc oficial: teclado/foco/ARIA por primitiva) — https://www.radix-ui.com/primitives/docs/overview/accessibility
- **WCAG 2.2** (doc oficial W3C: contraste, SC 2.5.8 Target Size, SC 2.4.11 Focus Not Obscured) — https://www.w3.org/TR/WCAG22/
- Fronteira a11y shadcn+Radix — **blog de comunidade** (eastondev), não normativo; confirmar contra Radix/WCAG oficiais acima — https://eastondev.com/blog/en/posts/dev/20260330-shadcn-radix-accessibility/

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 (ex.: extrair um `<Field>` que junta label + erro + `aria-describedby` para todo input;
testes de a11y no CI com axe; documentar variantes num story/preview quando o Design System crescer).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (a11y, estados, contraste, Impeccable) · `dev-senior` (composição, `forwardRef`) · `especialista-seguranca` (não injetar HTML do usuário — XSS).
- **Vem antes:** `design-tokens-gen` (os tokens) · `frontend-stack-decisor` (o stack).
- **Vem depois:** `web-data-layer` (liga o componente a dados) · `testador-real` (Playwright + axe).
- **Não confundir com:** `design-tokens-gen` (define os tokens; aqui se consomem) · `web-data-layer` (estado/dados; aqui é a casca visual + a11y).
