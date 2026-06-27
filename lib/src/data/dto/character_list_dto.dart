import 'package:takion/src/domain/entities/character_list.dart';

class CharacterListDto {
  const CharacterListDto({
    required this.id,
    required this.name,
    required this.slug,
    this.modified,
  });

  final int id;
  final String name;
  final String slug;
  final String? modified;

  factory CharacterListDto.fromJson(Map<String, dynamic> json) {
    return CharacterListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Unknown Character',
      slug: (json['slug'] as String?) ?? '',
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'modified': modified,
    };
  }

  CharacterList toEntity() {
    return CharacterList(
      id: id,
      name: name,
      slug: slug,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
