import "package:takion/src/domain/entities.dart";

class SuperHeroSearchResponseDto {
  const SuperHeroSearchResponseDto({
    required this.response,
    this.resultsFor,
    this.results = const [],
  });

  final String response;
  final String? resultsFor;
  final List<SuperHeroCharacterDto> results;

  factory SuperHeroSearchResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json["results"];
    return SuperHeroSearchResponseDto(
      response: (json["response"] as String?) ?? "",
      resultsFor: json["results-for"] as String?,
      results: rawResults is List
          ? rawResults
                .whereType<Map<String, dynamic>>()
                .map(SuperHeroCharacterDto.fromJson)
                .toList()
          : const [],
    );
  }
}

class SuperHeroCharacterDto {
  const SuperHeroCharacterDto({
    required this.id,
    required this.name,
    this.fullName,
    this.aliases = const [],
    this.imageUrl,
    this.powerstats,
  });

  final int id;
  final String name;
  final String? fullName;
  final List<String> aliases;
  final String? imageUrl;
  final SuperHeroPowerStatsDto? powerstats;

  factory SuperHeroCharacterDto.fromJson(Map<String, dynamic> json) {
    final rawImage = json["image"];
    final imageUrl = rawImage is Map<String, dynamic>
        ? _parseNullableString(rawImage["url"])
        : null;

    final rawPowerstats = json["powerstats"];
    final powerstats = rawPowerstats is Map<String, dynamic>
        ? SuperHeroPowerStatsDto.fromJson(rawPowerstats)
        : null;

    final rawBio = json["biography"];
    String? fullName;
    List<String> aliases = const [];
    if (rawBio is Map<String, dynamic>) {
      fullName = _parseNullableString(rawBio["full-name"]);
      final rawAliases = rawBio["aliases"];
      if (rawAliases is List) {
        aliases = rawAliases
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e != "-")
            .toList();
      }
    }

    return SuperHeroCharacterDto(
      id: _parseId(json["id"]),
      name: (json["name"] as String?)?.trim().isNotEmpty == true
          ? (json["name"] as String)
          : "Unknown Character",
      fullName: fullName,
      aliases: aliases,
      imageUrl: imageUrl,
      powerstats: powerstats,
    );
  }

  static int _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static String? _parseNullableString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? formatImageUrl(int superheroId, String name, String? rawUrl) {
    if (superheroId <= 0) return rawUrl;
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), "-")
        .replaceAll(RegExp(r"^-+|-+$"), "");
    if (slug.isEmpty) return rawUrl;
    return "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/$superheroId-$slug.jpg";
  }

  SuperHeroCharacter toEntity() {
    final formattedUrl = formatImageUrl(id, name, imageUrl);
    return SuperHeroCharacter(
      id: id,
      name: name,
      imageUrl: formattedUrl,
      powerstats: powerstats?.toEntity(),
    );
  }
}

class SuperHeroPowerStatsDto {
  const SuperHeroPowerStatsDto({
    this.intelligence,
    this.strength,
    this.speed,
    this.durability,
    this.power,
    this.combat,
  });

  final int? intelligence;
  final int? strength;
  final int? speed;
  final int? durability;
  final int? power;
  final int? combat;

  bool get hasStats =>
      intelligence != null ||
      strength != null ||
      speed != null ||
      durability != null ||
      power != null ||
      combat != null;

  int get validStatsCount {
    var count = 0;
    if (intelligence != null) count++;
    if (strength != null) count++;
    if (speed != null) count++;
    if (durability != null) count++;
    if (power != null) count++;
    if (combat != null) count++;
    return count;
  }

  factory SuperHeroPowerStatsDto.fromJson(Map<String, dynamic> json) {
    int? parseStat(dynamic value) {
      if (value is int) return value;
      if (value is String && value.trim().isNotEmpty) {
        final lower = value.trim().toLowerCase();
        if (lower == "null") return null;
        return int.tryParse(lower);
      }
      return null;
    }

    return SuperHeroPowerStatsDto(
      intelligence: parseStat(json["intelligence"]),
      strength: parseStat(json["strength"]),
      speed: parseStat(json["speed"]),
      durability: parseStat(json["durability"]),
      power: parseStat(json["power"]),
      combat: parseStat(json["combat"]),
    );
  }

  SuperHeroPowerStats toEntity() {
    return SuperHeroPowerStats(
      intelligence: intelligence,
      strength: strength,
      speed: speed,
      durability: durability,
      power: power,
      combat: combat,
    );
  }
}
