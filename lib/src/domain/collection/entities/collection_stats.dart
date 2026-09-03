class CollectionStatsByFormat {
  const CollectionStatsByFormat({
    required this.bookFormat,
    required this.count,
  });

  final String bookFormat;
  final int count;
}

class CollectionStats {
  const CollectionStats({
    required this.totalItems,
    required this.totalQuantity,
    this.totalValue = "0.00",
    required this.readCount,
    required this.unreadCount,
    this.ratingCount = 0,
    this.averageRating,
    this.coverYearOldest,
    this.coverYearNewest,
    this.unratedCount = 0,
    this.wishlistCount = 0,
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
  final int unratedCount;
  final int wishlistCount;
  final List<CollectionStatsByFormat> byFormat;
}
