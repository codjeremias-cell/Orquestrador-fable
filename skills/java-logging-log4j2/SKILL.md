---
name: java-logging-log4j2
description: "Configura ou padroniza o logging com Log4j 2 num projeto Java, trocando printStackTrace e System.out por logger com Throwable como último argumento e ajustando o log4j2.xml. Peça TRANSVERSAL do pipeline desktop Java. Acione com \"Log4j\", \"configura o Log4j\", \"troca os System.out por log\", \"padroniza o logging\", \"tira os printStackTrace\", \"preciso logar direito os erros\", \"os erros somem quando roda o .exe\", \"printStackTrace espalhado\", \"System.out no código\", \"rotação de log\", \"logger não preserva stack trace\", \"erro não aparece no arquivo de log\". NÃO acione para criar regra de negócio, tela ou DAO — apenas para o logging."
---

# Java — Logging com Log4j 2

📍 **No pipeline Java:** peça transversal. Vem depois de `java-project-bootstrap` (dependências e `log4j2.xml` base) e o padrão que ela fixa vale para todas as camadas seguintes — DAO, serviço e telas logam nessa mesma forma.

## Objetivo

Padronizar o registro de eventos e erros com Log4j 2 **na forma que o projeto já usa** — eliminando saídas inadequadas (`printStackTrace`, `System.out`, `System.err`) e garantindo que toda exceção seja logada com o `Throwable` preservado. Logging claro é evidência (RI-04) e base para auditoria.

## Entradas obrigatórias

1. O projeto alvo e se é configurar do zero ou padronizar o existente.

## Entradas opcionais

- Nível de log desejado por pacote, destinos (console, arquivo rotativo).
- Trechos específicos a migrar.

## Trava obrigatória (RO-01)

- Se já existe configuração/uso de logging, ler antes de alterar — não trocar o framework nem a forma de chamar o logger sem pedido explícito.

## Leituras obrigatórias

1. O `log4j2.xml` (ou config equivalente) atual, se existir.
2. Uma classe que já usa o logger no padrão do projeto (fachada própria? `LogManager.getLogger` direto? nome do logger?).
3. As dependências de logging no `pom.xml`/`build.gradle`.

## Os invariantes inegociáveis (RO-08 — valem em qualquer projeto)

Estes não variam — são correção e segurança, não estilo:

- **Nunca** `printStackTrace`, `System.out` ou `System.err` — a saída some quando o app roda sem terminal (ex.: `.exe` empacotado por `java-package-desktop`); é a razão de existir do logger.
- **Toda exceção logada leva o `Throwable` como último argumento** da chamada (`log.error("Falha ao salvar cliente {}", id, ex)` ou o equivalente na fachada do projeto) — preserva o stack trace completo.
- **Nunca logar dado sensível** (senha, token, credencial, hash) — registra-se a ocorrência, nunca o valor.
- **Nunca engolir exceção.** Logar não substitui tratar/propagar — silenciar é sempre erro.
- **Placeholder `{}` onde a API dá o slot; formatar antes da chamada onde a fachada só aceita `String` pronta — mesma regra, forma diferente.** `Logger` direto do Log4j2 tem slot: `log.error("Falha ao salvar {}", id, ex)`, nunca concatenação (`"Falha ao salvar " + id`). Uma fachada sem slot (ex.: SIGO `Log.erro(String mensagem, Throwable causa)`) só aceita `String` pronta — montar essa `String` antes da chamada **é o padrão da casa**, não um desvio a corrigir. O que não varia com a forma da API: **nunca concatenar dado sensível na mensagem** e **nunca perder o `Throwable`** (sempre à parte, nunca dentro da `String`).

## O que VARIA por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto: **como o logger é obtido e chamado.** Não há resposta única — leia a config e uma classe que já loga, e copie:

