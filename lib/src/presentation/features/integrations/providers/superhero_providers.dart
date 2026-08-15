import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/network/superhero_account_service.dart";
import "package:takion/src/core/network/superhero_dio_provider.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/integrations/superhero/superhero_character_repository_impl.dart";
import "package:takion/src/data/integrations/superhero/superhero_remote_data_source.dart";
import "package:takion/src/domain/integrations/entities/entities.dart";
import "package:takion/src/domain/integrations/repositories/repositories.dart";
import "package:takion/src/presentation/features/characters/providers/character_details_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";

final superheroEnabledProvider =
    AsyncNotifierProvider<SuperHeroEnabledNotifier, bool>(
      SuperHeroEnabledNotifier.new,
    );

class SuperHeroEnabledNotifier extends AsyncNotifier<bool> {
  static const _key = "superhero_integration_enabled";

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final row = await dao.getString(_key);
    if (row != null) {
      return row.toLowerCase() == "true";
    }
    final token = await dao.getString("superhero_api_token");
    return token != null && token.trim().isNotEmpty;
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final superheroUseImageProvider =
    AsyncNotifierProvider<SuperHeroUseImageNotifier, bool>(
      SuperHeroUseImageNotifier.new,
    );

class SuperHeroUseImageNotifier extends AsyncNotifier<bool> {
  static const _key = "superhero_use_image";

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return dao.getBool(_key, defaultValue: true);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final superheroUsePowerstatsProvider =
    AsyncNotifierProvider<SuperHeroUsePowerstatsNotifier, bool>(
      SuperHeroUsePowerstatsNotifier.new,
    );

class SuperHeroUsePowerstatsNotifier extends AsyncNotifier<bool> {
  static const _key = "superhero_use_powerstats";

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return dao.getBool(_key, defaultValue: true);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final superheroConnectionProvider = FutureProvider<SuperHeroConnectionStatus>(
  (ref) async {
    final service = ref.watch(superheroAccountServiceProvider);
    return service.validateStoredConnection();
  },
);

final superheroCharacterRepositoryProvider =
    Provider<SuperHeroCharacterRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final service = ref.watch(superheroAccountServiceProvider);
  return SuperHeroCharacterRepositoryImpl(
    remoteDataSource: SuperHeroRemoteDataSourceImpl(
      ref.watch(superheroDioProvider),
    ),
    cacheDao: db.superheroCharacterCacheDao,
    getToken: service.getStoredToken,
  );
});

final superheroCharacterProvider =
    FutureProvider.autoDispose.family<SuperHeroCharacter?, int>((ref, id) {
      final enabled = ref.watch(superheroEnabledProvider).value ?? false;
      final usePowerstats =
          ref.watch(superheroUsePowerstatsProvider).value ?? false;
      if (!enabled || !usePowerstats) return null;

      final details = ref.watch(characterDetailsProvider(id)).asData?.value;
      final name = details?.name;
      if (name == null || name.trim().isEmpty) return null;

      final repository = ref.watch(superheroCharacterRepositoryProvider);
      return repository.getCharacter(id, name, metronAlias: details?.alias);
    });
