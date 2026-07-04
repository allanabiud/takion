import 'package:takion/src/domain/entities/arc_list.dart';

class ArcListDto {
  const ArcListDto({
    required this.id,
    required this.name,
    this.modified,
  });

  final int id;
  final String name;
  final String? modified;

  factory ArcListDto.fromJson(Map<String, dynamic> json) {
    return ArcListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Unknown Arc',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'modified': modified,
  };

  ArcList toEntity() {
    return ArcList(
      id: id,
      name: name,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
