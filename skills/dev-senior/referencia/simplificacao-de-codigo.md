# Heurísticas de Simplificação de Código e Grounding (SDD)

Proveniência: `addyosmani/agent-skills` (MIT) — laudo em `garimpo-lote-5repos-2026-08-26.md` (G2, G3).

## Princípio Fundamental
Código sênior não é o código mais esperto ou sofisticado; é o código que **outro engenheiro lê, entende e altera sem medo amanhã**. A complexidade acidental se acumula através de abstrações prematuras, camadas desnecessárias de indireção e padrões desatualizados.

---

## 1. Heurísticas de Redução de Carga Cognitiva

### A. A Escada da Simplicidade (YAGNI com Evidência)
Antes de introduzir qualquer nova classe, interface ou função utilitária, varra a escada:
1. **Isso precisa existir?** (Se o requisito não pede hoje, corte).
2. **A biblioteca padrão (stdlib) resolve?** (Sem dependências extras).
3. **Um recurso nativo da plataforma/framework resolve?** (Não crie helper para o que a linguagem já oferece).
4. **Resolve em uma linha legível no próprio ponto de uso?** (Evite criar funções privadas de 1 linha que apenas rebatizam chamadas).
5. **Apenas quando os anteriores falharem:** crie a abstração mínima necessária.

### B. Inverted Guardrails (Early Return)
- Elimine aninhamentos profundos (`if` dentro de `if` dentro de `for`).
- Trate casos de erro, nulos e limites no topo da função com **retorno antecipado (early return)**.
- O corpo principal da função deve conter o fluxo primário (caminho feliz) no nível zero de indentação.

### C. Descarte de Indireção Vazia
- **Anti-Pattern:** Interfaces com uma única implementação que nunca terá variação (`UserServiceImpl` para `UserService` sem polimorfismo real).
- **Anti-Pattern:** Wrappers de pass-through que apenas repassam parâmetros sem adicionar validação, transformação ou controle transacional.
- **Ação:** Una a interface e a implementação se o módulo for interno e não representar fronteira de arquitetura.

### D. Unificação de Tipos e Contratos
- Evite criar DTOs intermediários idênticos que apenas espelham entidades campo a campo sem propósito de fronteira.
- Utilize tipos imutáveis modernos (`record` no Java 17+, `readonly struct` no C#, tipos estritos em TypeScript) para expressar valor.

---

## 2. Source-Driven Development (SDD) — Grounding em Fontes Oficiais

### Regra de Ouro (RO-01 Expandida)
Nunca implemente padrões de frameworks ou bibliotecas com base em memória desatualizada do modelo. Modelos de IA frequentemente alucinam métodos depreciados (ex.: Spring Security antigo com `WebSecurityConfigurerAdapter`, configurações obsoletas de Tailwind, APIs antigas de frameworks).

### Protocolo de Grounding:
1. **Identifique a versão exata do ecossistema:** Abra `pom.xml`, `package.json`, `build.gradle` ou `pubspec.yaml` antes de escrever código.
2. **Grounding obrigatório em padrões idiomáticos:**
   - Java / Spring Boot: Spring Boot 3+ (Jakarta EE, Java 17/21 records, interfaces funcionais).
   - Tailwind: Tailwind v4 (`@theme`, CSS vars, OKLCH).
   - React / Web: Server State (TanStack Query) vs Client State (Zustand), componentes acessíveis (Radix UI).
3. **Citação de Proveniência:** Se uma decisão de API for não óbvia, cite no comentário ou na documentação a fonte oficial consultada.

---

## 3. Recibos de Simplificação de Código
*Proveniência complementar: `deepseek-ai/deepseek-harness` @ `b150a551b8d465e31e418e1b2eaf5e79bbb7d28e` (MIT), `.agents/skills/dsh-find-simplifications/SKILL.md`, SHA-256 `c6f0165f6aa36af51ef46b3e0111c6c936d7498452cffcfd805cc81cc336fb4b` — laudo `garimpo-lote-4-repositorios-2026-08-27.md` §D1.*

Toda simplificação relevante deve apresentar três recibos objetivos:
1. **Auditoria por consumidores:** Quem realmente consome esta classe, método ou parâmetro hoje? Se for apenas um chamador interno ou apenas o próprio teste, inlinear ou simplificar.
2. **Propriedade e Ownership:** Quem é o dono do estado e do ciclo de vida deste dado? Evite gerenciar estado concorrente em múltiplos locais.
3. **Saldo Líquido de Complexidade:** A mudança reduz a complexidade líquida (`net: -N linhas` ou eliminação de dependência/camada indireta).

---

## 4. Checklist de "Deslop" de Código (Diff-Scoped)
*Proveniência: `openclaw/.agents/skills/deslop/SKILL.md` (MIT) — garimpo 2026-08-27 · OC1.*

Ao revisar ou finalizar alterações em um branch/PR, passe o pente-fino estritamente no `git diff` contra a base:
1. **Comentários de narração óbvia:** Remova comentários que apenas repetem a sintaxe do código (`// incrementa i`, `// chama o serviço`). Mantenha apenas os que explicam o **porquê** ou decisões não óbvias.
2. **Checagens defensivas imaginadas:** Remova blocos `try/catch` anormais ou validações para estados que a arquitetura do sistema torna impossíveis de ocorrer no fluxo interno.
3. **Type Laundering:** Elimine casts inseguros que fraudam a verificação de tipos (ex.: `as any`, `as unknown as T` em TypeScript, casts cegos sem `instanceof` em Java).
4. **Variáveis intermediárias de uso único:** Inline variáveis temporárias que não agregam semântica de domínio nem facilitam depuração.
5. **Shims e retries órfãos:** Remova fallbacks, adaptadores e retries que não possuam um contrato de remoção e um cliente ativo comprovado.
6. **Preservação de comportamento:** A limpeza é estritamente não-funcional; se houver qualquer dúvida sobre impacto no comportamento em tempo de execução, reporte antes de alterar.

