import 'package:takion/src/domain/entities/metron_reading_list.dart';

class ReadingListDto {
  const ReadingListDto({
    required this.id,
    required this.name,
    this.slug,
    this.listType,
    this.isPrivate,
    this.attributionSource,
    this.averageRating,
    this.ratingCount,
    this.modified,
  });

  final int id;
  final String name;
  final String? slug;
  final String? listType;
  final bool? isPrivate;
  final String? attributionSource;
  final double? averageRating;
  final int? ratingCount;
  final String? modified;

  factory ReadingListDto.fromJson(Map<String, dynamic> json) {
    return ReadingListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Unknown List',
      slug: json['slug'] as String?,
      listType: json['list_type'] as String?,
      isPrivate: json['is_private'] as bool?,
      attributionSource: json['attribution_source'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'list_type': listType,
    'is_private': isPrivate,
    'attribution_source': attributionSource,
    'average_rating': averageRating,
    'rating_count': ratingCount,
    'modified': modified,
  };

  MetronReadingList toEntity() {
    return MetronReadingList(
      id: id,
      name: name,
      slug: slug,
      listType: listType,
      isPrivate: isPrivate ?? false,
      attributionSource: attributionSource,
      averageRating: averageRating,
      ratingCount: ratingCount ?? 0,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
