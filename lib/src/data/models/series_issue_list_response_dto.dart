import 'package:takion/src/data/models/issue_list_dto.dart';

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
            .whereType<Map<String, dynamic>>()
            .map(IssueListDto.fromJson)
            .toList()
        : <IssueListDto>[];

    return SeriesIssueListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
