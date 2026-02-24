class CollectionScrobbleIssueRef {
  const CollectionScrobbleIssueRef({
    required this.id,
    this.seriesName,
    this.number,
  });

  final int id;
  final String? seriesName;
  final String? number;
}

class CollectionScrobbleResult {
  const CollectionScrobbleResult({
    required this.id,
    required this.issue,
    required this.isRead,
    this.dateRead,
    this.readDates = const [],
    required this.readCount,
    this.rating,
    required this.created,
    this.modified,
  });

  final int id;
  final CollectionScrobbleIssueRef issue;
  final bool isRead;
  final DateTime? dateRead;
  final List<DateTime> readDates;
  final int readCount;
  final int? rating;
  final bool created;
  final DateTime? modified;
}
