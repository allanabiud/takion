enum ActivityEventType {
  collected,
  uncollected,
  read,
  unread,
  wishlisted,
  unwishlisted,
  rated,
  subscribed,
  unsubscribed,
  favorited,
  unfavorited,
  pulled,
  unpulled,
}

class LibraryActivityEvent {
  const LibraryActivityEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.issueId,
    required this.seriesId,
    this.seriesName,
    this.issueNumber,
    this.imageUrl,
    required this.timestamp,
    this.metadata,
  });

  final String id;
  final String userId;
  final ActivityEventType type;
  final int issueId;
  final int seriesId;
  final String? seriesName;
  final String? issueNumber;
  final String? imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
}
