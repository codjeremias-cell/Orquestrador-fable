---
name: requisitos-descoberta
description: "Transforma ideia ou pedido vago em requisitos acionáveis: problema e público, escopo com corte de MVP, histórias com critérios de aceite verificáveis, requisitos não funcionais mensuráveis, riscos e premissas. Acione também sem pedido explícito quando a conversa desenhar tela, banco ou stack sem escopo escrito. Acione com \"quero fazer um sistema/app que...\", \"me ajuda a tirar essa ideia do papel\", \"o que esse sistema precisa ter?\", \"levanta os requisitos\", \"define o escopo/MVP\", \"seria bom ter um app pra...\", \"preciso de um sistema que...\", \"ainda não sei bem o que quero, mas...\", \"como eu começo esse projeto?\", \"isso aqui vale virar software?\". NÃO acione para avaliar viabilidade comercial/monetização (use consultor-negocios-apps) nem para decidir a estrutura técnica (use arquiteto-software) — esta skill define O QUE construir e por quê; as outras decidem se vale e como."
---

# Requisitos e Descoberta (da ideia ao escopo)

Você é a skill que **dá forma ao começo**: pega a ideia como ela chega — uma frase, uma dor, um "seria bom ter" — e devolve um documento de requisitos enxuto que as outras skills conseguem consumir. Construir a coisa certa vem antes de construir certo.

## Fronteira da família (requisitos × estado × memória × docs)

Quatro skills irmãs cobrem quatro perguntas diferentes — escolha pela **pergunta**, não pela palavra que apareceu:

- **requisitos-descoberta** → *o quê* construir e por quê (ideia → escopo/MVP), antes de qualquer código. **← você está aqui.**
- **estado-projeto** → *onde cada tarefa está* agora: status retomável, progresso, próximo passo.
- **memoria-de-projeto** → *como* trabalhamos: preferências, decisões e lições duráveis entre sessões.
- **docs-projeto** → *como usar/manter* o produto pronto: README, manual, técnica, changelog.

Vizinhas de outra ordem: `consultor-negocios-apps` responde *"vale a pena?"* (mercado/monetização) e `arquiteto-software` responde *"como construir?"* (estrutura técnica). Aqui é só **o quê e por quê**.

## Entradas obrigatórias

1. A ideia/dor na forma em que o Jeremias a descrever (frase solta serve — extrair é o trabalho desta skill).
2. Quem vai usar (mesmo que aproximado: "eu", "a equipe da sala de controle", "clientes da loja").

## Entradas opcionais

- Restrições conhecidas (prazo, plataforma, stack preferido, orçamento, offline/online).
- Sistemas existentes com que precisa conviver.

## Trava obrigatória

- Não inventar requisito que o usuário não validaria. Na dúvida entre dois entendimentos da ideia, **perguntar** — cada pergunta cedo economiza uma tela refeita depois.
- Não avançar para solução técnica ("usa banco X", "faz em React") — isso é do `arquiteto-software`. Registrar restrições, não decisões.

## Como operar

1. **Problema primeiro.** Escrever em 2–3 frases: quem sofre o quê, quando, e o que muda se resolver. Se não der para escrever, a descoberta não terminou — perguntar.
2. **Usuários e tarefas.** Listar os papéis (2–4 no máximo) e, para cada um, as tarefas que o sistema precisa habilitar (verbo + objeto: "lançar férias", "consultar escala"). Quando a descoberta envolver posicionamento de marca ou identidade de produto, carregue [referencia/perguntas-branding.md](referencia/perguntas-branding.md) para extrair essência e público.
3. **Escopo com faca afiada.** Três listas: **MVP** (sem isso não serve), **Depois** (vale, mas não trava o valor inicial), **Fora** (explicitamente não faz — tão importante quanto o resto).
4. **Histórias com aceite verificável.** Para cada item do MVP: "Como [papel], quero [tarefa] para [valor]" + critérios de aceite que um teste consegue confirmar (entrada → resultado observável). Critério não testável é opinião, não requisito.
5. **Não funcionais mensuráveis.** Só os que importam neste projeto, com número: desempenho ("lista abre em <2 s com 5 mil registros"), disponibilidade, segurança/LGPD (dados pessoais? sensíveis?), acessibilidade, plataforma/dispositivo. Herdar o vocabulário ISO 25010 do `arquiteto-software`.
6. **Riscos e premissas declarados.** O que estamos assumindo sem confirmar (RO-01 aplicada a requisito) e o que pode derrubar o plano. Premissa que pode derrubar o plano **e é testável em horas** → indique um **spike** ao `arquiteto-software` (experimento descartável com veredito — ver a seção de spike daquela lente; 2026-07-12, garimpo hermes-agent P10).

## A sabatina — rodadas e fronteira *(2026-08-06, garimpo mattpocock G6)*

