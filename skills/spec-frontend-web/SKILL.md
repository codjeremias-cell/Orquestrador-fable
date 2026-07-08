---
name: spec-frontend-web
description: "Orquestra a construção do frontend web de ponta a ponta, espelhando spec-projeto-completo mas focado no front: requisitos/descoberta → mockups (designer-ux-ui) → escolha de stack (frontend-stack-decisor) → tokens (design-tokens-gen) → componentes (web-component) → camada de dados (web-data-layer) → testador (Playwright+axe), iterando com o Comitê de Lentes até nota ≥9. Acione quando o usuário disser coisas como \"monta o frontend completo\", \"constrói a web app inteira no front\", \"do requisito à tela ponta a ponta no front\", \"orquestra o frontend web\", \"faz todo o front dessa feature\". Se o alvo for o sistema inteiro (backend+front+deploy), prefira spec-projeto-completo. NÃO acione para uma etapa isolada — use a skill específica (frontend-stack-decisor, design-tokens-gen, web-component ou web-data-layer)."
---

# Spec — Frontend Web (orquestrador do track web-frontend)

> (Track web-frontend, proposta 2026-07-07)

Espelha o `spec-projeto-completo`, mas restrito ao **frontend web**: conduz, em ordem determinística, do
requisito à tela testada, delegando às skills do track e validando cada gate. Não duplica o trabalho das
filhas. Backend assumido pronto (track `springboot-*` expondo REST/JSON) — este orquestrador **consome** esse
contrato, não o constrói.

## Objetivo

Entregar um frontend web de ponta a ponta — requisitos → design → stack → tokens → componentes → dados →
testes — aderente às [[REGRAS-DE-OURO]] (RI + RO universais; RO-SB4/SB6 do backend quando o contrato/tokens tocam o Spring Boot).

## Entradas obrigatórias

1. A feature/produto de front e seus usuários.
2. Natureza (SEO público × app logado) e o contrato do backend (REST/JSON do Spring Boot) — ou autorização para descobrir/propor.
3. Se inclui telas novas (mockup-first, RO-06).

## Entradas opcionais

- Restrições (deploy, i18n, budget de JS), design já existente, nota de corte diferente de 9.

## Validação do catálogo

Confirmar que existem as filhas: `requisitos-descoberta` · `designer-ux-ui` · `frontend-stack-decisor` ·
`design-tokens-gen` · `web-component` · `web-data-layer` · `testador-real` · `auditor-responsabilidades`.
Faltando uma crítica, **parar** e dizer qual e para qual papel.

## Sequência determinística

Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** `requisitos-descoberta` → escopo/telas do MVP. *Gate: corte aprovado.*
2. **Design (mockup-first, RO-06).** `designer-ux-ui` → Design Read + fluxos + mockups com todos os estados (vazio/carregando/erro). *Gate: mockups aceitos antes de qualquer código.*
3. **Stack.** `frontend-stack-decisor` → ADR do stack (SEO×app-logado; backend pronto ⇒ evitar Node SSR à toa). *Gate: ADR registrado.*
4. **Tokens.** `design-tokens-gen` → `tokens.dtcg.json` + `@theme` do Tailwind v4, contraste ≥ 4.5:1. *Gate: tokens gerados, sem hex solto.*
5. **Componentes.** `web-component` por componente (primitiva a11y + CVA + tokens, fronteira a11y invariável). *Gate: axe sem violações + teclado ok.*
6. **Dados.** `web-data-layer` (TanStack Query + Zustand/Jotai + Zod único, contrato do DTO real). *Gate: resposta validada pelo schema; error state tratado.*
7. **Testes de verdade.** `testador-real` executa **Playwright + axe** (fluxos, a11y, estados). *Gate: relatório datado sem FAIL crítico.*
8. **Iteração com o Comitê.** As lentes (`designer-ux-ui`, `dev-senior`, `especialista-seguranca`, `qa-usabilidade`) avaliam; **repetir 4–7 até nota ≥ 9** ou esgotar as rodadas. Iteração multi-modelo pesada ⇒ delegar ao `orquestrador-fable`. *Gate: nota ≥ 9 registrada.*
9. **Gate final.** `auditor-responsabilidades` audita RI/RO e evidências → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (mockup amarra o componente; DTO amarra o schema; relatório do testador alimenta o auditor) — nada de etapa decorativa.
- Backend Spring Boot é **contrato**, não é reescrito aqui (RO-SB4: o front consome o record de leitura; RO-SB6: tokens de cor).
- Segredo nunca no bundle (só `VITE_` público); **server-state nunca em store global**.
- Pedido pequeno não vira burocracia: etapas puláveis são puladas **declaradamente** (ex.: sem SEO, sem stack novo), nunca em silêncio.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Mockup não aprovado; contrato do backend ambíguo; falta de skill filha crítica.
- Nota do Comitê < 9 ao fim das rodadas.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas executadas e skills usadas · arquivos criados (caminhos exatos — RO-03) · evidências
por gate (mockups aceitos, ADR de stack, tokens, axe/Playwright, nota do Comitê) · pendências e limitações ·
**2–3 sugestões de evolução (RO-07)** · veredito do `auditor-responsabilidades`.

## Saída esperada

- Frontend web funcional ponta a ponta — stack decidido (ADR), tokens, componentes a11y, camada de dados tipada —
  com **nota do Comitê ≥ 9** e relatório do testador sem FAIL crítico.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (mockup, tokens, a11y) · `dev-senior` (implementação) · `especialista-seguranca` (XSS/CSP, env `VITE_`) · `qa-usabilidade`/`auditor-responsabilidades` (fechamento) · todas via Comitê.
- **Vem antes:** `spec-projeto-completo` (quando o pedido é o sistema inteiro, ele chama este para o front) · o track `springboot-*` (contrato do backend).
- **Vem depois:** o testador do projeto (bateria Playwright+axe) · `docs-projeto` · deploy do front.
- **Não confundir com:** `spec-projeto-completo` (ciclo inteiro, qualquer plataforma) · `spec-springboot-crud-feature` (a feature no backend) · `orquestrador-fable` (loop multi-modelo de execução; este é sequência de skills do front).
