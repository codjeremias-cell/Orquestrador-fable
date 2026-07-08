---
name: java-service-usecase
description: Cria a camada de serviço (caso de uso) que concentra a regra de negócio de uma operação em projeto Java desktop, tirando-a do controller da tela e orquestrando entidade(s) e DAO(s). Acione quando o usuário disser coisas como "cria o serviço de cadastrar cliente", "preciso da regra de negócio de fechar a escala", "tira essa lógica do controller", "monta o caso de uso de lançar férias" ou descrever uma operação de negócio com validações e passos. NÃO acione para acesso a dados puro (use java-jdbc-dao) nem para a tela (use javafx-screen-fxml).
---

# Java — Serviço / Caso de Uso

## Objetivo

Concentrar a regra de negócio de uma operação numa classe de serviço, mantendo os controllers de tela finos. O serviço valida, orquestra entidade(s) e DAO(s), garante a transação quando a operação tem vários passos, e devolve um resultado claro. É o lugar onde a regra mora — não no controller, não no DAO.

## Entradas obrigatórias

1. Nome da operação/caso de uso (ex.: `CadastrarCliente`, `FecharEscala`).
2. Entrada esperada (campos) e o que a operação deve produzir/retornar.
3. Dependências (quais DAOs, providers ou outros serviços ela usa).

## Entradas opcionais

- Regras de negócio explícitas e mensagens de erro.
- Se a operação é multi-passo (exige transação atômica).

## Trava obrigatória

- Não gerar sem a operação, a entrada e as dependências mínimas claras.
- Se a regra de negócio for ambígua, pedir o esclarecimento em vez de inventar comportamento.

## Leituras obrigatórias (RO-01)

1. Um serviço já existente no projeto (se houver) para copiar o padrão; se não houver, este é o primeiro — declarar o padrão proposto.
2. As entidades e DAOs que a operação usa (assinaturas reais).
3. O padrão de exceção/erro de negócio do projeto.

## Convenções obrigatórias

- Classe em `PascalCase` (ex.: `ClienteService` ou `CadastrarCliente`), métodos em inglês, no pacote `service` do projeto.
- Dependências recebidas por construtor (DAO, providers) — baixo acoplamento (RO-02).
- Validação de negócio antes de persistir; chamar `entidade.validate()` quando existir.
- **Transação atômica** quando a operação grava em mais de um lugar: orquestrar `commit`/`rollback` (no padrão do projeto — geralmente coordenado com o DAO/conexão).
- **RO-08 — Log4j 2** para erros e eventos relevantes. Sem `System.out`.
- Sem acesso a FXML/UI. Sem SQL direto (delegar ao DAO).

## Fluxo

1. Validar entradas e resolver dependências reais.
2. Ler serviço/entidade/DAO existentes e o padrão de erro.
3. Implementar o método do caso de uso: validar → orquestrar entidade/DAO → garantir transação → retornar resultado.
4. Tratar e logar erros; propagar exceção de negócio coerente.
5. Escrever teste do serviço com fakes/dublês simples dos DAOs (sem banco real).
6. Rodar o teste e reportar arquivos e suposições.

## Regras de implementação

- O controller da tela só chama o serviço e trata o resultado — nada de regra de negócio no controller.
- Não duplicar validação que já está na entidade; complementar com a regra que é do fluxo.
- Manter o método legível e com uma responsabilidade clara.

## Guardrails

- Não inventar assinatura de DAO/entidade (RO-01).
- Não acessar banco diretamente nem a UI.
- Não deixar gravação parcial em operação multi-passo.

## Saída esperada

- Classe de serviço/caso de uso no pacote `service`, com a regra concentrada.
- Teste do serviço com dublês dos DAOs.
- Nota com regras aplicadas e suposições.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair uma classe base de serviço; padronizar o objeto de resultado; mover constantes de domínio para um enum).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (regra legível e testada com dublês) · `arquiteto-software` (limites entre camadas).
- **Vem antes:** `java-javafx-entity` e `java-jdbc-dao` (o que o serviço orquestra).
- **Vem depois:** `javafx-screen-fxml` / `javafx-dashboard` (a UI chama o serviço).
- **Não confundir com:** `java-jdbc-dao` (acesso a dados puro) e o controller da tela (que só chama o serviço).
