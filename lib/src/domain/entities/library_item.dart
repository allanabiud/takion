enum LibraryOwnershipStatus {
  owned,
  wishlist,
  ordered,
  sold,
}

enum LibraryItemFormat {
  print,
  digital,
  both,
}

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.userId,
    required this.metronIssueId,
    required this.metronSeriesId,
    required this.ownershipStatus,
    required this.isRead,
    this.rating,
    this.purchaseDate,
    this.pricePaid,
    this.quantityOwned = 1,
    this.format = LibraryItemFormat.print,
    this.firstReadAt,
    this.conditionGrade,
    this.acquiredOn,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int metronIssueId;
  final int metronSeriesId;
  final LibraryOwnershipStatus ownershipStatus;
  final bool isRead;
  final int? rating;
  final DateTime? purchaseDate;
  final double? pricePaid;
  final int quantityOwned;
  final LibraryItemFormat format;
  final DateTime? firstReadAt;
  final String? conditionGrade;
  final DateTime? acquiredOn;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
