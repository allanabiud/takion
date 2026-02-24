class SeriesList {
  const SeriesList({
    required this.id,
    required this.name,
    this.yearBegan,
    this.volume,
    this.issueCount,
    this.modified,
  });

  final int id;
  final String name;
  final int? yearBegan;
  final int? volume;
  final int? issueCount;
  final DateTime? modified;
}
