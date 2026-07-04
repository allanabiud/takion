class ArcList {
  const ArcList({
    required this.id,
    required this.name,
    this.modified,
  });

  final int id;
  final String name;
  final DateTime? modified;
}
