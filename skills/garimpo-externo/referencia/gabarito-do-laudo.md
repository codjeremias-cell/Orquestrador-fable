# Gabarito do laudo de garimpo

A forma do documento, destilada dos **sete laudos reais** desta casa. Ela está aqui, e não no corpo
da skill, porque só quem chega ao Portão 6 precisa dela — os cinco portões anteriores decidem sem
consultar formato (teste de revelação, [[PADRAO-DE-AUTORIA]] §12.4).

Nome do arquivo: `garimpo-<fonte>-<AAAA-MM-DD>.md`, na **raiz** do catálogo. Segunda rodada da mesma
fonte: o mesmo arquivo ganha `# ⛏️ Rodada 2` abaixo da primeira, e a data do nome não muda.

---

## A ordem das seções

```markdown
---
tipo: garimpo
papel: laudo de aceite de fonte externa
fonte: <URL> @ <commit ou data de acesso>
licenca: <licença declarada no repo, ou "não declarada">
data: AAAA-MM-DD
metodo: <triagem por nome + leitura integral do que endereça lacuna nomeada>
fontes-lidas: <arquivo a arquivo, de um lado E do outro — o repo E as skills consultadas>
absorvido:                    # um item por achado ADOTADO; a chave some quando não houve adoção
  - achado: G<n>
    path: <caminho do arquivo NA FONTE>
    sha256: <64 hex do conteúdo bruto, conforme obtido na data acima>
---

# ⛏️ Garimpo: `<fonte>`

## Veredito de uma linha
## 🚑 Precondição bloqueante          ← só quando existe; vai ANTES da colheita
## 🔒 Segurança — classe de risco declarada
## ⚖️ Proveniência e licença — leia antes de usar qualquer coisa daqui
## O que já tinha sido colhido — não redescobrir
## Cobertura desta rodada — N de M
## Tabela-mestra                       ← Pepita | Nosso estado | Veredito
## Nível 1 — O que absorver
### G1 · <origem na fonte> → **<skill destino>** · degrau <n>
## Nível 2 — Skill nova (degrau 3)     ← com a tabela `Degrau tentado | Por que não bastou`
## Nível 3 — Cortados, com o motivo
## O corte mais caro — a joia da coroa ← prosa, 3–4 argumentos rotulados
## ⚔️ Conflito real                    ← quando houver; devolve a decisão
## Observação devolvida ao zelador-do-catalogo  ← número bruto, sem veredito sobre o acervo
## 📌 Cobertura declarada — o que NÃO foi garimpado
## 📌 Rastro de proveniência
## Registro
## 🔧 Correção …                        ← anexada aqui, datada, quando o método falhou
```

---

## O bloco `absorvido:` — o digest do que entrou *(2026-08-18, garimpo oh-my-opencode · G4)*

O cabeçalho já pinava **onde** a pepita foi encontrada (`fonte @ commit`). O que faltava era **o que
foi lido**: sem digest, a revisão futura — a de 60 dias, a da rodada 2 — não consegue responder "a
fonte mudou de posição desde então?", e acaba re-lendo tudo ou confiando na memória.

Receita, e ela é de duas linhas:

```bash
curl -sSfL https://raw.githubusercontent.com/<owner>/<repo>/<ref>/<path> | sha256sum
```

Colha **só o que foi adotado** — não o que foi lido. Um laudo com 17 pepitas e 5 adoções tem 5 linhas
aqui, não 17: digestar o cortado é pagar manutenção por decisão que já está fechada.

**O guardrail, e ele é o de sempre nesta casa: digest de arquivo não é identidade.** Normalização de
fim de linha muda o número sem mudar uma palavra do texto. Por isso o campo declara o digest do
**conteúdo bruto conforme obtido**, com a data ao lado, e **divergência futura é PERGUNTA** — *"a
fonte mudou; vale reabrir?"* — **nunca invalidação automática do laudo nem da regra que nasceu dele**.
Uma regra adotada sobrevive à fonte que a inspirou; o digest serve para decidir se vale olhar de novo,
não para revogar.

---

## Entra → sai: uma pepita ADOTADA

**Entra** (o que a fonte diz):

> "Before creating a new skill, search the existing catalog. Most requests are already covered."

**Sai** (a entrada do laudo):

