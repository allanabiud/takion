class IssueCollectionStatus {
  const IssueCollectionStatus({
    required this.isCollected,
    required this.isWishlisted,
    required this.isRead,
    this.rating,
  });

  final bool isCollected;
  final bool isWishlisted;
  final bool isRead;
  final int? rating;
}
