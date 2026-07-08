---
name: java-package-desktop
description: Empacota uma aplicação Java desktop (JavaFX) em executável Windows com JRE embutido usando jpackage sobre um fat-jar (maven-shade), gerando app-image (.exe) e, quando pedido, instalador .msi (WiX), para rodar sem Java instalado. Acione quando o usuário disser coisas como "gera o .exe", "empacota o app", "cria o instalador", "quero distribuir sem precisar de Java instalado", "monta o .msi". NÃO acione para build de código normal ou testes — apenas para empacotamento/distribuição.
---

# Java — Empacotamento Desktop (jpackage)

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
- Se WiX não estiver disponível e for pedido `.msi`, avisar e oferecer só o `app-image`.

## Leituras obrigatórias (RO-01)

1. O `pom.xml` — conferir o plugin `maven-shade` e o main-class do fat-jar.
2. Qualquer script/comando de empacotamento já validado no projeto (reusar antes de reinventar).
3. A pasta de recursos (ícone, nome do app).

## Convenções obrigatórias (RO-J2)

- Buildar **já com o `--name` final** (ex.: `--name SIGCOT`); declarar `--add-modules` explicitamente quando necessário.
- ⚠️ **Não renomear o `.exe`** depois — ele deriva o nome do `.cfg`; renomear quebra a execução.
- Copiar a pasta `dist/<App>/` **inteira** ao distribuir o `app-image`.
- `.msi` via `jpackage --type msi` (exige WiX instalado).
- Caminhos absolutos quando a ferramenta exigir (evita "Acesso negado" 0x5).

## Fluxo

1. Ler `pom.xml` e scripts existentes; confirmar fat-jar e main-class.
2. Gerar o fat-jar (maven-shade).
3. Rodar `jpackage` para `app-image` com `--name` final, ícone e módulos.
4. Quando pedido, gerar `.msi` (WiX) a partir do mesmo conjunto.
5. Conferir que o `.exe` abre e que a pasta `dist/<App>/` está completa.
6. Reportar artefatos gerados e como distribuir.

## Guardrails

- Não renomear o `.exe` gerado.
- Não inventar flags de `jpackage`/WiX não confirmadas (RO-01); reusar o que o projeto já validou.
- Não distribuir só o `.exe` solto — a pasta `dist/<App>/` é o conjunto.

## Saída esperada

- `app-image` (`.exe`) e, se pedido, `.msi`, com nome/ícone corretos.
- Instrução curta de distribuição.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: script único de release; assinatura do executável; versionamento automático no nome do artefato).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `qa-usabilidade` (smoke do .exe antes de distribuir) · `auditor-responsabilidades` (gate de release).
- **Vem antes:** o app pronto e provado (`testador-real` sem FAIL crítico) · fat-jar configurado pelo `java-project-bootstrap`.
- **Vem depois:** `docs-projeto` (manual e README acompanham a distribuição) · ciclo git completo (RO-13).
- **Não confundir com:** o build de desenvolvimento (mvn package) — aqui é a distribuição final ao usuário.
