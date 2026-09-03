# Template: Procedimento Operacional Padrão (SOP / POP)

> **Proveniência:** garimpo skills-ia 2026-08-19 · G7 (MIT; adaptado de Operações/Criador de SOP...).  
> **Degrau da Escada (§6.10):** 2 — arquivo de referência complementar.  
> **Consumido por:** docs-projeto (quando o pedido for documentar rotinas operacionais, procedimentos de suporte, deploy manual ou processos internos de equipe).

---

## 1. Estrutura Canônica de um SOP Robusto

Um Procedimento Operacional Padrão (SOP) deve ser autoexplicativo: qualquer membro da equipe ou agente deve conseguir executá-lo do início ao fim sem precisar perguntar nada fora do documento.

`markdown
# SOP-[CÓDIGO]: [Título Claro do Procedimento]

**Versão:** 1.0.0  
**Data da Última Revisão:** [AAAA-MM-DD]  
**Dono do Processo:** [Nome / Papel]  
**Aprovador:** [Nome / Papel]  
**Periodicidade / Gatilho:** [Diário / Sob Demanda / Incidente / Deploy]

---

## 1. Objetivo
[1 a 2 frases explicando exatamente o que este procedimento garante e qual risco ele elimina.]

## 2. Escopo e Aplicabilidade
- **Quando se aplica:** [Situações claras de acionamento]
- **Quando NÃO se aplica:** [Fronteiras e exceções onde outro procedimento deve ser usado]

## 3. Pré-requisitos e Acessos
- [ ] Permissão/Acesso: [ex: AWS Console, painel de admin, repositório X]
- [ ] Ferramentas instaladas: [ex: CLI, Python, VPN ativa]
- [ ] Insumos necessários: [ex: ticket aprovado, arquivo de entrada]

---

## 4. Passo a Passo de Execução

| Passo | Ação (Verbo + Objeto) | Ferramenta / Comando | Resultado Esperado / Evidência |
|---|---|---|---|
| **1** | [Verificar estado inicial] | [Comando / URL] | [Status OK / Print / Log] |
| **2** | [Executar a operação principal] | [Comando exato] | [Saída observável] |
| **3** | [Validar integridade pós-execução] | [Script de teste / Checagem] | [Relatório verde] |

---

## 5. Tratamento de Erros e Contingência (Plano B)

| Ponto de Falha | Sintoma / Mensagem de Erro | Ação Imediata / Rollback | Para Quem Escalar |
|---|---|---|---|
| **Falha no Passo 2** | [Erro timeout / HTTP 500] | [Executar comando de rollback X] | [Plantão / Tech Lead] |
| **Dado Inconsistente** | [Contagem diverge do previsto] | [Pausar processo e não commitar] | [Dono do Dado] |

---

## 6. SLAs e Métricas de Qualidade
- **Tempo Médio de Execução:** [ex: 15 minutos]
- **Tempo Máximo Tolerado (SLA):** [ex: 45 minutos]
- **Critério de Sucesso:** [100% dos itens processados sem intervenção manual adicional]

---

## 7. Histórico de Alterações
- **[AAAA-MM-DD] (v1.0.0):** Criação inicial do procedimento por [Autor].
`

---

## 2. Critérios de Auditoria de um SOP
- [ ] Todo comando técnico é copiável e traz os parâmetros explicados?
- [ ] O critério de sucesso é observável (print, log, status code), sem termos vagos como 'conferir se deu certo'?
- [ ] Existe plano de rollback explícito para o caso de falha no meio do processo?
- [ ] O dono do processo e o contato de escalonamento estão nomeados com clareza?
