class SeriesList {
  const SeriesList({
    required this.id,
    required this.name,
    required this.yearBegan,
    required this.volume,
    this.issueCount,
    this.modified,
    this.seriesType,
  });

  final int id;
  final String name;
  final int? yearBegan;
  final int? volume;
  final int? issueCount;
  final DateTime? modified;
  final String? seriesType;
}
