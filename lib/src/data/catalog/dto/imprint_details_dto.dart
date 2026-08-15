import "package:takion/src/domain/entities.dart";

String? _parseString(dynamic raw) {
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is List && raw.isNotEmpty) return raw.first.toString();
  return null;
}

class ImprintPublisherRefDto {
  const ImprintPublisherRefDto({required this.id, required this.name});

  final int id;
  final String name;

  factory ImprintPublisherRefDto.fromJson(Map<String, dynamic> json) {
    return ImprintPublisherRefDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: _parseString(json["name"]) ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  ImprintNamedRef toEntity() => ImprintNamedRef(id: id, name: name);
}

class ImprintDetailsDto {
  const ImprintDetailsDto({
    required this.id,
    required this.name,
    this.publisher,
    this.founded,
    this.desc,
    this.image,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final ImprintPublisherRefDto? publisher;
  final int? founded;
  final String? desc;
  final String? image;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory ImprintDetailsDto.fromJson(Map<String, dynamic> json) {
    return ImprintDetailsDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: _parseString(json["name"]) ?? "",
      publisher: json["publisher"] != null
          ? ImprintPublisherRefDto.fromJson(
              Map<String, dynamic>.from(json["publisher"]),
            )
          : null,
      founded: (json["founded"] as num?)?.toInt(),
      desc: _parseString(json["desc"]),
      image: _parseString(json["image"]),
      cvId: (json["cv_id"] as num?)?.toInt(),
      gcdId: (json["gcd_id"] as num?)?.toInt(),
      resourceUrl: _parseString(json["resource_url"]),
      modified: _parseString(json["modified"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "publisher": publisher?.toJson(),
    "founded": founded,
    "desc": desc,
    "image": image,
    "cv_id": cvId,
    "gcd_id": gcdId,
    "resource_url": resourceUrl,
    "modified": modified,
  };

  ImprintDetails toEntity() {
    return ImprintDetails(
      id: id,
      name: name,
      publisher: publisher?.toEntity(),
      founded: founded,
      desc: desc,
      image: image,
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
