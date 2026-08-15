import "package:takion/src/domain/entities.dart";

class ImprintListDto {
  const ImprintListDto({required this.id, required this.name, this.modified});

  final int id;
  final String name;
  final String? modified;

  factory ImprintListDto.fromJson(Map<String, dynamic> json) {
    return ImprintListDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: json["name"] as String? ?? "",
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "modified": modified,
  };

  ImprintList toEntity() => ImprintList(
    id: id,
    name: name,
    modified: modified != null ? DateTime.tryParse(modified!) : null,
  );
}
