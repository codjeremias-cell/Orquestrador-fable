---
name: java-service-usecase
description: "Cria a camada de serviço (caso de uso) que concentra a regra de negócio de uma operação em projeto Java desktop, tirando-a do controller da tela e orquestrando entidades e DAOs. Camada de REGRA DE NEGÓCIO do pipeline desktop Java. Acione com \"serviço\", \"cria o serviço de cadastrar cliente\", \"preciso da regra de negócio de fechar a escala\", \"tira essa lógica do controller\", \"monta o caso de uso de lançar férias\", \"regra de negócio de X\", \"caso de uso de Y\", \"essa lógica não é da tela\", \"orquestra entidade e DAO\", \"onde valida antes de salvar\". NÃO acione para acesso a dados puro (use java-jdbc-dao) nem para a tela (use javafx-screen-fxml)."
argument-hint: [nome-do-caso-de-uso]
---

# Java — Serviço / Caso de Uso

📍 **No pipeline Java:** camada de regra de negócio. Vem depois de `java-javafx-entity` e `java-jdbc-dao` (o que o serviço orquestra) e antes das telas (`javafx-screen-fxml` / `javafx-dashboard`, que chamam o serviço).

## Objetivo

Concentrar a regra de negócio de uma operação numa classe de serviço, mantendo os controllers de tela finos — o serviço novo tem que ser **indistinguível dos serviços existentes** do projeto. O serviço valida, orquestra entidade(s) e DAO(s), garante a transação quando a operação tem vários passos, e devolve um resultado claro. É o lugar onde a regra mora — não no controller, não no DAO.

## Entradas obrigatórias

1. Nome da operação/caso de uso (ex.: `CadastrarCliente`, `FecharEscala`).
2. Entrada esperada (campos) e o que a operação deve produzir/retornar.
3. Dependências (quais DAOs, providers ou outros serviços ela usa).

## Entradas opcionais

- Regras de negócio explícitas e mensagens de erro.
- Se a operação é multi-passo (exige transação atômica).

## Trava obrigatória (RO-01)

- Não gerar sem a operação, a entrada e as dependências mínimas claras.
- Se a regra de negócio for ambígua, pedir o esclarecimento em vez de inventar comportamento.

## Leituras obrigatórias (RO-01)

1. Um serviço já existente no projeto — extrair: pacote real, como ele resolve as dependências (construtor injetado? campo direto `new XDAO()`?), como trata erro (propaga? loga? cria exceção própria?), idioma dos métodos, se há teste com dublês. Se não houver serviço nenhum, este é o primeiro — declarar o padrão proposto ("SUPOSIÇÃO:").
2. As entidades e DAOs que a operação usa (assinaturas reais).
3. O padrão de exceção/erro de negócio do projeto — existe uma exceção de domínio já usada, ou o projeto sinaliza falha esperada com `null`/`Optional`/retorno específico?

## Os invariantes inegociáveis (valem em qualquer projeto)

Estes não variam — são correção e integridade, não estilo:

- **Validação de negócio antes de persistir.** A operação não grava entrada inválida; se a entidade já tem `validate()` (confirmado na leitura, não suposto), complementar com a regra que é do fluxo — não duplicar o que a entidade já garante.
- **Sem SQL direto, sem acesso a FXML/UI.** O serviço orquestra; quem fala com o banco é o DAO, quem fala com a tela é o controller. É o que mantém a regra testável e reusável fora de uma tela específica.
- **Atomicidade QUANDO multi-passo (o QUE é invariante).** A operação grava em 2+ lugares? Não pode deixar gravação parcial — precisa de commit/rollback coordenado. **ONDE mora a fronteira transacional (serviço × DAO) VARIA** por projeto (ver `java-jdbc-dao`) — detecte a colocação real, não force a transação no serviço se o projeto já a resolve no DAO/provedor.
- **RO-01 — não inventar.** Assinatura de DAO/entidade, exceção de domínio, ou mecanismo de erro que o projeto não tem: se não está confirmado na leitura, é suposição e se declara como tal.

## O que VARIA por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto:

