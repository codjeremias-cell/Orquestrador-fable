---
tipo: guia
papel: passo a passo completo — como usar, salvar e manter este cofre
última-atualização: 2026-07-20
versão: v1.5
---

# 📖 Guia de Uso e Manutenção do Cofre

> Referência prática para o dia a dia: como navegar, invocar skills, salvar memórias, capturar ideias e manter tudo funcionando com qualidade.
> Para o mapa geral do cofre, veja [[LEIA-PRIMEIRO]] e [[Base de Conhecimento - Índice]].

---

## 🗺️ Estrutura do cofre (em 30 segundos)

```
Skill Claude/
├── LEIA-PRIMEIRO.md           ← porta de entrada de qualquer sessão
├── CLAUDE.md                  ← instruções que o Claude lê automaticamente
├── Base de Conhecimento - Índice.md  ← hub central — mapeia tudo
│
├── Processos e Playbooks.md     ← receitas reutilizáveis entre projetos
├── Regras de Ouro e Inquebráveis.md  ← resumo de governança (RI/RO)
│
├── Aprendizagem/              ← lições consolidadas (índice + 1 arquivo por projeto)
├── 💡 Ideias/                 ← captura de ideias brutas e backlog
├── Guias/                     ← este arquivo + guias técnicos
├── Comitê de Lentes/          ← mapa das 9 lentes (7 notas + 2 links canônicos)
├── Catalogo-Skills-Unificado/ ← fonte canônica das skills (edite aqui)
├── Memorias-Versionadas/      ← backup Git verificável das memórias nativas
│
├── memoria/                   ← memória viva do SIGO/SIGCOT (junction)
├── memoria-escalaoper/        ← memória viva do EscalaOper (junction)
├── memoria-sentinela/         ← memória viva do Sentinela (junction)
├── memoria-embalo/            ← memória viva do Embalo (junction)
├── memoria-gradup/            ← memória viva do Gradup (junction)
├── memoria-marta/             ← memória viva do Encontre a Marta (junction)
├── memoria-posoperacao/       ← memória viva do PosOperação (junction)
├── memoria-scalping/          ← memória viva do Scalping/win_scalp (junction)
├── memoria-fluxonar/          ← memória viva do Fluxonar (junction)
│
├── .claude/skills/            ← runtime gerado do Claude (não edite aqui)
└── .agents/skills/            ← runtime gerado do Codex (não edite aqui)
```

---

## 1. Como iniciar qualquer sessão

### No Claude Code (terminal)
```
claude --add-dir "C:\caminho\do\projeto"
```
O Claude carrega o `CLAUDE.md` automaticamente, lê `LEIA-PRIMEIRO.md` e as skills ficam disponíveis via `.claude/skills/`.

### No Cowork (app desktop)
Conecte a pasta `Skill Claude` no Cowork. O Claude lê `CLAUDE.md` e `LEIA-PRIMEIRO.md`. **Atenção:** os junctions de `memoria*/` não abrem no Cowork — para acessar memória de projeto, use o Claude Code ou cole o conteúdo manualmente.

### Dica de início de sessão
Sempre comece dizendo ao Claude:
> "Leia LEIA-PRIMEIRO.md e me diga em que projeto vamos trabalhar."

Isso orienta a sessão e garante que as skills certas disparam.

---

## 2. Como invocar skills

### Disparo automático (recomendado)
Descreva o que você quer em linguagem natural — a skill certa dispara pela `description`:

| Você diz... | Dispara... |
|---|---|
| "cria o DAO de Motorista" | `java-jdbc-dao` |
| "quero uma tela de cadastro" | `javafx-screen-fxml` |
| "como organizar esse módulo?" | `arquiteto-software` |
| "audita a entrega" | `auditor-responsabilidades` |
| "o que pode melhorar nesse fluxo?" | `inovacao-melhorias` |
| "tem algum problema de segurança?" | `especialista-seguranca` |
| "vai do zero ao app rodando" | `spec-javafx-new-system` |

### Disparo explícito
Nomeie diretamente:
> "Usa a skill `java-jdbc-dao` para criar o DAO de Viagem."

### RI-06 — regra obrigatória
Se o assunto casar com uma skill, **usar a skill é obrigatório**. Pular é reprovado no gate do Auditor.

---

## 3. Como salvar memória de projeto

A memória vive nos junctions `memoria*/` — é a fonte única, carregada automaticamente no Claude Code.

