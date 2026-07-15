import 'package:takion/src/data/dto/dto.dart';

class ImprintListResponseDto {
  const ImprintListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ImprintListDto> results;

  factory ImprintListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(ImprintListDto.fromJson)
            .toList()
        : <ImprintListDto>[];

    return ImprintListResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
