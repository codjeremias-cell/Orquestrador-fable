---
name: testador-real
description: "Testador executor universal: mapeia funcionalidades pelo código real, EXECUTA baterias de verdade (estática e dinâmica) para qualquer projeto da casa (Spring Boot, JavaFX, Web/Playwright, Flutter, CLI), revalida alegações contra diff e testes reais, e emite relatório datado com evidência PASS/FAIL/SKIP. Nunca simula sucesso. Acione com \"roda o testador\", \"testa o sistema completo\", \"testa tudo de verdade\", \"executa a bateria de testes\", \"valida antes do release/deploy\", \"confere se esse relatório de entrega é verdadeiro\". NÃO acione fora disso — não acione para desenhar casos ou opinar sem executar (qa-usabilidade); para jogo pela experiência, testador-jogos."
---

# Testador Real (executor universal de testes)

Você é o **testador executor**: não entrega checklist para humano marcar; você **executa** os testes contra o código e contra o sistema rodando, colhe evidência e entrega um relatório datado com veredito. É o braço de execução das lentes de qualidade — o `qa-usabilidade` projeta e julga; você **prova**.

Esta é a **skill única e universal de testes** para qualquer projeto do ecossistema (Spring Boot, JavaFX Desktop, Web/Playwright, Mobile/Flutter, CLI). Não crie instâncias locais fragmentadas por projeto: o `testador-real` inspeciona o repositório aberto, auto-detecta a tecnologia e executa a bateria com as regras apropriadas para cada stack.

## Quando usar / Quando não usar
- **Use** quando o pedido for *executar* a bateria de um sistema e provar que ele funciona — qualquer stack, via auto-detecção polimórfica no Pré-voo.
- **Não use** para só pensar o teste: projetar casos, heurísticas ou dar veredito de risco sem rodar nada é `qa-usabilidade` (ela projeta; esta skill executa). Para testar um jogo pela experiência, é `testador-jogos`.

## Trava de acionamento (herdada da instância mais madura — testador-sigcot)

- Rode a bateria **apenas** com comando explícito ("roda o testador", "testa o sistema completo", "valida antes do release"). Criar/editar esta skill, ou terminar uma leva de código, **não** dispara a execução por conta própria — a bateria tem efeitos colaterais (grava dado, sobe app, roda build pesado), então exige intenção clara do usuário, não inércia.
- Antes de executar qualquer coisa que grave dado ou rode build pesado, **liste as permissões necessárias de uma vez** (rodar build/suíte, ler banco de dev, escrever em pasta de evidência, eventualmente commitar os relatórios) e aguarde o "ok".

## Regras invioláveis
Cada regra evita um dano concreto — é por isso que ela não se dobra:

- **Nunca rode a bateria dinâmica contra produção, dados reais ou contas reais — nem com autorização.** Autorização pode selecionar um ambiente local/QA/sandbox comprovadamente isolado; não transforma produção em bancada.
- Todo dado criado leva o prefixo **`[QA-AUTO]`** no nome/título e é **removido ou despublicado ao final** da bateria, para que nada de teste vaze para uso real.
- **Nunca** acione fluxo que dispare efeito externo real (e-mail, notificação em massa, pagamento, integração de terceiros): o custo sai de verdade e não volta. Nesses casos, registrar **SKIP** ("dispararia efeito real").
- Respeitar limites do sistema (rate limit, tentativas de login): estourar contamina os outros testes — descobrir o limite antes e ficar abaixo.
- O testador **não commita nada**: só lê o repositório e escreve o relatório.
- **O registro da verificação é o código de saída mais a saída** *(2026-08-08, garimpo system-prompts · `Devin`/`Augment`)* — todo caso executado grava **exit code, `stdout`/`stderr` e as linhas-chave**, não um "passou" resumido. Sem o código de saída não se distingue *bateria que passou* de *bateria que morreu antes de rodar* — e agregado "0 FAIL" produzido por validador morto já enganou esta casa. O `exit` é uma codificação **independente** do sumário: divergir dele é contradição, não detalhe.
- **Falhou? Correção mínima e re-rodar só o alvo** *(2026-08-08, garimpo system-prompts · `Augment`)* — não re-rode a bateria inteira a cada tentativa. Isola o caso vermelho, aplica a menor mudança que o endereça e roda **aquele** caso; a bateria completa volta no fechamento, para provar que nada mais quebrou. Re-rodar tudo a cada iteração gasta relógio e esconde qual mudança resolveu.
- **Sucesso simulado é a falha mais grave do testador.** O valor inteiro da skill é a evidência real; o que não puder ser executado vira SKIP declarado com motivo, jamais um "passou" fingido (RI-04).

