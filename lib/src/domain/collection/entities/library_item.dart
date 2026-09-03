enum LibraryOwnershipStatus { owned, notOwned, wishlist }

enum LibraryItemFormat { print, digital, both }

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.userId,
    required this.metronIssueId,
    required this.metronSeriesId,
    required this.ownershipStatus,
    required this.isRead,
    this.metronCollectionId,
    this.syncStatus = "synced",
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
  final int? metronCollectionId;
  final String syncStatus;
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

  LibraryItem copyWith({
    String? id,
    String? userId,
    int? metronIssueId,
    int? metronSeriesId,
    LibraryOwnershipStatus? ownershipStatus,
    bool? isRead,
    int? metronCollectionId,
    String? syncStatus,
    int? rating,
    DateTime? purchaseDate,
    double? pricePaid,
    int? quantityOwned,
    LibraryItemFormat? format,
    DateTime? firstReadAt,
    String? conditionGrade,
    DateTime? acquiredOn,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronIssueId: metronIssueId ?? this.metronIssueId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      isRead: isRead ?? this.isRead,
      metronCollectionId: metronCollectionId ?? this.metronCollectionId,
      syncStatus: syncStatus ?? this.syncStatus,
      rating: rating ?? this.rating,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaid: pricePaid ?? this.pricePaid,
      quantityOwned: quantityOwned ?? this.quantityOwned,
      format: format ?? this.format,
      firstReadAt: firstReadAt ?? this.firstReadAt,
      conditionGrade: conditionGrade ?? this.conditionGrade,
      acquiredOn: acquiredOn ?? this.acquiredOn,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
