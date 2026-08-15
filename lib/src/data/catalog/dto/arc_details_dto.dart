import "package:takion/src/domain/entities.dart";

class ArcDetailsDto {
  const ArcDetailsDto({
    required this.id,
    required this.name,
    this.desc,
    this.image,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? desc;
  final String? image;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;

  factory ArcDetailsDto.fromJson(Map<String, dynamic> json) {
    return ArcDetailsDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: (json["name"] as String?)?.trim().isNotEmpty == true
          ? (json["name"] as String)
          : "Unknown Arc",
      desc: json["desc"] as String?,
      image: json["image"] as String?,
      cvId: (json["cv_id"] as num?)?.toInt(),
      gcdId: (json["gcd_id"] as num?)?.toInt(),
      resourceUrl: json["resource_url"] as String?,
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "desc": desc,
    "image": image,
    "cv_id": cvId,
    "gcd_id": gcdId,
    "resource_url": resourceUrl,
    "modified": modified,
  };

  ArcDetails toEntity() {
    return ArcDetails(
      id: id,
      name: name,
      desc: desc,
      image: image,
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
