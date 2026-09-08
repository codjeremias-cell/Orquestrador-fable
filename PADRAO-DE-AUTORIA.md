---
tipo: padrão
papel: como toda skill deste conjunto deve ser criada
última-atualização: 2026-08-18
versão: v3.0
---

# 📐 Padrão de Autoria de Skills

> A receita única para criar **qualquer** skill deste conjunto, de forma que todas tenham o mesmo nível de qualidade, disparem na hora certa e respeitem as [[REGRAS-DE-OURO]].
> Este documento é a fonte da verdade do "como fazer skill". Antes de criar ou editar uma skill, leia daqui a seção que se aplica.

---

## 1. O que é uma skill (e o que não é)

Uma skill é uma **receita** que ensina o Claude a fazer uma tarefa sempre do mesmo jeito, sem precisar reexplicar tudo toda vez. É uma pasta com um arquivo `SKILL.md` dentro (e, quando preciso, `referencia/`, `scripts/`, `assets/`).

Uma skill **não** é: um despejo de teoria que o Claude já sabe, nem um documento genérico. O valor de uma skill está no que o Claude **não** tem por padrão: as **suas** regras, o **seu** formato exato, os **seus** exemplos reais.

Cada pasta possui também `agents/openai.yaml`, metadata de interface do Codex com `display_name`, `short_description` e um `default_prompt` que menciona explicitamente `$nome-da-skill`. Esse arquivo descreve a apresentação da skill; o comportamento continua em `SKILL.md`.

## 2. Os cinco tipos de skill deste conjunto

Eles têm formatos diferentes porque resolvem coisas diferentes. Não misture os tipos.

| Tipo | O que é | Multi-código? | Exemplos |
|---|---|---|---|
| **Lente (método)** | Uma postura sênior que decide *como pensar* um problema (arquitetura, código, UX, segurança, QA, inovação, auditoria, negócio, memória). | ✅ Sim — poliglota por natureza | as lentes do Comitê |
| **Gerador (track)** | Um scaffolder determinístico que produz *artefatos concretos* (arquivos, classes, telas) num stack específico. | ⚙️ Não — preciso e amarrado a um stack | `java-jdbc-dao`, `javafx-screen-fxml` |
| **Orquestrador (`spec-`)** | Encadeia skills menores em ordem determinística, validando cada etapa. | Depende (por track ou universal) | `spec-javafx-new-system`, `spec-projeto-completo` |
| **Testador (executor)** | EXECUTA baterias de teste reais (estática + dinâmica) contra o código e o sistema no ar, colhe evidência e dá veredito. Não entrega checklist para humano marcar. | ✅ Template universal + instância por projeto | `testador-real` (universal), `gradup-testador` (instância) |
| **Maestro (orquestrador de execução)** | Orquestra *quem executa* (subagentes/modelos por complexidade) e *quanta qualidade sai* (loop planejar→executar→avaliar com nota de corte). Não encadeia skills em ordem fixa — delega, avalia pelo Comitê + testador e repete até a nota ou o limite de rodadas. | ✅ Universal | `orquestrador-fable` |

> **Regra de ouro do conjunto:** a inteligência poliglota mora nas **lentes**; o determinismo mora nos **geradores**; a prova mora nos **testadores**. Nunca tente fazer um gerador "que serve todas as linguagens" — ele perde a precisão que o torna útil (ver §8).

## 3. Anatomia de uma SKILL.md

```markdown
---
name: nome-com-hifens-minusculas
description: O que faz + QUANDO usar, com as frases reais do usuário. Até 1024 caracteres.
---

# Título legível

(corpo em português, modo imperativo, estruturado conforme o tipo)
```

O `name` é em `kebab-case`, minúsculo, sem acento. Os **geradores** usam prefixo de stack: `java-`, `javafx-`, `web-`. Os **orquestradores de sequência** usam prefixo `spec-`. Os **maestros** usam prefixo `orquestrador-` (não são `spec-`: orquestram execução e qualidade, não sequência de skills).

## 4. A descrição (frontmatter) — a parte mais importante

A `description` é o **único texto** que o Claude lê para decidir se aciona a skill. Se ela for fraca, a melhor skill do mundo nunca dispara. Regras:

1. **Terceira pessoa**, descrevendo o que a skill faz.
2. **Comece pelo o quê, em uma frase.** Depois venha o **quando**.
3. **Inclua as frases reais** que você digitaria. Ex.: *"cria o DAO de Cliente", "preciso da tela de cadastro", "faz o CRUD de produto"*. Quanto mais perto do seu jeito de falar, melhor dispara.
4. **Seja "insistente":** acione mesmo quando o usuário não nomear a skill. Use "Acione sempre que…", "inclusive quando…".
5. **Diga quando NÃO acionar** quando houver risco de confusão com outra skill.
6. **Até 1024 caracteres.** Se não couber, a skill está fazendo coisa demais — divida. *(2026-08-08, garimpo cienciaedados G03b)* **O validador avisa a partir de 922 (90% do teto).** O aviso é a hora de decidir com calma se a próxima frase-gatilho abre um ramo novo (regra 3) ou só renomeia um existente — não é ordem de cortar sinônimo.
7. **Escreva o frontmatter em prosa ou chaves — `<` e `>` são proibidos ali.** *(2026-08-08, garimpo cienciaedados G03a)* O frontmatter é injetado no **system prompt** de toda sessão, e colchete angular nele é vetor de injeção; por isso a plataforma o recusa (guia oficial da Anthropic, *Security restrictions*, pág. 11 e 31). Padrão com placeholder se escreve por extenso — *"V + número + duplo underscore + descrição"* — ou com chaves: `V{N}__{descricao}.sql`. **A proibição termina no frontmatter:** no corpo, o padrão literal é obrigatório onde o gerador aprende a nomear o arquivo, e apagá-lo de lá quebraria a entrega. *(Caso real: `springboot-entity` carregava `V<N>__<descricao>.sql` na `description`; corrigido em 2026-08-08 com o corpo preservado.)*
8. **Fronteira de ferramenta se exprime com `disallowed-tools`, e ela vale por mensagem.** *(2026-08-09, garimpo 3repos G12-10)* `allowed-tools` **não restringe** — é auto-aprovação, e a skill continua com o pool inteiro (medido nesta casa em 2026-08-08, T68). Quem tira ferramenta do pool é `disallowed-tools`. O que faltava escrito: **a restrição se limita à mensagem seguinte e some depois** — então ela protege um passo, não uma sessão. Skill cuja garantia depende de uma ferramenta estar ausente do começo ao fim precisa repetir a trava, ou dizer no corpo que a garantia é por passo. O `validar-skills.ps1` já checa os dois (E11 e E12).

