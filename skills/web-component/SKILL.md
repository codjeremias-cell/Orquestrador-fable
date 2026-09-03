---
name: web-component
description: "Gera um componente de UI cujo COMPORTAMENTO de acessibilidade vem de uma primitiva headless (Radix, Base UI ou React Aria), estilizado só por tokens (DTCG para Tailwind v4 e CSS vars), com variantes via CVA e uma fronteira de acessibilidade invariável. Acione com \"cria o componente Button/Dialog/Select\", \"faz um componente acessível\", \"componente com variantes e CVA\", \"componente shadcn\", \"monta esse input com Radix\", \"componente com forwardRef e tokens\". NÃO acione para definir os tokens (use design-tokens-gen) nem para o data-fetching/estado (use web-data-layer)."
argument-hint: "[NomeDoComponente]"
---

# Web Component — a11y headless + tokens + CVA

> (Track web-frontend, proposta 2026-07-07)

Um componente aqui é a soma de três coisas: **comportamento de a11y** de uma primitiva headless
(**Radix** / **Base UI** / **React Aria**), **estilo** só por **tokens** (DTCG→Tailwind v4/CSS vars, de
`design-tokens-gen`) e **variantes** por **CVA** — dentro de uma **fronteira a11y invariável**.

> **Suposição de stack:** os geradores atuais miram **React + Vite**; stack não-React é decisão válida mas exige track próprio — escopo completo no `frontend-stack-decisor`.

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
- Trocar o elemento semântico para "estilizar mais fácil" → **parar** e manter o nativo (RO-FE3 — ver Fronteira a11y).
- Na dúvida sobre a prop real da primitiva, **consultar o shadcn MCP** (dados reais) — nunca inventar prop (RO-01).

## Leituras obrigatórias (RO-01)

1. O **registry/doc real** da primitiva e do componente shadcn — de preferência via **shadcn MCP** (regra anti-invenção de prop: Trava).
2. Os **tokens** do projeto (`design-tokens-gen`) — o estilo sai deles (RO-FE4, ver Convenções).
3. Um componente já existente do projeto para casar estilo (variantes, `forwardRef`).

## Convenções obrigatórias

- **shadcn copy-paste:** o código vive no projeto (você o possui e edita); Radix/Base UI/React Aria entram como dependência headless.
- **CVA** para variantes (`cva(base, { variants, defaultVariants })`); classes só com utilities dos tokens do Tailwind v4 (RO-FE4).
- **`ref` como prop + `{...props}`** sempre (React ≥19: `ref` é prop comum e `forwardRef` deixou de ser
  necessário — a doc oficial já o dá como a depreciar; em React 18, `forwardRef`); `asChild` quando a
  primitiva suporta composição.
- **Microinterações físicas táteis (pepita JK1):** botões e controles recebem feedback com `active:scale-[0.96] transition-transform` (nunca `transition: all`); contadores e valores dinâmicos usam `tabular-nums` para zerar layout shift; alvo de toque mínimo de 40×40px em desktop e 44×44px em touch.

## Fronteira a11y invariável (RO-FE3 — nunca cruzar)

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

## Exemplo (entra → sai)

> Pedido: *"cria o componente Button com variantes default|destructive|ghost e tamanhos sm|md|lg, acessível"*.
>
> Saída (props exatas da primitiva confirmadas no **shadcn MCP**; cores só dos tokens):

```tsx
type ButtonProps = React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & { asChild?: boolean };

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium " +
  "focus-visible:outline-none focus-visible:ring-2 disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground",
        ghost: "hover:bg-accent hover:text-accent-foreground",
      },
      size: { sm: "h-9 px-3", md: "h-10 px-4", lg: "h-11 px-6" },
    },
    defaultVariants: { variant: "default", size: "md" },
  }
);

function Button({ className, variant, size, asChild = false, ref, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : "button"; // Slot = composição do Radix (asChild)
  return <Comp ref={ref} className={cn(buttonVariants({ variant, size }), className)} {...props} />;
}
```

