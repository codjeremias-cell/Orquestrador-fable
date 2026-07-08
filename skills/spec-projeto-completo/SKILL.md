---
name: spec-projeto-completo
description: "Orquestrador universal de projeto completo, para QUALQUER plataforma (desktop, web, mobile, API, CLI): conduz da ideia ao sistema entregue passando por descoberta/requisitos, parecer de negócio quando fizer sentido, arquitetura, design, construção (delegando ao track do stack quando existir), testes executados de verdade, segurança, documentação, empacotamento/release e gate final do auditor. Acione quando o usuário disser coisas como \"quero construir um sistema/app completo\", \"do início ao fim\", \"da ideia à entrega\", \"conduz o projeto inteiro\", \"faz tudo: requisitos, código, testes e entrega\", em qualquer stack. Se o alvo for especificamente um app JavaFX desktop novo, prefira spec-javafx-new-system (track dedicado). NÃO acione para uma etapa isolada — use a skill específica da etapa."
---

# Spec — Projeto Completo (orquestrador universal, qualquer plataforma)

Esta é a **orquestradora de topo do ciclo de vida inteiro**: da ideia crua ao sistema entregue com prova. Ela não sabe construir nada sozinha — sabe **em que ordem** as skills e lentes do catálogo entram, o que valida cada etapa e quando parar. Onde existir track de geradores para o stack (ex.: Java/JavaFX), delega ao track; onde não existir, as **lentes poliglotas** conduzem a construção com o mesmo rigor.

## Objetivo

Entregar um projeto de ponta a ponta — requisitos → arquitetura → design → construção → testes reais → segurança → documentação → release — aderente às [[REGRAS-DE-OURO]] (RI + RO universais + RO do track quando houver).

## Entradas obrigatórias

1. A ideia/objetivo do sistema (mesmo em uma frase — a etapa 1 dá forma).
2. Plataforma-alvo (desktop, web, mobile, API, CLI) ou autorização para recomendá-la na etapa de arquitetura.

## Entradas opcionais

- Restrições (prazo, stack, offline/online, orçamento), sistemas com que convive, se quer o parecer de negócio.

## Validação do catálogo

Confirmar que existem as skills das etapas aplicáveis; se faltar uma crítica, **parar** e dizer qual e para qual papel: `requisitos-descoberta` · `consultor-negocios-apps` (opcional) · `arquiteto-software` · `designer-ux-ui` · `dev-senior` · `especialista-seguranca` · `testador-real` (ou o testador do projeto) · `qa-usabilidade` · `docs-projeto` · `auditor-responsabilidades` · e o track do stack quando existir (ex.: `spec-javafx-new-system`).

## Sequência determinística

Executar em ordem; cada etapa tem um **gate** — não seguir sem ele.

1. **Descoberta.** `requisitos-descoberta` → documento de requisitos. *Gate: Jeremias aprovou o corte de MVP.*
2. **Negócio (quando o produto visa mercado/usuários pagantes).** `consultor-negocios-apps` → parecer. *Gate: veredito viável ou ressalvas aceitas conscientemente.*
3. **Arquitetura.** `arquiteto-software` → estrutura, stack recomendado com trade-offs, ADRs, não funcionais mensuráveis. *Gate: decisão de stack/estrutura registrada (ADR).*
4. **Design.** `designer-ux-ui` → fluxos e mockups de todas as telas do MVP com estados. *Gate: mockups aceitos (RO-06) — antes de qualquer código de UI.*
5. **Construção.** Com track do stack: delegar (ex.: `spec-javafx-new-system` faz bootstrap→banco→shell→features→empacote). Sem track: `dev-senior` conduz por feature, com as RO universais (segredos fora do git, dados parametrizados, transação atômica, estados cobertos, logging decente). *Gate por feature: build verde + critérios de aceite da história atendidos.*
6. **Testes de verdade.** `testador-real` (ou o testador do projeto) executa as baterias estática + dinâmica. *Gate: relatório datado sem FAIL crítico aberto.*
7. **Segurança.** `especialista-seguranca` revisa superfície, autenticação, dados sensíveis (LGPD) — obrigatório antes de expor qualquer coisa publicamente. *Gate: sem achado crítico/alto aberto.*
8. **Documentação.** `docs-projeto` → README + manual do usuário + changelog da versão. *Gate: comandos do README testados.*
9. **Release.** Empacotamento/publicação do stack (ex.: `java-package-desktop` no desktop; deploy do track web) + ciclo git completo (RO-13). *Gate: artefato final aberto/acessado com sucesso.*
10. **Gate final.** `auditor-responsabilidades` audita RI/RO, evidências e responsabilidades → **veredito de prontidão (RI-05)**.

## Regras de coerência

- Cada etapa **consome a saída real da anterior** (requisitos alimentam arquitetura; mockups amarram a construção; o relatório do testador alimenta o auditor) — nada de etapa decorativa.
- Plataforma sem track de geradores ⇒ as lentes assumem, e as convenções validadas viram candidatas a track novo ([[PADRAO-DE-AUTORIA]] §8).
- Pedido pequeno não vira burocracia: etapas 2 e 8 podem ser puladas **declaradamente** quando não se aplicam — pular em silêncio, não.

## Condições de parada obrigatória

- Gate de qualquer etapa reprovado e não resolvido.
- Requisitos, stack ou primeira feature ambíguos após a etapa correspondente.
- Falta de skill crítica no catálogo.

## Formato do relatório final (RI-05)

Resumo objetivo: etapas executadas e skills usadas · artefatos criados (caminhos exatos — RO-03) · evidências por gate (requisitos aprovados, ADRs, mockups aceitos, builds, relatório do testador, análise de segurança, release) · pendências e limitações · **2–3 sugestões de evolução (RO-07)** · veredito do auditor.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas — este orquestrador é o mapa de quando cada uma entra; `auditor-responsabilidades` fecha.
- **Vem antes:** nada — é o ponto de partida quando o pedido é "o projeto inteiro".
- **Vem depois:** `memoria-de-projeto` (registrar decisões e lições do ciclo) · `inovacao-melhorias` (retrospectiva e próximos ganhos).
- **Não confundir com:** `spec-javafx-new-system` (track JavaFX do zero — prefira-o quando o alvo já é desktop JavaFX) · `spec-javafx-crud-feature` (uma feature num projeto existente).
