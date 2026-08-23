class LocalIssue {
  const LocalIssue({
    required this.id,
    this.seriesId,
    required this.number,
    this.imageUrl,
    this.coverDate,
    this.storeDate,
    this.modified,
    this.price,
    this.isFullyHydrated = false,
  });

  final int id;
  final int? seriesId;
  final String number;
  final String? imageUrl;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final DateTime? modified;
  final String? price;
  final bool isFullyHydrated;
}
