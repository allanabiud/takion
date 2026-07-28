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
    required this.totalValue,
    required this.readCount,
    required this.unreadCount,
    this.unratedCount = 0,
    this.wishlistCount = 0,
    this.byFormat = const [],
  });

  final int totalItems;
  final int totalQuantity;
  final String totalValue;
  final int readCount;
  final int unreadCount;
  final int unratedCount;
  final int wishlistCount;
  final List<CollectionStatsByFormat> byFormat;
}
