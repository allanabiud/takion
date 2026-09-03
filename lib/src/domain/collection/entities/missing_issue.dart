class MissingIssue {
  const MissingIssue({
    required this.id,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
  });

  final int id;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final String? imageUrl;
}

class MissingSeries {
  const MissingSeries({
    required this.id,
    required this.name,
    this.volume,
    this.yearBegan,
    this.totalIssues,
    this.missingCount,
    this.imageUrl,
  });

  final int id;
  final String name;
  final int? volume;
  final int? yearBegan;
  final int? totalIssues;
  final int? missingCount;
  final String? imageUrl;
}