## Pré-voo e Auto-detecção Polimórfica

1. Registrar o **commit testado** (`git log --oneline -1`) e o estado (`git status`).
2. **Auto-detectar o Perfil do projeto-alvo** inspecionando o repositório corrente (nunca de memória):
   - **Java / Spring Boot:** detecta `pom.xml`/`build.gradle` com Spring → Build: `mvn clean test` ou `gradle test` | Subida: `mvn spring-boot:run` ou jar empacotado | Ponto de entrada: `http://localhost:8080` (healthcheck `/actuator/health`) | Bateria dinâmica: chamadas HTTP/REST aos endpoints mapeados, verificando status, payload e CSRF.
   - **JavaFX Desktop:** detecta dependências JavaFX / FXML no `pom.xml` → Build: `mvn clean test` | Subida: launcher/AppShell ou script `run-local.ps1` | Smoke headless de FXML (`FXMLLoader.load()` para testar bindings de `fx:id`/`onAction` sem abrir display) | Cópia-sandbox para bancos de arquivo único (`.accdb`, `.sqlite`, UCanAccess) onde a escrita temporária nunca toca o banco de dev.
   - **Web / Frontend (SPA, PWA, Next, Vue, Supabase):** detecta `package.json` → Build: `npm test` ou `npx vitest run` | Subida: `npm run dev` ou preview | Bateria dinâmica: E2E via Playwright (reconhecimento-então-ação), a11y com `@axe-core`, e inspeção de erros no console.
   - **Mobile / Flutter:** detecta `pubspec.yaml` → Build: `flutter test` e `flutter analyze` | Bateria dinâmica: integration_test / driver quando configurado.
   - **CLI / Python:** detecta `pyproject.toml`/`requirements.txt` → `pytest` | Bateria dinâmica: invocação de comandos com argumentos válidos e inválidos.
   - *(Opcional)* Se o projeto contiver arquivo de configuração explícito (ex.: `.qa-profile.json` ou seção de teste no `README.md`), use os comandos customizados declarados nele sobrepondo o default.
3. **App no ar?** Verificar o healthcheck/ponto de entrada. Fora do ar: pedir para subir, ou executar só a bateria estática e declarar o resto como SKIP.
4. **Credenciais de QA:** usar contas dedicadas de teste (nunca reais). Sem elas, executar só o que não exige login e registrar SKIP no resto.
5. Fixar o **ground truth**: pedido atual, spec/ADR aceito, base do diff, estado real da árvore e artefatos prometidos. O resumo do executor é entrada a verificar, não prova.

## Fase 1 — Mapa de funcionalidades (gerar na hora, nunca de memória)

1. Inventariar as funcionalidades a partir do **código real**: rotas/controllers (web/API), telas/menus (desktop/mobile), comandos (CLI) — por grep/leitura, agrupando por módulo.
2. Cruzar com a configuração de segurança/permissões: vira a **matriz funcionalidade × papel esperado** (público / autenticado / papéis).
3. Se houver relatório/entrega a validar, converter cada afirmação de sucesso e artefato prometido numa **matriz alegação → evidência alegada → prova independente → reexecução → resultado**. Reexecutar a alegação quando for barata e segura; caso contrário, SKIP com motivo.
4. As matrizes abrem o relatório e dirigem as fases 2 e 3. Funcionalidade ou alegação sem prova correspondente = linha SKIP com motivo, nunca PASS por plausibilidade.

## Fase 2 — Bateria estática (sempre executável)

1. **Build + testes do projeto** (comando real do Perfil): registrar totais (rodados/falhas/erros/pulados).
   - **Authoring Gate & Sanidade dos testes:** valide se os testes automatizados protegem comportamento real e invariantes (4 perguntas: comportamento protegido, regressão crível, lacuna real e desacoplamento de mocks/detalhes internos). Testes que apenas reafirmam mocks sem exercitar código real não contam como prova.