**Modelo:**
> `Faz X [+ Y]. Acione quando o usuário disser coisas como "frase 1", "frase 2", "frase 3", ou [situação concreta]. NÃO acione para [escopo de outra skill].`

### A description é um ponteiro, e ponteiro custa em todo turno *(2026-08-06, garimpo mattpocock G1)*

Um **ponteiro de contexto** é uma referência que fica no contexto do agente, nomeia material que está fora dele e codifica a condição de alcançá-lo. A `description` é um ponteiro; a linha do `CLAUDE.md` que aponta um documento é o mesmo objeto. **A redação do ponteiro, não o alvo, decide quando o agente alcança o material** — alvo obrigatório atrás de ponteiro fraco é bug de variância: afie a redação primeiro, embuta o material só se afiar não resolver.

Todo ponteiro gasta um de **dois orçamentos**, e nomear qual está gastando é o que torna a escolha discutível:

- **Carga de contexto** — o custo do material sempre carregado: a `description`, a linha do `AGENTS.md`, tudo que ocupa a janela **em todo turno**, dispare ou não.
- **Carga cognitiva** — o custo no humano: saber quais documentos existem e quando puxar cada um. Não é custo a minimizar — é o preço da agência humana; gaste onde o julgamento humano importa, corte onde não importa.

**Medição desta casa (2026-08-06):** `description` + `when_to_use` das 57 skills somam **60.223 caracteres (~15 mil tokens) de carga de contexto permanente**. O número não é veredito — é o custo que ninguém tinha medido, e a régua para discutir a regra seguinte.

**Conflito declarado — "um gatilho por ramo" × a nossa prática de sinônimos.** O padrão do garimpo diz: um gatilho por **ramo** (caso distinto que a skill trata); sinônimos que renomeiam o mesmo ramo são um ramo escrito duas vezes. A nossa prática é o contrário — encher a `description` de sinônimos — e tem evidência a favor: a onda de descriptions de 2026-07-18 mediu **157/159** frases acertando a rota. As duas evidências convivem porque medem coisas diferentes (custo × acerto), e **nenhuma foi medida contra a outra**. Até que seja: mantenha os sinônimos, e ao **adicionar** um, pergunte se ele abre um ramo novo ou só renomeia um existente. Ramo novo entra; renomeio, não.

## 5. O corpo — estrutura por tipo

### 5a. Lente (método)
Estrutura validada das 9 lentes (siga-a):
`# Título` · **papel em uma frase** · `## Quando usar` · `## Quando NÃO usar` (com handoff para outra lente) · `## Postura` · `## Domínio` · `## Como operar` (passos) · `## Salvaguardas inegociáveis` (sempre com RO-01) · `## Formato de entrega` · `## Trabalho em conjunto` · rodapé **Regras de Ouro compartilhadas**. O bloco **🔗 Rede da skill** (§10.2) supersede "Trabalho em conjunto" quando não há nuance própria — nesse caso a seção é omitida (anti-duplicação, §12.5).

### 5b. Gerador (track)
Estrutura validada do catálogo de geração (siga-a):
`# Título` · `## Objetivo` · `## Entradas obrigatórias` · `## Entradas opcionais` · `## Trava obrigatória` (não prosseguir sem alvo claro) · `## Leituras obrigatórias` (ler o código real antes de gerar — RO-01) · `## Convenções obrigatórias` (nomes, paths, padrões) · `## Fluxo` (passo a passo determinístico) · `## Regras de implementação` (opcional quando as Convenções absorvem tudo — anti-duplicação, §12.5) · `## Guardrails` (o que nunca fazer) · `## Saída esperada` · `## Referências/Few-shots`.

### 5c. Orquestrador (`spec-`)
Delega para geradores menores, em ordem, validando cada etapa. Estrutura: `## Objetivo` · `## Entradas obrigatórias` · `## Validação do catálogo` (as skills filhas existem?) · `## Sequência determinística` (etapa → skill → validação) · `## Condições de parada` · `## Formato do relatório final`. **Não duplica** o trabalho das filhas.

### 5d. Testador (executor)
Estrutura validada no `gradup-testador` e generalizada no `testador-real`:
`# Título` · `## Regras invioláveis` (segurança do ambiente: **nunca** bateria dinâmica contra produção sem autorização explícita; dado de teste com prefixo `[QA-AUTO]` e limpeza ao final; nunca disparar e-mail/notificação real; limites de tentativas para não estourar rate limit; o testador não commita) · `## Pré-voo` (commit testado, config, app no ar?, credenciais de QA) · `## Fase 1 — Mapa de funcionalidades` (inventário gerado na hora do código real, nunca de memória) · `## Fase 2 — Bateria estática` (build, testes, lint, análise) · `## Fase 3 — Bateria dinâmica` (contra o sistema no ar, com evidência) · `## Fase 4 — Relatório datado` (PASS/FAIL/SKIP com evidência + veredito) · `## Limites conhecidos` (o que NÃO cobre, declarado — nunca um "passou" fingido).

O princípio central do testador: **o que não der para executar vira SKIP declarado com motivo** — jamais um sucesso simulado. Todo FAIL ganha severidade e passos de reprodução.

