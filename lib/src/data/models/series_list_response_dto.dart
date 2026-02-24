import 'package:takion/src/data/models/series_list_dto.dart';

class SeriesListResponseDto {
  const SeriesListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<SeriesListDto> results;

  factory SeriesListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(SeriesListDto.fromJson)
            .toList()
        : <SeriesListDto>[];

    return SeriesListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
