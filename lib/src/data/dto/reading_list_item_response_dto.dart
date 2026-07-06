import 'package:takion/src/data/dto/reading_list_item_dto.dart';

class ReadingListItemResponseDto {
  const ReadingListItemResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<ReadingListItemDto> results;

  factory ReadingListItemResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(ReadingListItemDto.fromJson)
            .toList()
        : <ReadingListItemDto>[];

    return ReadingListItemResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}
