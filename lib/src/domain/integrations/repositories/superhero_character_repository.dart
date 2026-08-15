import "package:takion/src/domain/integrations/entities/entities.dart";

abstract interface class SuperHeroCharacterRepository {
  Future<SuperHeroCharacter?> getCharacter(
    int metronCharacterId,
    String metronName, {
    String? metronAlias,
    bool forceRefresh = false,
  });

  Future<bool> validateToken(String token);
}
