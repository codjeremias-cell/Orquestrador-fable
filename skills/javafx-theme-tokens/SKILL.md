---
name: javafx-theme-tokens
description: "Cria ou ajusta o tema visual de uma aplicação JavaFX por tokens de cor em CSS — claro e escuro é o caso comum, mas o mesmo contrato de chaves vale para quantos temas o projeto tiver — com as variáveis declaradas no .root e sem cores fixas. Acione com \"cria o tema escuro\", \"preciso de light e dark\", \"centraliza as cores em tokens\", \"essa cor fixa está quebrando no dark\", \"monta o base.css e o tema-dark\". Fronteira entre as skills-irmãs: aqui é SÓ o tema/os tokens de cor (o contrato que as telas consomem); para a tela em si (FXML+controller) use javafx-screen-fxml; para um painel de KPIs use javafx-dashboard; para a casca do app (janela/navegação) use javafx-app-shell."
---

# JavaFX — Tema por Tokens (CSS por tema)

## Objetivo

Centralizar as cores da aplicação em **tokens** (variáveis CSS) declarados no `.root` (ou na classe de raiz do tema), com o **mesmo conjunto de chaves em todo tema** que o projeto tiver, de modo que nenhuma tela use cor fixa. Trocar de tema vira trocar o valor dos tokens — sem caçar hex espalhado.

## Fronteira com as skills-irmãs (não confundir)

Esta skill é a **dona do contrato de cor**; as outras o **consomem**:

- **Aqui (`javafx-theme-tokens`):** os tokens e o(s) CSS de tema — as chaves que todo tema preenche.
- **`javafx-screen-fxml` · `javafx-dashboard` · `javafx-app-shell`:** consomem os tokens pelo nome (nunca hex). Se uma dessas telas usa uma cor fixa, é aqui que se cria/normaliza o token para ela.

## Entradas

**Obrigatórias:** (1) o projeto JavaFX alvo e onde ficam os CSS (ex.: `src/main/resources/**/css`); (2) se é criar do zero (tema[s] novo[s]) ou ajustar tema(s) existente(s).

**Opcionais:** paleta desejada (marca, sucesso, erro, aviso); telas/CSS que ainda usam cor fixa e precisam migrar para token.

**Trava:** não reescrever um tema existente sem ler o(s) atual(is). Se houver mais de um CSS de tema, confirme quais entram.

## Leituras obrigatórias (RO-01)

1. O(s) CSS de tema já existentes, para copiar o padrão de nomes de token e a **contagem real** de temas.
2. Como o tema é trocado em runtime (qual classe/serviço aplica o(s) stylesheet(s) ou marca a raiz).
3. Uma tela que usa as cores, para conferir os tokens necessários.

## Contrato de temas (esta skill é a dona)

Todo tema do projeto-alvo — sejam 2 (claro/escuro) ou os 4 do SIGO (claro/escuro/cinza/grafite) — preenche o **mesmo conjunto fechado de chaves**: os tokens de base (fundo, texto, primária, bordas) e os tokens semânticos de status que o projeto usa (no SIGO: `Cores.Status` OK/ATENCAO/CRITICO/INFO/NEUTRO, resolvidos via `-status-*`).

- **Quem consome o contrato:** qualquer CSS de tela/componente (`javafx-screen-fxml`, `javafx-dashboard`, `javafx-app-shell`) que referencia o token pelo nome — nunca o hex; no padrão SIGO, também o call-site Java, que pinta via `Cores.status(s)` e nunca vê hex.
- **O que acontece quando um tema não preenche uma chave (o porquê da regra):** o JavaFX ignora a regra em silêncio (não há erro de compilação de CSS) — a tela fica com a cor do tema anterior ainda aplicado (troca parcial) ou, se o valor for lido como `Paint` em Java, `ClassCastException String→Paint`. Por isso, adicionar tema é adicionar um bloco novo com **todas** as chaves existentes, nunca um subconjunto.

## Os invariantes inegociáveis (valem em qualquer projeto)

- Cada cor é uma **variável de tema**, nunca hex fixo numa regra de componente (hex fixo não acompanha a troca de tema).
- O token precisa estar **declarado antes de ser usado** — token não declarado é ignorado em silêncio (ver Contrato acima).
- `-fx-border-color` com 4 valores = **TOP, RIGHT, BOTTOM, LEFT** (RO-12).
- **Todo tema do projeto define o mesmo conjunto de chaves** (Contrato acima) — nenhuma tela referencia cor fixa.
- Contraste mínimo 4.5:1 texto/fundo — casa com a lente Designer/QA (a11y).

