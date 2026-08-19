# javafx-dashboard — Referência extraída: auto-refresh e HoverDetalhe

> Extraído do corpo da SKILL.md em 2026-07-13 (Evolução R1→R2, onda transversal). **Fonte única** destes dois blocos — o corpo da skill só aponta para cá. Complementa (não substitui) `referencia/sigcot-stack.md`, que traz a API real.

## Atualização padrão (SIGCOT) — manual + automática a cada 30 min

Todo painel tem o botão **"Atualizar"** (manual) **e** auto-refresh de **30 min** (scheduler daemon + `Platform.runLater`; `shutdownNow()` ao fechar a janela). Sempre com carimbo **"Atualizado às HH:mm"** que vira **aviso de falha** no `onFailed` — dado velho nunca passa por vivo. Cadência diferente de 30 min só por decisão explícita do usuário.

**Guarda anti-empilhamento — critério checável:** disparo (manual ou automático) com refresh em curso é **ignorado e logado**; durante a prova, o log/contador de refresh ativo mostra **exatamente 1** mesmo clicando "Atualizar" repetidas vezes durante uma carga. Contador > 1 em qualquer momento = guarda quebrada, não está pronto.

## Detalhe sob demanda (hover) — `HoverDetalhe`

Passar o mouse num KPI/card/segmento **traz a lista organizada** por trás do número (cabeçalho + mini-tabela + rodapé-resumo); nível 1 instantâneo em memória, nível 2 assíncrono do banco com cache. É o drill que liga o número à sua origem sem tirar o usuário do panorama.

### 📜 Histórico
- **2026-07-13 — Criação (Evolução R1→R2, onda transversal):** blocos Atualização padrão e HoverDetalhe extraídos do corpo da SKILL.md (anti-sprawl, PADRAO §12.4); guarda anti-empilhamento ganhou critério checável (contador de refresh ativo = 1 durante a prova).