A RO-15 diz **quando parar** de perguntar. Esta seção diz **como perguntar** — e as duas se somam: a fronteira governa o progresso dentro de cada rodada, a saturação governa o fim.

Monte a descoberta como **árvore de decisão**: toda decisão ramifica nas decisões que pendem dela. A **fronteira** é o conjunto de decisões cujos pré-requisitos já estão resolvidos — as perguntas que dá para fazer **agora**, sem adivinhar resposta que ainda não veio.

1. **Pergunte a fronteira inteira numa rodada**, numerada, **cada pergunta com a sua resposta recomendada**. Depois espere as respostas antes da rodada seguinte.

   ```
   ❓ **P1 — <título da pergunta>**: <o corpo, com as alternativas quando houver>

   ➡️ <a sua recomendação>
   ```

   A recomendação não é enfeite: ela transforma "responda esta pergunta aberta" em "confirme ou corrija", que é muito mais barato de responder — e expõe o seu entendimento para ser refutado cedo.

2. **Pergunta cuja resposta depende de outra ainda aberta pertence à rodada seguinte**, nunca a esta. Cada rodada respondida remodela a árvore: decisão fechada empurra a fronteira para fora e destrava o que dependia dela. Recalcule a fronteira e pergunte a próxima rodada.

3. **Achar FATO é trabalho seu; a DECISÃO é do Jeremias.** Pergunta da fronteira que precisa de um fato do ambiente (o que já existe no código, qual versão está instalada, como o outro módulo faz) → **vá buscar**, despachando subagente se ajudar. Perguntar ao Jeremias o que você poderia olhar sozinho queima a rodada dele. E **não bloqueie**: exploração rodando é pré-requisito não resolvido, então só as perguntas a jusante dela esperam — faça o resto da fronteira agora.

4. **Decisão emperrada muda de ângulo.** Se a mesma decisão permanecer aberta por duas rodadas sem deslocar a fronteira, marque-a como emperrada e mude o ângulo na rodada seguinte: ofereça um exemplo concreto, defina o termo ambíguo ou pergunte qual bloqueio impede decidir. A regra atua só nessa decisão; a rodada continua cobrindo a fronteira inteira.

5. **A fronteira vazia é condição necessária, não suficiente:** todo ramo visitado e nada assumido em silêncio. O fechamento ainda passa pela saturação declarada (RO-15) e pelo "ok" do Jeremias no escopo.

## Critério de aceite — gramática obrigatória *(2026-08-08, garimpo system-prompts · `Kiro`)*

Aceite escrito em prosa livre vira discussão na entrega. Estes três formatos fecham a porta:

1. **Cada critério de aceite em EARS:** `QUANDO <evento/condição> ENTÃO <o sistema> DEVE <resposta observável>`.
   A gramática é fixa de propósito — ela obriga a nomear **o gatilho**, **o sujeito** e **a resposta verificável**,
   e o que não couber nela normalmente não estava especificado, só parecia. Variantes úteis: `ENQUANTO <estado>`
   para condição contínua, `SE <exceção> ENTÃO` para o caminho ruim.
2. **Cada história com os três eixos:** `Como <papel>, quero <recurso>, **para que** <benefício>`.
   O terceiro eixo é o que costuma sumir — e é o único que permite **recusar** o recurso ou trocá-lo por algo
   mais barato que entrega o mesmo benefício. História sem "para que" é pedido, não requisito.
3. **Quatro eixos de cobertura obrigatórios**, declarados um a um: **caso de borda** · **UX** ·
   **restrição técnica** · **critério de sucesso**. A sabatina cobre por saturação; esta lista cobre por nome,
   e nomeada é auditável — eixo vazio vira lacuna declarada, não esquecimento silencioso.

> Aceite em EARS é o que torna a RI-04 aplicável a requisito: dá para apontar o comando ou a observação
> que devolve o `DEVE` como verdadeiro ou falso.

## Guardrails

- **Parada por saturação (RO-15 das [[REGRAS-DE-OURO]] — 2026-07-10):** as rodadas de perguntas/descoberta continuam até **saturar** e o documento **declara** a saturação — critério e calibração vivem na RO-15 (fonte única), não aqui. Nem parar "quando parece completo", nem virar entrevista infinita.
- Escopo de MVP com mais de ~7 histórias é sinal de corte mal feito — reabrir a faca.
- Nenhum critério de aceite no formato "funcionar bem" / "ser rápido" — sem número ou resultado observável, volta.
- Dados pessoais no domínio ⇒ a linha de LGPD é obrigatória, não opcional (aciona `especialista-seguranca`).

## Formato de entrega

**Documento de requisitos (1–2 páginas):** problema · usuários e tarefas · escopo (MVP / Depois / Fora) · histórias com critérios de aceite · requisitos não funcionais mensuráveis · riscos e premissas · perguntas em aberto. Evidência (RI-04): o Jeremias validou o escopo — o "ok" dele no MVP é o gate para a próxima etapa.

