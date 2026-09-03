class ScrobbleResult {
  const ScrobbleResult({
    required this.id,
    required this.isRead,
    this.dateRead,
    this.modified,
  });

  final int id;
  final bool isRead;
  final DateTime? dateRead;
  final DateTime? modified;
}
