import 'package:takion/src/domain/entities/entities.dart';

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

class TeamCreatorRefDto {
  const TeamCreatorRefDto({required this.id, required this.name, this.modified});

  final int id;
  final String name;
  final String? modified;

  factory TeamCreatorRefDto.fromJson(Map<String, dynamic> json) {
    return TeamCreatorRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'modified': modified};

  TeamCreatorRef toEntity() => TeamCreatorRef(
    id: id,
    name: name,
    modified: modified != null ? DateTime.tryParse(modified!) : null,
  );
}

class TeamUniverseRefDto {
  const TeamUniverseRefDto({required this.id, required this.name, this.modified});

  final int id;
  final String name;
  final String? modified;

  factory TeamUniverseRefDto.fromJson(Map<String, dynamic> json) {
    return TeamUniverseRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'modified': modified};

  UniverseNamedRef toEntity() => UniverseNamedRef(id: id, name: name);
}

class TeamDetailsDto {
  const TeamDetailsDto({
    required this.id,
    required this.name,
    this.desc,
    this.image,
    this.creators = const [],
    this.universes = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? desc;
  final String? image;
  final List<TeamCreatorRefDto> creators;
  final List<TeamUniverseRefDto> universes;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory TeamDetailsDto.fromJson(Map<String, dynamic> json) {
    return TeamDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      desc: _parseString(json['desc']),
      image: _parseString(json['image']),
      creators: _parseRefList(json['creators'], TeamCreatorRefDto.fromJson),
      universes: _parseRefList(json['universes'], TeamUniverseRefDto.fromJson),
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: _parseString(json['resource_url']),
      modified: _parseString(json['modified']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'desc': desc,
    'image': image,
    'creators': creators.map((e) => e.toJson()).toList(),
    'universes': universes.map((e) => e.toJson()).toList(),
    'cv_id': cvId,
    'gcd_id': gcdId,
    'resource_url': resourceUrl,
    'modified': modified,
  };

  TeamDetails toEntity() {
    return TeamDetails(
      id: id,
      name: name,
      desc: desc,
      image: image,
      creators: creators.map((e) => e.toEntity()).toList(),
      universes: universes.map((e) => e.toEntity()).toList(),
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

List<T> _parseRefList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
}
