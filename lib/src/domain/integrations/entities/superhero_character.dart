class SuperHeroPowerStats {
  const SuperHeroPowerStats({
    this.intelligence,
    this.strength,
    this.speed,
    this.durability,
    this.power,
    this.combat,
  });

  final int? intelligence;
  final int? strength;
  final int? speed;
  final int? durability;
  final int? power;
  final int? combat;

  bool get hasStats =>
      intelligence != null ||
      strength != null ||
      speed != null ||
      durability != null ||
      power != null ||
      combat != null;

  int get validStatsCount {
    var count = 0;
    if (intelligence != null) count++;
    if (strength != null) count++;
    if (speed != null) count++;
    if (durability != null) count++;
    if (power != null) count++;
    if (combat != null) count++;
    return count;
  }
}

class SuperHeroCharacter {
  const SuperHeroCharacter({
    required this.id,
    required this.name,
    this.imageUrl,
    this.powerstats,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final SuperHeroPowerStats? powerstats;
}
