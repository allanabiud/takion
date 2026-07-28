class CharacterList {
  const CharacterList({
    required this.id,
    required this.name,
    required this.slug,
    this.modified,
  });

  final int id;
  final String name;
  final String slug;
  final DateTime? modified;
}
