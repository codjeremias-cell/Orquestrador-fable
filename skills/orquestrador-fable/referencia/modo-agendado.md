# Modo agendado — trabalho que roda sozinho no tempo

Referência carregada sob demanda pelo `orquestrador-fable`. O corpo aponta para cá quando a triagem
cai em **trabalho recorrente/agendado**.

> **Origem:** estudo `Novo Conceito/estudo-modo-agendado-2026-07-12.md` (P12 do garimpo
> `nousresearch/hermes-agent`), decidido na **T19** e desenhado na **T41**, ambas em 2026-08-18.
> Até então esta linha da triagem era a **única célula sem ação** — roteador que não roteia, achado 3
> do `evals/placar-comite-2026-07-24.md`, aberto desde julho.

## 1. A plataforma — medida, não suposta

O estudo supunha "tarefas agendadas do Cowork". **Medido em 2026-08-18, existem dois mecanismos, e
eles não são intercambiáveis:**

| | `CronCreate` | `scheduled-tasks` |
|---|---|---|
| Onde vive | memória da sessão | disco: `~/.claude/scheduled-tasks/{id}/SKILL.md` |
| Sobrevive ao fim da sessão? | **não** | **sim** |
| Validade | recorrente **expira em 7 dias** | até ser desligada |
| App fechado na hora | perde | roda no próximo lançamento |
| Memória entre execuções | — | **nenhuma** |

**Para trabalho agendado de verdade, o mecanismo é `scheduled-tasks`.** O `CronCreate` serve para
lembrete dentro de uma sessão viva e nada além — um monitor semanal montado nele morre antes da
segunda execução.

**A consequência que manda no desenho:** *"cada execução começa do zero, sem memória desta conversa"*.
O prompt agendado é **autossuficiente ou não é nada** — e é exatamente o contrato que a
`estado-projeto` já resolve. Rotina não lembra; ela **lê o estado**.

## 2. Fronteiras invioláveis

Herdadas do §4 do estudo, e nenhuma é negociável:

- **Rotina não agenda rotina.** Só o Jeremias cria, altera ou remove agendamento.
- **Rotina não decide.** Ela observa, compara e **avisa**. Mudar arquivo, promover, publicar,
  commitar ou despachar subagente está fora — o ato é sempre de uma sessão com gente presente.
- **Rotina não fala com produção nem com dado real.** A triagem de comandos derivados
  (`referencia/triagem-segura-de-comandos.md`) vale integralmente, e aqui é mais rígida: rotina é
  **somente leitura**, exceto pelo próprio arquivo de marcador.
- **Consentimento na origem, e ele expira.** O agendamento nasce de um pedido explícito, com prazo
  declarado. Vencido o prazo, a rotina se desliga e pede renovação em vez de continuar.
- **`[SILENT]` com trilha.** Execução sem novidade **não notifica**, mas registra que rodou. Silêncio
  que não deixa rastro é indistinguível de rotina morta.

## 3. A trava contra acordar para sempre — *fingerprint* e `stopped`

O risco central de trabalho agendado não é errar: é **continuar**. Uma rotina que acorda toda semana
num projeto parado é custo permanente disfarçado de diligência.

**Regra:** cada execução calcula um **fingerprint** do que observa. **Duas execuções seguidas com o
mesmo fingerprint = `stopped`** — a rotina se desliga sozinha e deixa dito por quê.

- O fingerprint cobre **o que a rotina julga**, não o arquivo inteiro: para o Piloto 1, o conjunto
  `(numero, status, prioridade, bloqueada_por)` de cada tarefa aberta. Assim, editar prosa de
  `resultado` não conta como movimento, e mudar um status conta.
- **Estado TERMINAL × INCERTO** *(garimpo hermes)*: rotina que não conseguiu ler o alvo está
  **incerta**, não parada — e incerteza **não** zera o contador de `stopped`, mas também não o
  incrementa. Duas leituras falhas seguidas = **bloqueio declarado**, não desligamento silencioso.
- Desligar é sempre **reversível e explicado**: a rotina deixa no marcador a data, o fingerprint
  repetido e a frase que o Jeremias usaria para religá-la.

## 4. Piloto 1 — monitor de pendências do ledger

**O alvo mudou.** O estudo o descrevia como *"monitor semanal de pendências do **ROADMAP**"*; a
**T24** aposentou o ROADMAP como fila em 2026-08-18. O alvo é `estado/estado.json` — e a troca
**melhora** o piloto: sai de contar marcas em Markdown e passa a comparar campos de JSON.

**Implementação:** [`estado/monitor-pendencias.py`](../../../estado/monitor-pendencias.py) — Python da
stdlib, somente leitura sobre o ledger, escreve apenas o próprio marcador.

**O que ele procura, em ordem de valor:**

| Sinal | Por que importa | Caso real que o justifica |
|---|---|---|
| **Prazo vencendo** | é o único que tem relógio | a T25 tinha data-alvo ~2026-09-12 |
| **Bloqueio que caiu** | tarefa `bloqueada` cujo bloqueador fechou | ninguém volta para desbloquear |
| **Evento de gatilho ocorrido** | critério que esperava um evento, e o evento veio | a T28 achou um vencido em ~2026-08-11, **uma semana depois** |
| **Parada longa** | aberta sem mudança de `atualizado_em` há N semanas | a T24 achou fila de julho nunca migrada |

**Quando fica quieto:** nada vencido, nada desbloqueado, nada parado além do limiar. Silêncio é o
caso comum, e é o que torna a notificação legível quando ela vem.

**Dois ledgers:** o monitor lê **todos** os `estado/estado.json` do projeto e **nomeia cada um**.
Mesma disciplina do hook `lembrete-de-contexto` — e pela mesma razão: a numeração colide.

## 5. Como se instala (ato do Jeremias)

```
mcp__scheduled-tasks__create_scheduled_task
  taskId         monitor-pendencias-catalogo
  cronExpression 17 9 * * 1          # segunda, 9h17 local — minuto fora de :00/:30 de propósito
  description    Monitor semanal de pendencias do ledger do Catalogo
  prompt         (autossuficiente: caminho do repo, comando, o que fazer com a saída)
```

O prompt precisa carregar tudo — caminho absoluto do cofre, o comando a rodar, e o que fazer com cada
tipo de saída. **A execução não lembra nada desta conversa.**

## 6. Critério de sucesso e reversão (padrão RO-14)

**Quatro semanas.** Sucesso = **≥1 notificação útil** (útil = levou a uma ação do Jeremias) **e** zero
notificação-spam **e** zero ato fora das fronteiras do §2.

Falha em qualquer um → **arquivar o modo com motivo**, não ajustar o limiar até parecer bom. Limiar
que se afrouxa para o piloto passar é o eval que se rebaixa para a nota subir.

## 7. O que este modo NÃO é

- **Não é o `Monitor`** do harness, que assiste a um processo vivo e reage no instante. Aqui o relógio
  é de parede e a granularidade é de dias.
- **Não é o modo métrica.** Lá um loop persegue uma métrica até o alvo; aqui nada é perseguido —
  observa-se e avisa-se.
- **Não substitui a revisão de garimpo.** A rotina lembra que o **evento** chegou; quem julga é a
  sessão, com a skill do assunto carregada.
