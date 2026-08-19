---
name: assistente-deterministico
description: "Modela e constrói um assistente DETERMINÍSTICO (100% offline, sem LLM e sem API) embutido num sistema hospedeiro: busca tolerante a typo, base de conhecimento editável, motor de documentos com form guiado, autopreenchimento, validação e saída numerada, e reuso por histórico de entidade. Acione com \"assistente\", \"quero um assistente dentro do sistema\", \"busca de procedimento/norma offline\", \"motor de documentos\", \"gerar/preencher documento a partir do cadastro\", \"autopreenchimento por entidade\", \"reuso de itens de documentos anteriores\", \"wizard/árvore de decisão\", \"assistente sem internet\". NÃO acione para chatbot/LLM ou tema livre (é o oposto: determinístico), nem confunda com orquestração (orquestrador-fable rege, painel-de-juizes compara, auditor-responsabilidades audita) — aqui você CONSTRÓI um subsistema."
---

# Assistente Determinístico (template para qualquer sistema)

Assistente que roda **dentro** de um sistema hospedeiro, **100% offline, sem LLM e
sem API**. Toda capacidade é **regra, busca, template, validação e cálculo**.
Nada sai do ambiente; nada depende de internet.

## Perfil do sistema-alvo (preencher por projeto)

- **SISTEMA:** `{nome}`
- **DOMÍNIO:** `{finalidade}`
- **STACK (linguagem/UI):** `{ex.: Java 21 / JavaFX}`
- **PERSISTÊNCIA:** `{ex.: MS Access via UCanAccess / SQL / arquivos}`
- **SAÍDA DE DOCUMENTOS:** `{ex.: PDFBox, iText, Apache POI}`
- **BUSCA:** `{ex.: Apache Lucene / índice em memória}`
- **REGRAS/CONVENÇÕES:** `{Regras de Ouro do projeto}`

Todo o restante referencia esse perfil.

## Fronteira (decidir sempre por aqui)

**Faz:** dúvidas a partir de base cadastrada; geração/preenchimento de documentos
(form guiado + autopreenchimento + reuso de histórico + validação + saída);
consultas cruzadas; cálculos; checklists; alertas por regra.

**Não faz:** tema livre; redação original de intenção vaga; resumo de documento
arbitrário; entrada não estruturada; ou responder fora da base. Texto descritivo
livre é digitado pelo usuário; o assistente guarda, valida e formata.

Essa fronteira é a **garantia de auditabilidade**. Pedido fora dela exigiria LLM:
sinalizar, não improvisar.

## Arquitetura (6 peças)

1. **MotorBusca** — normalização (minúsculas, sem acento) + similaridade
   (Levenshtein/Jaro) sobre a base. Implementar com `{BUSCA}` do perfil.
2. **BaseConhecimento (KB)** — tópicos/respostas/sinônimos cadastrados, editáveis
   pelo próprio sistema.
3. **MotorDocumentos** — schema por tipo → form guiado → validação →
   autopreenchimento → reuso de histórico → numeração/versão → saída.
4. **MotorRegras** — árvore de decisão / wizard (nó: pergunta → opções → próximo
   nó / resposta).
5. **DAO / Acesso a dados** — consultas **parametrizadas** conforme `{PERSISTENCIA}`,
   coesas e isoladas da lógica.
6. **UI** — hub do assistente + ações contextuais nos formulários + busca global.
   Em UI de thread única (JavaFX/Swing), trabalho pesado fora da thread de UI;
   atualizar pelo mecanismo próprio (ex.: `Platform.runLater`).

## Estrutura de pacotes sugerida

```
<raiz>.assistente
├── busca         (MotorBusca, indice, normalizacao, similaridade)
├── kb            (BaseConhecimento, KbDao)
├── documentos
│   ├── modelo    (schema/definicao de cada tipo de documento)
│   ├── motor     (form guiado, validador, autopreenchimento, reuso)
│   └── saida     (geracao via {SAIDA_DOCS})
├── regras        (arvore de decisao / wizard)
├── dados         (DAO/acesso conforme {PERSISTENCIA})
└── ui            (hub, integracoes contextuais, busca global)
```

## Capacidade 1 — Busca e dúvidas

- **Normalizar** texto na indexação e na consulta.
- **Tolerância a typo** via distância de edição; **sinônimos** via dicionário na KB.
- **Wizard**: nós cadastráveis; folha é a orientação oficial. Sem texto gerado.
- Resultado de busca sempre cita a **fonte**.

## Capacidade 2 — Motor de documentos

### Schema por documento
Cada documento é um **schema**: campos com nome, tipo, obrigatoriedade,
máscara/validação, valor padrão e **fonte** (digitado x dados). O form é guiado
pelo schema.

### Autopreenchimento
Ao informar a entidade-chave, o DAO puxa dados cadastrais e preenche os campos de
fonte "dados". Usuário só completa o que é digitado.

### Validação e regras
Antes de finalizar: obrigatórios, formatos, **coerência** (entidade existe? estado
esperado? conflito?), regras específicas do documento.

### Saída, numeração e versão
Gerar via `{SAIDA_DOCS}`. Numeração automática, data, versionamento.