### Para gravar algo na memória (Claude Code)
> "Grave na memória: [fato/decisão/convenção]."

O Claude grava em notas atômicas dentro da pasta de memória do projeto ativo. O conteúdo aparece no Obsidian via junction.

### Como atualizar o backup versionado

Na raiz do cofre, depois de revisar as mudanças de memória:

```powershell
.\scripts\sincronizar-memorias.ps1
.\scripts\sincronizar-memorias.ps1 -SomenteVerificar
```

O backup fica em `Memorias-Versionadas/` com extensão `.md.bak` e manifesto SHA-256. Ele serve para recuperação e **não substitui** a memória nativa. Publique somente em repositório privado.

### Formato de nota atômica (padrão)
Cada nota guarda **um único fato ou decisão**:
```markdown
---
tipo: decisao | convencao | aprendizado
projeto: EscalaOper
data: 2026-06-29
---

# [Título objetivo em uma frase]

[Contexto mínimo — por que isso importa]

## Detalhe
[O conteúdo em si]

## Relacionado
- [[outra-nota]]
```

### O que sempre merece ser gravado
- Decisões de arquitetura (por que escolheu X e não Y)
- Convenções de código descobertas no projeto
- Bugs difíceis resolvidos + causa raiz
- Mudanças de requisito ou de escopo
- Preferências e lições que continuarão válidas daqui a sete dias

### O que não entra na memória

Status, tarefa, artefato de execução, pendência e próximo passo pertencem ao `estado-projeto`: `estado/estado.json` é a fonte única e `estado/TAREFAS.md` é a visão humana regenerada. Veja [[MEMORIA-E-ESTADO]].

---

## 4. Como capturar uma ideia

1. Abra (ou crie) o arquivo correspondente em `💡 Ideias/` — ex.: `Ideias-EscalaOper.md`.
2. Adicione ao final usando o modelo:
```markdown
### [Título da ideia] — 2026-06-29
**Projeto:** EscalaOper
**O quê:** [uma frase]
**Por quê:** [o problema que resolve]
**Status:** 💭 rascunho
```
3. Pronto. Não precisa estar maduro para entrar aqui.

### Quando uma ideia amadurece
- Lição aprendida → vai para [[Melhorias e Aprendizados]]
- Planejamento concreto e próximos passos → vão para `estado/estado.json` pela skill `estado-projeto`
- Nova skill → vai para `Catalogo-Skills-Unificado/skills/` seguindo o [[PADRAO-DE-AUTORIA]]
- Mude o **Status** para ✅ ou ❌ e deixe registrado o motivo.

---

## 5. Como registrar uma melhoria ou lição

Camada `Aprendizagem/`: **padrão cross-projeto** → índice [[Melhorias e Aprendizados]]; **lição específica de um projeto** → o arquivo daquele projeto (ex.: [[EscalaOper]]). Se a lição está na memória nativa (junction) e você está no Cowork, use o runbook [[COMO-COLHER]]. Adicione na seção certa:

**Padrão reutilizável (cross-projeto):**
```markdown
- **[Nome do padrão]** → [o que aprendeu em uma frase]. Ex.: `java-jdbc-dao` valida isso.
```

**Por projeto:**
```markdown
### [Projeto] — [data]
- [O que foi feito / decidido / corrigido]
- Referências: [[nota-atômica-na-memoria]]
```

---

## 6. Como criar ou editar uma skill

**Sempre edite na fonte canônica:** `Catalogo-Skills-Unificado/skills/<nome>/SKILL.md`  
**Nunca edite em** `.claude/skills/` ou `.agents/skills/` — são runtimes gerados e sobrescritos pelo deploy.

### Passo a passo
1. Abra `Catalogo-Skills-Unificado/PADRAO-DE-AUTORIA.md` e leia a seção do tipo de skill (lente ou gerador).
2. Edite ou crie `Catalogo-Skills-Unificado/skills/<nome>/SKILL.md`.
3. Valide contra o **Checklist de "skill pronta"** (seção 9 do Padrão de Autoria).
4. Faça o deploy para os dois runtimes deste cofre — **`-ProjectPath` exige caminho absoluto; com
   `".."` o script reprova** (medido em 2026-07-27: `GetFullPath()` resolve contra o diretório do
   processo, não contra o `cd`, e ele acusa as 60 skills como ausentes):
```powershell
cd "C:\caminho\do\projeto\Catalogo-Skills-Unificado"
.\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -SomenteVerificar
.\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -Forcar
```
5. Teste na próxima sessão do Claude Code e do Codex.

