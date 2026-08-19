# Contrato da verdade

Referência carregada pelo `orquestrador-fable` antes da primeira delegação. O contrato impede que um pedido mude silenciosamente entre planejamento, execução, teste e entrega.

## Registro mínimo

```yaml
truth_contract:
  version: 1
  shape: pergunta_avaliacao | tarefa | plan_first
  reversibility: reversivel | sensivel | irreversivel
  INTENT: "<resultado observável pedido>"
  SCOPE_IN: ["<artefato, sistema, pessoa ou ação incluída>"]
  SCOPE_OUT: ["<limite explícito>"]
  DONE:
    artifacts: ["<saída nomeada>"]
    evidence: ["<prova verificável>"]
  EVIDENCE:
    accessible: ["<fato alcançável agora>"]
    researchable: ["<fato que exige fonte/permissão>"]
    inference: ["<hipótese ainda sem prova>"]
  PENDING:
    - item: "<decisão, entrada, permissão ou prova aberta>"
      owner: "<quem resolve>"
      blocks: "<frente ou entrega>"
  AUTH_REF:
    applicable: false
    citation_exact: "n/a"
    origin_turn: "n/a"
    action: "n/a"
    target: "n/a"
    environment: "n/a"
    limits: "n/a"
    contract_version: 1
    confirmed_at: "n/a"
  TWINS_REF: ["<pares registrados pelo testador ou n/a>"]
```

Campos vazios ficam como listas vazias ou `n/a`; não são omitidos silenciosamente. O contrato é artefato de coordenação, não substitui o estado retomável da `estado-projeto`.

## Regras

1. **`INTENT` é o norte.** Preserve a formulação exata do Jeremias quando ela define restrição, consentimento, negação ou ação externa. Resumo operacional pode acompanhar, mas não substituir a fonte.
2. **Escopo é bilateral.** Tudo que entra em `SCOPE_IN` tem dono; tudo que foi deliberadamente excluído entra em `SCOPE_OUT`. Descoberta fora do escopo vira surpresa, não mutação automática.
3. **`DONE` nomeia artefatos e provas.** “Melhorar” sem artefato/prova observável não fecha uma frente. Uma afirmação de conclusão sem sua evidência volta para o executor.
4. **Evidência não se mistura.** `accessible` pode sustentar fato; `researchable` só vira fato depois de obtida e citada; `inference` permanece hipótese rotulada.
5. **`PENDING` nunca desaparece por conveniência.** Toda pendência tem dono e impacto. Se bloqueia `DONE`, o status é `bloqueada`; se não bloqueia, segue visível na entrega final.
6. **Autorização tem dono único e escopo próprio.** `AUTH_REF` registra citação exata, turno/origem, ação, alvo, ambiente, limites, versão do contrato e confirmação validados pela `auditor-responsabilidades`. Ação materialmente diferente, novo alvo/ambiente ou contrato revisto exige reconfirmação; o maestro não interpreta silêncio, contexto antigo ou permissão menor como autorização nova. Quando não há ação externa/irreversível, usar `applicable: false` e os demais campos `n/a`.
7. **Artefatos pareados têm dono único.** `TWINS_REF` aponta para pares estabelecidos pelo pedido, pela spec ou por convenção real do projeto e para as verificações mantidas pelo `testador-real`; coalteração ou acoplamento, sozinhos, não criam um TWINS. O maestro apenas garante que a referência chegou ao plano e ao gate.

## Versionamento e surpresa

Qualquer alteração material em `INTENT`, escopo, `DONE`, reversibilidade ou autorização cria nova versão com motivo e origem. Não sobrescrever a versão anterior.

Ao surgir algo não previsto:

- **necessário para cumprir `INTENT` e reversível:** propor a mudança de contrato; executar só depois de ela passar pelos gates aplicáveis;
- **externo, irreversível ou fora de escopo:** adicionar `PENDING`, atribuir dono e parar a frente afetada; risco sensível porém local, reversível e já autorizado segue com orçamento de evidência alto;
- **mera oportunidade de melhoria:** manter fora do escopo e registrar como sugestão, sem implementar;
- **contradição entre fonte e inferência:** a fonte prevalece; registrar a hipótese refutada.

## Orçamento de evidência

Cada frente recebe um orçamento proporcional, declarado no plano:

| Nível | Condição | Prova mínima |
|---|---|---|
| **baixo** | reversível, mecânica, impacto local | inspeção do diff/artefato + verificação direta |
| **médio** | integração, comportamento compartilhado ou afirmação relevante | verificação direta + teste/checagem independente |
| **alto** | segurança, dados, ação externa, irreversibilidade ou surpresa material | fonte primária/estado real + teste independente + revisão adversarial pertinente |

O orçamento define **tipos de prova**, não quantidade ornamental de agentes ou citações. Evidência repetida pelo mesmo mecanismo não conta como independência. Se a prova de nível exigido não é alcançável, declarar `PENDING` ou `SKIP` com motivo; nunca rebaixar o nível em silêncio.

## Gate de fechamento

O contrato fecha somente quando:

- artefatos e provas de `DONE` existem;
- cada fato relevante aponta para evidência, e inferências continuam rotuladas;
- nenhuma mudança material de escopo ficou sem versão;
- `AUTH_REF` e `TWINS_REF` foram resolvidos quando aplicáveis;
- nenhuma `PENDING` bloqueante permanece; pendências não bloqueantes seguem declaradas com dono e impacto.
