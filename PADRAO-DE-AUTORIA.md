---
tipo: padrão
papel: como toda skill deste conjunto deve ser criada
última-atualização: 2026-07-05
versão: v2
---

# 📐 Padrão de Autoria de Skills

> A receita única para criar **qualquer** skill deste conjunto, de forma que todas tenham o mesmo nível de qualidade, disparem na hora certa e respeitem as [[REGRAS-DE-OURO]].
> Este documento é a fonte da verdade do "como fazer skill". Antes de criar ou editar uma skill, leia daqui a seção que se aplica.

---

## 1. O que é uma skill (e o que não é)

Uma skill é uma **receita** que ensina o Claude a fazer uma tarefa sempre do mesmo jeito, sem precisar reexplicar tudo toda vez. É uma pasta com um arquivo `SKILL.md` dentro (e, quando preciso, `referencia/`, `scripts/`, `assets/`).

Uma skill **não** é: um despejo de teoria que o Claude já sabe, nem um documento genérico. O valor de uma skill está no que o Claude **não** tem por padrão: as **suas** regras, o **seu** formato exato, os **seus** exemplos reais.

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
6. **Até 1024 caracteres.** Se não couber, a skill está fazendo coisa demais — divida.

**Modelo:**
> `Faz X [+ Y]. Acione quando o usuário disser coisas como "frase 1", "frase 2", "frase 3", ou [situação concreta]. NÃO acione para [escopo de outra skill].`

## 5. O corpo — estrutura por tipo

### 5a. Lente (método)
Estrutura validada das 9 lentes (siga-a):
`# Título` · **papel em uma frase** · `## Quando usar` · `## Quando NÃO usar` (com handoff para outra lente) · `## Postura` · `## Domínio` · `## Como operar` (passos) · `## Salvaguardas inegociáveis` (sempre com RO-01) · `## Formato de entrega` · `## Trabalho em conjunto` · rodapé **Regras de Ouro compartilhadas**.

### 5b. Gerador (track)
Estrutura validada do catálogo de geração (siga-a):
`# Título` · `## Objetivo` · `## Entradas obrigatórias` · `## Entradas opcionais` · `## Trava obrigatória` (não prosseguir sem alvo claro) · `## Leituras obrigatórias` (ler o código real antes de gerar — RO-01) · `## Convenções obrigatórias` (nomes, paths, padrões) · `## Fluxo` (passo a passo determinístico) · `## Regras de implementação` · `## Guardrails` (o que nunca fazer) · `## Saída esperada` · `## Referências/Few-shots`.

### 5c. Orquestrador (`spec-`)
Delega para geradores menores, em ordem, validando cada etapa. Estrutura: `## Objetivo` · `## Entradas obrigatórias` · `## Validação do catálogo` (as skills filhas existem?) · `## Sequência determinística` (etapa → skill → validação) · `## Condições de parada` · `## Formato do relatório final`. **Não duplica** o trabalho das filhas.

### 5d. Testador (executor)
Estrutura validada no `gradup-testador` e generalizada no `testador-real`:
`# Título` · `## Regras invioláveis` (segurança do ambiente: **nunca** bateria dinâmica contra produção sem autorização explícita; dado de teste com prefixo `[QA-AUTO]` e limpeza ao final; nunca disparar e-mail/notificação real; limites de tentativas para não estourar rate limit; o testador não commita) · `## Pré-voo` (commit testado, config, app no ar?, credenciais de QA) · `## Fase 1 — Mapa de funcionalidades` (inventário gerado na hora do código real, nunca de memória) · `## Fase 2 — Bateria estática` (build, testes, lint, análise) · `## Fase 3 — Bateria dinâmica` (contra o sistema no ar, com evidência) · `## Fase 4 — Relatório datado` (PASS/FAIL/SKIP com evidência + veredito) · `## Limites conhecidos` (o que NÃO cobre, declarado — nunca um "passou" fingido).

O princípio central do testador: **o que não der para executar vira SKIP declarado com motivo** — jamais um sucesso simulado. Todo FAIL ganha severidade e passos de reprodução.

