# Checklist de 58 Gates de Slop-Test + Autoavaliação Pré-Emissão

Proveniência: `nutlope/hallmark` (Together AI, MIT) — laudo em `garimpo-lote-5repos-2026-08-26.md` (G5).

## Autoavaliação Pré-Emissão (6 Eixos)
Antes de auditar os gates individuais, pontue o design de 1 a 5 em cada eixo. **Qualquer nota < 3 exige revisão antes de prosseguir:**
- **[A] Filosofia:** Há um propósito e posição clara no layout, ou é apenas uma disposição genérica de caixas?
- **[B] Hierarquia:** Um usuário identifica a ordem primária, secundária e terciária em 2 segundos?
- **[C] Execução:** Detalhes de alinhamento, espessura de linhas, contraste e espaçamento estão impecáveis?
- **[D] Especificidade:** O layout reflete a alma deste produto específico, ou serviria para qualquer empresa genérica?
- **[E] Restrição:** Todo elemento desnecessário, redundante ou puramente decorativo foi eliminado?
- **[F] Variedade:** A estrutura difere categoricamente do último layout gerado neste projeto?

---

## Os 58 Gates Anti-Slop (Toda resposta deve ser "NÃO")

### 1. Visual e Cores
1. A fonte de exibição/título é Inter, Roboto, Open Sans, Poppins ou padrão de sistema? (Use famílias com personalidade tipográfica).
2. Há gradiente roxo-para-azul ou ciano-para-magenta em qualquer lugar — especialmente em textos (`background-clip: text`)? (Proibido).
3. Há grid de 3 colunas iguais com cartões contendo ícone centralizado sobre o título? (Proibido).
4. Há cartões aninhados dentro de outros cartões? (Proibido).
5. Há cartões com bordas laterais grossas coloridas como único destaque? (Proibido).
6. **Hero centralizado total:** O Hero tem 100vh com eyebrow, título, lede e CTA todos empilhados e centralizados no mesmo eixo vertical? (Proibido; quebre o alinhamento com elementos assimétricos).
7. Cores de base são `#000` puro ou `#fff` puro sem tingimento (zero chroma)? (Use OKLCH com neutros levemente tingidos).

### 2. Estrutura e Ritmo
8. A página reutiliza o layout genérico (Hero → 3 features → CTA → Footer) ou repete a macroestrutura da tela anterior?
9. As seções são separadas apenas por espaços vazios idênticos sem variação de ritmo, contraste de fundo ou divisores deliberados?

### 3. Microinterações e Movimento
10. Usa `transition: all` ou `transition-all` indiscriminadamente? (Especifique as propriedades exatas).
11. Usa `hover:scale-105` uniforme em múltiplos elementos não relacionados?
12. Usa transições saltitantes/overshoot (`cubic-bezier` elástico) em botões, modais ou menus funcionais?
13. Um mesmo elemento possui múltiplos efeitos de hover simultâneos (escala + sombra + rotação + cor)?
14. Anima propriedades de layout (`width`, `height`, `margin`, `padding`, `top`, `left`) em vez de `transform` e `opacity`?
15. O anel de foco (`:focus-visible`) tem fade-in lento em vez de aparecer instantaneamente para navegação por teclado?
16. Há toast de sucesso redundante para uma ação cujo efeito visual já é imediatamente visível na tela?
17. Tooltips possuem delay de foco diferente de 0ms? (Foco de teclado deve ser imediato).
18. Conteúdo com rotação automática carece de botão de pausa e pausa ao hover/foco? (WCAG 2.2.2).
19. Há textos com nomes fictícios batidos como "Jane Doe", "John Smith" ou clichês corporativos como "Acme", "Unleash your potential"?

### 4. Implementação e Acessibilidade
20. Falta o carimbo de macroestrutura escolhida na especificação?
21. Houve recaída para o layout padrão de texto corrido sem intenção editorial explícita?
22. Superfícies neutras utilizam cinza sem croma (`oklch(L 0 H)`) em vez de neutro tingido pela matiz da marca?
23. A cor de acento ocupa mais de ~5% da área visível de qualquer viewport? (Acento é para ênfase pontual).
24. Há margens ou paddings arbitrários fora da escala de tokens (múltiplos de 4px)?
25. Blocos de texto de leitura contínua ultrapassam 75 caracteres ou ficam abaixo de 45 caracteres por linha?
26. Elementos interativos deixaram de declarar estados essenciais (`:hover`, `:focus-visible`, `:active`, `:disabled`)?
27. Há animações que não respeitam `@media (prefers-reduced-motion: reduce)`?

### 5. Elementos de Mídia e Ícones
28. Vídeos de demonstração tocam áudio automaticamente ou carecem de poster e prioridade de carregamento adequada?
29. Fundos abstratos utilizam gradientes animados em tela cheia ocupando todo o fundo?
30. **Ícones:** A página mistura bibliotecas de ícones diferentes ou usa emojis (✨, 🚀, ⚡, 🔥) como ícones de cartões e features? (Proibido).
31. Usa animações Lottie genéricas quando SVGs limpos ou formas CSS resolveriam com mais leveza?

### 6. Diversificação e Segurança de Layout
32. Elementos visuais decorativos (`<svg>`, `<canvas>`, divisores) carecem de `aria-hidden="true"`?
33. A página apresenta barra de rolagem horizontal em qualquer largura entre 320px e 1920px? (Use `overflow-x: clip` no `html` e `body`).
34. Efeitos decorativos em títulos (marca-texto, sublinhados) cobrem a linha base incorretamente ou criam borrões ilegíveis?
35. Linhas flexíveis misturando botões e textos falham em alinhar verticalmente no centro (`align-items: center`)?

### 7. Tipografia e Contraste
36. A página utiliza mais de 3 famílias tipográficas distintas? (Máximo 2 famílias: display + corpo, com no máximo 1 outlier para numerais/destaque).
37. Títulos e cabeçalhos utilizam itálico sem propósito editorial real? (Títulos são preferencialmente romanos).
38. Campos de formulário alteram `border-width` ao receber foco, causando salto de layout? (Use `outline` ou `box-shadow`).
39. **Contraste:** Há texto com contraste < 4.5:1 (ou < 3:1 para títulos grandes/ícones) em relação ao fundo computado?
40. Há falhas de texto preto em botão escuro ou texto branco em botão claro (falta de token `--color-accent-ink`)?
41. Seções com fundo escuro esqueceram de inverter a cor dos textos dos componentes filhos?

### 8. Navegação, Rodapé e Responsividade
42. O cabeçalho/nav é o clássico genérico de IA sem personalidade? (Consulte variações N1b a N13).
43. O rodapé é a clássica coluna quadrupla cinza genérica de IA? (Consulte variações Ft1 a Ft8).
44. O Hero requer rolagem em notebooks padrão (1280x800) para que o CTA primário seja visto?
45. Há elementos decorativos sem qualquer conexão semântica com o tema (stickers soltos, cursores flutuantes sem ação)?
46. Há métricas ou estatísticas quantitativas inventadas ("10x mais rápido", "50.000 clientes") sem fonte do usuário?
47. Há molduras desenhadas de navegadores ou celulares falsos em CSS em vez de screenshots reais?
48. Há cores ou fontes inseridas inline sem uso de Design Tokens?
49. Textos de botões ou links de navegação quebram em duas linhas no mobile?
50. Grids com imagens usam `1fr` sem `minmax(0, 1fr)` causando estouro de layout em telas pequenas?
