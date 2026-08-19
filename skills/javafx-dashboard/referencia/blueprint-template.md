# Blueprint do dashboard — preencher ANTES de construir

O blueprint é o contrato de design. Ele força as decisões certas enquanto ainda é barato mudar (no texto/mockup, não no FXML). Preencha-o, gere o mockup a partir dele e só então construa (RO-06). Um campo que você não consegue preencher é uma pergunta para o Jeremias, não um chute.

## Template (copie e preencha)

```markdown
# Blueprint — [Nome do painel]

## 1. Propósito (uma frase)
Painel para [público] [decidir o quê] [com que cadência].
> Ex.: "Painel para o operador da sala decidir, em tempo real, onde a janela vai estourar."

## 2. Arquétipo
[ ] Executivo/Estratégico   [ ] Operacional/Tempo real   [ ] Decisão/Analítico
Implicações: densidade = __ · cadência/refresh = __ · interação = __ · horizonte de tempo = __

## 3. Perguntas que o painel responde (3–7)
1. …
2. …
(Se passar de 7, provavelmente são dois painéis.)

## 4. KPIs / indicadores
Para cada um:
| KPI | Pergunta que responde | Fonte (DAO/método/query) | Fórmula / janela | Contexto (meta / comparação) | Cor semântica | Sem-dado |
|-----|----------------------|--------------------------|------------------|------------------------------|---------------|----------|
| Eventos em andamento | Há crise agora? | DashboardDAO.getKpis(data) → "eventos" | status ∈ {em campo} hoje | vs. ontem (Δ▲▼) | danger se >0 | "—" |

## 5. Gráficos
Para cada um:
| Gráfico | Pergunta | Tipo escolhido | Por que esse tipo (regra do design-canon) | Dados (fonte/forma) |
|---------|----------|----------------|-------------------------------------------|---------------------|
| Backlog por estágio | Onde está o gargalo? | Barra horizontal ordenada | comparação entre categorias → barra; ordenar conta a história | DashboardDAO.getEstagios(data) → Map<estágio,qtd> |

## 6. Tabelas de detalhe (se houver)
Quais listas item-a-item, colunas, e se permitem ordenar/persistir layout.

## 7. Layout (grid + hierarquia)
Esboço da grade (o mais importante no topo-esquerda). Ex.:
- Linha 1: bandeira de estado (largura total)
- Linha 2: 4–6 KPIs
- Linha 3: 2 gráficos | 2 gráficos
- Linha 4: tabelas de detalhe

## 8. Estados
- Vazio: [texto PT-BR do placeholder]
- Carregando: [placeholder + botão desabilitado]
- Erro: [mensagem amigável]
- Sem-dado por KPI: como cada número exibe ausência (nunca 0 falso)

## 9. Veracidade e atualização
- Carimbo de frescor: "Atualizado às HH:mm" / data de referência: [onde aparece] (vira "Falha ao atualizar às HH:mm" no erro)
- Refresh: [cadência/mecanismo real do projeto] — no SIGCOT: **manual + automático a cada 30 min** (gabarito, não regra universal); greenfield sem projeto-irmão, decida pelo arquétipo e declare **SUPOSIÇÃO:**
- Reconciliação: [que totais têm que bater, ex.: soma dos estágios = total de SIs]
- Temas: confirmar que o painel vira em **todos os temas que o projeto declara** — no SIGCOT hoje: **4** (claro/escuro/cinza/grafite; corrigido de um "6" desatualizado, ver Histórico da SKILL.md) — reconfirme a contagem real no CSS/enum do projeto-alvo, não copie este número às cegas

## 10. Mockup
[link/descrição do mockup gerado e aceito]
```

## Exemplo trabalhado (resumido) — Painel operacional da sala de controle

- **Propósito:** painel para o operador decidir, em tempo real, onde intervir antes da janela estourar.
- **Arquétipo:** Operacional → densidade alta com hierarquia, atualização manual + automática a cada 30 min, alertas que saltam, horizonte = agora/próximas horas.
- **Perguntas:** (1) Há evento em crise agora? (2) Quantas AES estão em campo? (3) Onde está o backlog? (4) Qual janela está perto de estourar?
- **KPIs:** Eventos em andamento (danger, vs. ontem); AES em campo (info); Estouro de janela (danger, "—" se sem dado); Concluídas hoje (success). Cada um com fonte em `DashboardDAO` e hover de detalhe (`HoverDetalhe`).
- **Gráficos:** Backlog por estágio → **barra ordenada** (gargalo salta); SIs por dia → **linha** (tendência). Nada de pizza aqui.
- **Layout:** bandeira de crise (topo) → linha de KPIs → barra | linha → tabela "estouro de janela" embaixo.
- **Estados:** placeholder "Nenhum evento em andamento", carregando com botão off, erro via `AlertHelper`. "0 em campo" ≠ "sem dado".
- **Veracidade:** "Atualizado às HH:mm" no header (vira aviso no erro); refresh manual + 30 min; soma dos estágios reconcilia com total de SIs ativas.

> Note como cada escolha de gráfico se justifica por uma regra do `design-canon.md` e cada número aponta para um método real do `DashboardDAO` (`sigcot-stack.md`). É essa rastreabilidade dupla — design + dado — que faz o painel ser de excelência.
