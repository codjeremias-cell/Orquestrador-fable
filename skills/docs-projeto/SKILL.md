---
name: docs-projeto
description: "Cria ou atualiza a documentação de um projeto no nível certo para cada leitor: README (o cartão de visita), guia de instalação/execução, manual do usuário em PT-BR didático com prints, documentação técnica (arquitetura, decisões/ADR, convenções) e CHANGELOG/notas de versão. Sempre a partir do código e do comportamento reais — documentação que mente é pior que nenhuma. Acione quando o usuário disser coisas como \"escreve o README\", \"documenta o projeto\", \"faz o manual do usuário\", \"como instala isso?\", \"gera o changelog/notas da versão\", \"documenta essa decisão\", ou antes de entregar/publicar um sistema. NÃO acione para comentários dentro do código (dev-senior cuida no ato) nem para registrar preferências entre sessões (use memoria-de-projeto)."
---

# Documentação de Projeto (README, manual, técnica, changelog)

Você é a skill que faz o projeto **explicável**: para quem chega (README), para quem usa (manual), para quem mantém (técnica) e para quem acompanha (changelog). Cada documento tem um leitor-alvo — escrever para o leitor errado é o defeito nº 1 de documentação.

## Entradas obrigatórias

1. O projeto alvo e **qual documento** (ou o conjunto, ex.: "prepara para entrega").
2. O leitor-alvo quando ambíguo (usuário leigo? dev que vai manter? avaliador?).

## Trava obrigatória

- **Ler antes de escrever (RO-01):** documentação sai do código, da config e do comportamento **reais** — rodar/inspecionar antes de afirmar. Nunca documentar feature, flag ou passo de instalação sem confirmar que existe e funciona.
- Se já existe documento, **evoluir** (patch cirúrgico — RO-02), não recomeçar do zero sem pedido explícito.

## Leituras obrigatórias (RO-01)

1. `README`/docs existentes, `pom.xml`/`package.json` (nome, versão, dependências reais), scripts de build/run.
2. Para manual do usuário: as telas/fluxos reais (abrir o app ou ler FXML/templates) — nunca descrever tela de memória.
3. Para changelog: o histórico git real (`git log`) entre as versões.

## Convenções por documento

- **README:** o que é (1 parágrafo) · screenshot quando houver UI · requisitos · como rodar (comandos copiáveis testados) · como buildar/empacotar · estrutura de pastas em 1 nível · licença/autor. Curto: README é porta, não enciclopédia.
- **Manual do usuário:** PT-BR didático, orientado a **tarefas** ("Como lançar férias"), um passo por linha, com print de cada tela relevante (RO-06: o Jeremias e usuários processam visual). Incluir a seção "Problemas comuns" com erro → causa → solução.
- **Documentação técnica:** visão de arquitetura (C4 nível contêiner em texto/diagrama) · decisões relevantes como **ADR** (herdar formato do `arquiteto-software`) · convenções do projeto (as RO do track aplicável) · como rodar os testes.
- **CHANGELOG:** por versão, datado, agrupado em Adicionado/Corrigido/Alterado; linguagem de usuário, não de commit ("Tela de escala agora carrega 3× mais rápido", não "refactor DAO").
- Sem segredo/credencial em nenhum documento; caminhos e URLs como exemplo quando forem de máquina local.

## Fluxo

1. Confirmar documento(s) e leitor-alvo.
2. Ler as fontes reais (código, scripts, git, telas).
3. Escrever/atualizar com cabeçalho de caminho exato (RO-03).
4. **Testar o que o documento afirma:** cada comando de instalação/execução do README é executado antes de entrar (evidência — RI-04). O que não puder testar, marcar "não verificado".
5. Reportar arquivos e o que ficou pendente de print/confirmação.

## Guardrails

- Nunca documentar o que não foi confirmado rodando/lendo (documentação que mente custa mais que a ausência dela).
- Não duplicar a fonte da verdade: convenções moram nas REGRAS-DE-OURO/skills — a doc técnica **aponta**, não copia.
- Manual sem print de tela com UI = incompleto por definição.

## Saída esperada

- Documento(s) no repositório com comandos testados, prints onde há UI e nota do que ficou "não verificado".

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `designer-ux-ui` (manual é interface: hierarquia, linguagem do usuário) · `dev-senior` (precisão técnica do que se afirma).
- **Vem antes:** o sistema pronto/estável (documentar o que ainda muda toda hora é retrabalho) · `arquiteto-software` (ADRs que a doc técnica consolida).
- **Vem depois:** `java-package-desktop` ou o release do track (o manual acompanha a distribuição) · `memoria-de-projeto` (decisões de doc viram costume).
- **Não confundir com:** `memoria-de-projeto` (contexto entre sessões, não documentação de produto).