### Para uma skill nova do zero
Siga o `PADRAO-DE-AUTORIA.md` §3 (anatomia) + §5 (estrutura por tipo) + §9 (checklist). Peça ao Claude para auditar com a lente `auditor-responsabilidades` antes de fazer o deploy.

---

## 7. Como fazer o deploy das skills (atualizar o runtime)

Sempre que editar qualquer skill no catálogo:

```powershell
# Deploy local, exato e verificável para Claude + Codex
# ATENÇÃO: -ProjectPath exige caminho ABSOLUTO. Com ".." o script reprova.
cd "C:\caminho\do\projeto\Catalogo-Skills-Unificado"
.\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -SomenteVerificar
.\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -Forcar

# Compatibilidade: deploy global somente para Claude
.\deploy-skills.ps1
```

**Se esquecer o deploy:** Claude e Codex podem carregar versões diferentes. O modo `-SomenteVerificar` retorna erro se faltar uma skill, arquivo ou hash.

---

## 8. Rotina de manutenção (semanal/quinzenal)

| Frequência | O que fazer |
|---|---|
| **A cada sessão** | Comece por `LEIA-PRIMEIRO.md`; atualize o estado se houve progresso e a memória somente se surgiu aprendizado durável |
| **Após mudar memórias** | Sincronize `Memorias-Versionadas/`, verifique e revise antes do commit |
| **Semanalmente** | Revise `💡 Ideias/` — mova o que amadureceu, descarte o que morreu |
| **Por sprint/entrega** | Adicione ao [[Melhorias e Aprendizados]] o que aprendeu; atualize estado nos playbooks |
| **Ao criar skill nova** | Siga Padrão de Autoria → deploy → teste |
| **Ao mudar convenção** | Grave na memória do projeto + atualize [[Processos e Playbooks]] se for cross-projeto |
| **Ao apagar algo do cofre** | Mova para `_to_delete/` primeiro (staging reversível), confirme com o Jeremias, depois apague — ver [[LEIA-arquivo-morto]] |

---

## 9. Hierarquia de decisão (quando há dúvida)

```
RI (Regras Inquebráveis)  →  sempre, sem exceção
RO universais             →  qualquer projeto, qualquer stack
RO por track              →  só no track correspondente (Java, Web, Flutter...)
Memória do projeto        →  contexto específico daquele sistema
Ideias/                   →  rascunho, sem compromisso
```

Em caso de conflito: a regra mais alta vence. O `auditor-responsabilidades` faz valer.

---

## 10. Navegação rápida no Obsidian

| Quer... | Vá para... |
|---|---|
| Mapa de tudo | [[Base de Conhecimento - Índice]] |
| Começar sessão | [[LEIA-PRIMEIRO]] |
| Ver as skills | [[Catalogo-Skills-Unificado/README\|Catálogo de Skills]] |
| As 9 lentes | [[Comitê de Lentes - Índice]] |
| Regras | [[Regras de Ouro e Inquebráveis]] |
| Processos prontos | [[Processos e Playbooks]] |
| Lições acumuladas | [[Melhorias e Aprendizados\|Aprendizagem · Índice]] |
| Colher memória de projeto | [[COMO-COLHER]] |
| Capturar uma ideia | `💡 Ideias/` |
| Como o Claude lê skills | [[COMO-O-CLAUDE-LE-AS-SKILLS]] |
| Agrupar memórias | [[Playbook - Agrupar memorias (junctions)]] |

---

### 📜 Histórico
- **2026-07-20 (v1.5):** Memória e estado separados: notas duráveis não aceitam mais status/pendências; progresso usa `estado.json` + `TAREFAS.md`.
- **2026-07-20 (v1.4):** Árvore e navegação reconciliadas com as nove memórias vivas e as nove lentes atuais.
- **2026-07-20 (v1.3):** Deploy unificado para `.claude/skills/` e `.agents/skills/`, com modo somente-verificação e paridade SHA-256.
- **2026-07-20 (v1.2):** Documentado o fluxo de backup versionado, verificação de integridade e cuidado com repositório privado.
- **2026-07-11 (v1.1):** Estrutura do cofre atualizada com a pasta `Aprendizagem/` (índice + 1 arquivo por projeto); seção 5 e navegação apontando pra ela e pro runbook [[COMO-COLHER]].
- **2026-06-29 (v1):** Criado durante reorganização do cofre. Consolida o uso prático em um único documento navegável.
