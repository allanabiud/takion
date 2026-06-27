class CharacterDetailsNamedRef {
  const CharacterDetailsNamedRef({required this.id, required this.name});

  final int id;
  final String name;
}

class CharacterDetails {
  const CharacterDetails({
    required this.id,
    required this.name,
    required this.slug,
    this.alias,
    this.desc,
    this.image,
    this.creators = const [],
    this.teams = const [],
    this.universes = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String slug;
  final String? alias;
  final String? desc;
  final String? image;
  final List<CharacterDetailsNamedRef> creators;
  final List<CharacterDetailsNamedRef> teams;
  final List<CharacterDetailsNamedRef> universes;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