- **Pacote e idioma dos métodos.** Não é sempre `service` genérico nem sempre inglês — espelhe o pacote e o idioma reais (ex.: no SIGO, `br.com.cot.service`, métodos em PT-BR como `autenticar`).
- **Como as dependências chegam.** Construtor injetado é uma opção comum, **não a única** — alguns projetos (SIGO) usam campo direto `private final XDAO dao = new XDAO();`, sem interface. Copie a forma do serviço existente; não imponha injeção onde o projeto não usa.
- **Como a falha é sinalizada.** Exceção de negócio própria é uma opção, mas o projeto pode preferir retorno `null`/`Optional` para falha esperada, reservando exceção só para o inesperado — instância real: convenção 5 de `referencia-exemplos-reais-sigo.md` (fonte única, não repetida aqui). Não crie uma `NegocioException` que o projeto não tem.
- **Onde o erro é tratado e logado.** O serviço loga (Log4j2) ou **propaga `throws SQLException`/checked limpo** e quem loga é o controller? Copie a escolha do projeto — não adicione logger no serviço se o padrão real propaga limpo.
- **Forma de valor composto.** Quando o retorno é composto, o projeto pode preferir um record aninhado com método de conveniência em vez de uma classe de resultado genérica — instância real: convenção 6 da mesma referência (fonte única, não repetida aqui).
- **Teste com dublês.** Só é obrigatório se o projeto **pratica** esse padrão — ver Verificação de fechamento.

**Gabarito SIGO (few-shot de código real):** projeto-alvo sendo o **SIGO/SIGCOT ou sua família** (EscalaOper, Sentinela), carregue `referencia-exemplos-reais-sigo.md` — traz o `AutenticacaoService` verbatim (o `AlertasService` está documentado em prosa nas Convenções REAIS, sem trecho de código) e a lista completa de convenções; é a fonte única desse padrão, não repetida aqui. O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Fluxo

1. Validar entradas e resolver dependências reais.
2. Ler serviço/entidade/DAO existentes e o padrão de erro — extrair pacote, forma de dependência, sinalização de falha, log.
3. Implementar o método do caso de uso: validar → orquestrar entidade/DAO → garantir transação → retornar resultado, **na forma detectada**.
4. Tratar erro como o projeto trata (propagar limpo OU logar — não as duas; nunca inventar exceção de domínio que não existe no projeto).
5. Teste do serviço com dublês dos DAOs **se o projeto pratica esse padrão**; senão, SKIP declarado (ver Verificação de fechamento).
6. Rodar build/teste disponível e reportar arquivos e suposições.

## Regras de implementação

- O controller da tela só chama o serviço e trata o resultado — nada de regra de negócio no controller.
- Manter o método legível e com uma responsabilidade clara; métodos longos podem se organizar por comentário de seção, se for o costume do projeto.

## Guardrails

- Não inventar exceção de domínio, anotação de injeção (`@Inject`/`@Autowired`) ou biblioteca que o projeto real não usa "porque é boa prática" — sofisticação que a casa não pratica é dívida, não zelo (RO-01).
- Dentro do MESMO serviço, não misturar formas de sinalizar falha (um método retorna `null`, outro lança exceção) sem que seja o costume real do projeto — inconsistência interna é pior que a escolha "errada" de padrão.
- Não abrir uma segunda transação por cima da que o DAO/provedor já garante (RO-10) — em conexão única (Access/UCanAccess) isso trava o banco; se a atomicidade já mora no DAO, o serviço não duplica.

## Verificação de fechamento (RI-04)

O serviço fecha quando compila e (quando o projeto testa serviços) o teste roda verde:

1. **Compila:** `mvn -q -DskipTests compile` (ou `./gradlew compileJava`) verde — o serviço bate com as assinaturas reais dos DAOs e entidades.
2. **Teste com dublês, se o projeto pratica:** se o projeto **pratica** teste de serviço com dublês/fakes dos DAOs (confirmado por exemplo real lido), escrever o teste nesse padrão e rodá-lo (`mvn -q test` / `./gradlew test`). Se o projeto **não tem exemplo de teste de serviço** (caso do SIGO na referência disponível), não inventar suite do zero — declarar **SKIP** com o motivo ("projeto não pratica teste de serviço; nenhum exemplo encontrado"), nunca "passou" fingido.

## Saída esperada

- Classe de serviço/caso de uso no pacote real do projeto, com a regra concentrada, na forma do serviço existente.
- Teste do serviço com dublês dos DAOs, quando o projeto pratica esse padrão — senão SKIP declarado.
- Nota com regras aplicadas, forma espelhada (pacote/dependência/erro) e suposições (RO-01).

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: extrair uma classe base de serviço; padronizar o objeto de resultado; mover constantes de domínio para um enum).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (regra legível e testada com dublês) · `arquiteto-software` (limites entre camadas).
- **Vem antes:** `java-javafx-entity` e `java-jdbc-dao` (o que o serviço orquestra).
- **Vem depois:** `javafx-screen-fxml` / `javafx-dashboard` (a UI chama o serviço).
- **Não confundir com:** `java-jdbc-dao` (acesso a dados puro) e o controller da tela (que só chama o serviço).

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-19 — Correção FINAL pós-Painel 3** (prova de acionamento via artefato datado real; description intocada).
