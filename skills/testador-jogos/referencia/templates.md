# Templates dos entregáveis

Use estas estruturas exatas (adapte seções vazias com "—" em vez de omitir; omitir seção
esconde que ela não foi coberta).

## 1. RELATORIO-QA-<jogo>-<data>.md

```markdown
# Relatório de QA + Análise Crítica — <Jogo> (<versão/build>)

**Data:** ... · **Testador:** Claude (skill game-tester) · **Modo:** A/B/C/D
**Ambiente:** navegador/viewport/plataforma · **Tempo de teste:** ~Xh

## Sumário executivo
(5 linhas: estado geral, nº de bugs por severidade, nota geral, veredito em uma frase,
recomendação: lançar / corrigir antes / voltar ao design.)

| Severidade | Qtd |
|---|---|
| A (crítico) | X |
| B (grave) | X |
| C (menor) | X |

## O que funciona bem
(3-6 bullets com exemplos concretos — o que preservar nas próximas versões.)

## Bugs encontrados
### Severidade A
(bugs no formato padrão do SKILL.md, ID sequencial: A-01, A-02…)
### Severidade B
### Severidade C

## Análise crítica
(As 8 categorias de analise-critica.md: nota + argumento + exemplo + sugestão, uma subseção
por categoria. Fechar com a tabela de notas, veredito em uma frase, top 3 alavancas,
para quem é / não é.)

## Resultados por persona
(Um parágrafo por persona: o que tentou, onde travou, resposta à pergunta-chave.)

## Limitações do teste
(O que NÃO foi testado e por quê: áudio real, multiplayer, dispositivo físico, duração…
Honestidade aqui protege a confiança em todo o resto.)
```

## 2. PLANO-DE-MELHORIAS-<jogo>-<data>.md

```markdown
# Plano de Melhorias — <Jogo>

(Ordenado por impacto ÷ esforço dentro de cada onda. Bugs A entram automaticamente em "Agora".
Itens 💡 da análise crítica entram na onda que o impacto justificar.)

## 🔴 Agora (bloqueia lançamento / afasta jogador no minuto 1)
| # | Item | Origem | Impacto | Esforço | Por quê |
|---|---|---|---|---|---|
| 1 | ... | Bug A-01 / Análise cat. 2 | Alto | P/M/G | ... |

## 🟡 Próxima versão (eleva a nota geral)
(mesma tabela)

## 🟢 Backlog (polimento e apostas)
(mesma tabela)

## Sequência sugerida
(3-5 linhas: por onde começar e por quê, dependências entre itens.)
```

## 3. CHECKLIST-REGRESSAO-<jogo>.md

```markdown
# Checklist de Regressão — <Jogo>

**Como usar:** a cada nova versão, execute os casos e marque Status:
✅ passou · ❌ falhou (abrir bug) · ⚠️ passou com ressalva · ⏭️ não aplicável/não testado.
Casos REG-* nasceram de bugs reais — se falharem, o bug voltou.

## Fumaça (rodar primeiro, ~5 min)
| ID | Caso | Passos resumidos | Esperado | Status |
|---|---|---|---|---|
| SMK-01 | Jogo abre | Abrir URL | Menu carrega sem erro de console | |
| SMK-02 | Partida inicia | ... | ... | |

## Núcleo (mecânicas principais)
| ID | Área | Caso | Passos resumidos | Esperado | Status |
|---|---|---|---|---|---|
| COR-01 | ... | ... | ... | ... | |

## Estados e persistência
(pause/restart/save — incluir sempre: "reiniciar zera score/vidas/timer", "pause congela timer")

## Interface
(menus, HUD, textos, resize)

## Regressão de bugs corrigidos
| ID | Caso (bug de origem) | Passos resumidos | Esperado | Status |
|---|---|---|---|---|
| REG-01 | Não trava ao pausar antes de iniciar (A-01) | ... | ... | |

## Destrutivos (arsenal mínimo)
(5-8 casos do arsenal do destruidor que este jogo precisa aguentar)
```

Regras: IDs estáveis (não renumerar entre versões — casos novos ganham IDs novos); mínimo de
15 casos no total; todo bug do relatório gera um caso REG-*; passos "resumidos" = reproduzíveis
em 1 linha, o detalhe completo vive no relatório.
