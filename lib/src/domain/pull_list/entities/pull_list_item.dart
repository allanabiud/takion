class PullListSeriesItem {
  const PullListSeriesItem({
    required this.id,
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.publisherName,
    this.imageUrl,
    this.addedOn,
  });

  final int id;
  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final String? publisherName;
  final String? imageUrl;
  final DateTime? addedOn;
}

class PullListIssueItem {
  const PullListIssueItem({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
    this.price,
    this.modified,
  });

  final int id;
  final int issueId;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final String? imageUrl;
  final double? price;
  final DateTime? modified;
}