- **Um `Logger` por classe** (`private static final Logger log = LogManager.getLogger(NomeClasse.class);`) **ou uma fachada única** do projeto sobre o Log4j2 (classe utilitária com métodos próprios, chamando um logger nomeado fixo)? Se existe fachada, chame-a — não abra `LogManager` direto ao lado dela.
- **Nome do logger:** a própria classe (`.class`) ou um nome fixo curto do sistema?
- **Nomenclatura dos métodos/níveis expostos:** `error/warn/info/debug` padrão do Log4j2, ou nomes PT-BR de uma fachada (`erro/aviso/info`)? Nem todo projeto expõe os quatro níveis — espelhe só os que a fachada oferece.
- **Rotação e retenção do arquivo:** diária ou por tamanho? quantos dias/arquivos de retenção? `.gz`? Copie os valores reais do `log4j2.xml` existente — não invente números diferentes do que já roda.
- **Sem config/uso existente (greenfield):** aplique o default genérico do Log4j2 (logger por classe, `error/warn/info/debug`, `RollingFile` diário com retenção razoável) e **declare "SUPOSICAO:"** (RO-01) — é chute educado, não fato do projeto.

## Fluxo

1. Ler a config e o uso atuais; conferir dependências.
2. Criar/ajustar `log4j2.xml` **na forma detectada** (ou default genérico + `SUPOSICAO:` se greenfield).
3. Substituir `printStackTrace`/`System.out`/`System.err` por chamadas de logger — patch cirúrgico (RO-02) — na forma real do projeto (fachada existente ou `LogManager.getLogger` por classe), sempre com `Throwable` no fim.
4. Conferir que nenhum dado sensível é logado — grep por senha/token/credencial/hash nas chamadas de log alteradas.
5. Rodar o build e reportar arquivos alterados + suposições.

## Guardrails

- Não inventar appender, dependência, método ou fachada não confirmados (RO-01) — inclui não supor que a fachada expõe um nível que ela não tem (ex.: chamar `Log.debug(...)` numa fachada que só define `erro/aviso/info`).
- Silêncio de exceção e dado sensível já são invariantes do RO-08 acima — não repetidos aqui. Não abrir `LogManager` ao lado de fachada existente já está em "O que VARIA" acima — vale mesmo "só para esse log específico"; exceção pontual é o começo de duas formas convivendo no mesmo projeto.

## Verificação de fechamento (RI-04)

- **Sempre executável:** grep/build confirmando **zero** `printStackTrace`/`System.out`/`System.err` restante no escopo alterado, e build verde (`mvn -q -DskipTests package`, ou `./gradlew build` no Gradle). Um `grep -rn "printStackTrace\|System.out\|System.err" src/` que volta vazio no escopo é a evidência concreta — "troquei os prints" sem esse grep não fecha.
- **Condicional — SKIP declarado quando não dá para observar em sessão:** o comportamento real de rotação/retenção do arquivo só se materializa depois de dias rodando; o próprio SIGO não prova isso em CI. Reporta a config aplicada (valores copiados do `log4j2.xml` real ou a `SUPOSICAO:` assumida) e declara SKIP com o motivo — nunca finge que rodou.

## Saída esperada

- `log4j2.xml` configurado e uso de logger padronizado, na forma real do projeto.
- `printStackTrace`/`System.out`/`System.err` eliminados nos arquivos no escopo.
- Nota com o que mudou, onde vive o logger neste projeto (fachada ou por-classe), e suposições (RO-01).

## Referências/Few-shots

- **SIGO/sistema-cot ou família:** carregue `referencia-exemplos-reais-sigo.md` antes de gerar — é o gabarito de forma (fachada `Log`, logger nomeado, rotação/retenção reais). Os valores concretos vivem só lá (fonte única): se mudarem no projeto real, atualize a referência, não este arquivo.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: `MDC`/contexto por operação; nível por ambiente; teste automatizado do appender).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `dev-senior` (nível e mensagem certos) · `especialista-seguranca` (nunca logar segredo).
- **Vem antes:** `java-project-bootstrap` (dependências e log4j2.xml base).
- **Vem depois:** todas as skills do track — o padrão de log vale para DAO, serviço e telas.
- **Não confundir com:** observabilidade/monitoramento de produção (fora do escopo desta skill).

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-19 — Rodada 2 (destravamento, decisões D-A..D-D)** (invariante de placeholder reescrito para a forma honesta fachada-sem-slot; guardrails deduplicados; evals com origem/fonte).
