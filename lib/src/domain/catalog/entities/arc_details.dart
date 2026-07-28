class ArcDetails {
  const ArcDetails({
    required this.id,
    required this.name,
    this.desc,
    this.image,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? desc;
  final String? image;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