### Registro de tipos de documento (preencher por projeto — não inventar)

| Documento | Gatilho | Campos | Fonte dos dados | Validações | Reuso? | Entidade-chave |
|---|---|---|---|---|---|---|
| `{...}` | | | | | | |

Obter do mestre de obras: nome correto, gatilho, campos, fonte de cada dado,
validações e reuso. **Nunca assumir** sigla ou nome de campo.

## PADRÃO — Reuso por Histórico de Entidade

Padrão reutilizável: qualquer documento que se repita por uma **entidade-chave**
(equipamento, processo, norma, ativo, etc.).

**Fluxo**
1. Usuário informa a **entidade-chave** (identificador estável) ao iniciar.
2. DAO busca documentos **concluídos** da mesma entidade (chave = identificador),
   ordenado por data desc.
3. Lista as ocorrências (nº, data, contexto, qtd. de itens). Se vazio, em branco.
4. Usuário escolhe (padrão: mais recente) ou descarta.
5. Itens copiados como **rascunho editável**, com etiqueta "herdado do {doc} nº X
   de DD/MM/AAAA".
6. **Revisão obrigatória** antes de finalizar.
7. Validações de coerência.
8. Geração + numeração + versão.

**Salvaguardas (obrigatórias)**
- Reuso é **sugestão**, nunca aplicação automática cega.
- **Proveniência visível** no item herdado.
- **Confirmação de revisão obrigatória** para finalizar.
- **Alertar** se a entidade mudou desde a origem (quando detectável).
- **Log de auditoria** do reuso e da origem.
- **Pré-requisito:** identificador **estável** da entidade. Se for texto livre,
  padronizar antes de confiar no casamento.

## Onde agregar no sistema

Camada transversal, três formas de acesso (mapear contra telas reais):
1. **Hub dedicado** — busca + dúvidas + iniciar documento.
2. **Ações contextuais** dentro de cada tela de documento.
3. **Busca global** sempre acessível.

## Dados e qualidade

- Acesso a dados **parametrizado** sempre (sem concatenar entrada).
- DAO isolado da lógica; consultas coesas e nomeadas.
- Tratar dado ausente/inconsistente com mensagem clara, sem derrubar a tela.

## Regras de Ouro (herdar do projeto)

Seguir as Regras de Ouro canônicas do `{SISTEMA}`. Em especial: um bug = um commit;
**nunca inventar** API/método/sigla/campo; pacotes coesos; nenhuma dependência
nova sem autorização.

## Checklist de "pronto" por frente

- [ ] Perfil do sistema-alvo preenchido
- [ ] Schema do documento confirmado (siglas, campos, fontes)
- [ ] Autopreenchimento puxando dos dados; texto livre só digitado
- [ ] Validações de obrigatório/formato/coerência ativas
- [ ] Reuso por histórico (quando aplicável) com proveniência + revisão obrigatória
- [ ] Log de auditoria do reuso
- [ ] Busca normalizada e tolerante a typo; resultado cita a fonte
- [ ] Trabalho pesado fora da thread de UI (se aplicável)
- [ ] Acesso a dados parametrizado; nenhuma dependência nova sem aval

## Verificação (prova executada, não "parece pronto")

O checklist acima é intenção; a prova é execução. Antes de dar por pronta a frente,
rode a bateria do `testador-real` (ou o testador do projeto) contra os três pontos
que mais quebram na prática:
- **Busca:** consulta com typo e com sinônimo devolve o item certo **e cita a fonte**.
- **Autopreenchimento/validação:** entidade-chave puxa os campos de fonte "dados";
  obrigatório vazio, formato inválido e incoerência (entidade inexistente/estado
  errado) são **barrados com mensagem clara**, sem derrubar a tela.
- **Reuso:** item herdado entra como rascunho com **proveniência visível** e exige
  **revisão** antes de finalizar; o **log de auditoria** registra origem e reuso.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-software` (fronteira e pacotes do subsistema) · `dev-senior` (implementação) · `especialista-seguranca` (consultas parametrizadas e log de auditoria).
- **Vem antes:** o sistema hospedeiro com dados e telas reais (o Perfil sai deles).
- **Vem depois:** `testador-real` (validação executada da busca, validações e reuso) · `docs-projeto` (manual do assistente).
- **Não confundir com:** um chatbot/LLM (este assistente é 100% determinístico e offline) — nem com as skills de orquestração do conjunto (`orquestrador-fable` rege agentes, `painel-de-juizes` compara, `auditor-responsabilidades` audita); aqui você **constrói um subsistema**, não coordena o comitê.

### 📜 Histórico

- **2026-08-10 — Seção de Histórico criada (T35, campanha do inventário; degrau §6.10: 1).** A skill não tinha nenhuma, e sem ela a proveniência exigida pela RI-04 não tem onde morar. Achado do inventário completo de 2026-08-10 (`_auditoria/zelador-inventario-2026-08-10.md`), padrão transversal 6.
- **2026-08-09 — `description` comprimida** na campanha das 61 (65.029 → 43.202 caracteres no catálogo, −34%), preservando as frases-gatilho e a fronteira `NÃO acione`. Registro retroativo: a compressão foi aplicada e não anotada aqui na época.
