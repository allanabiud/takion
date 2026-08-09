import 'package:takion/src/data/catalog/dto/dto.dart';

class SeriesIssueListResponseDto {
  const SeriesIssueListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<IssueListDto> results;

  factory SeriesIssueListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
              .whereType<Map>()
              .map((e) => IssueListDto.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <IssueListDto>[];

    return SeriesIssueListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}