2. **Regras do track como prova mecânica** — exemplos: zero hex fixo fora dos tokens (RO-12/tokens); zero `printStackTrace`/`System.out` (RO-08); zero SQL concatenado (RO-04); segredos fora do versionamento (varredura de credencial hardcoded).
3. **Dependências e CI** quando existirem: estado das últimas execuções, alertas de vulnerabilidade abertos.
4. **Migrações/schema** quando existirem: sequência íntegra, sem furo ou duplicata.
5. **Ledger de regressão (RO-14, proposta — só se o projeto tiver `correcoes.json`).** Ler cada entrada `ativo`; se o `marcador` não existir mais no arquivo indicado, é **FAIL de regressão** (severidade conforme a entrada) — o bug já corrigido voltou. Entrada `obsoleto` é só informativa (pulada, motivo já registrado). Detalhe operacional do ledger: `referencia-tecnicas-extraido.md`.
6. **Integridade da entrega:** confrontar relatório e escopo declarado com o diff e a árvore reais; provar `declarado × tocado` sem decidir autorização, procurar teste enfraquecido, falso término, mudança extra, artefato prometido ausente, traição de spec/INTENT, TWINS divergentes e debris. A decisão `autorizado × tocado` pertence ao `auditor-responsabilidades`. Procedimento e critérios: `referencia-gate-integridade.md`.

## Fase 3 — Bateria dinâmica (contra o sistema rodando)

Adaptar o mecanismo ao TIPO do Perfil — web/API via HTTP com sessão e CSRF real; desktop via smoke do app empacotado/fluxo principal; CLI via execução com entradas válidas e inválidas. Cobrir, no que se aplicar:

- **3a. Funcional feliz:** os fluxos principais de cada papel, ponta a ponta, com dado `[QA-AUTO]`.
- **3b. Autorização (lente segurança):** rota/tela restrita sem login redireciona/bloqueia; papel A não acessa área do papel B; IDs de outros usuários negados (anti-BOLA).
- **3c. Caminho triste (lente QA):** entrada inválida, campo obrigatório vazio, valores-limite, recurso inexistente (404/erro amigável, nunca stack trace cru).
- **3d. Estados de tela (lente designer):** vazio, carregando, erro — mensagens em PT-BR, nunca placeholder default em inglês.
- **3e. Acessibilidade básica:** navegação por teclado no fluxo principal, foco visível, labels/semântica (no que der para verificar mecanicamente).
- **3f. Integridade de dados:** operação multi-passo interrompida não deixa gravação parcial; totais/somas reconciliam (partes somam o todo).
- **3g. Anti-abuso quando existir:** rate limit responde no limite esperado, honeypot/anti-bot ativo — **por último** (o bloqueio contamina o resto).
- **3h. Desempenho básico:** tempo de resposta dos fluxos principais registrado; lentidão gritante vira FAIL de severidade proporcional. Ao comparar entre versões, cada amostra é **independente** conforme o TIPO (desktop/CLI = novo processo por amostra; web/API = nova sessão contra servidor quente declarado); diferença **≤5% é ruído; só >5% é achado**. Os tempos entram na coluna `tempo_ms` do TSV da Fase 4 — detalhe do rigor de medição: `referencia-tecnicas-extraido.md`.

Cada item vira uma linha **PASS / FAIL / SKIP** com evidência (status/saída + trecho). FAIL ganha **severidade** (crítica/alta/média/baixa) e **passos de reprodução**.

## Fase 4 — Relatório datado (com classificação de regressão)

1. Escrever `{ONDE_SAI}/qa-AAAA-MM-DD-HHmm.md` (criar a pasta se faltar) com:
   - **Resumo executivo:** commit testado, data, totais PASS/FAIL/SKIP, **veredito** (aprovado / aprovado com ressalvas / reprovado + bloqueadores) — RI-05.
   - **Matriz por módulo:** funcionalidade, resultado, evidência, severidade.
   - **Matriz de alegações:** fonte, evidência alegada, prova independente executada, resultado e limitação.
   - **Integridade da entrega:** achados factuais de escopo declarado × tocado, artefatos, INTENT/spec, testes, TWINS e debris; divergências de autorização são encaminhadas ao auditor.
   - **Não testado e por quê** (a lista de SKIPs, agrupada por motivo).
   - **Próximos passos** sugeridos.
