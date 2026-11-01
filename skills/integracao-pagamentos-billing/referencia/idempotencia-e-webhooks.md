# Referência Técnica: Padrão Transactional Inbox para Webhooks

Este documento define o padrão arquitetural obrigatório para consumo de webhooks de pagamento.

## 1. O Problema do Consumo Ingênuo de Webhook

Em implementações frágeis, o endpoint HTTP recebe o webhook e executa imediatamente os efeitos colaterais (envia e-mail, atualiza status, gera fatura). Se o servidor cair no meio:
- O gateway reenvia o webhook.
- O e-mail é disparado duas vezes.
- Ou o webhook falha e o cliente fica sem o produto liberado.

## 2. A Solução: Transactional Inbox

```sql
CREATE TABLE webhook_inbox (
    event_id VARCHAR(128) PRIMARY KEY,
    provider VARCHAR(32) NOT NULL,
    event_type VARCHAR(64) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);
```

### Ciclo de Execução:
1. **Recebimento e Validação de Assinatura:**
   O endpoint valida o HMAC do header com a chave secreta. Se for inválido, rejeita com HTTP 400.
2. **Inserção Durável:**
   Insere o payload cru na tabela `webhook_inbox` com status `PENDING`. Se `event_id` já existir (chave duplicada), responde HTTP 200 imediatamente sem duplicar o trabalho.
3. **Confirmação Rápida:**
   Devolve HTTP 200 ao gateway em menos de 200ms para evitar timeout.
4. **Worker Assíncrono:**
   Um processo lê eventos com status `PENDING` (usando `SELECT ... FOR UPDATE SKIP LOCKED`), processa os efeitos transacionais em bloco e marca como `PROCESSED`.
