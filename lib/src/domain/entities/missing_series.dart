class MissingSeriesNamedRef {
  const MissingSeriesNamedRef({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class MissingSeries {
  const MissingSeries({
    required this.id,
    required this.name,
    this.sortName,
    this.yearBegan,
    this.yearEnd,
    this.publisher,
    this.seriesType,
    required this.totalIssues,
    required this.ownedIssues,
    required this.missingCount,
    required this.completionPercentage,
  });

  final int id;
  final String name;
  final String? sortName;
  final int? yearBegan;
  final int? yearEnd;
  final MissingSeriesNamedRef? publisher;
  final MissingSeriesNamedRef? seriesType;
  final int totalIssues;
  final int ownedIssues;
  final int missingCount;
  final int completionPercentage;
}
