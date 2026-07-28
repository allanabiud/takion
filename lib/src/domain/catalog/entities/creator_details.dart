class CreatorDetails {
  const CreatorDetails({
    required this.id,
    required this.name,
    this.birth,
    this.death,
    this.desc,
    this.image,
    this.alias = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final DateTime? birth;
  final DateTime? death;
  final String? desc;
  final String? image;
  final List<String> alias;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
