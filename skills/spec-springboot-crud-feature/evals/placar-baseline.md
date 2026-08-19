# Placar baseline × com-skill — spec-springboot-crud-feature

> Medição do §11 do PADRAO-DE-AUTORIA - **2026-07-09**. Executor: **Sonnet** (baseline sem acesso ao catálogo vs. com a SKILL.md carregada). **Juiz cego** por eval (ordem A/B alternada), pontuando 1 / 0,5 / 0 por expectation; score = fração das expectations atendidas. Workflow `placar-baseline-orquestradores` (run `wf_8db22f26-e56`, 84 agentes, 28 evals, 0 erros).

| Eval | Baseline | Com skill |
|---|---|---|
| crud-springboot-completo | 0,43 | 0,86 |
| nao-aciona-para-camada-isolada | 0,67 | 1,00 |
| nao-confunde-track-javafx | 0,50 | 1,00 |
| **Média** | **0,53** | **0,95** |

## Observações do juiz (evidência RI-04)

- **crud-springboot-completo:** Resposta A é uma condução genérica de dev sênior (bem fundamentada, com boas perguntas de escopo e recusas justificadas), mas não segue o protocolo específico da skill spec-springboot-crud-feature: não valida as 3 skills filhas do catálogo, não menciona o gate de mockup (RO-06) nem a regra RO-SB4 (view não recebe entidade JPA), e no fechamento só cita 'mvn test' genérico sem o gate por DB_URL nem a varredura de hex fora de tokens.css. Em compensação, é mais explícita e consistente nos nomes de cada camada (Categoria/CategoriaRepository/CategoriaService/CategoriaAdminController).\n\nResposta B segue explicitamente a estrutura da skill (gates numerados, referências RO-06/RO-SB4/RO-07), valida a existência das 3 skills filhas no catálogo, reconhece corretamente a condição de parada por ambiguidade antes de acionar springboot-entity, cita o padrão de migração V<N>__..., a regra de não vazar entidade JPA para a view, e planeja o fechamento com mvn test + varredura de hex fora de tokens.css + relatório final com sugestões de evolução. É mais fraca em mostrar nomes de classes concretos por camada (ainda não gerou artefatos), por isso perde um pouco na expectation de consistência de nomes/slug.
- **nao-aciona-para-camada-isolada:** Resposta A cita explicitamente a regra de escopo da própria skill (NÃO acionar para camada isolada), reconhece o pedido como pertencente a springboot-repository-service, nomeia essa skill como o caminho correto e declara não ter tocado em entidade/tela existentes. Atende plenamente às 3 expectations. Resposta B produz um plano de engenharia sólido e respeita o escopo (não mexe em entidade/tela), mas nunca menciona ou direciona para a skill 'springboot-repository-service' nem para qualquer mecanismo de roteamento entre skills — trata a tarefa como problema de engenharia genérico, ambíguo até sobre o stack (JPA vs JDBC/DAO manual), sem nunca reconhecer o ecossistema de skills do catálogo. Isso falha a expectation 2, que exige acionar/direcionar explicitamente a skill filha.