```markdown
### G8 · `docs/authoring.md` §3 → **`PADRAO-DE-AUTORIA` §6.10** · degrau 1 · 1 linha

**Nosso estado:** PARCIAL. A escada de pegada existe e cobre os quatro degraus
(`PADRAO-DE-AUTORIA.md:96`, seção aberta e lida) — mas ela ordena *onde* a capacidade
aterrissa, e não manda **procurar antes**. Procurei por "buscar antes", "já existe",
"duplicata" no corpo inteiro: nada.

**Cliente real:** o próprio `zelador-do-catalogo`, criado em 2026-08-06 depois de duas
propostas de skill que já tinham dono.

**Degrau 1, e por que o de baixo basta:** o conceito já mora na §6.10; falta uma oração.
Arquivo: `PADRAO-DE-AUTORIA.md`, §6.10, ao fim do parágrafo do degrau 3.

**Guardrail:** procurar não vira veto — achado que existe **fora** daqui ainda passa pelo
Portão 1 antes de entrar (skill de terceiro é cadeia de suprimentos).

✅ **ADOTAR**
```

Repare no que faz a entrada valer: *nosso estado* tem **caminho e seção aberta**, o cliente tem
**nome próprio**, o degrau tem **arquivo exato** e o guardrail impede a regra nova de contradizer a
skill que a recebe.

---

## Entra → sai: uma pepita CORTADA

**Entra:** um motor de busca BM25 compartilhado entre as skills — a peça mais elaborada do
repositório de origem.

**Sai:**

```markdown
### G8 · motor de busca BM25 → ❌ **CORTAR**

**Etiqueta:** capacidade sem cliente.

**Nosso estado:** Não aplicável. As 60 skills são carregadas por gatilho semântico (RI-06),
não por busca; nenhuma skill consulta índice.

**Por que corto** — este é o corte mais importante deste laudo, e vai em prosa:

(a) O cliente não existe: nada nesta casa consulta um índice, e construir o motor criaria a
demanda que ele diz servir.
(b) Contradiz a arquitetura de ativação: busca por termo compete com o gatilho semântico em
vez de reforçá-lo.
(c) Nem o ROADMAP nem o PLANO-EVOLUCAO preveem motor de busca.

**Precedente:** mesma etiqueta do corte de 2026-07-14, e pelo mesmo motivo.
```

O corte da joia da coroa **paga a justificativa mais cara que qualquer adoção**. Os cortes óbvios
ficam agrupados numa linha só; este, nunca.

---

## Entra → sai: um CONFLITO declarado

```markdown
## ⚔️ Conflito real — "um gatilho por ramo" × a nossa prática de sinônimos

**A posição da fonte:** um gatilho por ramo; sinônimo que renomeia o mesmo ramo é ramo escrito
duas vezes. **Mede:** carga de contexto permanente.
**Evidência dela:** o custo por turno de toda `description` carregada.

**A nossa posição:** encher a `description` de sinônimos. **Mede:** acerto de rota.
**Evidência nossa:** 157/159 frases acertando o destino na onda de 2026-07-18.

**As duas medem coisas diferentes, e nenhuma foi medida contra a outra.**

**Síntese proposta:** manter os sinônimos e, ao *adicionar* um, perguntar se ele abre ramo novo
ou só renomeia um existente.

**Devolvido ao Jeremias** — muda o comportamento de uma skill que ele usa todo dia.
```

Empate com evidência dos dois lados **não é do garimpeiro desatar**.

---

## A tabela-mestra

Três colunas fixas, e a do meio é o instrumento inteiro:

| Pepita | Nosso estado | Veredito |
|---|---|---|
| G1 · resumo em 6 palavras | **PARCIAL** — `skill-x/SKILL.md` §4 cobre A e B, não cobre C (seção aberta) | ✅ ADOTAR · degrau 1 |
| G2 · … | **SIM e mais rigoroso** — `skill-y` §11 já exige o baseline antes | ❌ CORTAR · coverage superior |
| G3 · … | **Contraindicado** — colide com o anti-AI-slop da `designer-ux-ui` | ❌ CORTAR · contraindicado |

O identificador (`G1…Gn`) é o mesmo da tabela até o fim do documento, e nos laudos seguintes que o
citarem.

---

## A citação que a skill editada carrega depois

Toda edição nascida deste laudo leva, no 📜 Histórico da skill editada:

```
garimpo <fonte> <AAAA-MM-DD> · G<n>
```

É a ligação achado → mudança. Sem ela, a linha vira regra órfã: daqui a seis meses ninguém sabe de
onde veio nem o que provou que ela devia entrar.
