import 'package:takion/src/domain/entities/character_details.dart';

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

class CharacterDetailsNamedRefDto {
  const CharacterDetailsNamedRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory CharacterDetailsNamedRefDto.fromJson(Map<String, dynamic> json) {
    return CharacterDetailsNamedRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  CharacterDetailsNamedRef toEntity() =>
      CharacterDetailsNamedRef(id: id, name: name);
}

class CharacterDetailsDto {
  const CharacterDetailsDto({
    required this.id,
    required this.name,
    required this.slug,
    this.alias,
    this.desc,
    this.image,
    this.creators = const [],
    this.teams = const [],
    this.universes = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String slug;
  final String? alias;
  final String? desc;
  final String? image;
  final List<CharacterDetailsNamedRefDto> creators;
  final List<CharacterDetailsNamedRefDto> teams;
  final List<CharacterDetailsNamedRefDto> universes;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory CharacterDetailsDto.fromJson(Map<String, dynamic> json) {
    return CharacterDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      slug: _parseString(json['slug']) ?? '',
      alias: _parseString(json['alias']),
      desc: _parseString(json['desc']),
      image: _parseString(json['image']),
      creators: _parseNamedRefList(json['creators']),
      teams: _parseNamedRefList(json['teams']),
      universes: _parseNamedRefList(json['universes']),
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: _parseString(json['resource_url']),
      modified: _parseString(json['modified']),
    );
  }

  static List<CharacterDetailsNamedRefDto> _parseNamedRefList(
    dynamic raw,
  ) {
    if (raw is! List) return const [];
    return raw
        .where((e) => e is Map)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(CharacterDetailsNamedRefDto.fromJson)
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'alias': alias,
    'desc': desc,
    'image': image,
    'creators': creators.map((e) => e.toJson()).toList(),
    'teams': teams.map((e) => e.toJson()).toList(),
    'universes': universes.map((e) => e.toJson()).toList(),
    'cv_id': cvId,
    'gcd_id': gcdId,
    'resource_url': resourceUrl,
    'modified': modified,
  };

  CharacterDetails toEntity() {
    return CharacterDetails(
      id: id,
      name: name,
      slug: slug,
      alias: alias,
      desc: desc,
      image: image,
      creators: creators.map((e) => e.toEntity()).toList(),
      teams: teams.map((e) => e.toEntity()).toList(),
      universes: universes.map((e) => e.toEntity()).toList(),
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
