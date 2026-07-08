---
name: javafx-theme-tokens
description: Cria ou ajusta o tema visual de uma aplicação JavaFX por tokens de cor em CSS (tema claro e escuro), com as variáveis declaradas no .root e sem cores fixas, seguindo o padrão do projeto. Acione quando o usuário disser coisas como "cria o tema escuro", "preciso de light e dark", "centraliza as cores em tokens", "essa cor fixa está quebrando no dark", "monta o base.css e o tema-dark". NÃO acione para criar a tela em si (use javafx-screen-fxml).
---

# JavaFX — Tema por Tokens (CSS claro/escuro)

## Objetivo

Centralizar as cores da aplicação em **tokens** (variáveis CSS) declarados no `.root`, com um tema claro e um escuro, de modo que nenhuma tela use cor fixa. Trocar de tema vira trocar o conjunto de tokens — sem caçar hex espalhado.

## Entradas obrigatórias

1. O projeto JavaFX alvo e onde ficam os CSS (ex.: `src/main/resources/**/css`).
2. Se é criar do zero (base + dark) ou ajustar um tema existente.

## Entradas opcionais

- Paleta desejada (cores de marca, sucesso, erro, aviso).
- Telas/CSS que ainda usam cor fixa e precisam migrar para token.

## Trava obrigatória

- Não reescrever um tema existente sem ler o atual. Se houver mais de um CSS de tema, confirmar quais entram.

## Leituras obrigatórias (RO-01)

1. O(s) CSS de tema já existentes (ex.: `base.css`, `tema-dark.css`) para copiar o padrão de nomes de token.
2. Como o tema é trocado em runtime no projeto (qual classe/serviço aplica o stylesheet).
3. Uma tela que usa as cores, para conferir os tokens necessários.

## Convenções obrigatórias (RO-12)

- Cada cor é uma **variável de tema** (ex.: `-color-bg`, `-color-text`, `-color-primary`, `-color-success`) **declarada no `.root`**; usar a variável, nunca o hex direto na regra.
- A variável precisa estar **declarada antes de ser usada** — token não declarado é ignorado em silêncio (e gera `ClassCastException String→Paint`).
- `-fx-border-color` com 4 valores = **TOP, RIGHT, BOTTOM, LEFT** (ordem CSS web).
- Tema claro e escuro definem **o mesmo conjunto de tokens** com valores diferentes; nenhuma tela referencia cor fixa.
- Garantir contraste mínimo (texto 4.5:1) — casa com a lente Designer/QA (a11y).

## Fluxo

1. Ler os CSS atuais e o mecanismo de troca de tema.
2. Definir/normalizar o conjunto de tokens no `.root` (claro e escuro).
3. Migrar cores fixas encontradas para tokens (patch cirúrgico — RO-02).
4. Conferir que todo token usado está declarado e que o contraste passa.
5. Validar a troca claro↔escuro e reportar o que mudou.

## Guardrails

- Nenhum hex fixo em regra de componente — só token.
- Não usar token não declarado no `.root`.
- Não inventar o mecanismo de troca de tema (RO-01) — usar o real do projeto.

## Saída esperada

- `base.css`/tema claro e `tema-dark.css` com o mesmo conjunto de tokens.
- Telas migradas para tokens onde havia cor fixa.
- Nota com tokens criados e contraste conferido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: token de motion/raio/sombra; gerar uma tabela de tokens como contrato com o Designer; teste visual claro/escuro).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (decide paleta e estratégia; a referência Impeccable é o vocabulário — este gerador traduz para o CSS real do JavaFX).
- **Vem antes:** `java-project-bootstrap` (CSS placeholder inicial).
- **Vem depois:** `javafx-app-shell`, `javafx-screen-fxml` e `javafx-dashboard` (todos consomem os tokens).
- **Não confundir com:** `javafx-screen-fxml` (a tela em si — aqui só o tema).
