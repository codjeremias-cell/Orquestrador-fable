# Matriz Operacional SAST e Supply-Chain por Ecossistema

> **Referência operacional da lente `especialista-seguranca`** (carregada sob demanda).  
> **Proveniência:** `tools/security-scan.md` e `tools/deps-audit.md` de `github.com/wshobson/commands` (MIT) — laudo em `garimpo-lote-3-fontes-2026-08-28.md` (`WS1`).

---

## 1. Matriz de Ferramentas SAST (Static Application Security Testing)

Ao realizar varredura estática de vulnerabilidades e code review focado em segurança, utilize as ferramentas canônicas do ecossistema correspondente:

| Ecossistema / Linguagem | Ferramenta Canônica | Tipo / Foco | Comando Típico / Configuração |
|---|---|---|---|
| **Python** | `bandit` | AST Security Linter (CWE / OWASP) | `bandit -r . -f json -o bandit-report.json` |
| **Python** | `semgrep` | Padrões customizados e regras de segurança | `semgrep --config=p/security-audit --json` |
| **JavaScript / TypeScript** | `eslint-plugin-security` | Regras anti-injection, RegExp DoS e AST | `eslint . --ext .js,.ts,.tsx` |
| **JavaScript / TypeScript** | `semgrep` | Padrões de framework (React/Node/Next.js) | `semgrep --config=p/javascript --config=p/typescript` |
| **Go** | `gosec` | AST Linter para Go (SQLi, TLS fraco, overflows) | `gosec -fmt=json -out=gosec-report.json ./...` |
| **Rust** | `cargo-geiger` | Auditoria de blocos `unsafe` e crates inseguros | `cargo geiger` |
| **Java** | `spotbugs` + `find-sec-bugs` | Bytecode Analysis para vulnerabilidades Java | `mvn spotbugs:check` (com plugin `findsecbugs-plugin`) |

---

## 2. Matriz de Auditoria de Dependências e Vulnerabilidades de Terceiros

Para checagem de CVEs, dependências desatualizadas e advisory databases (NVD/OSV/GitHub Advisory):

| Ecossistema | Arquivo de Manifesto / Lockfile | Ferramenta Canônica | Comando de Auditoria |
|---|---|---|---|
| **Node.js (npm)** | `package.json`, `package-lock.json` | `npm audit` | `npm audit --json` |
| **Node.js (pnpm)** | `pnpm-lock.yaml` | `pnpm audit` | `pnpm audit --json` |
| **Node.js (yarn)** | `yarn.lock` | `yarn audit` | `yarn audit --json` |
| **Python** | `requirements.txt`, `pyproject.toml`, `poetry.lock` | `pip-audit` / `safety` | `pip-audit --format json` ou `safety check --json` |
| **Go** | `go.mod`, `go.sum` | `govulncheck` | `govulncheck ./...` |
| **Rust** | `Cargo.toml`, `Cargo.lock` | `cargo audit` | `cargo audit --json` |
| **Java / Maven** | `pom.xml` | OWASP Dependency-Check | `mvn org.owasp:dependency-check-maven:check` |

---

## 3. Verificações de Supply-Chain e Typosquatting

Ataques de cadeia de suprimentos frequentemente exploram nomes similares ou scripts de ciclo de vida de instalação:

### 3.1. Prevenção de Typosquatting
- Ao auditar novos pacotes ou dependências externas, verifique a distância de Levenshtein contra pacotes populares do ecossistema (ex.: `reacct` vs `react`, `lodsh` vs `lodash`, `reqeusts` vs `requests`).
- Se a distância for 1 ou 2 caracteres de diferença, trate como suspeita de typosquatting e exija verificação manual do autor/repositório antes de instalar.

### 3.2. Lifecycle Scripts Maliciosos
- **Node.js:** inspecione scripts `preinstall`, `install` e `postinstall` no `package.json` de pacotes de terceiros.
- **Python:** inspecione execuções no `setup.py` / `build.py` que realizem chamadas de rede ou decodificação base64 em install-time.
- **Postura:** em ambientes de build/CI, use flags que bloqueiem scripts não essenciais (ex.: `npm install --ignore-scripts`).

## 4. GitHub Actions — integridade do pipeline

Ao revisar ou criar workflows que executem código do repositório, trate o pipeline como superfície de supply chain:

- **Pinagem imutável:** actions de terceiros devem usar o SHA completo do commit, com comentário da tag humana conferida. Resolva e valide o SHA no repositório oficial; não copie o hash de outro projeto.
- **Privilégio mínimo:** declare `permissions: {}` no topo e conceda somente os escopos indispensáveis em cada job. Um job que publica, atesta ou comenta deve explicar por que precisa escrever.
- **Credencial do checkout:** configure `persist-credentials: false` em todo `actions/checkout` que não precise fazer push ou tag depois do checkout. Se precisar, declare o mecanismo de autenticação substituto e o escopo.
- **Análise do workflow:** rode `zizmor` ou analisador equivalente no YAML antes de promover o workflow a gate; fixe o analisador em uma versão exata, nunca `latest`. Falha de análise é lacuna de prova, não sinal para desabilitar a verificação.
- **Atualização:** mudar a tag humana não basta; confira o novo commit, revise permissões e reexecute o gate. O comentário da tag é legibilidade, não identidade.

**Limite:** estes controles endurecem a cadeia do workflow; não substituem SAST/SCA do código nem provam que um action de terceiro é benigno. A action e o SHA continuam sujeitos ao vetting de origem e licença.
