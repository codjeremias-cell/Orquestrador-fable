# Referência — Técnicas avançadas do testador-real

> Extraído do corpo da `SKILL.md` em 2026-07-13 (Evolução R1→R2, onda transversal). O corpo mantém 1 linha de gatilho por técnica; o detalhe operacional completo vive aqui. Nenhuma regra foi removida — só realocada.

## Checklist com invalidação por hash

Para projetos com muitas telas/rotas testadas repetidamente, mantenha um `CHECKLIST-TESTADOR.md` com uma linha por item (alvo, arquivos cobertos, hash da última execução, status, evidência). A cada rodada, recompute o hash dos arquivos cobertos (`git hash-object`); hash diferente do registrado ⇒ o item volta para `REFAZER` com o motivo. Isso poupa retestar o sistema inteiro a cada chamada e garante que nada mudou "por baixo" sem re-teste.

## Cópia-sandbox para bancos de arquivo único

Quando o banco é um arquivo único não thread-safe (ex.: Access/UCanAccess), nunca escreva no arquivo de dev real: copie para uma pasta temporária, aponte a config para a cópia, execute os testes de escrita ali, e descarte a cópia ao final. O banco de dev nunca recebe write do testador.

## Smoke headless de UI declarativa

Em telas FXML, suba o toolkit JavaFX sem janela visível e rode `FXMLLoader.load()` em todas as views — pega binding quebrado de `fx:id`/`onAction` (o erro nº 1 de runtime) sem precisar de pixel. Em UI 100% programática (sem FXML), este atalho não existe — declare como limitação e teste a lógica por trás (serviços/DAOs) em vez da tela.

## Ledger de regressão de correções (RO-14, proposta — inspirado na skill `witness` do Ruflo, sem a assinatura criptográfica deles)

Quando o projeto mantém `correcoes.json` na própria raiz (nunca no catálogo compartilhado), cada entrada é `{id, descrição, arquivo, marcador, data, status}`. Na Fase 2, para cada entrada `status: ativo`, confirme que o `marcador` (um trecho de código distintivo que só existe enquanto o fix estiver presente) ainda aparece no `arquivo` indicado — sumiu = **FAIL de regressão**, entra no relatório com o motivo "marcador do fix {id} ausente". Quem adiciona a entrada é quem fecha a correção (dev-senior ou o `spec-` que fechou o fix), no momento em que o fix é confirmado testado. Mover uma entrada para `status: obsoleto` exige motivo textual (ex.: "reescrito na v2, ver ADR-00X") — só quem entende por que o marcador deixou de fazer sentido decide isso, nunca o testador sozinho. Projeto sem `correcoes.json` simplesmente não passa por este passo (a regra não se aplica — não é SKIP, é "não configurado").

## E2E de navegador com Playwright (alvos web/SPA/mobile-web) — pepita 2026-07-07, da pesquisa de tracks

Para o TIPO web/SPA, a bateria dinâmica (Fase 3) roda via **Playwright** contra o app no ar, no padrão **reconhecimento-então-ação**: navegar → `wait_for_load_state('networkidle')` → screenshot/DOM → agir com selectors reais, cobrindo os fluxos 3a-3h. Acessibilidade (3e) com **@axe-core/playwright** varrendo WCAG 2.2 — crítico (label ausente, teclado quebrado, foco perdido) é FAIL; cosmético é warning. É o análogo web do "smoke headless FXML". Vira o padrão da instância de testador do track web quando ele existir (ver ROADMAP item 1).

## Rigor de medição da fase 3h (desempenho) — detalhe

Ao comparar tempo entre versões, cada amostra é **independente** — o que isso significa depende do TIPO do Perfil:

- **Desktop/CLI:** **novo processo** por amostra — nunca N repetições no mesmo processo, porque aquecimento, cache e GC contaminam as amostras seguintes.
- **Web/API:** **nova sessão/cliente** por amostra contra o servidor já quente, **declarando o estado quente**; reiniciar o servidor só se a medição for de boot.

Banda de ruído: diferença **≤5% é ruído; só >5% é achado** (RI-04: número honesto > número animador). Os tempos medidos entram no TSV da Fase 4 (coluna `tempo_ms`) — é ele, não a prosa, a fonte da comparação com a bateria seguinte.
