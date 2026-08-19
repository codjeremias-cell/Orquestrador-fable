---
name: spec-javafx-new-system
description: "Orquestra a criação de um sistema Java/JavaFX completo do ZERO, do projeto Maven vazio até o app rodando e empacotado — cobrindo bootstrap, fundação de banco (Access/UCanAccess por padrão), logging, tema, shell, a primeira feature CRUD e o empacotamento. Acione com \"constrói um sistema novo do zero\", \"cria o app desktop JavaFX inteiro do começo ao fim\", \"quero um sistema JavaFX pronto pra rodar\", \"monta tudo: projeto, banco, telas e instalador\". NÃO acione fora disso — use esta APENAS para JavaFX/Access do zero. NÃO acione para evoluir um projeto que já existe — aí é spec-javafx-crud-feature (uma feature) ou a skill da camada."
---

# Spec — Sistema JavaFX do Zero (orquestrador-topo)

Esta skill é a **orquestradora de topo**. Leva uma pasta vazia até um app desktop JavaFX rodando e empacotado, aplicando o método das skills do track Java e validando cada etapa. Não duplica o trabalho detalhado delas.

## Quando usar / Quando NÃO usar

Use **esta** só quando são verdadeiras as três: **(1)** desktop, **(2)** stack JavaFX/Access, **(3)** sistema **novo** (pasta vazia → empacotado). Se faltar qualquer uma, a filha certa é outra:

- Projeto JavaFX **já existe**, quero **uma feature** → `spec-javafx-crud-feature`.
- Desktop **novo**, mas **não** JavaFX (Tauri/Avalonia/Electron/Flutter) → `spec-desktop-app`.
- Plataforma indefinida, não-desktop, ou sistema universal → `spec-projeto-completo` (ele faz **handoff** para cá quando decide por JavaFX; este não devolve).
- Só **uma etapa** (só bootstrap, só tema, só packaging) → a skill da camada.

## Objetivo

Entregar um sistema novo de ponta a ponta — projeto + fundação de banco + logging + tema + shell + primeira feature + empacotamento — aderente às [[REGRAS-DE-OURO]] do track Java/JavaFX.

## Entradas obrigatórias

1. Nome do app e pacote raiz/coordenadas Maven.
2. Banco alvo (padrão: Access/UCanAccess).
3. A primeira entidade/feature (nome + atributos + tabela/colunas) para já nascer com algo útil.

## Entradas opcionais

- Itens de navegação, tema inicial, ícone/fornecedor, regras de negócio da primeira feature.

## Validação do catálogo

Confirmar que existem as skills filhas (ajuste o caminho real de instalação); se faltar uma crítica, **parar** e dizer qual e para qual papel:

- `java-project-bootstrap`
- `java-db-foundation`
- `java-logging-log4j2`
- `javafx-theme-tokens`
- `javafx-app-shell`
- `spec-javafx-crud-feature`
- `java-package-desktop`

## Sequência determinística

> **Invoque, não descreva.** Cada passo abaixo que cita uma skill exige
> **carregá-la pela ferramenta Skill** — não ler o `SKILL.md` no lugar
> dela, não aplicar o método de memória. Sem a chamada `Skill`, o passo não
> começou.


Executar em ordem; validar cada etapa (compila? abre? teste passa?) antes de seguir.

1. **Visão e mockup (RO-06).** Alinhar as telas principais e apresentar o mockup do app; obter aceite.
2. **Esqueleto.** Carregue a skill `java-project-bootstrap` (ferramenta Skill — invoque, não descreva): projeto Maven JavaFX que compila e gera fat-jar.
3. **Banco.** Carregue a skill `java-db-foundation` (ferramenta Skill — invoque, não descreva): provedor de conexão + resiliência/retry na forma que o projeto pratica (espelhar, não impor) + `config.properties` (segredos fora do git).
4. **Logging.** Carregue a skill `java-logging-log4j2` (ferramenta Skill — invoque, não descreva): `log4j2.xml` + fachada de logger nomeada, na forma real do projeto (ex.: `Log` no SIGO). Valida: `log4j2.xml` carrega sem erro e uma chamada de teste grava linha real (arquivo/console) — não "arquivo criado", log **gravado**.
5. **Tema.** Carregue a skill `javafx-theme-tokens` (ferramenta Skill — invoque, não descreva): base clara + escura por tokens (nunca hex direto no call-site). Valida: app abre nos dois modos sem exceção; nenhuma tela nova usa cor hardcoded fora dos tokens.
6. **Shell.** Carregue a skill `javafx-app-shell` (ferramenta Skill — invoque, não descreva): janela principal, navegação, `AlertaUtil`, controller-base.
7. **Primeira feature.** Carregue a skill `spec-javafx-crud-feature` (ferramenta Skill — invoque, não descreva): entidade → DAO → serviço → tela, plugada no shell. Se a primeira feature for um painel de indicadores, quem conduz a tela é a `javafx-dashboard`.
8. **Empacotamento.** Carregue a skill `java-package-desktop` (ferramenta Skill — invoque, não descreva): `.exe`/`.msi` que roda sem Java.
9. **Fechamento com prova.** Build + smoke do app; bateria do `testador-real` (ou testador do projeto) quando aplicável; veredito da lente `auditor-responsabilidades` — as duas carregadas pela ferramenta Skill.

## Regras de coerência

