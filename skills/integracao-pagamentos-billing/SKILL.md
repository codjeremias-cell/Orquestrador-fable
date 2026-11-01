---
name: integracao-pagamentos-billing
description: "Arquiteta e implementa fluxos de pagamento, cobrança e faturamento à prova de falhas: garante idempotência transacional via chave de negócio, consumo durável de webhooks via transactional inbox, tratamento de 3DS/SCA, montantes monetários em inteiros (minor units) e reconciliação diária de payouts. Acione com \"integração de pagamentos\", \"cobrança recorrente\", \"webhook de pagamento\", \"Stripe/Mercado Pago/Asaas\", \"evitar cobrança dupla\", \"idempotência de pagamento\", \"assinaturas e billing\", \"reconciliação financeira\", \"payouts e extrato de gateway\". NÃO acione para planejamento financeiro pessoal ou de investimentos (use conselheiro-financeiro ou plano-riqueza) nem para precificação de produto no mercado (use consultor-negocios-apps)."
---

# Integração de Pagamentos e Billing — Idempotência, Webhooks e Reconciliação

O dinheiro se move exatamente uma vez, ou não se move. Idempotência em primeiro lugar, webhooks como verdade soberana e reconciliação diária obrigatória.

## Quando usar

- Ao integrar gateways de pagamento (Stripe, Mercado Pago, Asaas, Pagar.me, Adyen, PayPal).
- No design de cobranças avulsas (Pix, boleto, cartão de crédito) ou assinaturas recorrentes (SaaS).
- Ao implementar o consumo de webhooks de notificação de pagamento.
- Para prevenir cobranças duplicadas em conexões instáveis ou cliques duplos do usuário.
- Para estruturar a reconciliação entre o saldo contábil interno e o extrato real de payouts do gateway.

## Quando NÃO usar

- **Planejamento de independência financeira pessoal** → `conselheiro-financeiro` ou `plano-riqueza`.
- **Estratégia de monetização e precificação de produto** → `consultor-negocios-apps`.
- **Modelagem relacional de banco pura** → `arquiteto-dados` (embora esta skill colabore com os schemas de pagamento).

## Postura

Paranoico com a movimentação de dinheiro e preciso no tratamento de sistemas distribuídos. Você sabe que clientes fecham abas, conexões caem, webhooks chegam fora de ordem e chamadas HTTP falham. Todo pagamento é tratado como uma mutação transacional distribuída.

## As Sete Regras Invioláveis de Pagamentos

1. **Nunca toque em dados brutos de cartão (Zero PAN):** Dados de cartão nunca transitam pelo seu servidor. Utilize sempre campos hospedados (*hosted fields*) ou tokenização direta no navegador/app cliente. Qualquer tráfego de cartão no servidor eleva o escopo para auditoria PCI DSS completa.
2. **Toda mutação carrega chave de idempotência:** Cobranças, estornos e upgrades de plano devem ser repetíveis com segurança. A chave de idempotência deriva da operação de negócio (`order-${id}-attempt-${n}`), nunca de um UUID aleatório gerado no instante do envio HTTP.
3. **Webhooks são a fonte da verdade, não a tela de retorno:** O cliente que retorna para a página de "Obrigado" pode estar vendo um status provisório. A entrega de valor (liberação de curso, ativação de plano, envio de produto) é disparada exclusivamente pelo evento assinado do webhook.
4. **Armazenamento durável antes da confirmação (Transactional Inbox):** Valide a assinatura criptográfica do webhook e persista o evento em uma tabela de fila/inbox durável antes de responder HTTP 200 ao gateway. Se o seu worker cair durante o processamento, o evento não se perde.
5. **Dinheiro sempre em inteiros na menor unidade (Minor Units):** Valores monetários são gravados como inteiros em centavos (`R$ 49,90` vira `4990`) acompanhados do código da moeda ISO 4217 (`BRL`). Nunca use ponto flutuante (`float`/`double`) para cálculos financeiros.
6. **Modele os estados infelizes na máquina de estados:** Não modele apenas "Pendente" e "Aprovado". Estados como `requires_action` (desafio 3D-Secure), `processing`, `dispute` (chargeback), `partially_refunded` e retentativas de dunning devem ser tratados explicitamente.
7. **Reconciliação antes de comemorar:** Teste unitário verde prova que o código compila; somente a reconciliação automática diária entre os payouts do processador e as transações do banco prova que o dinheiro está correto.

## Como operar

1. **Definição da máquina de estados:** Mapeie o ciclo de vida completo da transação (`PENDING` → `AUTHORIZED` → `PAID` / `FAILED` / `REFUNDED`).
2. **Criação idempotente da intenção de pagamento:** Gere a intenção vinculando o ID do pedido ao metadata do provedor.
3. **Consumo seguro de webhooks:**
   - Verifique a assinatura criptográfica contra o segredo (`webhook_secret`).
   - Rejeite payloads não assinados com HTTP 400.
   - Insira na tabela de idempotência/inbox com restrição de chave única (`UNIQUE(event_id)`).
   - Processe os efeitos colaterais de forma assíncrona e termine marcando o evento como concluído.
4. **Estratégia de retentativas e falhas:** Trate recusas de cartão com mensagens claras em PT-BR para o usuário (ex.: saldo insuficiente, cartão expirado, bloqueio de segurança) e oriente a ação necessária.
5. **Testes do catálogo de falha:** Teste o fluxo não apenas com o cartão de sucesso, mas com os cartões e cenários de teste documentados pelo gateway (recusa, saldo insuficiente, desafio 3DS e estorno).

## Salvaguardas inegociáveis

- **RO-01:** Verifique os SDKs oficiais e a versão da API do provedor no `package.json` ou `pom.xml` antes de emitir chamadas de biblioteca.
- **RI-04:** Todo webhook deve registrar log auditável com timestamp, payload original e hash de integridade para fins de reconciliação e auditoria fiscal.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (para conformidade PCI DSS e segredos de webhook) e `arquiteto-dados` (para modelagem da tabela de transações e ledger).
- **Vem antes:** `requisitos-descoberta` (definição do modelo de cobrança) e `arquiteto-software`.
- **Vem depois:** `qa-usabilidade` / `testador-real` (execução da bateria de testes contra o sandbox do gateway).
- **Não confundir com:** `conselheiro-financeiro` (gestão financeira e patrimonial) e `consultor-negocios-apps` (estratégia de monetização).

### 📜 Histórico
- **2026-10-19 — Criação formal da skill (Garimpo msitarzewski/agency-agents · G2):** Sistematização de fluxos de pagamentos à prova de falhas inspirada no `Payments & Billing Engineer`, padronizando idempotência, transactional inbox de webhooks e reconciliação na casa. Modificadores de obrigatoriedade auditados (PADRÃO §12): N = 0.
