# Referência Impeccable — Leis de design, proibições e anti-slop (catálogo completo)

Catálogo de referência opinativo da lente `designer-ux-ui`, carregado sob demanda (não fica no corpo da skill para não custar token todo turno). Base de design de frontend Apache-2.0, `pbakaus/impeccable`. Use para sair do genérico: abaixo está o que o modelo NÃO acerta por padrão.

## Sumário
1. Leis de design (decida com elas)
2. Proibições absolutas (match-and-refuse)
3. Teste anti-"AI slop" (1ª e 2ª ordem)
4. Acessibilidade — critérios WCAG 2.2 AA específicos
5. Fronteira com o gerador `javafx-theme-tokens` (RO-12)
6. Quando aprofundar → qual referência `referencia/impeccable/` ler
7. Proveniência (RO-01)

---

## 1. Leis de design (decida com elas)
- **Cor:** OKLCH, não HSL. Nunca `#000`/`#fff` — tinja todo neutro na direção do hue da marca (chroma 0.005–0.01). Escolha uma *estratégia de cor* (restrained / committed / full palette / drenched) ANTES das cores. "Acento ≤10%" só vale no *restrained*.
- **Tema (light/dark):** nunca por reflexo de categoria. Escreva uma frase da cena física (quem usa, onde, sob que luz, em que humor) e deixe-a forçar a resposta.
- **Tipografia:** medida de 65–75ch; hierarquia por escala + peso (razão ≥1.25 entre passos); evite escalas chapadas.
- **Layout:** varie o espaçamento (ritmo > padding igual em tudo); card é a resposta preguiçosa, e card aninhado é sempre erro; não embrulhe tudo num container.
- **Motion:** não anime propriedades de layout (`width/height/top/left`); ease-out exponencial (quart/quint/expo); sem bounce/elastic.
- **Ousadia concentrada (pepita 2026-07-07, via skill `frontend-design` da Anthropic):** gaste a ousadia num **único elemento assinatura** (um herói, um gráfico, um gesto memorável) e mantenha o resto sóbrio — ousadia espalhada por tudo vira ruído. Reforça o "Teste anti-AI slop" por outro ângulo: lá é *previsibilidade por categoria*; aqui é *concentração × difusão* da ousadia.

## 2. Proibições absolutas (match-and-refuse — se for escrever, reescreva o elemento)
- **Borda lateral colorida** (`border-left/right` > 1px como acento em card/lista/alerta) → borda inteira, fundo tingido, número/ícone à frente, ou nada.
- **Texto em gradiente** (`background-clip: text`) → cor sólida; ênfase por peso/tamanho.
- **Glassmorphism por padrão** · **template "hero-metric"** (número gigante + label + stats + gradiente) · **grid de cards idênticos** · **modal como primeira ideia** (esgote inline/progressivo antes).
- **Sem em dash (—) na copy de UI.** Use vírgula, dois-pontos, ponto ou parênteses.
- **Card arredondado enorme sem motivo** (proposta 2026-07-07, via `open-design`) → varie o raio por hierarquia (raio maior só no elemento de maior destaque) ou justifique pelo conteúdo; card não é resposta default.
- **Fileira de 3 cards de feature idênticos** (mesmo ícone-título-parágrafo repetido) → quebre o padrão de 3, ou diferencie hierarquia/tamanho entre eles conforme importância real.
- **Adjetivo de marketing vazio sem prova ao lado** — lista fechada banida sem métrica/exemplo: "seamless", "next-generation", "revolucionário", "state-of-the-art", "cutting-edge", "world-class" → ou remove o adjetivo, ou acompanha de um número/exemplo concreto que o sustente.

## 3. Teste anti-"AI slop"
Se dá pra olhar a interface e dizer "uma IA fez isso" sem dúvida, falhou. Cheque em dois níveis:
1. **1ª ordem:** dá pra adivinhar tema + paleta só pela categoria? ("observability → dark blue", "saúde → branco + teal", "fintech → navy + dourado", "cripto → neon no preto"). Se sim, é o primeiro reflexo dos dados de treino — refaça a frase da cena e a estratégia de cor.
2. **2ª ordem:** dá pra adivinhar a estética pela categoria + anti-referência? ("ferramenta de IA que não é SaaS-cream → editorial-tipográfica"). Refaça até nenhuma das duas ser óbvia.

## 4. Acessibilidade — critérios WCAG 2.2 AA específicos
(proposta 2026-07-07, via `affaan-m/ECC` — nível AA, verificados contra a numeração oficial; **confirme contra a especificação do W3C antes de tratar como definitivo**, pois critério pode mudar de classificação entre versões):
- **Alvo de toque mínimo 24×24px CSS** (SC 2.5.8 Target Size Minimum).
- **Foco não pode ficar escondido** atrás de header/barra fixa ao navegar por teclado (SC 2.4.11 Focus Not Obscured Minimum).
- **Não pedir o mesmo dado duas vezes** no mesmo fluxo, salvo quando essencial re-confirmar (SC 3.3.7 Redundant Entry).
- **Gesto de arrastar sempre com alternativa de ponteiro único** — clique/toque simples que faça o mesmo que o drag (SC 2.5.7 Dragging Movements).

## 5. Fronteira com o gerador `javafx-theme-tokens` (não quebrar — RO-12)
O Impeccable é **web-first**: OKLCH, container queries e anchor positioning **não existem** no CSS do JavaFX. Aqui a referência é **vocabulário de princípio**; a lente **decide**; o gerador `javafx-theme-tokens` **traduz** para o JavaFX real (tokens declarados em `.root`, `-fx-border-color` com 4 valores TOP/RIGHT/BOTTOM/LEFT, sem hex fixo, sem OKLCH). Em web (Embalo) o Impeccable vale direto.

## 6. Quando aprofundar → qual referência ler (sob demanda)
As 7 referências completas ficam em `referencia/impeccable/` (arquivos reais do cofre; carregue só o necessário):

| Assunto | Arquivo |
|---|---|
| Tipografia, fontes, escala, OpenType, fluid type | `referencia/impeccable/typography.md` |
| Cor, OKLCH, neutros tingidos, WCAG, dark mode | `referencia/impeccable/color-and-contrast.md` |
| Espaço, grid 4pt, hierarquia, container queries, alvos de toque | `referencia/impeccable/spatial-design.md` |
| Motion, durações 100/300/500, easing, reduced-motion | `referencia/impeccable/motion-design.md` |
| 8 estados, focus-visible, dialog/popover, undo > confirm | `referencia/impeccable/interaction-design.md` |
| Responsivo, mobile-first, pointer/hover, safe-areas, srcset | `referencia/impeccable/responsive-design.md` |
| UX writing, labels, fórmula de erro, empty states, i18n | `referencia/impeccable/ux-writing.md` |

## 7. Proveniência (RO-01 — atribuição obrigatória)
- Referência Impeccable (`referencia/impeccable/`): projeto **Impeccable**, autor **Paul Bakaus** (`pbakaus/impeccable`, Apache-2.0), por sua vez baseado na skill oficial `frontend-design` da Anthropic. Importado em 2026-06-19 (ver `NOTICE.md` da pasta).
- Passo "Leitura de briefing" e Modo "Polish Pass" (2026-07-07): agregados via `nexu-io/open-design` (catálogo de skills, 75k+ estrelas) — autores originais **Leonxlnx** (`Leonxlnx/taste-skill`, "Leitura de briefing") e o próprio time do Impeccable (`pbakaus/impeccable`, "Polish Pass"). Cite sempre o autor original, não só o agregador.
