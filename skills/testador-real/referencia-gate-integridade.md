# Referência — Gate de integridade da entrega

> Carregue esta referência quando houver relatório, resumo de execução, lista de artefatos ou alegação de “pronto” a validar. Ela complementa as Fases 1, 2 e 4 da `SKILL.md`; não autoriza bateria sem comando explícito nem relaxa os guardrails contra produção e efeitos externos.

## 1. Fixar o ground truth antes de ler a conclusão

Registre as fontes verificáveis nesta ordem:

1. pedido atual do Jeremias, em suas palavras;
2. spec, critérios de aceite e ADRs aceitos;
3. base declarada da mudança e diff real (`git status`, diff staged/unstaged e comparação com a base);
4. árvore real de arquivos e artefatos produzidos;
5. comandos executáveis do projeto e suas saídas.

O relatório do executor vem depois: ele diz **o que precisa ser provado**, não prova a si mesmo. Se a base do diff for ambígua, declare a ambiguidade e limite o veredito; não escolha silenciosamente uma base conveniente.

Defina **INTENT** em uma frase checável: “a entrega deve produzir `{resultado}` dentro de `{escopo}`, preservando `{restrição}`”. Havendo conflito entre pedido atual e ADR aceito, aplique RI-01: declare o conflito e peça decisão, sem resolver por conta própria.

## 2. Matriz alegação → prova

Uma linha por afirmação verificável ou artefato prometido:

| id | alegação e fonte | evidência alegada | método independente | reexecução | resultado | evidência real/limitação |
|---|---|---|---|---|---|---|
| CLM-01 | “todos os testes passam” — relatório | log colado | teste executável | comando + exit code | PASS/FAIL/SKIP | caminho do log + trecho |
| CLM-02 | “manual atualizado” — pedido | arquivo citado | inspeção mecânica | não se aplica | PASS/FAIL | existência + diff relevante |

Use três classes de prova, sempre nomeadas:

- **Inspeção mecânica:** existência, conteúdo, diff, grep, hash, schema ou contagem. Prova estrutura, não comportamento.
- **Teste executável:** comando/fluxo realmente rodado, com ambiente, exit code/estado observado e saída preservada.
- **Limitação/SKIP:** prova inviável, insegura, cara sem autorização, dependente de produção, credencial ou efeito externo. Registre o bloqueio e o que seria necessário para executar.

**Regra de reexecução:** alegação de sucesso barata e segura é reexecutada independentemente, mesmo que o relatório traga log verde. Reuso de log anterior pode corroborar, nunca substituir a reexecução atual. Se o teste puder disparar e-mail, pagamento, notificação, integração real, escrita em produção ou exceder a permissão concedida, não execute: SKIP com motivo.

## 3. Caça adversarial no diff e na árvore

Não pare no primeiro verde. Procure deliberadamente:

1. **Teste enfraquecido:** teste removido, renomeado para não ser descoberto, `skip`/`ignore`, assertion apagada ou afrouxada, mock que elimina a integração, snapshot/baseline atualizado apenas para aceitar a saída errada. Verde obtido assim não confirma a alegação.
2. **Falso término:** relatório diz “pronto”, mas há TODO/stub, caminho não implementado, teste não executado, comando interrompido, erro oculto ou evidência de outra revisão/commit.
3. **Escopo extra:** arquivo ou comportamento fora do INTENT/escopo declarado. Registre factualmente `declarado × tocado` e prove o delta por diff/árvore; não classifique autorização nem aceite “necessário e explicado” como substituto de `AUTH`. Alegação “não houve mudança extra” refutada = FAIL da alegação. Existência de mudança extra, declarada ou não, é encaminhada à `auditor-responsabilidades`, que decide `autorizado × tocado` e o efeito no gate.
4. **Artefato prometido ausente:** arquivo, migração, relatório, documentação, pacote ou prova nomeada no pedido/relatório não existe no local esperado ou está vazio/inutilizável.
5. **Traição de spec/INTENT:** implementação passa nos testes existentes, mas muda contrato, decisão de ADR, formato público, restrição ou resultado pedido. A spec real prevalece sobre teste incompleto.
6. **Debris:** arquivo temporário, log, dump, backup, saída de build, credencial, dado `[QA-AUTO]`, debug ou untracked gerado sem destino. Diferencie evidência deliberadamente versionável de resíduo acidental.

Para cada achado, cite arquivo/comando e impacto; não atribua intenção ao autor.

## 4. TWINS — artefatos que precisam se espelhar

TWINS são dois artefatos que representam o mesmo contrato e deveriam mudar juntos: schema ↔ migração, OpenAPI ↔ cliente gerado, código ↔ documentação, enum ↔ opções de UI, fonte ↔ runtime gerado.

1. Descubra pares pelo pedido, convenções do projeto e diff; não invente obrigação que o projeto não possui.
2. Declare o invariante compartilhado (campos, versão, rotas, valores ou hash esperado).
3. Compare mecanicamente os dois lados e, quando houver gerador oficial, regenere apenas em sandbox/cópia autorizada para comparar o diff.
4. Divergência comprovada = FAIL; par plausível mas não verificável = SKIP com limitação. “Parecem alinhados” nunca é PASS.

## 5. Regra de fechamento

O veredito só pode ser:

- **Aprovado:** todas as alegações bloqueadoras confirmadas por força de prova adequada; nenhum desvio crítico/alto de integridade.
- **Aprovado com ressalvas:** limitações/SKIPs ou achados não bloqueadores estão explícitos, com risco e próximo passo.
- **Reprovado:** alegação bloqueadora refutada, teste enfraquecido, artefato obrigatório ausente, spec/INTENT/ADR traído, alegação de escopo refutada ou evidência fabricada. Ampliação factual de escopo sem alegação falsa segue como achado para decisão do auditor.

O relatório deve separar fatos observados, inferências e limitações. Nunca promova inspeção mecânica a prova de comportamento nem trate ausência de evidência como PASS.
