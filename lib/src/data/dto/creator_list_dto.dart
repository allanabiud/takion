import 'package:takion/src/domain/entities/creator_list.dart';

class CreatorListDto {
  const CreatorListDto({
    required this.id,
    required this.name,
    this.modified,
  });

  final int id;
  final String name;
  final String? modified;

  factory CreatorListDto.fromJson(Map<String, dynamic> json) {
    return CreatorListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Unknown Creator',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modified': modified,
    };
  }

  CreatorList toEntity() {
    return CreatorList(
      id: id,
      name: name,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
