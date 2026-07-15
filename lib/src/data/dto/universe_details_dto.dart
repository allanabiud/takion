import 'package:takion/src/domain/entities/entities.dart';

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

class UniversePublisherRefDto {
  const UniversePublisherRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory UniversePublisherRefDto.fromJson(Map<String, dynamic> json) {
    return UniversePublisherRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  UniverseNamedRef toEntity() => UniverseNamedRef(id: id, name: name);
}

class UniverseDetailsDto {
  const UniverseDetailsDto({
    required this.id,
    required this.name,
    this.publisher,
    this.designation,
    this.desc,
    this.gcdId,
    this.image,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final UniversePublisherRefDto? publisher;
  final String name;
  final String? designation;
  final String? desc;
  final int? gcdId;
  final String? image;
  final String? resourceUrl;
  final String? modified;

  factory UniverseDetailsDto.fromJson(Map<String, dynamic> json) {
    return UniverseDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      publisher: json['publisher'] != null
          ? UniversePublisherRefDto.fromJson(
              Map<String, dynamic>.from(json['publisher']),
            )
          : null,
      name: _parseString(json['name']) ?? '',
      designation: _parseString(json['designation']),
      desc: _parseString(json['desc']),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      image: _parseString(json['image']),
      resourceUrl: _parseString(json['resource_url']),
      modified: _parseString(json['modified']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'publisher': publisher?.toJson(),
    'name': name,
    'designation': designation,
    'desc': desc,
    'gcd_id': gcdId,
    'image': image,
    'resource_url': resourceUrl,
    'modified': modified,
  };

  UniverseDetails toEntity() {
    return UniverseDetails(
      id: id,
      publisher: publisher?.toEntity(),
      name: name,
      designation: designation,
      desc: desc,
      gcdId: gcdId,
      image: image,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
