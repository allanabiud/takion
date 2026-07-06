class MetronReadingList {
  const MetronReadingList({
    required this.id,
    required this.name,
    this.slug,
    this.listType,
    required this.isPrivate,
    this.attributionSource,
    this.averageRating,
    required this.ratingCount,
    this.modified,
  });

  final int id;
  final String name;
  final String? slug;
  final String? listType;
  final bool isPrivate;
  final String? attributionSource;
  final double? averageRating;
  final int ratingCount;
  final DateTime? modified;
}
