# Contabilidade de métricas e regras do placar

Referência carregada sob demanda pelo `orquestrador-fable`. O corpo da skill aponta para cá quando é hora de montar a contabilidade e registrar/avaliar o placar da rodada.

## Contabilidade de métricas (por frente)

Na descoberta de runtime, registrar quais métricas são realmente expostas. Ao concluir, cada subagente devolve apenas esses campos; anotar no fechamento quando o runtime não os preserva depois. Campo não exposto fica **não reportado**, nunca estimado ou reconstruído em silêncio (RI-04).

O relatório traz uma linha por frente, inclusive orquestração:

| Rodada | Frente | Classe | Modelo descoberto | Status | Tokens | Duração | Skill | Nota |
|---|---|---|---|---|---|---|---|---|
| 1 | Planejamento + consolidação | orquestração | `<id-runtime>` | concluída | não reportado | 00:03:10 | `orquestrador-fable` | — |
| 1 | Implementação da frente A | geral | `<id-runtime>` | concluída | 8.420 | não reportado | `<skill>` | 9,2 |
| 1 | Revisão de segurança | crítica | `<id-runtime>` | concluída | 3.110 | 00:01:44 | `especialista-seguranca` | 8,5 |
| 1 | Bateria de testes | geral | `<id-runtime>` | concluída | não reportado | 00:02:08 | `testador-real` | — |

**Status** usa `concluída`, `refeita`, `falhou` ou `bloqueada`; **Tokens/Duração** recebem o valor reportado ou `não reportado`; **Nota** é 0–10 quando aplicável. Emoji não é contrato de dado.

Fechar com resumo apenas das classes/modelos efetivamente usados. Se tokens não estiverem disponíveis em todas as linhas, não calcular porcentagem parcial como se fosse total:

| Classe | Modelo descoberto | Frentes | Tokens reportados | Cobertura da métrica |
|---|---|---:|---:|---:|
| orquestração | `<id-runtime>` | 1 | não reportado | 0/1 |
| geral | `<id-runtime>` | 2 | 11.530 | 2/2 |
| **Total observado** | — | **3** | **11.530** | **2/3** |

Regras: tokens, não moeda; não converter por preço chumbado. Métrica com cobertura incompleta é observação, não total da tarefa. A tabela orienta otimização apenas quando há cobertura suficiente e comparação homogênea.

## Regras do placar

- Nota é **por lente**, 0–10, sempre acompanhada do motivo e do que falta para subir — nota sem crítica acionável não vale.
- O placar de cada rodada é registrado (rodada, notas, FAILs abertos, o que mudou) — é ele que prova a evolução (RI-04).

### O placar de UMA rodada é um número: a menor nota entre as lentes

*(2026-08-18 — fecha o achado 6 do `evals/placar-comite-2026-07-24.md`, aberto com confiança alta: "detector de anti-estagnação não é computável do dado persistido — falta regra de agregação das N notas de uma rodada".)*

Uma rodada produz **N notas** (uma por lente). Toda regra abaixo que diz "o placar da rodada" refere-se a **um** valor, e ele é definido assim:

> **`placar(rodada) = min(notas das lentes pertinentes daquela rodada)`.**

**Isto é derivado, não escolhido.** A regra de corte já é conjuntiva — *"todas as lentes ≥ 9,5"* —, então a nota que decide é sempre a **mínima**. Média deixaria um 10 mascarar um 7 e reportaria "subiu" numa rodada que o gate reprova: o detector passaria a medir grandeza diferente da que o gate lê. Com `min`, detector e gate leem o mesmo número.

Três bordas, para o valor nunca ficar ambíguo:

- **Rodada sem Comitê** (o gate de conformidade barrou antes das notas, ou a rodada só teve execução) **não tem placar** e **não entra na janela** — mesma disciplina do detector (b): o que não computou não conta como estagnação, mas também não conta como progresso.
- **Lente não pertinente** àquela entrega não entra no `min`. Quais são as pertinentes é decisão do maestro no passo 4, e ela é **registrada junto do placar** — senão o `min` muda de significado entre rodadas e a comparação deixa de ser homogênea.
- **FAIL crítico do testador** não vira nota; ele impede `≥ 9,5` por outra via e é registrado à parte.

- **Anti-estagnação (v2 — 2026-07-10, garimpo autoresearch P6; agregação fixada em 2026-08-18):** três detectores, todos param antes do teto e perguntam ao Jeremias: (a) **estagnação** — janela deslizante das últimas **3 rodadas**: o melhor `placar(rodada)` da janela (pela definição acima) não supera o `placar(rodada)` de antes dela = estagnado (cobre a oscilação: nota que sobe-desce e no líquido não sobe **também é estagnação**; o modo métrica usa a própria janela, de 5 iterações); (b) **falha de infraestrutura** — rodada que crashou/não computou é declarada e **não conta** como estagnação, mas 2 seguidas = bloqueio (parar e reportar: algo está quebrado, insistir é desperdício); (c) **oscilação de campeão** — **o maestro conta as trocas** de vencedor do portão pareado no placar que ele mesmo persiste (`estado-projeto`); >3 trocas em 5 rodadas = o ciclo não está convergindo, parar (os vereditos vêm da `painel-de-juizes`; a contagem e a decisão são do maestro — juiz tem contexto limpo, não vê histórico). Insistir no mesmo plano é desperdício, não persistência.
- **Calibração da nota (faixas, proposta 2026-07-07, do harness GAN/ECC):** 1–3 = quebrado/genérico ("AI slop") · 4–6 = funciona mas cru, inconsistente · 7–8 = polido e coeso · 9–10 = excelente, à prova de borda (o piso do conjunto, RI-02). Serve para as lentes pontuarem consistente: lente que dá 9 num resultado que "só funciona" está calibrando frouxo — o auditor sinaliza.
