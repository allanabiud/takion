import 'package:takion/src/domain/entities/entities.dart';

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

List<String> _parseStringList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
  }
  if (raw is String && raw.trim().isNotEmpty) return [raw.trim()];
  return [];
}

class CreatorDetailsDto {
  const CreatorDetailsDto({
    required this.id,
    required this.name,
    this.birth,
    this.death,
    this.desc,
    this.image,
    this.alias = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? birth;
  final String? death;
  final String? desc;
  final String? image;
  final List<String> alias;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory CreatorDetailsDto.fromJson(Map<String, dynamic> json) {
    return CreatorDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      birth: _parseString(json['birth']),
      death: _parseString(json['death']),
      desc: _parseString(json['desc']),
      image: _parseString(json['image']),
      alias: _parseStringList(json['alias']),
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: _parseString(json['resource_url']),
      modified: _parseString(json['modified']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birth': birth,
    'death': death,
    'desc': desc,
    'image': image,
    'alias': alias,
    'cv_id': cvId,
    'gcd_id': gcdId,
    'resource_url': resourceUrl,
    'modified': modified,
  };

  CreatorDetails toEntity() {
    return CreatorDetails(
      id: id,
      name: name,
      birth: birth != null ? DateTime.tryParse(birth!) : null,
      death: death != null ? DateTime.tryParse(death!) : null,
      desc: desc,
      image: image,
      alias: alias,
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
