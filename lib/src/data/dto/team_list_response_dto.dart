import 'package:takion/src/data/dto/dto.dart';

class TeamListResponseDto {
  const TeamListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<TeamListDto> results;

  factory TeamListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(TeamListDto.fromJson)
            .toList()
        : <TeamListDto>[];

    return TeamListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
