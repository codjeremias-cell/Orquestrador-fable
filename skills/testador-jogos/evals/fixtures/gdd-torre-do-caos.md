# GDD — Torre do Caos (roguelite mobile)

**Versão:** 0.9 · **Autor:** estúdio indie (1 dev + 1 artista) · **Plataforma:** Android/iOS, free-to-play
**Elevator pitch:** um roguelite de escalada onde cada run é única — suba a Torre, morra, tente de novo. **Pilar central: "só mais uma run".**

## Público-alvo

Jogador **casual mobile** (25-40 anos), joga no transporte e em filas, sessões de 5-15 minutos. Não é fã hardcore de roguelike — queremos ser a porta de entrada do gênero.

## Loop central

Escalar andares da Torre em combate por turnos rápidos → coletar relíquias e ouro → morrer (ou vencer o andar 200) → recomeçar do andar 1.

## Estrutura e conteúdo

- **200 andares**, divididos em checkpoints visuais a cada 50 (mesma Torre, iluminação muda).
- **1 bioma** (interior da Torre) no lançamento; bioma 2 planejado para a temporada 2.
- **3 tipos de inimigo** (Esqueleto, Cultista, Gárgula) com stats escalando por andar; boss a cada 50 andares (mesmo boss, +50% de vida por aparição).
- **Permadeath total:** morrer zera a run — sem meta-progressão entre runs no lançamento (upgrades permanentes ficam para a temporada 2; queremos que a habilidade do jogador seja o único progresso).

## Onboarding

Tutorial obrigatório de **15 minutos** cobrindo os 9 sistemas (combate, relíquias, ouro, gemas, energia, forja, maldições, bênçãos, ranking). Não pulável na primeira sessão — dados de outros jogos mostram que quem pula tutorial dá churn.

## Controles

- 4 botões virtuais (ataque, defesa, habilidade 1, habilidade 2) na base da tela;
- **swipe** para trocar de alvo; **segurar** o botão de habilidade para ver o tooltip;
- combos por sequência (ex.: defesa → segurar ataque = contra-ataque).

## Economia e monetização

- **Ouro** (soft): dropa nas runs, compra relíquias na forja durante a run. Zera na morte.
- **Gemas** (hard, paga): compra energia, **continue após a morte (1× por run, 50 gemas)** e cosméticos. Pacote inicial R$ 19,90.
- **Energia:** cada run consome 1 raio; **1 raio regenera a cada 40 minutos** (máx. 3). Assinatura mensal remove a energia.
- **Anúncio recompensado de 30 segundos após cada morte** (obrigatório na versão grátis) — é onde projetamos 60% da receita.

## Métricas-alvo

D1 40% · D7 15% · sessão média 12 min · 3 runs/dia por usuário ativo.

## Riscos conhecidos pelo time

Arte de 1 bioma pode cansar; boss repetido é aposta consciente (orçamento).
