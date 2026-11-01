import "package:takion/src/domain/collection/entities/collection_stats.dart";

class CollectionStatsByFormatDto {
  const CollectionStatsByFormatDto({
    required this.bookFormat,
    required this.count,
  });

  final String bookFormat;
  final int count;

  factory CollectionStatsByFormatDto.fromJson(Map<String, dynamic> json) {
    return CollectionStatsByFormatDto(
      bookFormat: json["book_format"] as String? ?? "PRINT",
      count: (json["count"] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"book_format": bookFormat, "count": count};

  CollectionStatsByFormat toEntity() {
    return CollectionStatsByFormat(bookFormat: bookFormat, count: count);
  }
}

class CollectionStatsDto {
  const CollectionStatsDto({
    required this.totalItems,
    required this.totalQuantity,
    this.totalValue = "0.00",
    required this.readCount,
    required this.unreadCount,
    this.ratingCount = 0,
    this.averageRating,
    this.coverYearOldest,
    this.coverYearNewest,
    this.byFormat = const [],
  });

  final int totalItems;
  final int totalQuantity;
  final String totalValue;
  final int readCount;
  final int unreadCount;
  final int ratingCount;
  final double? averageRating;
  final int? coverYearOldest;
  final int? coverYearNewest;
  final List<CollectionStatsByFormatDto> byFormat;

  factory CollectionStatsDto.fromJson(Map<String, dynamic> json) {
    final rawVal = json["total_value"];
    String totalValStr = "0.00";
    if (rawVal is num) {
      totalValStr = rawVal.toStringAsFixed(2);
    } else if (rawVal is String) {
      totalValStr = rawVal;
    }

    final byFormatJson = json["by_format"] as List<dynamic>? ?? [];
    final byFormat = byFormatJson
        .whereType<Map<String, dynamic>>()
        .map(CollectionStatsByFormatDto.fromJson)
        .toList();

    return CollectionStatsDto(
      totalItems: (json["total_items"] as num?)?.toInt() ?? 0,
      totalQuantity: (json["total_quantity"] as num?)?.toInt() ?? 0,
      totalValue: totalValStr,
      readCount: (json["read_count"] as num?)?.toInt() ?? 0,
      unreadCount: (json["unread_count"] as num?)?.toInt() ?? 0,
      ratingCount: (json["rating_count"] as num?)?.toInt() ?? 0,
      averageRating: (json["average_rating"] as num?)?.toDouble(),
      coverYearOldest: (json["cover_year_oldest"] as num?)?.toInt(),
      coverYearNewest: (json["cover_year_newest"] as num?)?.toInt(),
      byFormat: byFormat,
    );
  }

  Map<String, dynamic> toJson() => {
    "total_items": totalItems,
    "total_quantity": totalQuantity,
    "total_value": totalValue,
    "read_count": readCount,
    "unread_count": unreadCount,
    "rating_count": ratingCount,
    if (averageRating != null) "average_rating": averageRating,
    if (coverYearOldest != null) "cover_year_oldest": coverYearOldest,
    if (coverYearNewest != null) "cover_year_newest": coverYearNewest,
    "by_format": byFormat.map((e) => e.toJson()).toList(),
  };

  CollectionStats toEntity() {
    return CollectionStats(
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      totalValue: totalValue,
      readCount: readCount,
      unreadCount: unreadCount,
      ratingCount: ratingCount,
      averageRating: averageRating,
      coverYearOldest: coverYearOldest,
      coverYearNewest: coverYearNewest,
      byFormat: byFormat.map((e) => e.toEntity()).toList(),
    );
  }
}
