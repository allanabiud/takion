class SeriesSubscription {
  const SeriesSubscription({
    required this.id,
    required this.userId,
    required this.metronSeriesId,
    required this.isActive,
    required this.autoAddToPullList,
    required this.subscribedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int metronSeriesId;
  final bool isActive;
  final bool autoAddToPullList;
  final DateTime subscribedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
