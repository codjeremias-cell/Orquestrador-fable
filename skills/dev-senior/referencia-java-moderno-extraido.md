# Referência — Java moderno (extraído da lente `dev-senior`)

Regras de Java moderno da lente `dev-senior` (proposta 2026-07-07, via `affaan-m/ECC`). **Condicionado ao JDK do projeto: confirme a versão real antes de usar (RO-01 — nunca inventar; redação nas Salvaguardas do SKILL.md).**

- `record` para DTOs/tipos de valor imutáveis (Java 16+); campos `final` por padrão.
- `sealed interface`/`sealed class` para hierarquias fechadas conhecidas (Java 17+).
- Pattern matching com `instanceof` sem cast explícito (Java 16+); em `switch`, exaustivo sobre tipo `sealed` (estável desde Java 21).
- Text blocks para strings multi-linha — SQL, JSON de template (Java 15+).
- `Optional<T>` só como **retorno** de método (nunca como campo ou parâmetro); usar `map`/`flatMap`/`orElseThrow` — nunca `get()` sem checar presença.
- Pipeline de stream curto (3-4 operações); lógica complexa vira loop explícito, não stream forçado.
