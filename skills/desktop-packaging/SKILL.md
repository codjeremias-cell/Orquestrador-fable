---
name: desktop-packaging
description: "Empacota e distribui um app desktop Tauri v2: instaladores por SO (MSI/NSIS, .dmg, .AppImage/.deb), assinatura (chaves do updater e code signing de macOS/Windows) e auto-update via GitHub Releases com artefatos assinados. Acione com \"gera o instalador do app Tauri\", \"assina e publica o release\", \"quero auto-update via GitHub Releases\", \"monta o .msi/.dmg/.AppImage\", \"configura o updater assinado\", \"distribui o app\". NÃO acione para o empacotamento JavaFX com jpackage (use java-package-desktop) nem para o scaffold (desktop-tauri-scaffold) ou a feature (desktop-feature-crud)."
---

# Desktop Tauri v2 — Empacotamento, Assinatura e Auto-update (track desktop, proposta 2026-07-07)

## Objetivo

Levar o app Tauri **provado** à distribuição: **instaladores por SO**, artefatos **assinados** e
**auto-update** verificado por assinatura via **GitHub Releases** (plugin oficial). É o passo de
entrega ao usuário final.

> **Alternativa .NET (Velopack):** no galho Avalonia/.NET, o empacotamento e o auto-update
> (com delta updates, multiplataforma) ficam com o **Velopack** (https://github.com/velopack/velopack),
> não com o updater do Tauri (RO-DT4 já o registra).

## Entradas obrigatórias

1. App Tauri que já builda (vindo do `desktop-tauri-scaffold`) e os alvos de SO desejados.
2. Onde publicar: repositório do **GitHub Releases**.
3. Se haverá **code signing** de SO (certificado Windows / Apple Developer) além da assinatura do
   updater.

## Entradas opcionais

- Ícones por SO, categoria/publisher, canal (stable/beta), NSIS vs MSI no Windows.

## Trava obrigatória

- Sem o **par de chaves do updater** (pública no config, **privada só em secret de CI**) → **parar**, não publicar (detalhe: Convenções).
- Não assinar release em cima de um build **sem prova** (`testador-real` sem FAIL crítico).
- Sem certificado de code signing, **avisar** que o SO mostrará "editor desconhecido"
  (SmartScreen/Gatekeeper) e seguir só com a assinatura do updater se autorizado.

## Leituras obrigatórias (RO-01)

1. Doc do **updater** (https://v2.tauri.app/plugin/updater/) — geração de chave (`tauri signer
   generate`), `pubkey`, `endpoints`, formato do `latest.json`, variáveis
   `TAURI_SIGNING_PRIVATE_KEY(_PASSWORD)`.
2. O `tauri.conf.json` atual (bundle, `targets`, bloco updater herdado do scaffold).
3. O workflow de CI existente — reusar antes de reinventar (publicação assinada via `tauri-action`: Convenções).

## Convenções obrigatórias (Track desktop Tauri v2, proposta 2026-07-07)

- **Targets por SO:** Windows `msi` (WiX) e/ou `nsis`; macOS `dmg` (+ `app`); Linux `appimage` e/ou
  `deb`. Declarar em `bundle.targets`.
- **Assinatura do updater (obrigatória p/ auto-update):** chave gerada com `tauri signer generate`;
  **pública** no config, **privada + senha** como secrets de CI; cada artefato gera um `.sig` que o
  updater **verifica antes de instalar** — update não assinado é vetor de ataque.
- **Code signing do SO (recomendado):** Windows (Authenticode, cert em secret) e macOS (Developer ID
  + **notarização**) para não cair em SmartScreen/Gatekeeper. É **separado** da chave do updater.
- **Auto-update via GitHub Releases:** `endpoints` apontando para o `latest.json` do release;
  `tauri-action` publica os artefatos + `latest.json` assinados. Canal beta = endpoint separado.
- Versão do artefato = versão do app (**semver**). **Nunca renomear** artefato à mão depois de
  assinado — quebra a verificação.

## Fluxo

1. Ler updater doc, `tauri.conf.json` e CI (RO-01).
2. Gerar o par de chaves do updater; pública no config, privada nos secrets.
3. Configurar `bundle.targets` por SO e (se houver) o code signing.
4. Configurar `tauri-action` para buildar a matriz, **assinar** e **publicar** no GitHub Releases
   com `latest.json`.
5. Publicar um release de **teste**; instalar num SO limpo; disparar um update `vN → vN+1` e
   confirmar que baixa, **verifica a assinatura** e aplica (RI-04).
6. Reportar artefatos, endpoints e como o usuário recebe o update.

## Few-shot (entra → sai)

**Entra:** app Tauri provado · alvos Windows+Linux · publicar no GitHub Releases · sem cert de code signing (só assinatura do updater).

**Sai** (entrega ao usuário final):
- Par de chaves do updater (`tauri signer generate`): **pública** no `tauri.conf.json`, **privada + senha** em secrets de CI.
- `bundle.targets`: Windows `nsis` + Linux `appimage`; cada artefato acompanha seu `.sig`.
- `tauri-action` na CI buildando a matriz, **assinando** e publicando release + `latest.json`.
- Aviso de "editor desconhecido" (SmartScreen) pela ausência de code signing de SO.
- Update de teste `vN → vN+1` num SO limpo: baixa, **verifica a assinatura** e aplica (RI-04).

## Guardrails

- **Nunca** commitar a chave privada do updater nem o certificado — só secrets de CI (RO-DT4).
- Nunca publicar update **não assinado** (RO-DT4 — porquê e mecânica do `.sig`: Convenções).
- **Nunca testar o fluxo de update contra usuários reais/produção** — usar repo/canal de teste
  primeiro.

## Saída esperada

- Instaladores por SO **assinados**; `tauri.conf.json` com updater (`pubkey` + `endpoints`); CI que
  publica release + `latest.json`; auto-update ponta a ponta verificado por assinatura. Update de
  teste `vN → vN+1` aplicado como evidência (RI-04).

## Verificação / Checklist final

O update é código que roda na máquina do usuário sem ele clicar em nada — a prova é a assinatura, não o build:

- **Chaves no lugar certo:** `.sig` por artefato; **pública** no config; **privada + senha** só em secret de CI (nada de chave no repo).
- **Release de teste** (repo/canal de teste, **nunca** produção) publicado com o `latest.json` assinado.
- **Update ponta a ponta:** instalar `vN` num SO limpo, publicar `vN+1` → o app baixa, **verifica a assinatura** e aplica (RI-04).
- **Versão:** artefato = semver do app; nenhum artefato renomeado à mão depois de assinado.
- **Code signing de SO:** presente, ou o aviso de "editor desconhecido" (SmartScreen/Gatekeeper) foi comunicado ao usuário.

## Sugestões de evolução (RO-07)

Fechar com 2–3 (ex.: canais stable/beta; rollback fixando versão; migração para **Velopack** se o
alvo virar .NET/Avalonia; delta updates).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `especialista-seguranca` (chaves, assinatura, notarização) · `auditor-responsabilidades` (gate de release) · `dev-senior` (CI) · `qa-usabilidade` (smoke do instalador em SO limpo).
- **Vem antes:** app provado (`testador-real` sem FAIL crítico) + `desktop-tauri-scaffold` (bloco updater já no config).
- **Vem depois:** `docs-projeto` (notas de versão/manual) · ciclo git completo (RO-13).
- **Não confundir com:** `java-package-desktop` (jpackage/.exe/.msi do track JavaFX) — aqui é Tauri v2, assinado e com auto-update.

### 📜 Histórico
- **2026-07-13 — Poda de duplicação P1 (auditoria de notas das 52 skills):** fonte única + referência com gloss (PADRAO §12.5); itens C6, C7, C8, C9, C10; −4 linhas.
- **2026-07-20 — Polimento de autoria:** `when_to_use` reforça a fronteira (packaging vs. scaffold vs. feature vs. jpackage); +checklist de Verificação consolidando o update de teste `vN→vN+1` assinado e a guarda das chaves. Convenções, few-shot e guardrails preservados.
