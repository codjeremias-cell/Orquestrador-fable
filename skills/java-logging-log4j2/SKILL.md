---
name: java-logging-log4j2
description: Configura ou padroniza o logging com Log4j 2 num projeto Java, substituindo printStackTrace/System.out por logger com Throwable como último argumento, e ajustando o log4j2.xml. Acione quando o usuário disser coisas como "configura o Log4j", "troca os System.out por log", "padroniza o logging", "tira os printStackTrace", "preciso logar direito os erros". NÃO acione para criar regra de negócio, tela ou DAO — apenas para o logging.
---

# Java — Logging com Log4j 2

## Objetivo

Padronizar o registro de eventos e erros com Log4j 2 em todo o projeto, eliminando saídas inadequadas (`printStackTrace`, `System.out`, `System.err`) e garantindo que exceções sejam logadas corretamente. Logging claro é evidência (RI-04) e base para auditoria.

## Entradas obrigatórias

1. O projeto alvo e se é configurar do zero ou padronizar o existente.

## Entradas opcionais

- Nível de log desejado por pacote, destinos (console, arquivo rotativo).
- Trechos específicos a migrar.

## Trava obrigatória

- Se já existe configuração de logging, ler antes de alterar; não trocar o framework sem pedido explícito.

## Leituras obrigatórias (RO-01)

1. O `log4j2.xml` (ou config equivalente) atual, se existir.
2. Uma classe que já usa o logger no padrão do projeto.
3. As dependências de logging no `pom.xml`/`build.gradle`.

## Convenções obrigatórias (RO-08)

- Um `Logger` por classe: `private static final Logger log = LogManager.getLogger(NomeClasse.class);` (no padrão real do projeto).
- **Nunca** `printStackTrace`, `System.out` ou `System.err`.
- Ao logar exceção, o **`Throwable` é o último argumento**: `log.error("Falha ao salvar cliente {}", id, ex);` — preserva o stack trace.
- Mensagens com placeholders `{}`, não concatenação.
- Não logar dado sensível (senha, token, credencial) — registrar só a convenção, nunca o valor.
- Níveis coerentes: `error` para falha real, `warn` para situação recuperável, `info` para evento de negócio, `debug` para diagnóstico.

## Fluxo

1. Ler a config e o uso atuais; conferir dependências.
2. Criar/ajustar `log4j2.xml` (console + arquivo rotativo se fizer sentido).
3. Substituir `printStackTrace`/`System.out` por chamadas de logger (patch cirúrgico — RO-02), com `Throwable` no fim.
4. Conferir que nenhum dado sensível é logado.
5. Rodar o build e reportar arquivos alterados.

## Guardrails

- Não inventar appender/dependência não confirmada (RO-01).
- Não silenciar exceção (logar e tratar/propagar, nunca engolir).
- Não logar segredo.

## Saída esperada

- `log4j2.xml` configurado e uso de logger padronizado.
- `printStackTrace`/`System.out` eliminados nos arquivos no escopo.
- Nota com o que mudou e pendências.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: `MDC`/contexto por operação; rotação/retention de log; nível por ambiente).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (nível e mensagem certos) · `especialista-seguranca` (nunca logar segredo).
- **Vem antes:** `java-project-bootstrap` (dependências e log4j2.xml base).
- **Vem depois:** todas as skills do track — o padrão de log vale para DAO, serviço e telas.
- **Não confundir com:** observabilidade/monitoramento de produção (fora do escopo desta skill).