## O que VARIA por projeto — espelhe, não prescreva

- **Quantidade de temas.** 2 (claro/escuro) é o piso genérico, não regra fixa — o SIGO tem 4. A contagem real do CSS existente vence o genérico.
- **Nomenclatura do prefixo do token.** `-color-*`, `-sigo-*`, `-status-*` — copie o prefixo já em uso; não inventar um segundo prefixo convivendo com o existente.
- **Mecanismo de troca.** Trocar o stylesheet inteiro (`Application.setUserAgentStylesheet`), marcar/desmarcar classes CSS na raiz da Scene, ou trocar o arquivo carregado — leia o mecanismo real (RO-01), nunca suponha.
- **Arquitetura em camadas.** Um único CSS autoral, ou uma base de terceiros (ex.: AtlantaFX Primer/Nord) por baixo de uma camada própria de identidade — espelhar o que o projeto já tem.

**Gabarito SIGO (few-shot de código real):** projeto-alvo **SIGO/SIGCOT ou família** → carregue `referencia-exemplos-reais-sigo.md` — `Tema.java` verbatim + arquitetura real (2 camadas: base AtlantaFX Primer/Nord + `styles.css` único com identidade; 4 temas por classes de raiz `tema-escuro`/`tema-cinza`/`tema-grafite`; aplicação só via `Tema.cena/aplicar/aplicarModo`; escolha persiste em `Preferencias`). Fora dessa família (outra casa ou greenfield), isto é exemplo de FORMA, não a arquitetura a copiar — desvio se declara (RO-01).

## Fluxo

1. Ler os CSS atuais e o mecanismo de troca de tema.
2. Definir/normalizar o conjunto de tokens — as mesmas chaves em todo tema existente e no(s) novo(s).
3. Migrar cores fixas encontradas para tokens (patch cirúrgico — RO-02).
4. Conferir que todo token usado está declarado em TODOS os temas e que o contraste passa.
5. Reportar o que mudou; em greenfield, declarar **SUPOSIÇÃO:** para contagem de temas e prefixo do token (RO-01).

## Guardrails

- Nenhum hex fixo em regra de componente — só token.
- Não usar token não declarado em algum dos temas.
- Não inventar o mecanismo de troca nem a contagem de temas (RO-01) — usar o real do projeto.
- Greenfield: não importar a arquitetura de 2 camadas + 4 temas do SIGO por reflexo — propor o mais simples que atende aos invariantes acima e declarar **SUPOSIÇÃO:** (RO-01).

## Saída esperada

- CSS de tema(s) com o mesmo conjunto de tokens em cada um.
- Telas migradas para tokens onde havia cor fixa.
- Nota com tokens criados, contraste conferido e, em greenfield, as suposições declaradas.

## Verificação de fechamento (RI-04)

Executável em sessão, **sem abrir o app**:

1. **Nenhum hex solto?** Varredura textual dos CSS confirmando que não há hex fora dos blocos de declaração de token.
2. **Contrato completo?** Todo token referenciado num CSS de tela/componente está declarado em CADA tema do projeto (uma chave faltando = troca parcial silenciosa ou `ClassCastException`).
3. **Contraste passa?** Os pares fundo/texto conferidos por cálculo (mínimo 4.5:1).

**SKIP declarado:** a troca de tema ao vivo dentro do app rodando exige o app aberto — quando não há como executar isso na sessão, vira SKIP com o motivo, nunca "validado visualmente" fingido.

## Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: token de motion/raio/sombra; gerar uma tabela de tokens como contrato publicável com o Designer; teste visual automatizado claro/escuro).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (decide paleta e estratégia; a referência Impeccable é o vocabulário — este gerador traduz para o CSS real do JavaFX).
- **Vem antes:** `java-project-bootstrap` (CSS placeholder inicial).
- **Vem depois:** `javafx-app-shell`, `javafx-screen-fxml` e `javafx-dashboard` (todos consomem o contrato de temas acima).
- **Não confundir com:** `javafx-screen-fxml` (a tela em si — aqui só o tema).

### 📜 Histórico
O changelog detalhado de evolução desta skill está em [referencia/historico.md](referencia/historico.md) (movido para fora do corpo para reduzir custo de token em cada turno — progressive disclosure).