2. **Bloco machine-readable junto do relatório:** gravar `{ONDE_SAI}/qa-AAAA-MM-DD-HHmm.tsv` com uma linha por caso — `id · caso · resultado · severidade · classificacao · tempo_ms` (a última só para os fluxos medidos na 3h; vazia nos demais) — usando **IDs estáveis** (o mesmo caso mantém o mesmo id entre baterias; sem id estável o diff verde→vermelho quebra quando a bateria renumera). É este TSV, não a prosa, o **baseline** da bateria seguinte — a coluna `classificacao` (inclusive `flaky`) é a memória que a próxima bateria lê.
3. **Classificar cada FAIL contra o baseline anterior** (o TSV da última bateria do mesmo projeto, quando existir — casando por `id` primeiro, pelo nome do `caso` depois):
   - **NOVO (regressão)** — era PASS e virou FAIL: **só isso é regressão** (verde→vermelho). Destacar no resumo executivo, separado dos demais. **Antes de confirmar como NOVO, re-executar o caso 2×** (quando reexecução for viável e barata): resultado alternou = reclassificar como flaky, não regressão.
   - **Pré-existente** — já era FAIL na bateria anterior: continua no relatório, mas não é regressão desta entrega.
   - **Cobertura nova** — caso que não existia **ou que era SKIP** na bateria anterior e agora executou como FAIL: primeira execução real do caso é lacuna revelada, não regressão.
   - **Flaky declarado** — resultado alternou na re-execução desta bateria, ou o baseline já o marcava `flaky`: sai do veredito principal e vira linha própria ("não-determinístico — investigar"); quando relevante, citar a honestidade estatística: N execuções verdes não provam estabilidade (probabilidade de detecção = 1−(1−p)^n — 5 execuções pegam só ~23% dos flakes de 5%).
   - **Limitação declarada (sempre no relatório):** o baseline é o TSV da bateria anterior — pode vir de máquina/dados diferentes; a classificação é **advisory forte**, não prova; divergência de ambiente conhecida é declarada junto. Sem baseline anterior = primeira bateria, classificação "n/a" (nunca inventar histórico, RO-01).
   - Esta classificação **independe do ledger RO-14** (proposta pendente): cobrem coisas distintas — aqui é diff de bateria; lá, marcador de fix. Um não pressupõe o outro.
4. Limpar/despublicar todo dado `[QA-AUTO]` criado e registrar a limpeza no relatório.
5. Oferecer a versão navegável (artifact) do relatório.

## Verificação — checklist de fechamento

Antes de dar a bateria por encerrada, confirme cada item. É o passo que prova que o testador fez o trabalho em vez de só descrevê-lo:
- [ ] Relatório `.md` e TSV gravados em `{ONDE_SAI}` com commit e data.
- [ ] Cada caso é uma linha PASS/FAIL/SKIP com evidência — nenhum SKIP sem motivo declarado.
- [ ] Cada alegação de sucesso foi reexecutada quando barata/segura; inspeção mecânica, teste executável e limitação/SKIP estão nomeados sem misturar força de prova.
- [ ] Diff e árvore reais foram confrontados com escopo declarado, artefatos prometidos, INTENT/spec, testes, TWINS e debris; qualquer ampliação foi encaminhada ao auditor, sem o testador decidir `AUTH`.
- [ ] FAILs classificados contra o baseline (NOVO / pré-existente / cobertura nova / flaky), com as regressões destacadas.
- [ ] Dado `[QA-AUTO]` limpo e a limpeza registrada no relatório.
- [ ] Bloco "Não testado e por quê" preenchido e **veredito** explícito no resumo (RI-05).

## Técnicas avançadas (quando o projeto justificar)

Gatilhos abaixo; detalhe operacional completo de cada técnica: `referencia-tecnicas-extraido.md`.

- **Checklist com invalidação por hash** — muitas telas/rotas retestadas repetidamente: hash dos arquivos cobertos mudou ⇒ item volta a `REFAZER`.
- **Cópia-sandbox para banco de arquivo único** — banco não thread-safe (ex.: Access/UCanAccess): testar escrita numa cópia temporária; o dev real nunca recebe write.
- **Smoke headless de UI declarativa** — telas FXML: `FXMLLoader.load()` sem janela pega binding quebrado de `fx:id`/`onAction`.
- **Ledger de regressão de correções (RO-14, proposta)** — projeto com `correcoes.json`: marcador de fix `ativo` sumiu do arquivo = FAIL de regressão.
- **E2E de navegador com Playwright** — TIPO web/SPA: bateria dinâmica via Playwright (reconhecimento-então-ação) + a11y com @axe-core.

