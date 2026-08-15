import "package:takion/src/domain/entities.dart";

class UniverseListDto {
  const UniverseListDto({required this.id, required this.name, this.modified});

  final int id;
  final String name;
  final String? modified;

  factory UniverseListDto.fromJson(Map<String, dynamic> json) {
    return UniverseListDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: (json["name"] as String?)?.trim().isNotEmpty == true
          ? (json["name"] as String)
          : "Unknown Universe",
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "modified": modified};
  }

  UniverseList toEntity() {
    return UniverseList(
      id: id,
      name: name,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