- Nomes consistentes entre projeto, pacote, entidade, DAO, serviço, controller, FXML e artefato final.
- Reaproveitar o que cada etapa criou (a feature lê a fundação de banco e o shell reais — RO-01).
- Operação multi-passo = transação atômica; UI nunca congela (RO-J1); segredos fora do git.
- **O que é invariante aqui × o que varia (espelhar, não impor).** Invariante deste orquestrador: a **ordem** 1→8 (fundação — banco/log/tema/shell — antes da primeira feature; empacotamento por último; ver `referencia-exemplo-montado-sigo.md`) e os gates de cada etapa. **Como** cada etapa resolve o problema (onde vive o retry, quantos temas, forma do DAO, mecanismo de trava) é decisão de quem executa a skill filha, na forma real do projeto — este orquestrador sequencia e valida, não prescreve o detalhe técnico de nenhuma etapa (evita duplicar o corpo das filhas — nenhum detalhe do SIGO é regra fixa fora dela, ver eval greenfield).

## Verificação da spec (autossuficiência)

Antes de sair do mockup (etapa 1) para o código, confira que a spec do sistema se sustenta sozinha — o porquê: sem fronteira definida, o app nasce fazendo coisa que ninguém pediu e sem critério para dizer "pronto". A spec responde **sim** a:

- **Escopo** — quais telas/entidades o MVP inclui (a primeira feature está nomeada com atributos e tabela)?
- **Fora-de-escopo** — o que fica para depois (features, integrações, telas) está declarado, não subentendido?
- **Critério de aceite ponta-a-ponta** — há ao menos um caminho verificável de fora (ex.: "app abre → cria um registro da 1ª entidade → aparece na listagem → reabre e persiste") que o smoke/`testador-real` possa provar?

Faltando qualquer item, volte à etapa 1 antes de gerar o esqueleto.

## Condições de parada obrigatória

- Falta de skill filha crítica no catálogo.
- Entradas ambíguas (pacote, banco, primeira feature).
- Mockup não aprovado; spec sem escopo/fora-de-escopo/critério de aceite (ver acima).
- Falha em build/smoke obrigatório em qualquer etapa.

## Verificação de fechamento (RI-04)

Cada etapa fecha com a evidência que a própria skill filha declara (build, smoke, teste) antes de avançar — este orquestrador não substitui essa evidência, só a confere. O sistema completo fecha com: build final verde + smoke do app rodando + bateria do `testador-real` (ou testador do projeto) + veredito do `auditor-responsabilidades`. Etapa que não pode ser executada de verdade nesta sessão (ex.: empacotamento sem jpackage/Windows disponível, banco de teste inacessível) vira **SKIP declarado** com o motivo — nunca "passou" fingido.

## Formato do relatório final (RI-05)

Resumo objetivo: skills usadas · arquivos/artefatos criados (com caminho exato — RO-03) · builds e smokes executados · o que foi validado · pendências/limitações · **2–3 sugestões de evolução (RO-07)**. Submeter à lente `auditor-responsabilidades` para o veredito de prontidão.

## Saída esperada

- Sistema JavaFX novo, do projeto vazio ao `.exe`/`.msi`, com banco, logging, tema, shell e a primeira feature funcionando — aderente às Regras de Ouro do track.

**Exemplo montado real (SIGO):** carregue `referencia-exemplo-montado-sigo.md` — o próprio SIGO é o gabarito de um sistema JavaFX do zero ao empacotado (bootstrap→banco→log→tema→shell→1ª feature→packaging), cada elo com o arquivo real. É a sequência-capstone que amarra as 11 skills de geração do track. O padrão real vence o genérico (RO-01).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** todas as do comitê ao longo das etapas; `auditor-responsabilidades` fecha com o veredito.
- **Vem antes:** `requisitos-descoberta` (escopo e primeira feature definidos) ou `spec-projeto-completo` (que delega para cá quando a plataforma é desktop JavaFX).
- **Vem depois:** `testador-real` (bateria completa) · `docs-projeto` (README + manual acompanham a entrega).
- **Não confundir com:** `spec-projeto-completo` (universal, qualquer plataforma — este é o track JavaFX) · `spec-javafx-crud-feature` (uma feature num projeto existente) · `spec-desktop-app` (orquestrador desktop multi-stack — Tauri/Avalonia/Electron/Flutter; ele faz **handoff** para cá quando a stack escolhida é JavaFX/Access, este não devolve).

### 📜 Histórico
- **2026-08-18 — Invoque, não descreva: a rota volta a ser exigida (T14; **reverte a T29**; degrau §6.10: 1 — só edição).** Mutação de uma variável (a frase de invocação), n=3×3, medida na `spec-springboot-crud-feature`: com o texto da T29 os geradores foram acionados pela ferramenta `Skill` **0/3 nas três rodadas**; com o texto de invocação, **3/3 nas três**. Orquestrador 6/6 e entrega 6/6 nos dois braços: o efeito é de **rota**, não de entrega. **Esta skill não foi medida** — o texto foi aplicado por decisão do Jeremias, extrapolando o resultado daquela. O callout traz `skill` onde o medido dizia `gerador`, porque esta sequência também cita lentes. Placar: `estado/artefatos/t9-placar-final-2026-08-18.md`.
- **2026-08-10 — A promessa alinhada ao medido (T29; degrau §6.10: 1 — só edição).** A skill dizia **encadear/delegar** aos geradores do track. Medição de 2026-08-09 (6 rodadas, 2 orquestradores, bancadas atendendo a pré-condição): **acionou 6/6, delegou 0/6**, e a saída cumpriu as prescrições dos geradores. Os passos passam a dizer *criar X — método em `gerador`*, que é o comportamento real; os geradores seguem existindo e invocáveis. Escolha do Jeremias entre alinhar a promessa e forçar a delegação — alinhar venceu porque a saída medida é boa. Laudo em `_auditoria/zelador-custo-2026-08-08.md`.
O histórico de autoria/rodadas deste orquestrador foi movido para [referencia/historico.md](referencia/historico.md) para manter o corpo enxuto (progressive disclosure) — carregue-o só quando precisar auditar a evolução da skill.