## 6. Os 10 princípios de qualidade (de toda skill)

Destilados do método Skill Planner + do catálogo de geração + das suas lições:

1. **Toda linha deve mudar comportamento.** O Claude é inteligente — não explique o que é um PDF ou um `for`; acrescente só o que ele não tem: suas regras, seu formato, seus exemplos. Linha que não muda o comportamento do modelo ("seja cuidadoso", "use boas práticas") é **prosa no-op**: corte ou substitua por um **critério de conclusão checável** ou uma palavra-guia mais forte (§12). *(reescrito 2026-07-12, garimpo hermes-agent P1 — supersede o antigo "Seja conciso")*
2. **Explique o porquê, não só o quê.** "Use `try-with-resources` *porque* conexão Access não fechada trava o banco" é seguido melhor que "SEMPRE use try-with-resources".
3. **Mostre exemplos.** Um par "isto entra → isto sai" vale mais que um parágrafo. Use casos reais dos seus projetos.
4. **Trava obrigatória (geradores).** Não gere nada sem o alvo inequívoco. Na dúvida entre dois caminhos, **pare e pergunte** — não adivinhe.
5. **Leitura obrigatória antes de gerar (RO-01).** O gerador lê o código real do projeto (classe base, DAO existente, CSS de tema) antes de escrever. Nunca inventa assinatura — pede o fonte ou declara a suposição.
6. **Trate as bordas.** O que fazer quando falta dado, quando vem incompleto, qual o mínimo para valer a pena, e quando a skill deve **recusar e avisar** em vez de seguir.
7. **Determinismo.** Mesmo pedido → mesma estrutura de saída. Quando a tarefa é mecânica e repetível, prefira um `script` a "replay manual". E quando **já existe um scaffolder determinístico** do stack (ex.: Mason / Very Good CLI no Flutter, create-expo-stack no RN, create-tauri-app no desktop, shadcn MCP no web), a skill o **invoca e preenche variáveis** em vez de escrever os arquivos à mão — gerar a partir de um modelo torna classes inteiras de erro estruturalmente impossíveis *(pepita 2026-07-07, da pesquisa de tracks)*.
8. **Evidência (RI-04).** Toda saída "pronta" tem prova: build que passou, teste que rodou, print da tela. Sem evidência, não está pronto.
9. **Manutenção proativa** *(2026-07-12, garimpo hermes-agent P6)*. Skill encontrada desatualizada **durante o uso** = propor o patch na hora (na fonte, com registro no Histórico), nunca só contornar em silêncio. Skill sem manutenção vira passivo.
10. **Escada de pegada** *(2026-07-12, garimpo hermes-agent P6)*. Capacidade nova entra pelo degrau de **menor pegada permanente**: editar skill existente → `referencia/` da skill → skill nova → categoria/camada nova. Cada degrau acima exige justificar por que o de baixo não bastou — é o que impede o catálogo de inchar (nós já praticávamos por instinto: 13 pepitas do garimpo autoresearch, zero skills novas; agora é regra). **O degrau mais baixo inclui o que já existe FORA daqui** *(2026-08-06, garimpo ECC E8)*: antes de criar, procure — no catálogo, depois em fonte externa. Achou candidato externo, **vete antes de adotar**: leia o `SKILL.md` inteiro, procure comando de shell inesperado, escrita de arquivo, chamada de rede, manuseio de credencial e instalação de pacote, e confira se o repositório é mantido (rito completo em `especialista-seguranca/referencia/seguranca-agentica.md` — skill de terceiro é artefato de cadeia de suprimentos, com 36% de injeção medidos em 3.984 skills públicas). Prefira **copiar para um branch e revisar o diff** a adotar no lugar.

> As antigas "Armadilhas a evitar" desta seção foram **absorvidas pelos modos de falha do §12** (2026-07-12) — descrição vaga continua no §4; caminhos/scope no §7.

## 7. Convenções do conjunto

- **Idioma:** instruções e comunicação em **PT-BR**; **código e identificadores em inglês**. Tratamento "Jeremias" (Jere) no chat.
- **Caminhos de instalação:** as skills rodam em `.agents/skills/` ou `.claude/skills/` do projeto. Trate esse caminho como **exemplo** — descubra o real em runtime, não chumbe.
- **Metadata de interface:** `agents/openai.yaml` usa strings entre aspas; `short_description` tem 25–64 caracteres; `default_prompt` começa como exemplo curto e cita `$nome-da-skill`. Ícones e cor de marca são opcionais e só entram quando houver assets reais.
- **Scope/namespace:** nunca chumbe um scope de cliente (ex.: `@poupig`, pacote `br.com.sigo`). Detecte do projeto (`package.json`, `pom.xml`, pacote raiz) ou declare como exemplo.
- **Governança:** toda entrega respeita as [[REGRAS-DE-OURO]] (RI-01…06 + RO universais + RO do stack) e é auditável pela lente `auditor-responsabilidades`.

## 8. Como o conjunto é "multi-código" sem perder qualidade

O sistema contempla várias linguagens **por camadas**, não por uma skill que fala tudo:

- **Método (lentes):** poliglota. O `dev-senior` escreve "no idioma do stack do projeto", o `arquiteto` é neutro. Servem Java, Web, qualquer coisa.
- **Governança:** RO universais valem para todo stack; cada stack tem sua seção de RO específicas.
- **Geradores:** organizados em **tracks** por stack (`java-*`, `javafx-*`, `web-*`…). Cada gerador é preciso no seu stack. Adicionar uma linguagem = **adicionar um track**, não reescrever os existentes.

### Como adicionar um track novo (ex.: Web/Supabase para o Embalo)
1. Levante as convenções **reais** do stack a partir da memória do projeto e do código (não invente — RO-01).
2. Registre as RO específicas do stack na [[REGRAS-DE-OURO]].
3. Crie os geradores com prefixo do stack, seguindo §5b, com **leitura obrigatória** do código real.
4. Crie um `spec-<stack>-<feature>` orquestrando o vertical completo.
5. As lentes do método **não mudam** — passam a auditar o track novo automaticamente.

