# Placar do Comitê de Lentes — orquestrador-fable

**Data:** 2026-07-24 · **Rodada:** 1 · **Nota de corte:** 9,5 em todas as lentes
**Artefato avaliado:** `SKILL.md` + 7 referências + `evals/` (estado do commit `6a234ec`)
**Método:** 7 lentes em paralelo, cada uma com contexto limpo (só o artefato + o critério).

## Placar

| Lente | Nota | Pertinência | Crítica de maior peso |
|---|---:|---|---|
| `arquiteto-software` | **9,2** | plena | Validação do catálogo não checa `painel-de-juizes` nem `estado-projeto` — ausência delas é deadlock, não degradação |
| `dev-senior` | **9,0** | plena | Falta seção de formato do relatório final (§5c do PADRÃO exige para orquestradores) |
| `qa-usabilidade` | **8,8** | plena | Gatilhos do `when_to_use` exigem o vocabulário interno da skill; só 1 dos 7 é linguagem natural |
| `designer-ux-ui` | **8,8** | parcial | Os 6 ponteiros dos passos usam `ciclo-detalhado.md#ancora` sem prefixo `referencia/` |
| `inovacao-melhorias` | **8,7** | plena | Não existe governador de custo/tempo — a skill aceita "orçamento de tokens" e nenhuma regra o consome |
| `especialista-seguranca` | **8,6** | plena | **BLOQUEANTE**: item 8 do gate positivo remete a "fluxo próprio" que não existe em lugar nenhum |
| `arquiteto-dados` | **8,5** | plena | **BLOQUEANTE**: o ciclo escrita→leitura do estado não fecha; grão do `placar[]` incompatível com a regra de corte |

**Média: 8,80 · Menor nota: 8,5 · Corte de 9,5: NÃO ATINGIDO** (nenhuma lente alcançou 9,5).

## Veredito

A skill **não passa no corte da própria régua**. A regra do catálogo exige **todas** as lentes
≥ 9,5, não a média — e a maior nota foi 9,2. Nenhuma lente reprovou o desenho: a distância até
o corte é feita de lacunas concretas e nomeadas, não de defeito conceitual.

Duas críticas vieram marcadas como **bloqueantes**:

1. **Gate positivo com ponta solta** (`referencia/triagem-segura-de-comandos.md`, item 8) —
   exclusão, publicação, deploy, envio, compra e migração mutante "saem deste gate e exigem
   fluxo próprio + `AUTH` aplicável", mas esse fluxo próprio não está definido em lugar nenhum.
   As operações mais perigosas são encaminhadas para um procedimento inexistente.
2. **O ciclo escrita→leitura do estado não fecha** (`arquiteto-dados`) — manda-se gravar
   "contrato da verdade vigente" e "campeão", mas o esquema de `estado-projeto` não tem campo
   para eles; e o `placar[]` é gravado no grão `rodada×frente`, enquanto a regra de corte
   ("todas as lentes ≥ 9,5") e os detectores de anti-estagnação precisam do grão
   `rodada×lente`. O dado persistido não sustenta a decisão que depende dele.

## Convergências (achado que aparece em 2+ lentes tem peso maior)

| # | Achado | Lentes | Peso |
|---|---|---|---|
| 1 | `SKILL.md:85` diz "Parar em: nota atingida **ou** 10 rodadas" — **omite a anti-estagnação**, que a referência inclui. Quem lê só o corpo não sabe que existe parada antes do teto | 4 | alto |
| 2 | "Placar persistido em arquivo" não diz **qual** arquivo, nome ou formato — checkbox não conferível e retomada frágil | 3 | alto |
| 3 | Linha "Trabalho recorrente/agendado" é a **única célula da tabela de triagem sem ação** — roteador que não roteia | 4 | médio |
| 4 | Evals **não cobrem** guardrails de segurança nem o modo métrica; e os sintéticos vieram da mesma sessão que escreveu a skill (circularidade) | 3 | alto |
| 5 | `_decisoes/ADR-001-modo-metrica.md` é citado 4× e **não resolve** de dentro da skill (a pasta não vai para os runtimes) | 3 | médio |
| 6 | Detector de anti-estagnação **não é computável** do dado persistido — falta regra de agregação das N notas de uma rodada | 2 | alto |
| 7 | Falta **seção de formato da saída final** — sabe-se o que a skill faz, não o que ela entrega | 2 | alto |
| 8 | Fórmula da largura da onda `min(slots, frentes)` **triplicada** em redação normativa | 2 | médio |
| 9 | `referencia/_indice-modo-metrica.md` é **órfão** (não citado em Recursos adicionais) e usa wikilinks que não resolvem no runtime | 2 | baixo |

## Divergência entre lentes

Houve uma divergência que merece registro: `arquiteto-software` elogiou o progressive
disclosure (corpo enxuto delegando a referências) enquanto `arquiteto-dados` apontou que essa
mesma distribuição é onde os esquemas se contradizem — três vocabulários de status para a
mesma entidade, dois esquemas divergentes de `predicado_sucesso`, duas semânticas na coluna
`Nota`. Não é contradição: a arquitetura de documento está boa, a **tipagem que atravessa os
documentos** é que não foi unificada. É o eixo mais barato de subir de nota.

## Limitação declarada

O `auditor-responsabilidades` que faria esta consolidação **não executou** — falhou por limite
semanal de cota. Esta consolidação foi feita pelo agente principal a partir dos 7 laudos
íntegros. Ela **não substitui** a auditoria de governança (conformidade RI-01…06 e RO), que
segue pendente. Duas lentes (`dev-senior`, `inovacao-melhorias`) tiveram o classificador de
segurança indisponível na revisão; seus laudos foram conferidos manualmente e são consistentes
com os demais.

O gate §11 do `PADRAO-DE-AUTORIA` continua **aberto** — este é um placar do Comitê sobre o
artefato, não a medição baseline × com-skill que o §11 exige. **Selo Lendário não declarado.**
