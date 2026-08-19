---
name: java-package-desktop
description: "Empacota uma aplicação Java desktop (JavaFX) em executável Windows com JRE embutido via jpackage sobre fat-jar (maven-shade), gerando app-image (.exe) e, quando pedido, instalador .msi (WiX), para rodar sem Java instalado. PASSO FINAL do pipeline desktop Java. Acione com \"jpackage\", \"gera o .exe\", \"empacota o app\", \"cria o instalador\", \"quero distribuir sem precisar de Java instalado\", \"monta o .msi\", \"prepara a versão pra mandar pro cliente\", \"gera a release\", \"app que roda sem Java\", \"runtime embutido\", \"instalador Windows\", \"pacote pra distribuir\". NÃO acione para build de código normal (mvn package de desenvolvimento) ou testes — apenas para empacotamento/distribuição final."
---

# Java — Empacotamento Desktop (jpackage)

📍 **No pipeline Java:** passo final (entrega). Vem depois do app pronto e provado (`testador-real` sem FAIL crítico) e do fat-jar configurado no `java-project-bootstrap`; é seguido por `docs-projeto` (manual/README acompanham a distribuição) e o ciclo git completo (RO-13).

## Objetivo

Gerar a distribuição da aplicação desktop que roda **sem Java instalado**: `jpackage` sobre um fat-jar (maven-shade), produzindo `app-image` (`.exe`) e, quando pedido, instalador `.msi` (WiX). É o passo de entrega ao usuário final.

## Entradas obrigatórias

1. O projeto e o nome final do app (ex.: `SIGCOT`).
2. Se a saída é só `app-image` (.exe) ou também `.msi`.

## Entradas opcionais

- Ícone `.ico`, versão, fornecedor, módulos extras (`--add-modules`).
- Pasta de saída de distribuição.

## Trava obrigatória

- Confirmar que o fat-jar é gerado (maven-shade) antes de empacotar.
- **Confirmar o ambiente antes de começar:** `jpackage` disponível (checar `JAVA_HOME`/`jpackage --version`) e o SO da sessão compatível com o alvo — `jpackage` **não faz cross-compile de instalador**; gerar `.exe`/`.msi` exige rodar em Windows. Sem Windows disponível: parar e declarar o bloqueio (RI-04), nunca simular que gerou.
- Se WiX não estiver disponível e for pedido `.msi`, avisar e oferecer só o `app-image`.

## Leituras obrigatórias (RO-01)

1. O `pom.xml` — conferir o plugin `maven-shade` e o main-class do fat-jar.
2. Qualquer script/comando de empacotamento já validado no projeto (reusar antes de reinventar).
3. A pasta de recursos (ícone, nome do app).
4. Projeto-alvo **SIGO/família** → também `referencia-exemplos-reais-sigo.md` (ver Gabarito abaixo).

## Os invariantes inegociáveis (valem em qualquer projeto)

Estes não variam — são correção e segurança da entrega, não estilo:

- **Fat-jar antes de empacotar.** `jpackage` nunca roda sobre o jar comum — sempre sobre o artefato do maven-shade (o mesmo `Launcher`-como-mainClass que o `java-project-bootstrap` configurou).
- **`--name` final definido ANTES de gerar** (ex.: `--name SIGCOT`) — ele deriva o `.cfg` do `.exe`. ⚠️ **Não renomear o `.exe` depois**: renomear quebra a execução.
- **`.msi` exige WiX instalado.** Ausência → avisar e oferecer só `app-image`; nunca inventar workaround (RO-01).
- **Não inventar flag de `jpackage`/WiX não confirmada** (RO-01) — reusar o que o projeto já validou ou pedir a confirmação.
- **Caminhos absolutos quando a ferramenta exigir** (evita "Acesso negado" 0x5).

## O que VARIA por projeto — espelhe, não prescreva

A parte que mais erra sem ler o projeto: **a forma exata do empacotamento**. Não há resposta única — há a decisão que **este** projeto tomou. Leia o script/comando já validado + o `pom.xml` e copie:

