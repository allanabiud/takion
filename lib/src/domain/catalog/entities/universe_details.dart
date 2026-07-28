class UniverseNamedRef {
  const UniverseNamedRef({required this.id, required this.name});

  final int id;
  final String name;
}

class UniverseDetails {
  const UniverseDetails({
    required this.id,
    required this.name,
    this.publisher,
    this.designation,
    this.desc,
    this.gcdId,
    this.image,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final UniverseNamedRef? publisher;
  final String name;
  final String? designation;
  final String? desc;
  final int? gcdId;
  final String? image;
  final String? resourceUrl;
  final DateTime? modified;
}
