class MetronReadingListDetail {
  const MetronReadingListDetail({
    required this.id,
    required this.name,
    this.slug,
    this.desc,
    this.image,
    this.listType,
    required this.isPrivate,
    this.attributionSource,
    this.attributionUrl,
    this.averageRating,
    required this.ratingCount,
    this.itemsUrl,
    this.resourceUrl,
    this.userId,
    this.username,
    this.modified,
  });

  final int id;
  final String name;
  final String? slug;
  final String? desc;
  final String? image;
  final String? listType;
  final bool isPrivate;
  final String? attributionSource;
  final String? attributionUrl;
  final double? averageRating;
  final int ratingCount;
  final String? itemsUrl;
  final String? resourceUrl;
  final int? userId;
  final String? username;
  final DateTime? modified;
}
