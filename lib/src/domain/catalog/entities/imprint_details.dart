class ImprintNamedRef {
  const ImprintNamedRef({required this.id, required this.name});

  final int id;
  final String name;
}

class ImprintDetails {
  const ImprintDetails({
    required this.id,
    required this.name,
    this.publisher,
    this.founded,
    this.desc,
    this.image,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final ImprintNamedRef? publisher;
  final int? founded;
  final String? desc;
  final String? image;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
