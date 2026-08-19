# Modo Polish Pass — revisão de tela/artefato já existente

(proposta 2026-07-07, inspirado em `impeccable-design-polish` via `nexu-io/open-design`; autor original: time do Impeccable, `pbakaus/impeccable`.)

Use este modo quando a tarefa for **revisar/refinar uma tela que já existe** — diferente do fluxo padrão da lente ("Como operar"), que é desenhar do zero com mockup-first (RO-06).

**Fronteira (RI-04 — não confundir com execução):** este modo é juízo qualitativo da lente, **sem** evidência PASS/FAIL executada — quem prova é a bateria do `testador-real` (ver Rede da skill: "Não confundir com"). Aqui você refina; lá se executa e comprova.

## Definition of Done por etapa
Cada etapa só conta como feita se produzir o artefato descrito — sem o artefato é intenção, não trabalho:

1. **Audit** — inspecione a tela/artefato real (nunca de memória, RO-01). Saída obrigatória: tabela `achado · localização exata · severidade (crítica/alta/média/baixa)` cobrindo hierarquia, espaço, cor, tipo, estados e responsivo.
2. **Critique** — explique, achado a achado, o que está genérico/inconsistente/incompleto e por qual heurística ou lei de UX isso pesa.
3. **Polish** — edite os itens de maior impacto preservando conteúdo, marca e intenção do Jeremias; prefira poucos ajustes decisivos a reforma cosmética ampla.
4. **Animate (quando aplicável)** — motion restrito, só onde melhora feedback/compreensão (nunca decorativo); nunca anima propriedade de layout (ver Leis de motion no catálogo Impeccable); **sempre** com fallback de `prefers-reduced-motion` (web) ou equivalente de "reduzir animações" (desktop) — item obrigatório, não opcional.
5. **Harden** — saída obrigatória: checklist de a11y com **valor medido**, não só "ok"/"não ok" — contraste mínimo real anotado (WCAG 4.5:1/3:1), navegação por teclado/tab order testada na ordem real, foco visível confirmado, rótulos/semântica para leitor de tela (ou label acessível no componente nativo, em JavaFX), e os estados (mín. vazio/carregando/erro) tratados como categoria própria — não como "detalhe faltando" genérico. Cubra também os critérios WCAG 2.2 AA específicos (ver catálogo Impeccable, seção 4).
6. **Live** — prepare para apresentação: QA visual final e lista de próximas ações (RO-07).