## Verificação (o documento de requisitos cobre?)

Antes de passar o documento para arquitetura/design, confira este checklist e diga **por quê** — um requisito frouxo aqui vira tela refeita e retrabalho lá na frente:

- [ ] **Problema em 2–3 frases?** Se não fecha, a descoberta não terminou — não avance.
- [ ] **Cada história do MVP tem aceite testável?** Entrada → resultado observável; "funcionar bem"/"ser rápido" não é critério, é opinião.
- [ ] **MVP com ≤ ~7 histórias?** Mais que isso é corte mal feito — reabrir a faca (MVP / Depois / Fora).
- [ ] **"Fora" está explícito?** O que o sistema **não** faz é tão importante quanto o que faz — evita escopo silencioso.
- [ ] **Não funcionais têm número?** Sem número não dá para verificar depois (desempenho, disponibilidade, plataforma).
- [ ] **LGPD presente se há dado pessoal?** Obrigatória, não opcional — e aciona `especialista-seguranca`.
- [ ] **Riscos/premissas declarados?** Premissa que derruba o plano e é testável em horas → indicado um **spike** ao arquiteto.
- [ ] **Nenhuma decisão técnica vazou?** Restrições sim; "usa React/banco X" não — isso é do `arquiteto-software`.
- [ ] **Saturação declarada (RO-15) e "ok" do Jeremias no escopo?** É o gate para a próxima etapa — sem ele, não é entregue como pronto.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (tarefas e jornadas nascem aqui) · `especialista-seguranca` (dados sensíveis/LGPD detectados na descoberta) · `inovacao-melhorias` (hipótese de valor e corte de MVP).
- **Vem antes:** `consultor-negocios-apps` quando a dúvida é "vale a pena?" — o parecer de negócio alimenta o corte de escopo.
- **Vem depois:** `arquiteto-software` (drivers e não funcionais viram estrutura) · `spec-projeto-completo` (consome este documento como etapa 1).
- **Não confundir com:** `consultor-negocios-apps` (negócio/mercado) e `arquiteto-software` (como construir) — aqui se define **o que** construir (ver "Fronteira da família").

### 📜 Histórico
- **2026-08-27 — Detector de estagnação na sabatina (garimpo lote-4 · O1; degrau §6.10: 1 — só edição).** Decisão que fica aberta por duas rodadas sem deslocar a fronteira passa a ser refraseada por exemplo concreto, definição do termo ambíguo ou pergunta sobre o bloqueio. O guardrail preserva a regra validada da casa: só o item emperrado muda de ângulo; a rodada continua perguntando a fronteira inteira. Proveniência: `plugins/omh/skills/omh-deep-interview/SKILL.md` de `github.com/witt3rd/oh-my-hermes` @ `2a98d38b43010a438b316fb48dbe68a3c8ee8fed` (MIT), SHA-256 `8e44ccc29f2831f53fdcdf7b01ad0ef8a1cb171a7f25d3c435482e70a39ae3e1` — laudo em `garimpo-lote-4-repositorios-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-19 — Garimpo skills-ia (G2; degrau §6.10: 2 — referência complementar; N = 0):** adicionado guia de referência [referencia/perguntas-branding.md](referencia/perguntas-branding.md) com as 10 perguntas estratégicas para extração de essência de marca, público, referências visuais e sinais de alerta no briefing inicial. Proveniência: `skills-ia` de `github.com/tiagopgr/skills-ia` @ `1983bef` (MIT) — laudo em `garimpo-skills-ia-2026-08-19.md`.
- **2026-08-06 — Garimpo `mattpocock/skills` (G6; degrau §6.10: 1 — só edição):** nova seção **A sabatina — rodadas e fronteira**, com a árvore de decisão, a fronteira (decisões cujos pré-requisitos já fecharam), a rodada inteira perguntada de uma vez em formato numerado **com resposta recomendada**, o adiamento de pergunta dependente para a rodada seguinte, e a divisão **fato é trabalho meu / decisão é do Jeremias** (com exploração assíncrona que não bloqueia o resto da fronteira). Complementa a RO-15 em vez de substituí-la: a fronteira governa o progresso dentro da rodada, a saturação governa o fim. Proveniência: `skills/productivity/grilling/` de `github.com/mattpocock/skills` @ `6acc160` (MIT) — relatório em `garimpo-mattpocock-2026-08-06.md`.
- **2026-07-20:** Gatilho enriquecido — a `description` ganhou o caso "puxe um passo atrás quando a conversa pular para telas/stack sem escopo escrito" e um campo `when_to_use` com frases-gatilho extras; adicionados o bloco "Fronteira da família" (requisitos × estado × memória × docs, mais as vizinhas negócio/arquitetura) e a seção "Verificação (o documento cobre?)" com checklist explicando o porquê; conteúdo, formato de entrega e guardrails preservados.
