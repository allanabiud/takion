class IssueCollectionStatus {
  const IssueCollectionStatus({
    required this.isCollected,
    required this.isWishlisted,
    required this.isRead,
    this.rating,
    this.syncStatus = "synced",
  });

  final bool isCollected;
  final bool isWishlisted;
  final bool isRead;
  final int? rating;
  final String syncStatus;

  IssueCollectionStatus copyWith({
    bool? isCollected,
    bool? isWishlisted,
    bool? isRead,
    int? rating,
    String? syncStatus,
  }) {
    return IssueCollectionStatus(
      isCollected: isCollected ?? this.isCollected,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isRead: isRead ?? this.isRead,
      rating: rating ?? this.rating,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueCollectionStatus &&
          runtimeType == other.runtimeType &&
          isCollected == other.isCollected &&
          isWishlisted == other.isWishlisted &&
          isRead == other.isRead &&
          rating == other.rating &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode =>
      Object.hash(isCollected, isWishlisted, isRead, rating, syncStatus);
}
