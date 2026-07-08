# NOTICE — Impeccable (atribuição)

As 7 referências de design nesta pasta são derivadas do projeto **Impeccable**.

- **Projeto:** Impeccable — https://github.com/pbakaus/impeccable · site: https://impeccable.style
- **Autor:** Paul Bakaus
- **Licença:** Apache License 2.0
- **Origem:** o Impeccable, por sua vez, é baseado na skill `frontend-design` original da Anthropic (ver `NOTICE.md` do projeto upstream).

## O que foi importado
As 7 referências de domínio, mantidas no **inglês original** (fonte da verdade), carregadas sob demanda pela lente `designer-ux-ui`:

- `typography.md` — sistemas de tipo, pareamento, escala modular, fluid type, OpenType.
- `color-and-contrast.md` — OKLCH, neutros tingidos, WCAG, light/dark.
- `spatial-design.md` — espaçamento 4pt, grids, hierarquia, container queries, alvos de toque.
- `motion-design.md` — durações 100/300/500, easing, reduced-motion, performance percebida.
- `interaction-design.md` — os 8 estados, focus-visible, dialog/popover, anchor positioning, undo > confirm.
- `responsive-design.md` — mobile-first, pointer/hover, safe-areas, srcset.
- `ux-writing.md` — labels, fórmula de erro, empty states, i18n, consistência.

As **leis de design**, as **proibições absolutas** e o **AI slop test** foram sintetizados (em PT-BR) na própria `SKILL.md` da lente `designer-ux-ui`, para disparo direto.

## Fronteira de uso
O conteúdo do Impeccable é **web-first** (OKLCH, container queries, anchor positioning não existem no CSS do JavaFX). No track Java/JavaFX, vale como **vocabulário de princípio**: a lente decide e o gerador `javafx-theme-tokens` traduz para a realidade do JavaFX (RO-12). Em web (ex.: Embalo/Supabase) o Impeccable se aplica diretamente.

Importado em 2026-06-19.
