# Padrões universais de Flutter/Dart — extraídos de um projeto real (Encontre a Marta)

> Fonte: `Jogo-Simples-Celular (Encontre a Marta)/lib/domain/models/city.dart` + `data/cities_repository.dart` (lidos 2026-07-18, jogo Flutter em produção, offline-first). **Escopo (RI-04):** a Marta é um **jogo offline sem backend e SEM code-gen** (não usa `freezed` nem `riverpod_generator` — ver `pubspec.yaml`). Estes padrões são o gabarito **para projeto Flutter que optou por NÃO usar code-gen**. O default da skill (freezed + `@riverpod` + AsyncNotifier) **continua valendo para app-style com code-gen** — escolha declarada por projeto, não substituição cega.

## Quando usar este gabarito × o default da skill

- **Projeto SEM code-gen** (sem `freezed`/`build_runner`/`riverpod_generator` no pubspec) → modelo imutável À MÃO + providers Riverpod simples, como abaixo.
- **Projeto COM code-gen** (freezed/riverpod_generator já no pubspec) → mantém o default da skill (model freezed, `@riverpod`). Não misturar os dois estilos no mesmo projeto.
- Regra de decisão: olhe o `pubspec.yaml` real ANTES (RO-01) — ele diz qual estilo o projeto já adotou.

## Padrão 1 — Modelo imutável à mão (alternativa universal ao freezed)

Convenções reais: construtor `const` com named params `required`; campos `final` (nullable explícito com `?`); **doc comment por campo** explicando o negócio; `factory X.fromJson(Map)` + `toJson()` manuais; coleções embrulhadas em `List.unmodifiable`; `==`/`hashCode` **por identidade** (id), não campo a campo; `toString()` curto; getters de conveniência de domínio (ex.: `paisBrasil`).

```dart
/// Uma cidade do acervo. Modelo imutavel, espelha o schema de `cidades_seed.json`.
class City {
  /// Slug unico minusculo (ex.: "rio_de_janeiro"). Chave de identidade.
  final String id;
  final String city;
  final String continent;
  /// Subregiao opcional (ex.: "transcontinental").
  final String? region;
  final bool isCapital;
  /// 5 pistas ordenadas por [Clue.order] (1 vaga ... 5 obvia).
  final List<Clue> clues;

  const City({
    required this.id,
    required this.city,
    required this.continent,
    required this.isCapital,
    required this.clues,
    this.region,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    final clues = (json['clues'] as List<dynamic>)
        .map((e) => Clue.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return City(
      id: json['id'] as String,
      city: json['city'] as String,
      continent: json['continent'] as String,
      region: json['region'] as String?,
      isCapital: json['isCapital'] as bool,
      clues: List.unmodifiable(clues),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'continent': continent,
        if (region != null) 'region': region,
        'isCapital': isCapital,
        'clues': clues.map((c) => c.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) => other is City && other.id == id;
  @override
  int get hashCode => id.hashCode;
  @override
  String toString() => 'City($id)';
}
```

## Padrão 2 — Repositório testável + validação de invariantes (universal)

Convenções reais: construtor privado nomeado `X._(...)`; **`factory X.fromJson(String)` puro** (parseável sem depender do Flutter → testável em `dart test`) + **`static Future<X> carregarDoAsset()`** para o app real (esse sim usa `rootBundle`); exceção de domínio tipada (`RepositorioInvalidoException`) com mensagem clara; `_validar()` privado que checa invariantes explícitas e lança cedo; coleções finais em `List.unmodifiable`.

```dart
class CitiesRepository {
  static const String caminhoPadrao = 'assets/data/cidades.json';
  final List<City> cidades;
  CitiesRepository._({required this.cidades});

  /// Parseia e valida o conteudo bruto. Testavel: nao depende de Flutter.
  factory CitiesRepository.fromJson(String source) {
    final Map<String, dynamic> raiz;
    try {
      raiz = jsonDecode(source) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw RepositorioInvalidoException('JSON malformado: ${e.message}');
    }
    final cidades = (raiz['cities'] as List<dynamic>)
        .map((e) => City.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _validar(cidades);
    return CitiesRepository._(cidades: List.unmodifiable(cidades));
  }

  /// So no app real (depende de rootBundle).
  static Future<CitiesRepository> carregarDoAsset([String caminho = caminhoPadrao]) async {
    return CitiesRepository.fromJson(await rootBundle.loadString(caminho));
  }

  static void _validar(List<City> cidades) {
    if (cidades.isEmpty) throw const RepositorioInvalidoException('acervo vazio.');
    final ids = <String>{};
    for (final c in cidades) {
      if (!ids.add(c.id)) throw RepositorioInvalidoException('id duplicado: ${c.id}.');
    }
  }
}
```

**Por que o split `fromJson(String)` × `carregarDoAsset()` é ouro:** a lógica de parse/validação vira testável em `dart test` puro (sem harness de Flutter), e só a leitura do bundle fica presa ao framework. Padrão que transfere pra qualquer repositório Flutter que leia dado empacotado.

## O que NÃO transferir da Marta (limites do gabarito)

- **Sem Firebase / backend:** a Marta é offline-first (`shared_preferences` + JSON empacotado). Para app com backend, a skill `mobile-flutter-firebase` continua sendo a referência — a Marta não tem o que ensinar ali.
- **Sem AsyncNotifier/code-gen:** os providers da Marta são Riverpod simples. Se o projeto usa `@riverpod`, siga o default da skill.
- **Identificadores em PT-BR** (`cidadesPorTiers`, `porId`): padrão da casa do Jeremias; mesma pendência de governança da RO "código em inglês" já registrada para o SIGO.
