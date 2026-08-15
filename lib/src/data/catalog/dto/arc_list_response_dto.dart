import "package:takion/src/data/catalog/dto/dto.dart";

class ArcListResponseDto {
  const ArcListResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ArcListDto> results;

  factory ArcListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json["results"];
    final results = rawResults is List
        ? rawResults
              .whereType<Map<String, dynamic>>()
              .map(ArcListDto.fromJson)
              .toList()
        : <ArcListDto>[];

    return ArcListResponseDto(
      count: (json["count"] as num?)?.toInt() ?? results.length,
      next: json["next"] as String?,
      previous: json["previous"] as String?,
      results: results,
    );
  }
}
