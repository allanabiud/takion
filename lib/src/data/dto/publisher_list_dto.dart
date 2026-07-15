import 'package:takion/src/domain/entities/entities.dart';

class PublisherListDto {
  const PublisherListDto({
    required this.id,
    required this.name,
    this.modified,
  });

  final int id;
  final String name;
  final String? modified;

  factory PublisherListDto.fromJson(Map<String, dynamic> json) {
    return PublisherListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'modified': modified,
  };

  PublisherList toEntity() => PublisherList(
        id: id,
        name: name,
        modified: modified != null ? DateTime.tryParse(modified!) : null,
      );
}
