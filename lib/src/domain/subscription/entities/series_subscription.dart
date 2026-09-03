class SeriesSubscription {
  const SeriesSubscription({
    required this.id,
    required this.userId,
    required this.metronSeriesId,
    this.metronPullListId,
    this.syncStatus = "synced",
    required this.isActive,
    required this.autoAddToPullList,
    required this.subscribedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int metronSeriesId;
  final int? metronPullListId;
  final String syncStatus;
  final bool isActive;
  final bool autoAddToPullList;
  final DateTime subscribedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SeriesSubscription copyWith({
    String? id,
    String? userId,
    int? metronSeriesId,
    int? metronPullListId,
    String? syncStatus,
    bool? isActive,
    bool? autoAddToPullList,
    DateTime? subscribedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeriesSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      metronPullListId: metronPullListId ?? this.metronPullListId,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
      autoAddToPullList: autoAddToPullList ?? this.autoAddToPullList,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
