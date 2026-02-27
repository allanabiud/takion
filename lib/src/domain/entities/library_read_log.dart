class LibraryReadLog {
  const LibraryReadLog({
    required this.id,
    required this.userId,
    required this.collectionItemId,
    required this.readAt,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String collectionItemId;
  final DateTime readAt;
  final String? notes;
  final DateTime createdAt;
}