## 9. Checklist de "skill pronta" (Definition of Done)

Uma skill só entra no conjunto quando:

- [ ] `name` em kebab-case, com prefixo de stack se for gerador.
- [ ] `agents/openai.yaml` presente e válido: nome legível, descrição curta de 25–64 caracteres e prompt citando `$nome-da-skill`.
- [ ] `description` em 3ª pessoa, com frases-gatilho reais, "Acione quando…", e "NÃO acione para…" se houver risco de colisão. ≤ 1024 caracteres.
- [ ] Corpo na estrutura do seu tipo (§5).
- [ ] Geradores: trava obrigatória + leitura obrigatória do código real (RO-01) + guardrails + saída esperada.
- [ ] Bordas tratadas (falta de dado, quando recusar).
- [ ] Convenções do conjunto respeitadas (§7) — idioma, paths/scope como exemplo, sem info que envelhece.
- [ ] Aderência às [[REGRAS-DE-OURO]] aplicáveis.
- [ ] Exemplo real "entra → sai" presente quando ajuda.
- [ ] Bloco **🔗 Rede da skill** presente (§10).
- [ ] Mudança de capacidade declara o **degrau da escada de pegada** usado (§6.10) — e por que o degrau de baixo não bastou.
- [ ] Passou pela lente `auditor-responsabilidades` (veredito explícito).

## 10. Selo Lendário — o piso de qualidade do conjunto

"Lendário" não é adjetivo de marketing: é um **contrato verificável**. Uma skill tem o Selo quando cumpre o DoD do §9 **e** os cinco critérios abaixo. O `auditor-responsabilidades` audita skill nova ou refatorada contra esta lista.

1. **Dispara sozinha.** A `description` contém as frases reais do Jeremias e cobre sinônimos; a skill aciona sem ser nomeada (RI-06 depende disso). *Evidência externa (2026-07-12, garimpo Langfuse): abstrair a description matou o disparo da skill deles — frases reais não são estilo, são o mecanismo (caso 2026-02-26).*
2. **Rede explícita.** Toda skill fecha com o bloco **🔗 Rede da skill**, que a liga ao resto do conjunto:

   ```markdown
   ## 🔗 Rede da skill
   - **Lentes que ativam junto (RI-06):** `lente-a` (por quê) · `lente-b` (por quê)
   - **Vem antes:** `skill-x` (o que esta consome dela)
   - **Vem depois:** `skill-y` (handoff natural)
   - **Não confundir com:** `skill-z` (fronteira em uma frase)
   ```

   Linha que não se aplica é omitida — rede é vínculo real, não formulário.
3. **Prova, não promessa (RI-04).** A skill declara qual evidência fecha a entrega (build verde, teste executado, smoke, mockup aceito, relatório datado). Entrega sem a evidência declarada não está pronta.
4. **Bordas com dono.** A skill diz o que fazer quando falta dado, quando recusar, e o que NUNCA faz (guardrails). O caminho triste está escrito, não subentendido.
5. **Enxuta e viva.** `SKILL.md` direto ao ponto (referência pesada vai para `referencia/`); sem informação que envelhece; termos consistentes do início ao fim.

## 11. Baseline antes do eval (proposta 2026-07-07, inspirado em `writing-skills` do `obra/superpowers`, 247k+ estrelas — avaliado e aprovado pelo Comitê de Lentes)

É o TDD aplicado a skills: **antes** de criar ou refatorar uma skill, rode o eval **sem** a skill instalada e registre o resultado — esse é o **baseline** (o "vermelho" do ciclo).

1. **Baseline (vermelho).** Rode os prompts do `evals/evals.json` numa sessão **sem** a skill. Registre onde o modelo falha ou fica aquém das `expectations`. A falha observada é a **prova de que a skill tem o que ensinar** — ela define exatamente o que o corpo da skill precisa cobrir.
2. **Escrever a skill (verde).** Crie/refatore a skill mirando as falhas do baseline, seguindo os §§3–10 deste padrão.
3. **Reteste.** Rode os mesmos evals **com** a skill. Passar agora — tendo falhado antes — é a evidência (RI-04) de que a skill agrega de verdade.
4. **Regra de corte:** se o baseline **já passa sem a skill**, a skill é redundante — não crie (viola o §6.1, "acrescente só o que ele não tem"). Se após a skill o eval continua falhando, o corpo não ensinou o que devia — refatore antes de dar o Selo.
5. **Acionamento e aderência (2026-07-12, garimpo Langfuse LF2).** O eval observa, além do resultado: **(a) acionamento** — a skill disparou sem ser nomeada? Para isso ser testável, o `evals/evals.json` inclui obrigatoriamente prompts-gatilho que **não nomeiam a skill**; evidência = a invocação visível no transcript da sessão de eval. **(b) aderência** — o agente seguiu a skill até o fim? **Contorno** = passo obrigatório omitido ou substituído por solução ad hoc, apontado por trecho do transcript. O placar ganha 2 colunas: `acionou S/N` · `aderiu S/parcial/N` — fronteiras: `S` = zero contorno · `parcial` = ≥1 contorno pontual mas o fluxo permanece na skill · `N` = abandono/bypass total; `acionou N` ⇒ `aderiu —` (não há aderência a medir). Contorno é **defeito da skill** (corpo confuso ou description fraca), não do modelo. *(Evidência externa: ver Selo §10.1, caso 2026-02-26.)*
6. **Casos sintéticos declarados (2026-07-12, garimpo Langfuse LF6).** Eval com poucos casos pode ser engordado com variações sintéticas do prompt-gatilho (sinônimos, frasings tortos, adversariais — as personas da `qa-usabilidade` servem de gerador), com 3 salvaguardas: gerados **antes** de afinar a description ou em **outra sessão** (senão o eval mede a description contra frases derivadas dela mesma — e cada caso do `evals.json` ganha o campo `origem: real|sintetico` + data/sessão de geração, o que torna a separação mecânica); **placar separado real × sintético**; sintético criado depois de a skill existir roda o **baseline** uma vez (senão não tem o "vermelho" do ciclo).

