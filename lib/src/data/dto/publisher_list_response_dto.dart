import 'package:takion/src/data/dto/dto.dart';

class PublisherListResponseDto {
  const PublisherListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<PublisherListDto> results;

  factory PublisherListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(PublisherListDto.fromJson)
            .toList()
        : <PublisherListDto>[];

    return PublisherListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
