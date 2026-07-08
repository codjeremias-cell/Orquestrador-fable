---
name: memoria-de-projeto
description: Mantém um arquivo de memória de projeto portável (preferências, lições aprendidas e costumes) que preserva o contexto entre sessões. Use SEMPRE que o usuário anexar ou mencionar um arquivo de memória/contexto de projeto, pedir para salvar ou consolidar preferências, lições ou costumes, preparar o "handoff" para a próxima sessão, atualizar a memória do projeto, ou iniciar dizendo que vai continuar um trabalho anterior. Acione TAMBÉM ao detectar, durante a conversa, novas preferências, decisões, correções ou convenções que valham ser registradas para sessões futuras — mesmo que o usuário não peça explicitamente.
---

# Memória de Projeto

## Propósito

O Claude não lembra de conversas anteriores entre sessões. Esta Skill resolve isso com um único arquivo Markdown portável — a "memória do projeto" — que o usuário guarda junto com os arquivos do projeto e anexa no início de cada nova sessão. O arquivo concentra três coisas: **preferências** (como o usuário gosta que o trabalho seja feito), **lições aprendidas** (decisões, correções, o que funcionou e o que não) e **costumes** (padrões e convenções recorrentes).

A ideia é simples: no início da sessão o Claude *lê* esse arquivo e age de acordo; durante a conversa ele *capta* novos aprendizados; ao final (ou quando pedido) ele *devolve* a versão atualizada para o usuário guardar. Assim o contexto se acumula sessão após sessão, sob controle total do usuário e versionável junto com o projeto.

## O arquivo de memória

- **Nome padrão:** `MEMORIA-PROJETO.md`. Um projeto pode personalizar (ex.: `MEMORIA-SIGCOT.md`, `MEMORIA-EMBALO.md`); cada projeto tem o seu.
- **Como reconhecer:** ao iniciar uma sessão, considere candidato a arquivo de memória qualquer anexo cujo nome contenha `MEMORIA`, `MEMÓRIA` ou `CONTEXTO`, ou cujo conteúdo siga a estrutura desta Skill.
- **Template completo:** está em `assets/MEMORIA-PROJETO.template.md`. Use-o como base ao criar a memória de um projeto novo.

## Fluxo de trabalho

### Fase 1 — Carregar (início da sessão)

Se houver um arquivo de memória disponível (anexado, no projeto, ou no diretório de trabalho):

1. Leia-o por completo antes de responder à primeira solicitação.
2. Internalize preferências, lições e costumes — eles passam a guiar suas respostas durante toda a sessão.
3. Confirme o carregamento em **uma linha curta**, citando a versão e a data da última atualização. Ex.: *"Memória do projeto carregada (v7, atualizada em 2026-06-10). Pronto para continuar."* Não despeje o conteúdo de volta nem faça resumo longo — o usuário já conhece o próprio arquivo.

Se não houver arquivo e o trabalho aparentar ser de projeto contínuo, ofereça criar a memória a partir do template.

### Fase 2 — Capturar (durante a conversa)

Fique atento a sinais de que algo merece ser registrado e acumule esses itens ao longo da conversa (mentalmente ou em rascunho):

- O usuário expressa uma **preferência** ("sempre faça X", "prefiro Y", "não gosto de Z", "use sempre este padrão").
- Uma **lição** surge: um bug resolvido e sua causa, uma decisão de arquitetura, uma abordagem que falhou, uma correção que o usuário fez no seu trabalho.
- Um **costume** se repete: uma convenção de nomenclatura, um fluxo de trabalho, uma ordem de etapas que o usuário segue.

Não interrompa o trabalho a cada item. Apenas registre internamente e consolide na Fase 3. Se um aprendizado for claramente importante e duradouro, você pode confirmar em uma linha: *"Anotei para a memória: [item]."*

### Fase 3 — Consolidar (fim da sessão ou sob demanda)

Ao final de uma sessão produtiva, ou quando o usuário pedir ("atualiza a memória", "prepara o handoff", "consolida o que aprendemos"):

1. **Releia** o arquivo de memória atual (se existir).
2. **Mescle** os novos aprendizados com o conteúdo existente — não recomece do zero.
3. **Atualize** o cabeçalho: incremente a versão e registre a data atual da sessão.
4. **Entregue** o arquivo atualizado (veja "Adaptação por ambiente").

## O que registrar — e o que NÃO registrar

**Registre** apenas o que for útil em sessões *futuras*: preferências duradouras, decisões com motivo, convenções, lições reaproveitáveis. Cada item deve ser uma frase curta e acionável.

**Não registre:**
- Conversa-fiação, passos triviais ou contexto efêmero que não se repete.
- **Dados sensíveis**: senhas, tokens, chaves de API, credenciais, números de documentos, dados pessoais sensíveis. Se algo do tipo aparecer, registre apenas a *convenção* (ex.: "as chaves ficam em variáveis de ambiente"), nunca o valor.

## Regras de consolidação

Para o arquivo se manter útil em vez de virar um depósito confuso:

- **Mescle, não duplique.** Antes de adicionar, verifique se o item já existe. Se existir de forma parecida, refine o existente em vez de criar um quase-igual.
- **Atualize o que mudou.** Se uma preferência ou decisão foi revista, substitua a antiga e anote a mudança no histórico — não deixe as duas versões convivendo.
- **Não apague histórico relevante sem confirmar.** Remover ou reescrever lições antigas em peso exige um "ok" do usuário.
- **Date as mudanças.** Use sempre a data atual da sessão (não datas fixas) e registre cada consolidação no histórico ao final do arquivo.
- **Versione.** Incremente a versão a cada consolidação (v1, v2, ...).
- **Mantenha enxuto.** Itens curtos e diretos. Se uma seção crescer demais, agrupe por tema com subtítulos.

## Adaptação por ambiente

A forma de entregar o arquivo atualizado depende de onde a sessão roda:

- **Com acesso a sistema de arquivos** (Claude Code, Cowork, ou chat com ferramentas de arquivo): escreva/atualize o arquivo diretamente e informe o caminho para o usuário salvar ou versionar.
- **Chat sem sistema de arquivos** (claude.ai/app comum): apresente o conteúdo completo do arquivo atualizado em um bloco para o usuário copiar e salvar. Deixe explícito que ele deve **substituir** o arquivo antigo e **reanexar** essa versão na próxima sessão — é o que mantém o ciclo funcionando.

## Estrutura do arquivo

O template canônico está em `assets/MEMORIA-PROJETO.template.md`. Em resumo, o arquivo tem: cabeçalho com nome do projeto, versão e data; visão geral (projeto, objetivo, stack); regras invioláveis; preferências; lições aprendidas; costumes e convenções; pendências/decisões em aberto; e histórico de atualizações ao final. Siga essa estrutura ao criar ou atualizar a memória.

## Relação com a memória nativa do Claude

Algumas superfícies do Claude já têm memória automática própria. Esta Skill é **complementar e diferente**: o arquivo de memória é *manual, por projeto, portável e versionável*, fica sob controle do usuário e pode acompanhar o repositório. Não dependa da memória nativa para o que esta Skill cobre — a fonte da verdade é o arquivo.

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `auditor-responsabilidades` (não conformidade recorrente vira lição) · `inovacao-melhorias` (aprendizados alimentam retrospectivas).
- **Vem antes:** qualquer sessão de trabalho — a memória carrega no início.
- **Vem depois:** qualquer entrega relevante — preferências, decisões e correções consolidadas.
- **Não confundir com:** `docs-projeto` (documentação de produto para leitores do projeto — aqui é contexto portável entre sessões).
