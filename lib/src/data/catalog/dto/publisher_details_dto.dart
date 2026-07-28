import 'package:takion/src/domain/entities.dart';

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

class PublisherDetailsDto {
  const PublisherDetailsDto({
    required this.id,
    required this.name,
    this.founded,
    this.country,
    this.desc,
    this.image,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final int? founded;
  final String? country;
  final String? desc;
  final String? image;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory PublisherDetailsDto.fromJson(Map<String, dynamic> json) {
    return PublisherDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _parseString(json['name']) ?? '',
      founded: (json['founded'] as num?)?.toInt(),
      country: _parseString(json['country']),
      desc: _parseString(json['desc']),
      image: _parseString(json['image']),
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: _parseString(json['resource_url']),
      modified: _parseString(json['modified']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'founded': founded,
    'country': country,
    'desc': desc,
    'image': image,
    'cv_id': cvId,
    'gcd_id': gcdId,
    'resource_url': resourceUrl,
    'modified': modified,
  };

  PublisherDetails toEntity() {
    return PublisherDetails(
      id: id,
      name: name,
      founded: founded,
      country: country,
      desc: desc,
      image: image,
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