- **`--main-class`:** aponta para o launcher real do projeto (no SIGO, `br.com.cot.Launcher`, não `App`) — confirme no `pom.xml`/shade, não assuma.
- **`--add-modules`:** depende das libs do projeto (SIGO usa `java.se,jdk.unsupported` por causa do UCanAccess) — não copiar por reflexo se o projeto-alvo não usa o mesmo driver/dependência.
- **Forma do entregável final:** pasta `dist/<App>/` solta, `.msi`, ou `.zip` com retentativa anti-antivírus (o SIGO monta um `.zip` porque o runtime recém-criado é travado por instantes por antivírus/Explorer) — o gabarito SIGO **não é regra universal**, é o que ESSE projeto faz.
- **Artefatos extras empacotados junto:** o SIGO adiciona um `config.properties` modelo comentado + `docs/INSTALACAO.txt` ao lado do `.exe`. Só replique se o projeto-alvo tiver o mesmo costume; senão, proponha o mínimo e declare a suposição (RI-04).
- **Script de empacotamento:** reusar o script já validado do projeto (ex.: `empacotar.ps1`) em vez de escrever comandos `jpackage` soltos. Sem script existente, propor o mínimo necessário (`app-image` simples) e declarar `SUPOSIÇÃO:` (RI-04).

**Gabarito SIGO (few-shot de código real):** projeto-alvo **SIGO/família**, carregue `referencia-exemplos-reais-sigo.md` — `empacotar.ps1` verbatim (4 passos: fat-jar shade → jpackage app-image com Java embutido → pacote com config.properties modelo → zip com retentativa anti-antivírus). **`--main-class Launcher` + `--add-modules java.se,jdk.unsupported`**; entregável é o .zip. O padrão real vence o genérico (RO-01); desvio se declara (RI-04).

## Fluxo

1. Ler `pom.xml` e scripts existentes; confirmar fat-jar, main-class e ambiente (Windows + `jpackage`).
2. Gerar o fat-jar (maven-shade).
3. Rodar `jpackage` para `app-image` com `--name` final, ícone e módulos **na forma detectada do projeto**.
4. Quando pedido, gerar `.msi` (WiX) a partir do mesmo conjunto.
5. Fechar com a Verificação de fechamento (abaixo) — nunca pular para o passo 6 sem ela.
6. Reportar artefatos gerados, forma do entregável e como distribuir.

## Guardrails

- Não distribuir peças soltas fora do conjunto que o projeto usa como entregável (`dist/<App>/` inteira, ou `.zip`, conforme o padrão real detectado) — nunca só o `.exe` solto.
- Fora do SIGO/família, sem projeto-irmão para espelhar (greenfield): **NÃO importe por reflexo** o `.zip` com retentativa, o `config.properties` modelo, `--main-class Launcher`, nem `--add-modules java.se,jdk.unsupported` — são decisões do SIGO (UCanAccess + distribuição por rede), não requisitos universais do `jpackage`. Proponha o `app-image` mínimo e declare `SUPOSIÇÃO:` (RI-04).

## Verificação de fechamento (RI-04)

A distribuição só fecha quando o entregável abre e roda — "gerou o arquivo" não basta:

1. **Pré-requisito:** o fat-jar do maven-shade existe e é o insumo do `jpackage` (não o jar comum).
2. **O `app-image` (`.exe`) abre e roda de verdade:** executar `dist/<App>/<App>.exe` (ou equivalente) e confirmar que a janela inicial aparece sem erro. Renomear o `.exe` depois quebra a execução — confira o nome final ANTES.
3. **`.msi` (quando pedido):** confirmar que o instalador roda até o fim numa máquina limpa.
4. **Roda sem Java instalado:** o objetivo da entrega — o runtime embutido dispensa JRE externo.

O que não dá para executar (sem Windows disponível na sessão, sem WiX instalado, sem GUI) vira **SKIP declarado com motivo** — nunca "abriu" fingido.

## Saída esperada

- `app-image` (`.exe`) e, se pedido, `.msi`, com nome/ícone corretos.
- Instrução curta de distribuição (qual é o conjunto: pasta, `.zip` ou `.msi`).
- Resultado da Verificação de fechamento (PASS ou SKIP com motivo).

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: script único de release; assinatura do executável; versionamento automático no nome do artefato).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `qa-usabilidade` (smoke do .exe antes de distribuir) · `auditor-responsabilidades` (gate de release).
- **Vem antes:** o app pronto e provado (`testador-real` sem FAIL crítico) · fat-jar configurado pelo `java-project-bootstrap`.
- **Vem depois:** `docs-projeto` (manual e README acompanham a distribuição) · ciclo git completo (RO-13).
- **Não confundir com:** o build de desenvolvimento (mvn package) — aqui é a distribuição final ao usuário.

### 📜 Histórico
Registro completo de rodadas de evolução movido para [referencia/HISTORICO.md](referencia/HISTORICO.md) (progressive disclosure — metadado de autoria não precisa custar token a cada turno). Última rodada: **2026-07-19 — C1/Onda B (espelhar-não-impor)** (corpo em invariantes × o que varia; checagem de ambiente Windows+jpackage na Trava; verificação de fechamento RI-04 com SKIP; correção de citação RI-04).
