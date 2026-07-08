---
name: mobile-flutter-firebase
description: Conecta um app Flutter ao Firebase e gera os repositórios de backend — flutterfire configure (firebase_options.dart determinístico), AuthRepository com o stream certo por caso (authStateChanges para login/logout, idTokenChanges para refresh de token/claims, userChanges para mudança de perfil), FirestoreRepository que desacopla o Firestore atrás da interface, StorageRepository, e o starter de security rules (Firestore + Storage) que nasce junto com o modelo de dados. Acione quando o usuário disser coisas como "conecta o Firebase no app", "adiciona login com Firebase Auth", "quero salvar no Firestore", "configura autenticação e banco na nuvem", "preciso das security rules do Firestore". NÃO acione para criar a feature/tela que consome o repositório (use mobile-flutter-feature) nem para iniciar o projeto (use mobile-flutter-scaffold).
---

# Flutter — Conector Firebase (Auth + Firestore + Storage + Security Rules)

Gerador do **track mobile (Flutter-first, proposta 2026-07-07)**. Pluga o Firebase de forma
determinística e entrega os **repositórios** que desacoplam o SDK do resto do app — e as
**security rules**, que são o backend/firewall real e **nascem junto com o modelo de dados**.

## Objetivo

Conectar o app ao Firebase e expor Auth, Firestore e Storage atrás de **interfaces de repositório**
(a UI e os notifiers nunca veem tipos do Firebase), com as security rules escritas junto ao modelo
— não depois. O Firestore não valida sozinho: as rules **são** a camada de autorização.

## Entradas obrigatórias

1. Projeto/console Firebase alvo (ou autorização para criar) e plataformas (Android/iOS/web).
2. Serviços a plugar: Auth (quais provedores?), Firestore, Storage — e o **modelo de dados**
   (coleções, documentos, dono de cada registro) que as rules vão proteger.
3. Regra de acesso por coleção (quem lê/escreve o quê) — insumo direto das rules.

## Entradas opcionais

- Custom claims/roles (então o stream é `idTokenChanges`), App Check, emulador para testes.

## Trava obrigatória

- Não gerar rules **sem o modelo de dados** definido — rules genéricas `allow read, write: if true`
  são proibidas (violação de segurança). Na dúvida sobre dono/escopo de uma coleção, **parar e
  perguntar** (`arquiteto-dados` + `especialista-seguranca`).
- Não escolher o stream de auth "no chute" — confirmar o caso de uso (ver tabela abaixo).
- **SUPOSIÇÃO a validar** no Claude Code: que o backend do projeto é Firebase (alternativa Supabase
  = track paralelo futuro). Confirmar com o Jeremias antes de plugar.

## Leituras obrigatórias (RO-01)

1. O `pubspec.yaml` e o `main.dart` do projeto (estrutura do scaffold, `ProviderScope`).
2. O modelo de dados/`freezed` das features que vão persistir (as rules protegem esses campos).
3. Se já existir um `AuthRepository`/`firestore.rules` no projeto, ler para **estender**, não
   duplicar. Nunca inventar caminho de coleção — ler o real.

## Convenções obrigatórias (Track Mobile Flutter)

- **`flutterfire configure` (determinístico, Pepita P-a):** rodar a FlutterFire CLI para gerar
  `firebase_options.dart` e registrar os apps por plataforma; `Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform)` no `main`. Não editar `firebase_options.dart` à mão.
  Pacotes: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
- **`AuthRepository` desacopla o SDK:** expõe um `Stream<AppUser?>` de domínio (mapeado de `User?`,
  sem vazar o tipo `User` do Firebase). **Escolher o stream certo:**

  | Stream | Dispara quando | Usar para |
  |---|---|---|
  | `authStateChanges()` | login / logout (+ estado inicial) | pergunta padrão "está logado?" (guarda de rota) |
  | `idTokenChanges()` | login / logout **+ refresh do token / mudança de custom claims** | quando lê roles/claims ou precisa do token fresco |
  | `userChanges()` | login / logout **+ mudança de perfil** (displayName, foto, e-mail, `reload`) | quando a UI reflete campos do perfil |

- **`FirestoreRepository` desacopla o Firestore:** tipar com `withConverter<T>` (fromFirestore /
  toFirestore) e retornar **modelos de domínio**; nenhum `DocumentSnapshot`/`Map` vaza além do
  repositório. Queries estruturadas (`where`/`orderBy`), nunca montando caminho por concatenação de
  entrada do usuário.
- **`StorageRepository`:** referências de upload/download tipadas; mídia pesada por Storage/CDN, não
  embutida no app.
