enum PullListEntryStatus {
  upcoming,
  missing,
  owned,
  skipped,
}

enum PullListEntrySource {
  subscription,
  manual,
}

class PullListEntry {
  const PullListEntry({
    required this.id,
    required this.userId,
    required this.metronSeriesId,
    required this.metronIssueId,
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
  final DateTime? releaseDate;
  final PullListEntryStatus entryStatus;
  final PullListEntrySource source;
  final DateTime generatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
