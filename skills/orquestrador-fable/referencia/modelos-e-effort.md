# Capacidades do runtime e eixo de effort

Referência carregada sob demanda pelo `orquestrador-fable`. Nenhum nome comercial, quantidade de slots ou nível de effort é presumido: o runtime da sessão é a fonte da verdade.

## Descoberta obrigatória

Antes do plano, registrar um inventário:

| Campo | Como preencher |
|---|---|
| `orchestrator` | identificador do modelo mais capaz disponível para planejar/consolidar; **não executa subtarefa** |
| `workers[]` | identificadores realmente delegáveis e suas capacidades documentadas/expostas |
| `effort_levels[]` | níveis aceitos por worker; `não suportado` quando o runtime não oferece o eixo |
| `slots_total` / `slots_livres` | valores expostos pelo runtime naquele momento; se não forem consultáveis, usar apenas a capacidade de disparo observável e abrir ondas conservadoras |
| `metrics[]` | somente campos efetivamente reportados (`tokens`, duração etc.); ausência não vira estimativa |

Inventário vazio ou contraditório é `PENDING`: o maestro não inventa worker, effort ou paralelismo para manter o ciclo andando.

## Classes de capacidade

Mapear identificadores descobertos às classes abaixo **para esta sessão**. A classe é requisito da frente; o identificador é implementação do runtime.

| Classe | Papel | Quando |
|---|---|---|
| **orquestração** | analisa, planeja, consolida e decide | sempre no maestro; não recebe frente executora |
| **crítica** | arquitetura, algoritmo complexo, decisão difícil, alto custo de erro | complexidade/risco alto ou falha por capacidade |
| **geral** | feature definida, testes, documentação técnica, lentes | padrão quando não há motivo para subir ou reduzir |
| **mecânica** | busca, extração, conversão e alteração repetitiva bem especificada | tarefa barata de conferir e refazer |

Se o runtime oferecer só uma classe executora, usá-la e declarar a limitação; não fingir diversidade. Se um identificador puder cumprir várias classes, escolher a menor capacidade que satisfaça risco + complexidade.

## Effort — o segundo eixo

Capacidade escolhe *o que o executor consegue resolver*; **effort** escolhe *quanto rigor ele aplica*. O maestro designa `classe + identificador + effort` quando o runtime suportar:

- subir **capacidade** quando a falha mostra insuficiência de conhecimento/raciocínio;
- subir **effort do mesmo executor** quando a falha mostra arquivo pulado, teste não rodado ou conclusão prematura;
- reduzir effort apenas em trabalho mecânico com aceite barato e objetivo;
- se o runtime não expõe effort, reforçar o contrato, a evidência e o gate; registrar `effort: não suportado`.

## Slots e largura

A onda usa `min(slots_livres, frentes_independentes_prontas)`. Reservar capacidade para revisão/teste quando o runtime compartilha o mesmo pool. Mais frentes que slots viram ondas sequenciais; frente bloqueada por entrada ou dependência não ocupa slot.

O piloto de 1–2 frentes representativas continua útil em decomposição grande, mas não autoriza um teto fixo. Julgamento e consolidação permanecem estreitos porque o custo de integrar cresce mesmo quando o runtime dispõe de muitos slots.

> Ligado ao **Escalonamento em 2 eixos** do passo 6 (ver `ciclo-detalhado.md#decisao`): falhou por não saber o bastante → sobe a **classe de capacidade**; falhou por não tentar o bastante → sobe o **effort** do mesmo executor, quando suportado.