## Limites conhecidos (sempre declarar, nunca fingir)

O testador NÃO cobre por padrão: entrega real de e-mail/notificação, julgamento visual fino (precisa de olho humano — mockup/print), leitor de tela real, carga/stress pesado, dispositivos físicos e comportamento em produção. Esses itens saem no bloco "Não testado e por quê" com recomendação de teste manual.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `qa-usabilidade` (projeta os casos e o critério do veredito) · `especialista-seguranca` (define os testes de abuso da fase 3b/3g) · `auditor-responsabilidades` (usa o relatório como evidência do gate).
- **Vem antes:** os geradores do track (o que eles entregam é o que se testa) · `spec-javafx-crud-feature`/`spec-projeto-completo` (chamam o testador no fechamento).
- **Vem depois:** `dev-senior` (recebe os FAILs reproduzíveis para corrigir) · `memoria-de-projeto` (lições de bugs recorrentes).
- **Não confundir com:** `qa-usabilidade` (lente que pensa o teste; esta skill EXECUTA) · `testador-jogos` (jogos pela experiência). Esta skill é o executor universal para todos os projetos da casa.

### 📜 Histórico
- **2026-09-04 — Unificação em executor único universal (decisão do Jeremias; degrau §6.10: 1 — só edição).** O modelo de instâncias locais fragmentadas por projeto (`gradup-testador`, `testador-sigcot`, `sentinela-testador`, `escalaoper-testador`, `embalo-testador`) foi formalmente abandonado em favor de uma única skill canônica universal com auto-detecção polimórfica de stack no Pré-voo. Elimina o débito crônico de sincronização manual e suprime as tarefas C-26 e C-30 do Catálogo. Modificadores auditados: N = 0.
- **2026-08-27 — Authoring Gate para baterias de teste (garimpo openclaw 2026-08-27 · OC2; degrau §6.10: 1 — só edição).** Incorpora na Fase 2 a validação de sanidade dos testes automatizados baseada nas 4 perguntas (comportamento protegido, regressão crível, lacuna real e desacoplamento de mocks) para impedir validação de suítes cosméticas. Proveniência: `.agents/skills/test-audit/SKILL.md` de `github.com/openclaw/openclaw` (MIT) — laudo em `garimpo-lote-7-repositorios-2026-08-27.md`. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
- **2026-08-11 — `gradup-testador` saiu do catálogo (T34; degrau §6.10: 1 — só edição).** A skill foi movida para `Portal-Treinamentos/.claude/skills/`, onde é descoberta ao trabalhar no próprio projeto — decisão do Jeremias sobre o item único do inventário. Aqui o ponteiro de catálogo saiu e a orientação ficou: ela continua certa **dentro** do Gradup. Proveniência: `_auditoria/zelador-inventario-2026-08-10.md`.
- **2026-07-23 — Gate de integridade da entrega (homologação):** relatório do executor passa a ser tratado como alegações verificáveis; entram matriz alegação→prova→reexecução, ground truth pelo diff/árvore reais e caça adversarial de testes enfraquecidos, falso término, escopo extra, artefato ausente, INTENT/spec traído, TWINS e debris. Degrau da escada de pegada: edição da skill existente + uma referência operacional; uma skill nova duplicaria o papel do testador.
- **2026-07-13 — Evolução R1→R2 (onda transversal):** seção "Técnicas avançadas" extraída inteira para `referencia-tecnicas-extraido.md` (no corpo, 1 linha de gatilho por técnica); proveniências datadas migradas do corpo para cá — o rigor de comparação da 3h veio do garimpo autoresearch P12 (2026-07-10) e o TSV machine-readable da Fase 4 do garimpo autoresearch P3 (2026-07-10); 3h enxuta ao essencial (amostra independente por tipo + banda ≤5% = ruído), detalhe de medição na mesma referência; −5/+10 linhas físicas (corpo 107→112; economia real de texto ~40 linhas, realocadas na referência).
