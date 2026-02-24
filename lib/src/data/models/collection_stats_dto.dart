import 'package:takion/src/domain/entities/collection_stats.dart';

class CollectionStatsByFormatDto {
  const CollectionStatsByFormatDto({
    required this.bookFormat,
    required this.count,
  });

  final String bookFormat;
  final int count;

  factory CollectionStatsByFormatDto.fromJson(Map<String, dynamic> json) {
    return CollectionStatsByFormatDto(
      bookFormat: (json['book_format'] as String?) ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'book_format': bookFormat,
        'count': count,
      };

  CollectionStatsByFormat toEntity() {
    return CollectionStatsByFormat(bookFormat: bookFormat, count: count);
  }
}

class CollectionStatsDto {
  const CollectionStatsDto({
    required this.totalItems,
    required this.totalQuantity,
    required this.totalValue,
    required this.readCount,
    required this.unreadCount,
    this.byFormat = const [],
  });

  final int totalItems;
  final int totalQuantity;
  final String totalValue;
  final int readCount;
  final int unreadCount;
  final List<CollectionStatsByFormatDto> byFormat;

  factory CollectionStatsDto.fromJson(Map<String, dynamic> json) {
    final rawByFormat = json['by_format'];

    return CollectionStatsDto(
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalValue: (json['total_value'] as String?) ?? '',
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      byFormat: rawByFormat is List
          ? rawByFormat
              .whereType<Map<String, dynamic>>()
              .map(CollectionStatsByFormatDto.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_items': totalItems,
        'total_quantity': totalQuantity,
        'total_value': totalValue,
        'read_count': readCount,
        'unread_count': unreadCount,
        'by_format': byFormat.map((entry) => entry.toJson()).toList(),
      };

  CollectionStats toEntity() {
    return CollectionStats(
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      totalValue: totalValue,
      readCount: readCount,
      unreadCount: unreadCount,
      byFormat: byFormat.map((entry) => entry.toEntity()).toList(),
    );
  }
}