Por que assim: o elemento nativo é `<button>` (não `div`), então role/foco/teclado vêm de graça; `ref` e
`{...props}` chegam ao nó real (não engolimos `aria-*`/`onClick`) — no React ≥19 `ref` entra como prop
comum (`React.ComponentProps<"button">` já o inclui), sem `forwardRef`; a cor é só token (`bg-primary`…), nunca hex;
o foco é visível (`focus-visible:ring-2`) e a altura mínima (`h-9` = 36px) respeita o alvo ≥24×24px.

## Regras de implementação

- O componente não busca dados nem guarda server-state — isso é do `web-data-layer`. Aqui é a casca visual + a11y.

## Guardrails

- `div` clicável / `{...props}` omitido / `outline:none` — a **Fronteira a11y** vale integralmente (RO-FE3).
- Nenhum hex/px de cor solto — só tokens (RO-FE4).

## Saída esperada

- `<Component>.tsx` (primitiva + CVA + tokens) com evidência a11y: navegação por teclado + **axe** sem violações + contraste medido.

## Verificação / Checklist final

Não basta "parece pronto" — prove a fronteira a11y (é o único motivo de a skill existir):

- **Teclado:** Tab/Shift+Tab alcança tudo, Enter/Espaço aciona, Esc fecha overlay; foco **visível** em cada estado (sem `outline:none` órfão).
- **axe** (ex.: Playwright + axe) sem violações no componente isolado.
- **Contraste** medido ≥ 4.5:1 (texto) / 3:1 (grande e ícone); **alvo ≥ 24×24px**; foco não obscurecido por barra fixa.
- **DOM real:** inspecionar e confirmar `<button>`/nó semântico nativo (não `div`) e que `ref`/`{...props}` chegaram nele.
- **Só tokens:** nenhuma cor em hex/rgb solta nas classes.

## Referências reais (RO-01)

- shadcn/ui — https://ui.shadcn.com/
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

### 📜 Histórico
- **2026-08-27 — Microinterações físicas em componentes de UI (garimpo jakubkrehel 2026-08-27 · JK1; degrau §6.10: 1 — só edição).** Adiciona às Convenções obrigatórias o feedback de clique tátil com `active:scale-[0.96] transition-transform` (banindo `transition: all`), números tabulares em contadores dinâmicos e área mínima de toque de 40×40px/44×44px. Proveniência: `skills/make-interfaces-feel-better/SKILL.md` de `github.com/jakubkrehel/make-interfaces-feel-better` (MIT) — laudo em `garimpo-lote-9-fontes-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-11 — React ≥19: `ref` como prop no lugar de `forwardRef`:** Convenções bullet 3 e o few-shot do Button reescritos sem `forwardRef` (`function Button({ ..., ref, ...props })`), mantendo `cva`, `Slot`/`asChild` e o *"Por que assim"*. **Guardrails e a Fronteira a11y invariável (RO-FE3) não mudaram** — o invariante segue sendo `ref` e `{...props}` chegando ao nó real. Fato externo **confirmado antes de editar** (RO-01) na doc oficial React: *"In React 19, `forwardRef` is no longer necessary. Pass `ref` as a prop instead. `forwardRef` will be deprecated in a future release."* (react.dev/reference/react/forwardRef). Proveniência: inventário do zelador de 2026-08-10, ATUALIZAR item 10 (RI-04). `description` **intocada**: "componente com forwardRef e tokens" é frase-gatilho medida. Ficaram fora do escopo do item, e seguem dizendo `forwardRef`: Leituras obrigatórias 3 e Fluxo passo 3.
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens C18, C19, C20, C21, C22, C23; −2 linhas.
- **2026-07-20 — Polimento de autoria:** gatilho `when_to_use` + `argument-hint`; +few-shot canônico (CVA/`forwardRef`/`Slot`, com o *porquê* da fronteira) e +checklist de Verificação a11y explícito. Descrição e convenções preservadas.