## 6. Os 8 princípios de qualidade (de toda skill)

Destilados do método Skill Planner + do catálogo de geração + das suas lições:

1. **Seja conciso.** O Claude é inteligente. Não explique o que é um PDF ou um `for`. Acrescente só o que ele não tem: suas regras, seu formato, seus exemplos.
2. **Explique o porquê, não só o quê.** "Use `try-with-resources` *porque* conexão Access não fechada trava o banco" é seguido melhor que "SEMPRE use try-with-resources".
3. **Mostre exemplos.** Um par "isto entra → isto sai" vale mais que um parágrafo. Use casos reais dos seus projetos.
4. **Trava obrigatória (geradores).** Não gere nada sem o alvo inequívoco. Na dúvida entre dois caminhos, **pare e pergunte** — não adivinhe.
5. **Leitura obrigatória antes de gerar (RO-01).** O gerador lê o código real do projeto (classe base, DAO existente, CSS de tema) antes de escrever. Nunca inventa assinatura — pede o fonte ou declara a suposição.
6. **Trate as bordas.** O que fazer quando falta dado, quando vem incompleto, qual o mínimo para valer a pena, e quando a skill deve **recusar e avisar** em vez de seguir.
7. **Determinismo.** Mesmo pedido → mesma estrutura de saída. Quando a tarefa é mecânica e repetível, prefira um `script` a "replay manual". E quando **já existe um scaffolder determinístico** do stack (ex.: Mason / Very Good CLI no Flutter, create-expo-stack no RN, create-tauri-app no desktop, shadcn MCP no web), a skill o **invoca e preenche variáveis** em vez de escrever os arquivos à mão — gerar a partir de um modelo torna classes inteiras de erro estruturalmente impossíveis *(pepita 2026-07-07, da pesquisa de tracks)*.
8. **Evidência (RI-04).** Toda saída "pronta" tem prova: build que passou, teste que rodou, print da tela. Sem evidência, não está pronto.

### Armadilhas a evitar
Informação que envelhece ("antes de agosto de 2025") · trocar de termo no meio (escolha um e repita) · descrição vaga ("ajuda com código") · caminho de arquivo no estilo Windows dentro da skill · pasta `referencia/`/`scripts/` que não vai ser usada (skill simples é só a `SKILL.md`).

## 7. Convenções do conjunto

- **Idioma:** instruções e comunicação em **PT-BR**; **código e identificadores em inglês**. Tratamento "Jeremias" (Jere) no chat.
- **Caminhos de instalação:** as skills rodam em `.agents/skills/` ou `.claude/skills/` do projeto. Trate esse caminho como **exemplo** — descubra o real em runtime, não chumbe.
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
- [ ] `description` em 3ª pessoa, com frases-gatilho reais, "Acione quando…", e "NÃO acione para…" se houver risco de colisão. ≤ 1024 caracteres.
- [ ] Corpo na estrutura do seu tipo (§5).
- [ ] Geradores: trava obrigatória + leitura obrigatória do código real (RO-01) + guardrails + saída esperada.
- [ ] Bordas tratadas (falta de dado, quando recusar).
- [ ] Convenções do conjunto respeitadas (§7) — idioma, paths/scope como exemplo, sem info que envelhece.
- [ ] Aderência às [[REGRAS-DE-OURO]] aplicáveis.
- [ ] Exemplo real "entra → sai" presente quando ajuda.
- [ ] Bloco **🔗 Rede da skill** presente (§10).
- [ ] Passou pela lente `auditor-responsabilidades` (veredito explícito).

## 10. Selo Lendário — o piso de qualidade do conjunto

"Lendário" não é adjetivo de marketing: é um **contrato verificável**. Uma skill tem o Selo quando cumpre o DoD do §9 **e** os cinco critérios abaixo. O `auditor-responsabilidades` audita skill nova ou refatorada contra esta lista.

1. **Dispara sozinha.** A `description` contém as frases reais do Jeremias e cobre sinônimos; a skill aciona sem ser nomeada (RI-06 depende disso).
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
4. **Bordas com dono.** A skill diz o que fazer quando falta dado, quando recusar, e