class MetronReadingListItem {
  const MetronReadingListItem({
    required this.id,
    required this.issueId,
    this.seriesId,
    this.seriesName,
    this.seriesVolume,
    this.yearBegan,
    this.issueNumber,
    this.coverDate,
    this.storeDate,
    required this.order,
    this.issueType,
  });

  final int id;
  final int issueId;
  final int? seriesId;
  final String? seriesName;
  final int? seriesVolume;
  final int? yearBegan;
  final String? issueNumber;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final int order;
  final String? issueType;
}
