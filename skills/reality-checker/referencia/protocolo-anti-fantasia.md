# Protocolo Anti-Fantasia e Evidência Pareada

Este documento estabelece a matriz de evidências mínimas para auditoria de entregas de software.

## 1. A Matriz de Evidência Pareada

Toda funcionalidade que altera o estado do sistema exige prova em duas camadas:

| Camada | O que NÃO prova | O que É evidência válida |
|---|---|---|
| **Camada 1: Visual / Apresentação** | Screenshot do formulário com texto digitado | Screenshot do formulário **após** clique em salvar, exibindo feedback de sucesso e recarregamento dos dados na tabela/grid. |
| **Camada 2: Persistência / Dados** | Mensagem de "Salvo com sucesso" no console | Consulta SQL direta (`SELECT * FROM ... WHERE id = ...`) comprovando o registro persistido no banco com todos os campos preenchidos. |

## 2. Rubrica de Classificação de Defeitos

- 🔴 **Bloqueador (Impede Deploy):**
  * Perda de dados ou corrupção silenciosa.
  * Falha de segurança, injeção ou bypass de autorização.
  * Quebra total de layout em telas de tablet ou celular.
  * Funcionalidade que alega existir mas não possui implementação real.
- 🟡 **Ajuste Necessário (Revisão Obrigatória):**
  * Mensagens de erro em inglês ou técnicas expostas ao usuário final.
  * Lentidão perceptível (> 2s) sem indicador de carregamento.
  * Inconsistência de alinhamento ou quebra de contraste (WCAG AA).
- 💭 **Observação / Melhoria Futura:**
  * Sugestões de microinterações ou refinamento visual menor que não bloqueia o uso.
