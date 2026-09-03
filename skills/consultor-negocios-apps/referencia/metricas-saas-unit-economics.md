# Métricas SaaS, Unit Economics e Diagnóstico de Churn

> **Proveniência:** `garimpo skills-ia 2026-08-19 · G3` (MIT; adaptado de `Produto/Análise de Motivos de Churn` e `Financeiro/Framework de Unit Economics`).  
> **Degrau da Escada (§6.10):** 2 — arquivo de referência complementar.  
> **Consumido por:** `consultor-negocios-apps` (avaliação de monetização, sustentabilidade e retenção) e `conselheiro-financeiro`.

---

## 1. Unit Economics Essencial para Apps e SaaS

Unit Economics mede a rentabilidade e sustentabilidade financeira de cada cliente adquirido. Nenhum app deve escalar aquisição antes de equilibrar estes números:

### 1.1 CAC (Customer Acquisition Cost)
O custo total para adquirir um novo cliente pagante em determinado período:

$$\text{CAC} = \frac{\text{Gastos Totais em Marketing} + \text{Gastos Totais em Vendas}}{\text{Número de Novos Clientes Conquistados}}$$

- **O que incluir:** Ads (Meta/Google), ferramentas de vendas/marketing, salários/comissões proporcionais da equipe de captação.
- **Armadilha comum:** Dividir apenas pelo gasto de mídia (Ads) e ignorar ferramentas, custos de onboarding e tempo do time.

---

### 1.2 LTV (Lifetime Value)
O valor financeiro líquido que um cliente gera durante todo o tempo em que permanece ativo:

$$\text{LTV} = \frac{\text{ARPU (Receita Média por Usuário)} \times \text{Margem Bruta}}{\text{Taxa de Churn de Clientes (Logo Churn)}}$$

Ou, pela duração média do contrato ($\text{Tempo Médio de Retenção} = \frac{1}{\text{Churn}}$):

$$\text{LTV} = \text{ARPU} \times \text{Tempo Médio de Retenção} \times \text{Margem Bruta}$$

---

### 1.3 Razão LTV : CAC (A Saúde do Modelo)
- **< 1.0:** Destruição de capital (o cliente custa mais do que devolve).
- **1.0 a 2.5:** Modelo frágil; margem de erro quase nula para imprevistos.
- **3.0 a 5.0 (Ponto Ótimo):** Modelo saudável e escalável.
- **> 5.0:** Possível subinvestimento em aquisição (está deixando mercado na mesa).

---

### 1.4 CAC Payback (Tempo de Recuperação do Caixa)
Tempo (em meses) necessário para o lucro gerado pelo cliente pagar o custo de adquiri-lo:

$$\text{Payback (meses)} = \frac{\text{CAC}}{\text{ARPU Mensal} \times \text{Margem Bruta}}$$

- **Benchmark B2C:** $\le 6\text{ meses}$.
- **Benchmark B2B / PME:** $\le 12\text{ meses}$.
- **Benchmark Enterprise:** $\le 18\text{ meses}$.

---

### 1.5 Métricas Avançadas de Tração
- **NRR (Net Revenue Retention):** 
  $$\text{NRR} = \frac{\text{MRR Inicial} + \text{Expansões} - \text{Contratações} - \text{Churn}}{\text{MRR Inicial}} \times 100$$
  *(Ideal: $> 100\%$, significando que a base existente cresce mesmo sem novas vendas).*
- **SaaS Quick Ratio:**
  $$\text{Quick Ratio} = \frac{\text{New MRR} + \text{Expansion MRR}}{\text{Churned MRR} + \text{Contraction MRR}}$$
  *(Saudável: $> 4.0$. Abaixo de 2.0 indica que o churn está corroendo o crescimento).*

---

## 2. Framework de Diagnóstico Sistemático de Churn

Quando a taxa de cancelamento sobe, investigue pelas **4 causas raízes estruturais**, e nunca por suposições superficiais:

| Causa Raiz | Sintoma Observável | Diagnóstico Técnico / Operacional | Plano de Contenção Imediato |
|---|---|---|---|
| **1. Falha de Onboarding** | Churn ocorre nos primeiros 14 a 30 dias (Early Churn). | O usuário não atingiu o momento "Aha!" (primeira entrega de valor); setup complexo demais. | Simplificar o fluxo de primeiro uso (Time-to-Value < 5 min); implementar checklist interativo de ativação. |
| **2. Falha de Entrega de Valor** | Queda gradual de uso (DAU/WAU em declínio) antes do cancelamento. | O produto resolveu uma dor pontual e perdeu a relevância recorrente; falta de loop de hábito. | Identificar a feature de maior retenção; criar lembretes contextuais, automações e relatórios periódicos de valor gerado. |
| **3. Atrito de UX / Confiabilidade** | Reclamações frequentes de suporte, bugs críticos, lentidão. | Dívida técnica e falhas de usabilidade gerando frustração acumulada. | Acionar auditoria de `qa-usabilidade` e `dev-senior`; priorizar correções de bugs sobre novas features. |
| **4. Inadequação de Preço / Packaging** | O cliente gosta do app mas cancela alegando "custo alto" ou corte de orçamento. | Modelo de cobrança desalinhado com o valor percebido (ex.: cobrança fixa para quem usa pouco). | Testar planos escalonados por volume/uso ou pacotes de entrada com escopo reduzido. |

---

## 3. Checklist de Aplicação em Consultoria de Negócios
- [ ] O app tem cálculo explícito de CAC separando mídia de custos fixos?
- [ ] O Payback do CAC é sustentável dentro do capital de giro disponível?
- [ ] O Churn é medido separadamente por número de contas (Logo) e por volume financeiro (Revenue)?
- [ ] Há sinal claro de retenção e momento "Aha!" antes de alocar verba em tráfego pago?