- **Security rules starter (nascem com o modelo):** `firestore.rules` e `storage.rules` com
  **default deny**, exigindo `request.auth != null`, escopo por dono **separando o create do resto**:
  `allow read, update, delete: if resource.data.ownerId == request.auth.uid;` e
  `allow create: if request.resource.data.ownerId == request.auth.uid;` — no create o documento
  ainda não existe, então `resource.data` é null e o dono só chega em `request.resource.data` (o
  footgun clássico). Validação de tipos/campos obrigatórios sempre no `request.resource.data`, e sem
  confiar em nada do cliente. As rules são o **firewall** — auditadas pela lente
  `especialista-seguranca`. Deploy: `firebase deploy --only firestore:rules,storage`.
- **Segredos:** `firebase_options.dart` e as API keys do Firebase **não são segredo** (a proteção
  são as rules + App Check), mas `google-services.json`/`GoogleService-Info.plist` seguem a política
  do time; nada de credencial de service-account no app.
- Identificadores em inglês; UI em PT-BR; sem emoji em código (RO-05).

## Fluxo

1. Confirmar serviços, modelo de dados e regra de acesso por coleção (trava).
2. Ler pubspec, main e modelos das features (RO-01).
3. `flutterfire configure` + `firebase_core` no `main` (`ProviderScope` já vem do scaffold).
4. Escrever `AuthRepository` (stream escolhido por caso) + provider Riverpod; mapear `User?` →
   `AppUser?` de domínio.
5. Escrever `FirestoreRepository` com `withConverter` e `StorageRepository`; providers Riverpod.
6. Escrever `firestore.rules` + `storage.rules` **default-deny** junto ao modelo; deploy.
7. Provar: `flutter analyze` + testes dos repositórios (mock do SDK com `mocktail`) e, quando o
   tooling Node existir, **rules unit tests** no emulador (`firebase emulators:exec` +
   `@firebase/rules-unit-testing`) — senão **SKIP declarado com motivo** (RI-04), nunca "passou"
   fingido.
8. Reportar arquivos/rules criados, stream escolhido (e por quê), evidências e suposições.

## Guardrails

- Nunca `allow read, write: if true` nem rules "abertas para destravar agora".
- Nunca vazar tipo do Firebase (`User`, `DocumentSnapshot`) além do repositório.
- Nunca escolher o stream de auth sem casar com o caso de uso (claims ⇒ `idTokenChanges`; perfil ⇒
  `userChanges`; só login/logout ⇒ `authStateChanges`).
- Não confiar no cliente para autorização — a autorização vive nas rules, validada no servidor.
- Não editar `firebase_options.dart` à mão (regerar pela CLI).

## Saída esperada

- `firebase_options.dart` (gerado) · `AuthRepository` + provider · `FirestoreRepository`
  (`withConverter`) + provider · `StorageRepository` · `firestore.rules` + `storage.rules`
  default-deny.
- `flutter analyze` verde + testes dos repositórios; rules testadas no emulador **ou** SKIP
  declarado. Rules default-deny como evidência de segurança.

## Referências oficiais (RO-01)

- FlutterFire / `flutterfire configure`: https://firebase.google.com/docs/flutter/setup
- Streams de auth (authStateChanges/idTokenChanges/userChanges): https://firebase.google.com/docs/auth/flutter/start
- Arquitetura viva Flutter+Firebase+Riverpod (repos desacoplando o SDK): https://github.com/bizz84/starter_architecture_flutter_firebase

## 💡 Sugestões de evolução (RO-07)
Fechar com 2–3 sugestões (ex.: **Firebase App Check** antes de publicar; índices compostos do
Firestore para as queries mais comuns; rules unit tests no CI; migração de rules versionada junto ao
modelo).

## 🔗 Rede da skill
- **Lentes que ativam junto (RI-06):** `arquiteto-dados` (modelo do Firestore — coleções, dono, e as rules que o protegem, nascidas juntas) · `especialista-seguranca` (rules = firewall; App Check; anti-enumeração no Auth) · `dev-senior` (repositórios que não vazam o SDK).
- **Vem antes:** `mobile-flutter-scaffold` (projeto já com `ProviderScope`) · `arquiteto-dados` (modelo desenhado).
- **Vem depois:** `mobile-flutter-feature` (a impl do repositório abstrato da feature usa estes repositórios) · `testador-real` (bateria com emulador).
- **Não confundir com:** `springboot-repository-service` / `java-jdbc-dao` (persistência dos tracks Java) · `mobile-flutter-feature` (consome o repositório; não configura o backend).
