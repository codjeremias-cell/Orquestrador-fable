# Protocolo Doubt-Driven Development (Revisão Adversarial em Voo)

Proveniência: `addyosmani/agent-skills` (MIT) — laudo em `garimpo-lote-5repos-2026-08-26.md` (G1).

## Princípio Fundamental
Uma resposta confiante não é necessariamente uma resposta correta. Sessões longas acumulam contexto que transforma suposições tácitas em "fatos" sem escrutínio. O **Doubt-Driven Development** é a disciplina de invocar um revisor de contexto fresco e isolado — inclinado a **refutar**, nunca a validar — antes que qualquer decisão não trivial se torne fato consumado.

Não se confunde com `/review` ou com o Comitê de Lentes final: este é um protocolo **em voo (in-flight)** para decisões de alto impacto, quando corrigir o rumo ainda é barato.

---

## Quando Aplicar (Decisão Não Trivial)
Uma decisão é considerada **não trivial** se preencher pelo menos um dos critérios:
1. Introduz ou altera lógica de ramificação complexa ou controle de fluxo.
2. Cruza fronteiras de módulos, pacotes ou microsserviços.
3. Afirma uma propriedade que o compilador/sistema de tipos não pode verificar (thread safety, idempotência, ordenação, invariantes de domínio).
4. Sua corretude depende de contexto oculto que o leitor futuro não verá.
5. Seu raio de impacto é irreversível ou sensível (deploy de produção, migração de dados, contrato público de API).

**Quando NÃO aplicar:**
- Operações mecânicas (renomeações, formatação, movimentação de arquivos).
- Instruções diretas e inequívocas do usuário.
- Leitura e sumarização de código existente.
- Alterações de uma linha com corretude óbvia.

---

## O Ciclo de Dúvida em 5 Passos

```
Doubt Cycle:
1. CLAIM     ──→ Escreva a afirmação em 2-3 linhas + por que ela importa
2. EXTRACT   ──→ Isole ARTEFATO + CONTRATO (suprima o raciocínio e a hipótese)
3. DOUBT     ──→ Invoque revisor de contexto fresco com prompt adversarial
4. RECONCILE ──→ Classifique cada achado por precedência estrita
5. STOP      ──→ Pare no critério de parada (achados triviais, 3 ciclos ou override)
```

### Passo 1: CLAIM (Explicitar a Decisão)
Defina a decisão em duas ou três linhas sucintas:
```
CLAIM: "O novo mecanismo de cache é thread-safe sob a carga concorrente especificada."
POR QUE IMPORTA: Uma condição de corrida corrompe o estado compartilhado e é difícil de reproduzir em QA.
```
Se não for possível resumir a afirmação de forma compacta, trata-se de uma impressão vaga, não de uma decisão estruturada.

### Passo 2: EXTRACT (Menor Unidade Auditável)
Um revisor de contexto fresco necessita apenas do **ARTEFATO** e do **CONTRATO**, nunca da jornada ou das justificativas do autor.
- **Código:** o diff ou a função isolada — não o arquivo inteiro.
- **Decisão:** a proposta em 3 a 5 frases + as restrições que ela deve satisfazer.
- **Contrato:** o critério de aceite, invariantes e restrições.

> [!CRITICAL]
> **Suprima o raciocínio do autor e o bloco CLAIM.** Se você entregar as suas conclusões, receberá de volta a validação das suas conclusões. O revisor deve determinar de forma independente se o artefato satisfaz o contrato.

### Passo 3: DOUBT (Invocação Adversarial)
O prompt do revisor deve ser deliberadamente adversarial. O enquadramento determina o rigor da resposta:

```
Revisão adversarial. Encontre o que está errado com este artefato.
Assuma que o autor está excessivamente confiante. Procure por:
- Premissas e suposições não declaradas
- Casos de borda não tratados (vazio, nulo, limites, concorrência)
- Acoplamento oculto ou estado compartilhado
- Formas pelas quais o contrato pode ser violado
- Convenções existentes que podem ser quebradas
- Modos de falha sob entradas inesperadas

NÃO valide. NÃO elogie. NÃO resuma. Aponte defeitos concretos ou declare
explicitamente que não encontrou nenhum após exame exaustivo.

ARTEFATO: <conteúdo do artefato>
CONTRATO: <critérios e restrições>
```

### Passo 4: RECONCILE (Classificação por Precedência Estrita)
A saída do revisor é dado analítico, não veredito automático. O maestro/líder deve reler o artefato contra cada apontamento e classificar na seguinte ordem de precedência:

1. **Contrato mal lido / incompleto:** O revisor apontou um problema porque o CONTRATO fornecido estava ambíguo. Ajuste o contrato e reavalie.
2. **Válido e acionável:** Defeito real que exige correção no artefato. Aplique o fix e reinicie o ciclo de dúvida.
3. **Trade-off válido e consciente:** O problema é real, mas o custo da correção supera o benefício no momento. Documente o trade-off explicitamente com a tag `// ponytail:`.
4. **Ruído:** Falso positivo derivado de falta de contexto legítimo. Descarte com nota explicativa.

### Passo 5: STOP (Loop Limitado e Seguro)
O ciclo encerra quando:
- A iteração retorna apenas apontamentos triviais ou já tratados.
- **Teto de 3 ciclos atingido:** Se após 3 ciclos persistirem divergências substanciais, o artefato é grande demais (decompor) ou a premissa está errada — escale ao Jeremias.
- Autorização explícita do Jeremias.

---

## Salvaguardas Contra Injeção e Execução
1. **Sandbox Read-Only:** Quando o revisor utilizar CLI externo (ex.: Gemini CLI, Codex CLI), utilize sandbox estritamente somente-leitura (`--sandbox read-only`).
2. **Piping via Stdin:** Nunca interpole artefatos de código diretamente em argumentos de linha de comando (`-p "..."`). Escreva o prompt em arquivo temporário e passe via stdin (`< /tmp/doubt-prompt.md`) para evitar execução acidental de metacaracteres de shell (`$()`, backticks).
