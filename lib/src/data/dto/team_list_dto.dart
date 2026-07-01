import 'package:takion/src/domain/entities/team_list.dart';

class TeamListDto {
  const TeamListDto({
    required this.id,
    required this.name,
    this.modified,
  });

  final int id;
  final String name;
  final String? modified;

  factory TeamListDto.fromJson(Map<String, dynamic> json) {
    return TeamListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Unknown Team',
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

  TeamList toEntity() {
    return TeamList(
      id: id,
      name: name,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