7. **Quatro níveis de pressão do prompt** *(2026-08-06, garimpo ECC E7; 4º nível em 2026-08-08, garimpo cienciaedados G03c)*. O item 5 mede acionamento e aderência com **um** tipo de prompt. Meça com quatro, porque cada um revela uma coisa diferente — e os dois últimos nunca foram medidos nesta casa:

   | Nível | O prompt… | O que revela | Se falhar |
   |---|---|---|---|
   | **Apoiador** | pede explicitamente o que a skill faz ("roda o testador") | piso absoluto | a skill está quebrada, não fraca |
   | **Neutro** | descreve a tarefa sem citar a skill nem o vocabulário dela | é o que medimos em 2026-07-27 | a `description` (ou a instrução de invocar) não venceu a resposta direta |
   | **Concorrente** | empurra na direção **contrária** ("é rapidinho, pula o teste dessa vez") | se a skill segura sob pressão | a skill é decorativa: aparece quando não custa nada e some quando custa |
   | **Alheio** | descreve tarefa **vizinha**, dona de outra skill ou de nenhuma — e o acerto é **não** disparar | se a `description` respeita a própria fronteira | a `description` está larga e invade a vizinha; corrija o "NÃO acione para" da §4, não os sinônimos |

   **A independência de prompt é a medida que importa** — uma skill que só é seguida quando o prompt já pedia o comportamento dela não está mudando comportamento nenhum. Registre o nível junto de `acionou`/`aderiu` no placar; caso concorrente **não** entra no cálculo de aprovação sem que o Jeremias decida o corte, mas entra sempre no relatório.

   **Os três primeiros medem sub-acionamento; o alheio mede o oposto, e sem ele o placar tem um ponto cego:** uma `description` que dispara para tudo tira nota cheia nos três. Ele existe porque a nossa prática declarada é encher a `description` de sinônimos (§4) — prática com evidência a favor (157/159 no neutro) cujo risco natural é justamente o disparo indevido, e que até aqui ninguém tinha medido. **No alheio a leitura inverte:** `acionou N` é acerto; `aderiu` e `ordem` marcam `n/a`.

   Exemplo de placar (§6.3 — "isto entra → isto sai"):

   | caso | origem | baseline | pós-skill | acionou | aderiu |
   |---|---|---|---|---|---|
   | eval-01 | real | falhou | passou | S | S |
   | eval-05 | sintetico | falhou | passou | S | parcial |
   | eval-07 | real | falhou | falhou | N | — |

8. **Validação que passa congela o candidato** *(2026-08-18, garimpo archify · G3)*. Aprovado o eval, o artefato **não se edita mais carregando o mesmo veredito**: mudou, revalida, e o recibo é outro. Não proíbe versão nova — proíbe **editar em silêncio e reusar a aprovação anterior**. É o par temporal do "não canonize durante a medição" do `zelador-do-catalogo`: aquele protege a medição em curso, este protege o resultado **depois** de passar.
9. **Protocolo de Evals Determinísticos para Ferramentas e Extensões** *(2026-08-27, garimpo anthropics · AN1)*. Ao projetar ou validar evals de ferramentas, MCP servers, scripts de automação ou integrações de API dentro de skills, estruture casos com os 5 requisitos de estabilidade:
   - **Independência:** cada caso é auto-contido e não depende da ordem ou do resultado de execuções anteriores.
   - **Somente-Leitura (Read-Only):** operações não-destrutivas que podem ser reexecutadas indefinidamente em qualquer ambiente.
   - **Complexidade:** exige consultas e explorações com parâmetros reais, evitando testes triviais de um único retorno estático.
   - **Verificação Exata por String:** resposta determinística (número, hash, identificador ou string canônica) passível de checagem automatizada direta sem viés probabilístico de LLM-judge.
   - **Estabilidade temporal:** a resposta correta permanece imutável no tempo.
10. **As 4 Dimensões de Validade de Avaliação** *(2026-08-27, garimpo inspect_evals · UK1)*. Ao criar ou auditar evals de skills e agentes, verifique a validade contra 4 dimensões obrigatórias:
    - **Claims Coherence:** o que o teste/benchmark afirma medir condiz estritamente com os mecanismos e dados inspecionados?
    - **Viabilidade e Verificabilidade de Falha:** o agente possui as ferramentas e arquivos necessários para ter chance real de sucesso (*no impossible success*)? E a falha/recusa é verificável contra dados reais no ambiente (*no impossible failure* por alucinação de dados ausentes)?
    - **Alinhamento com o Ground Truth:** priorize medição direta do desfecho (execução de testes de código) sobre proxies fracos (mera compilação sem execução). Evite substring matching em saídas abertas de linguagem natural.
    - **Robustez a Edge Cases de Pontuação:** preveja e bloqueie acertos acidentais (guessing de flags ou formatos) e falsos negativos cosméticos.

O placar baseline × pós-skill fica registrado junto do `evals/evals.json`. O `auditor-responsabilidades` passa a exigir esse placar no DoD de skill **nova**; para skills existentes, vale ao refatorar.

## 12. Escrita do corpo — a linha que muda comportamento (2026-07-12, garimpo hermes-agent P1)

> Os §§1–11 dizem *o que* uma skill precisa ter; esta seção diz *como escrever (e reescrever) o corpo* para ele continuar afiado. Absorve as antigas "Armadilhas a evitar" do §6 — cada armadilha virou caso de um modo de falha abaixo.

