---
name: spec-frontend-web
description: "Orquestra a construção do FRONTEND WEB de ponta a ponta, com o backend assumido pronto: requisitos, mockups, escolha de stack, tokens de design, componentes, camada de dados e testes — o espelho de spec-projeto-completo restrito ao front. Acione com \"monta o frontend completo\", \"constrói a web app inteira no front\", \"do requisito à tela ponta a ponta no front\", \"orquestra o frontend web\", \"faz todo o front dessa feature\", \"consome essa API REST numa SPA React/Vue\". NÃO acione fora disso — se o alvo é o sistema INTEIRO (backend + front + deploy), prefira spec-projeto-completo; se é a feature no BACKEND Spring Boot, spec-springboot-crud-feature. NÃO acione para etapa isolada — use frontend-stack-decisor, design-tokens-gen, web-component ou web-data-layer."
---

# Spec — Frontend Web (orquestrador do track web-frontend)

> Track web-frontend — medido com juiz cego em **2026-07-09** (0,14 → 1,00; `evals/placar-baseline.md`) e roteado nominalmente por `spec-projeto-completo`.

Espelha o `spec-projeto-completo`, mas restrito ao **frontend web**: conduz, em ordem determinística, do
requisito à tela testada, aplicando o método das skills do track e validando cada gate. Não duplica o trabalho das
filhas. Backend assumido pronto (track `springboot-*` expondo REST/JSON) — este orquestrador **consome** esse
contrato, não o constrói.

## Quando usar / Quando NÃO usar

Use **esta** quando o trabalho é o **frontend web** e o backend já existe (ou o contrato REST está definido). Se a fronteira for outra:

- Sistema **inteiro** (backend + front + deploy juntos) → `spec-projeto-completo` (ele chama esta para o front).
- Trabalho no **backend** (entidade, serviço, controller, template Thymeleaf) → `spec-springboot-crud-feature`.
- Só **uma etapa** do front (só o stack, só os tokens, só um componente, só a camada de dados) → `frontend-stack-decisor`, `design-tokens-gen`, `web-component` ou `web-data-layer`.

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

> **Invoque, não descreva.** Cada passo abaixo que cita uma skill exige
> **carregá-la pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** Carregue a skill `requisitos-descoberta` (ferramenta Skill — invoque, não descreva) → escopo/telas do MVP. *Gate: corte aprovado.*
2. **Design (mockup-first, RO-06).** Carregue a skill `designer-ux-ui` (ferramenta Skill — invoque, não descreva) → Design Read + fluxos + mockups com todos os estados (vazio/carregando/erro). *Gate: mockups aceitos antes de qualquer código.*
3. **Stack.** Carregue a skill `frontend-stack-decisor` (ferramenta Skill — invoque, não descreva) → ADR do stack (SEO×app-logado; backend pronto ⇒ evitar Node SSR à toa). *Gate: ADR registrado.*
4. **Tokens.** Carregue a skill `design-tokens-gen` (ferramenta Skill — invoque, não descreva) → `tokens.dtcg.json` + `@theme` do Tailwind v4, contraste ≥ 4.5:1. *Gate: tokens gerados, sem hex solto.*
5. **Componentes.** Carregue a skill `web-component` (ferramenta Skill — invoque, não descreva) por componente (primitiva a11y + CVA + tokens, fronteira a11y invariável). *Gate: axe sem violações + teclado ok.*
6. **Dados.** Carregue a skill `web-data-layer` (ferramenta Skill — invoque, não descreva; TanStack Query + Zustand/Jotai + Zod único, contrato do DTO real). *Gate: resposta validada pelo schema; error state tratado.*
7. **Testes de verdade.** Carregue a skill `testador-real` (ferramenta Skill — invoque, não descreva); ela executa **Playwright + axe** (fluxos, a11y, estados). *Gate: relatório datado sem FAIL crítico.*
8. **Iteração com o Comitê.** Carregue as lentes `designer-ux-ui`, `dev-senior`, `especialista-seguranca` e `qa-usabilidade` (ferramenta Skill — invoque, não descreva); elas avaliam; **repetir 4–7 até nota ≥ 9** ou esgotar as rodadas. Iteração multi-modelo pesada ⇒ delegar ao `orquestrador-fable`. *Gate: nota ≥ 9 registrada.*
9. **Gate final.** Carregue a skill `auditor-responsabilidades` (ferramenta Skill — invoque, não descreva); ela audita RI/RO e evidências → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (mockup amarra o componente; DTO amarra o schema; relatório do testador alimenta o auditor) — nada de etapa decorativa.
- Backend Spring Boot é **contrato**, não é reescrito aqui (RO-SB4: o front consome o record de leitura; RO-SB6: tokens de cor).
- Segredo nunca no bundle (só `VITE_` público); **server-state nunca em store global**.
- Pedido pequeno não vira burocracia: etapas puláveis são puladas **declaradamente** (ex.: sem SEO, sem stack novo), nunca em silêncio.

## Verificação da spec (autossuficiência)

Antes de sair do design (etapa 2) para a implementação, confira que a spec do front se sustenta sozinha — o porquê: sem fronteira e sem critério de aceite, o front cobre coisa que a API não expõe e "pronto" fica sem prova. A spec responde **sim** a:

- **Escopo** — telas do MVP, natureza (SEO × app logado) e o **contrato do backend** (endpoints/DTOs consumidos) estão definidos?
- **Fora-de-escopo** — o que **não** é responsabilidade do front nesta entrega (endpoints a criar no backend, telas futuras) está declarado?
- **Critério de aceite ponta-a-ponta** — há, por fluxo, um caminho verificável de fora (ex.: "abrir lista → carregar do endpoint real → filtrar → estado de erro tratado", provável em Playwright + axe sem violação), e não só "o componente renderiza"?

Faltando qualquer item, volte à etapa correspondente antes de codar.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Mockup não aprovado; contrato do backend ambíguo; spec sem escopo/fora-de-escopo/critério de aceite (ver acima); falta de skill filha crítica.
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

### 📜 Histórico
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.

- **2026-08-11 — A epígrafe "proposta 2026-07-07" trocada pelo estado medido.** Proveniência: `_auditoria/zelador-inventario-2026-08-10.md`, ATUALIZAR item 13. A linha 8 apresentava o track como proposta enquanto `evals/placar-baseline.md` já registrava juiz cego em 2026-07-09 (0,14 → 1,00, o maior delta da família) e `spec-projeto-completo` já roteia esta skill nominalmente. Trocado por essas duas evidências. **1 linha; nada mais tocado** — os evals desta skill já estavam coerentes, conforme o próprio laudo.
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. O texto passa a dizer *aplicar o método*, que é o comportamento real; os geradores seguem existindo e invocáveis. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
- *(Seção de Histórico criada nesta data — a skill não tinha nenhuma, e sem ela a proveniência da RI-04 não tem onde morar.)*
