enum PullListEntryStatus { upcoming, missing, owned, skipped }

enum PullListEntrySource { subscription, manual }

class PullListEntry {
  const PullListEntry({
    required this.id,
    required this.userId,
    required this.metronSeriesId,
    required this.metronIssueId,
    this.metronPullListId,
    this.syncStatus = "synced",
    this.releaseDate,
    required this.entryStatus,
    required this.source,
    required this.generatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int metronSeriesId;
  final int metronIssueId;
  final int? metronPullListId;
  final String syncStatus;
  final DateTime? releaseDate;
  final PullListEntryStatus entryStatus;
  final PullListEntrySource source;
  final DateTime generatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PullListEntry copyWith({
    String? id,
    String? userId,
    int? metronSeriesId,
    int? metronIssueId,
    int? metronPullListId,
    String? syncStatus,
    DateTime? releaseDate,
    PullListEntryStatus? entryStatus,
    PullListEntrySource? source,
    DateTime? generatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PullListEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      metronIssueId: metronIssueId ?? this.metronIssueId,
      metronPullListId: metronPullListId ?? this.metronPullListId,
      syncStatus: syncStatus ?? this.syncStatus,
      releaseDate: releaseDate ?? this.releaseDate,
      entryStatus: entryStatus ?? this.entryStatus,
      source: source ?? this.source,
      generatedAt: generatedAt ?? this.generatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