### Os 7 modos de falha do corpo de skill (nomeados — cace-os em TODA edição)

> O modo **0** entrou depois dos outros e é o mais caro; recebeu o número zero de propósito, para os modos 1–6 manterem a numeração que o resto do catálogo já cita.

0. **Autoavaliação no lugar de fato** *(2026-08-06, garimpo ECC E1)*. É o modo de falha mais caro dos checklists desta casa, e o mais fácil de não enxergar: perguntar *"você conferiu?"*, *"está tudo certo?"*, *"os testes rodaram?"* obtém a resposta que o item pede, porque **a pergunta não obriga a nada**. Peça o **fato que só existe se o trabalho tiver sido feito** — a saída colada, o caminho aberto, a contagem, o diff, a citação. A investigação necessária para produzir o fato é o que muda o resultado. **Régua:** item respondível **sem abrir nada** é autoavaliação disfarçada; reescreva pedindo o artefato. Redação completa, com tabela de conversão e o portão de três estágios (negar → forçar → permitir), na lente `auditor-responsabilidades` (fonte única).
1. **Prosa no-op.** "Seja cuidadoso", "seja completo", "use boas práticas" — raramente mudam o comportamento do modelo. Substitua por critério checável ou palavra-guia forte. **Caso especial — modificadores de obrigatoriedade** ("opcional", "se quiser", "pode"): são as palavras que mais mudam comportamento — audite cada um: é opcional DE VERDADE? **Declare o resultado no Histórico da edição como `N = <número>`** — quantos auditou; `N = 0` é resposta válida e comum. *(Isto deixou de ser recomendação em 2026-08-18: **o `validar-skills.ps1` reprova** entrada de Histórico datada de 2026-08-19 em diante que não declare N — checagem **E16**. Virou trava porque, medido na T25, a regra existia aqui desde 2026-07-12 e **nenhuma** skill a cumpria: o gatilho disparou dezenas de vezes e a prática não aconteceu uma. Entradas anteriores ao corte não são reprovadas — regra retroativa não conserta o passado, só suja o presente.)* *(Caso real: um comentário "optional" onde devia ser "mandatory" causou >90% de falha; corrigida A PALAVRA, as retentativas zeraram — Langfuse 2026-02-26, garimpo LF3.)*
2. **Conclusão prematura.** O agente corre um passo → primeiro **afie o critério de conclusão daquele passo**; só divida a sequência se os passos seguintes distraírem do atual.
3. **Sedimento.** Camadas de conselho velho que ninguém remove (inclui a antiga armadilha "informação que envelhece"). **Regra anti-sedimento: uma skill deve ficar mais curta ou mais afiada com o tempo — ao adicionar uma regra, remova a redação antiga que ela substitui; não empilhe conselho para sempre.** *(2026-08-06, garimpo mattpocock G1)* **O ambiente também é fonte da verdade** — `pom.xml`, `package.json`, o layout de pastas, a saída de `--help` —, e o documento que o repete é um **cache**: só se paga quando a consulta é cara. Cacheie o que o agente **não acha olhando** (a convenção não escrita, o motivo de uma escolha, a pegadinha que nenhuma config confessa) e deixe a consulta de um arquivo/um comando para o ambiente, onde ela não envelhece.
4. **Espalhamento (sprawl).** Regra longe do conceito que ela governa; material pesado no corpo (vai para `referencia/` — Selo §10.5); pasta `referencia/`/`scripts/` criada sem uso (antiga armadilha). *(2026-08-06, garimpo mattpocock G1)* **Teste de revelação — decide o que fica e o que vai para `referencia/`: embuta no corpo o que TODO ramo precisa; empurre para trás do ponteiro o que SÓ ALGUNS ramos alcançam.** (Ramo = caso distinto que a skill trata, em que execuções diferentes tomam caminhos diferentes.) Não é otimização de token: é o que protege a hierarquia. Numa skill com passos, referência que devia estar revelada **soterra os passos** e transforma prestar atenção neles em cara ou coroa.
5. **Duplicação.** O mesmo conselho em duas seções — ou em duas skills (use fonte única + referência, padrão RO-15). Trocar de termo no meio (antiga armadilha) é duplicação disfarçada: escolha um termo e repita.
6. **Negação** *(2026-08-06, garimpo mattpocock G1)*. Dirigir por proibição **arrasta o comportamento proibido para o contexto e o torna MAIS disponível, não menos** — *não pense num elefante*, e só há elefante. A negação é um modificador fraco que o conceito fortemente ativado atropela, e a proibição se lê pela metade como instrução de fazer. **Prompte o positivo:** enuncie o comportamento-alvo ("escreva comentário de uma linha") de modo que o proibido nunca seja pronunciado. **Exceção declarada:** guardrail duro que não se enuncia positivamente (as Salvaguardas inegociáveis, o "NÃO acione para" da §4) permanece negativo — e mesmo aí vem **emparelhado com o alvo positivo**, para a atenção cair no que fazer.

### Regras de escrita do corpo

