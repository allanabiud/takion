import 'package:takion/src/data/catalog/dto/dto.dart';

class UniverseListResponseDto {
  const UniverseListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<UniverseListDto> results;

  factory UniverseListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
              .whereType<Map<String, dynamic>>()
              .map(UniverseListDto.fromJson)
              .toList()
        : <UniverseListDto>[];

    return UniverseListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
