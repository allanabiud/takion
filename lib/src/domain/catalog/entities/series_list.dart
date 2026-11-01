class SeriesList {
  const SeriesList({
    required this.id,
    required this.name,
    required this.yearBegan,
    required this.volume,
    this.yearEnd,
    this.issueCount,
    this.modified,
    this.seriesType,
    this.publisherName,
    this.cvId,
    this.gcdId,
  });

  final int id;
  final String name;
  final int? yearBegan;
  final int? yearEnd;
  final int? volume;
  final int? issueCount;
  final DateTime? modified;
  final String? seriesType;
  final String? publisherName;
  final int? cvId;
  final int? gcdId;
}