- **Cada passo termina com critério de conclusão checável.** "Todo arquivo modificado listado" > "resuma as mudanças". *(2026-08-06, garimpo mattpocock G1)* O critério tem **dois eixos, e o segundo é o que costuma faltar**: **clareza** (dá para distinguir feito de não-feito? limite vago — "entendimento alcançado" — convida à conclusão prematura do modo 2) e **exigência** (quanto ele obriga? *"toda entidade modificada prestada em conta"* força escavação que *"produza uma lista de mudanças"* não força). Exigência não depende de haver passos: *"toda regra aplicada"* amarra um corpo de referência plana do mesmo jeito que *"todo passo feito"* amarra uma sequência — é assim que skill sem passos ainda carrega barra de exaustividade. **O critério forte é checável E exaustivo.**
- **Palavras-guia fortes:** conceitos compactos que o modelo já domina ("causa-raiz", "teste de regressão", "laço apertado") ancoram comportamento e economizam tokens. *(2026-08-06, garimpo mattpocock G1)* **Prefira a palavra que o modelo já traz do pré-treino à palavra cunhada:** cunhar funciona se você define bem, mas termo inventado **não recruta priors** — você paga em tokens de definição o que uma palavra existente entrega de graça. E a palavra-guia também passa pelo teste do no-op: palavra fraca demais para vencer o padrão do modelo ("seja minucioso", quando ele já é minucioso-ish) é no-op, e a correção é uma palavra **mais forte** ("implacável"), não outra técnica.
- **Co-localize a regra com o conceito que ela governa** — não em seção separada de "observações".
- **Formatos de força** para regra inegociável (uso comedido — viram papel de parede se usados em tudo): bloco destacado tipo **"Lei de Ferro"** · tabela **Desculpa → Realidade** (desmonta racionalizações previsíveis do modelo, por nome) · lista **"Red Flags — PARE"** (frases-gatilho que o próprio modelo reconhece em si). *Proveniência: praticados nas skills-bandeira do hermes-agent (`test-driven-development`, `systematic-debugging`), não no padrão de autoria deles.* **Régua de escalada (2026-07-12, garimpo Langfuse LF3):** escale a força (linha → destaque → Lei de Ferro) quando o mesmo erro **reincidir com a redação vigente** — reincidência comprovada = **≥2 ocorrências em artefatos ou datas distintas** (colheita da Aprendizagem, relatório do testador ou **placar de eval real** — caso sintético não conta para escalada), **posteriores à redação vigente**, citadas no Histórico da skill ao escalar (2 falhas no mesmo relatório = incidente, não reincidência). **Exceção declarada:** regra de segurança/irreversibilidade pode nascer no grau máximo sem esperar reincidir — **registrando no Histórico o risco irreversível nomeado** (o que se perde e por que não pode esperar; rótulo "segurança" sem risco nomeado não ativa a exceção). *(Caso real: o erro `{var}` vs `{{var}}` só morreu quando o aviso escalou a CRITICAL — Langfuse 2026-03-24.)*

**Critério de revisão (padrão RO-14):** após as próximas 5 edições de skill — ao menos 3 mais curtas ou mais afiadas = anti-sedimento funcionando; virou burocracia sem mudar qualidade → rebaixar de regra a recomendação, com motivo.

---

> ⚠️ **Nota de reconstrução (2026-07-07):** o final original deste documento (deste §11 em diante, incluindo a seção Histórico) foi perdido por truncamento — achado registrado no [[ROADMAP]] item 0. Como o Git não estava acessível na sessão de restauração, este §11 foi **reconstruído** a partir dos registros em [[ROADMAP]] e `_arquivo-morto/novo-conceito-2026-07-09/PROPOSTA-EVOLUCAO-v1.md`. Se a versão original for recuperada do Git, ela prevalece sobre esta reconstrução. As **adições datadas de 2026-07-12** (itens 5–6 do §11, o §12 inteiro e as entradas v2.2/v2.3 do Histórico — garimpos hermes-agent e Langfuse) estão **fora do escopo desta reconstrução** — a prevalência do Git não as alcança.

---

### 📜 Histórico
- **2026-08-27 (v3.2) — As 4 Dimensões de Validade de Avaliações (garimpo inspect_evals 2026-08-27 · UK1; degrau §6.10: 1 — só edição).** §11 ganhou o **item 10** definindo as 4 dimensões obrigatórias para auditoria de evals (Claims Coherence, viabilidade/verificabilidade de falha, alinhamento direto com o ground truth e edge cases de pontuação). Proveniência: `.claude/skills/eval-validity-review/SKILL.md` de `github.com/UKGovernmentBEIS/inspect_evals` (MIT) — laudo em `garimpo-lote-9-fontes-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-27 (v3.1) — Protocolo de Evals Determinísticos para Ferramentas e Extensões (garimpo anthropics 2026-08-27 · AN1; degrau §6.10: 1 — só edição).** §11 ganhou o **item 9** com os 5 requisitos de estabilidade para evals de tools/MCPs/extensões (independência, somente-leitura, complexidade realista, verificação exata por string sem juiz probabilístico, estabilidade temporal). Proveniência: `skills/mcp-builder/SKILL.md` de `github.com/anthropics/skills` (Apache-2.0) — laudo em `garimpo-lote-6-fontes-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-18 (v3.0) — Validação que passa congela o candidato (garimpo archify 2026-08-18 · G3; degrau §6.10: 1 — só edição):** §11 ganhou o **item 8**. O ciclo baseline → skill → reteste dizia como chegar ao verde e **não dizia o que acontece depois dele**: o artefato aprovado podia ser editado seguindo a carregar o mesmo veredito. Agora, mudou → revalida, e o recibo é outro. É o par temporal do "não canonize durante a medição" do `zelador-do-catalogo` — aquele protege a medição em curso, este protege o resultado depois de passar. Fonte: `tt-a1i/archify` @ `e1ac748f` (MIT), §Fast authoring path passo 4. Laudo em `garimpo-archify-2026-08-18.md`.

- **2026-08-09 (v2.9) — Garimpo 3 repos (G12-10; degrau §6.10: 1 — só edição):** §4 ganhou a **regra 8** — `allowed-tools` não restringe (medição da casa, T68) e `disallowed-tools`, que restringe, **vale por mensagem e some depois**; skill cuja garantia depende da ausência de uma ferramenta precisa repetir a trava ou declarar que a garantia é por passo. Proveniência: `best-practice/claude-skills.md` de `github.com/shanraisshan/claude-code-best-practice` (MIT) — laudo em `garimpo-3repos-2026-08-08.md`.
> Seção restaurada por reconstrução em 2026-07-07 (o original foi perdido no truncamento acima descrito); entradas anteriores resumidas a partir do histórico do [[README]].

- **2026-08-08 (v2.8) — Garimpo cienciaedados → guia oficial de Skills da Anthropic (G03a, G03b, G03c):** §4 ganhou a **regra 7 — `<` e `>` proibidos no frontmatter**, porque ele é injetado no system prompt e colchete angular ali é vetor de injeção (restrição da plataforma, *Security restrictions*, pág. 11 e 31); a proibição termina no frontmatter, e o corpo mantém o padrão literal onde o gerador aprende a nomear arquivo. Achado com **defeito em produção**: `springboot-entity` carregava `V<N>__<descricao>.sql` na `description` — corrigido na mesma rodada, e o `validar-skills.ps1` ganhou as checagens **E11** (colchete angular) e **E12** (`README.md` dentro da pasta da skill), ambas provadas contra alvo sintético. §4.6 ganhou a **banda de aviso em 922 caracteres** (90% do teto), materializada no aviso **A5** — 18 das 60 skills disparam hoje, três com menos de 20 caracteres de folga. §11.7 passou de três para **quatro níveis de pressão**, com a entrada do nível **alheio** (tarefa vizinha, e o acerto é *não* disparar): os três originais mediam só sub-acionamento, e o disparo indevido — risco natural da nossa prática de sinônimos — nunca tinha sido medido. **O grosso do guia não entrou:** progressive disclosure, qualidade de description, gatilho negativo e teste de acionamento já existiam aqui em versão mais desenvolvida, e a técnica de perguntar ao modelo "quando você usaria esta skill?" foi **cortada como contraindicada** — é o modo 0 de falha. Registro em `garimpo-cienciaedados-2026-08-08.md`.
- **2026-08-06 (v2.7) — Garimpo `affaan-m/ECC` v2.1.0 (E1, E7, E8):** §12 ganhou o **modo de falha 0 — autoavaliação no lugar de fato** (item respondível sem abrir nada é autoavaliação disfarçada; peça o artefato, porque a investigação necessária para produzi-lo é o que muda o resultado), numerado como zero para preservar a numeração 1–6 já citada em outras skills; a redação completa e o portão de três estágios vivem no `auditor-responsabilidades` (fonte única). §11 ganhou o item 7 — **três níveis de pressão do prompt** (apoiador / neutro / **concorrente**), com a régua de que independência de prompt é a medida que importa e o registro de que o nível concorrente nunca foi medido aqui. §6.10 passou a dizer que **o degrau mais baixo inclui o que já existe fora daqui**, com o vetting obrigatório de skill externa antes da adoção. Registro em `garimpo-ecc-2026-08-06.md`.
- **2026-08-06 (v2.6) — Garimpo `mattpocock/skills` (G1):** §4 ganhou o **ponteiro de contexto** (a redação decide o disparo, não o alvo), os **dois orçamentos** (carga de contexto × carga cognitiva), a medição de 60.223 caracteres (~15 mil tokens) de carga permanente das 57 descriptions e o conflito declarado "um gatilho por ramo" × prática de sinônimos (157/159 medidos em 2026-07-18) — sem mudar a prática, com o critério de "ramo novo entra, renomeio não". §12 passou a **6 modos de falha** com a entrada de **Negação** (proibição torna o proibido mais disponível; prompte o positivo, guardrail duro como exceção emparelhada), o modo 3 ganhou **ambiente como fonte da verdade / documento como cache**, o modo 4 ganhou o **teste de revelação por ramo**, o critério de conclusão ganhou o eixo **exigência** e as palavras-guia ganharam **pré-treinada > cunhada**. Registro em `garimpo-mattpocock-2026-08-06.md`.
- **2026-07-20 (v2.5):** `agents/openai.yaml` incorporado à anatomia e ao DoD, com contrato de nome, descrição curta e prompt explícito por skill.
- **2026-07-13 (v2.4) — Emendas da poda P1 (auditoria de notas):** §5a — a Rede da skill supersede "Trabalho em conjunto" quando não há nuance própria; §5b — "Regras de implementação" opcional quando as Convenções absorvem tudo. Aprovadas nominalmente pelo Jeremias junto do lote da poda de duplicação (registro em `_auditoria/2026-07-13-P1-poda-aplicacao.md`).
- **2026-07-12 (v2.3) — Garimpo Langfuse, Lote 1 (LF2+LF3+LF6):** §11 ganhou acionamento/aderência (prompts sem nomear a skill obrigatórios; colunas `acionou`/`aderiu`; contorno = defeito da skill) e casos sintéticos com salvaguardas anti-circularidade; §12 ganhou o caso dos modificadores de obrigatoriedade e a régua de escalada de força (≥2 reincidências datadas; exceção para regra de segurança); Selo §10.1 com evidência externa do disparo. Registro em `Novo Conceito/garimpo-langfuse-blog-2026-07-12.md`.
- **2026-07-12 (v2.2) — Garimpo hermes-agent, Lote 1 (P1+P6):** §6 ampliado para **10 princípios** (§6.1 reescrito como "toda linha deve mudar comportamento"; entraram §6.9 manutenção proativa e §6.10 escada de pegada); criado o **§12 — Escrita do corpo** (5 modos de falha nomeados, regra anti-sedimento, critério de conclusão checável, palavras-guia, formatos de força), absorvendo as antigas "Armadilhas a evitar" do §6; DoD do §9 ganhou a linha do degrau da escada. Registro completo em `Novo Conceito/garimpo-hermes-agent-2026-07-12.md`.
- **2026-07-07 (v2.1):** §11 (Baseline antes do eval) e seção Histórico restaurados por reconstrução, com nota de proveniência.
- **2026-07-05 (v2) — Reforma Lendária:** §10 (Selo Lendário) com o bloco 🔗 Rede da skill; tipos **Testador (executor)** e **Maestro** adicionados ao §2/§5; DoD do §9 ampliado.
- **2026-06-15 (v1):** criação do padrão único (tipos, anatomia, description, princípios, convenções, multi-código por tracks, DoD).
