import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/metron_metadata_cache.dart";
import "package:takion/src/core/cache/user_state_cache.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
export "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source_impl.dart";
import "package:takion/src/data/reading_list/repositories/local_reading_list_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/local/series_name_index.dart";
import "package:takion/src/data/common/drift/daos/junction_dao.dart";
import "package:takion/src/data/common/drift/daos/metron_entity_dao.dart";
import "package:takion/src/data/catalog/mappers/entity_mapper.dart";
import "package:takion/src/data/activity/repositories/local_activity_repository.dart";
import "package:takion/src/data/favorites/repositories/local_favorites_repository.dart";
import "package:takion/src/data/collection/repositories/local_library_repository.dart";
import "package:takion/src/data/pull_list/repositories/local_pull_list_repository.dart";
import "package:takion/src/data/subscription/repositories/local_subscription_repository.dart";
import "package:takion/src/data/catalog/repositories/metron_local_catalog_repository.dart";
import "package:takion/src/data/catalog/repositories/metron_repository_impl.dart";
import "package:takion/src/domain/repositories.dart";

final userStateCacheProvider = Provider<UserStateCache>((ref) {
  return UserStateCache();
});

final metronMetadataCacheProvider = Provider<MetronMetadataCache>((ref) {
  return MetronMetadataCache();
});

final metronRemoteDataSourceProvider = Provider<MetronRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronRemoteDataSourceImpl(dio);
});

final metronLocalDataSourceProvider = Provider<MetronLocalDataSource>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return MetronLocalDataSourceImpl(db);
});

final seriesNameIndexProvider = Provider<SeriesNameIndex>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return SeriesNameIndex(db);
});

final metronEntityDaoProvider = Provider<MetronEntityDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return MetronEntityDao(db);
});

final junctionDaoProvider = Provider<JunctionDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return JunctionDao(db);
});

final entityMapperProvider = Provider<EntityMapper>((ref) {
  final entityDao = ref.watch(metronEntityDaoProvider);
  final junctionDao = ref.watch(junctionDaoProvider);
  return EntityMapper(entityDao, junctionDao);
});

final localCatalogRepositoryProvider = Provider<LocalCatalogRepository>((ref) {
  final entityDao = ref.watch(metronEntityDaoProvider);
  final mapper = ref.watch(entityMapperProvider);
  return MetronLocalCatalogRepository(entityDao, mapper);
});

final metronRepositoryProvider = Provider<CatalogRepository>((ref) {
  final remoteDataSource = ref.watch(metronRemoteDataSourceProvider);
  final localDataSource = ref.watch(metronLocalDataSourceProvider);
  final entityDao = ref.watch(metronEntityDaoProvider);
  final junctionDao = ref.watch(junctionDaoProvider);
  final seriesNameIndex = ref.watch(seriesNameIndexProvider);
  final metadataCache = ref.watch(metronMetadataCacheProvider);

  unawaited(metadataCache.hydrateFromDatabase(entityDao));

  return MetronRepositoryImpl(
    remoteDataSource,
    localDataSource,
    entityDao,
    junctionDao,
    seriesNameIndex,
    metadataCache: metadataCache,
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return ref.watch(metronRepositoryProvider);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final cache = ref.watch(userStateCacheProvider);
  return LocalLibraryRepository(db, cache);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final cache = ref.watch(userStateCacheProvider);
  return LocalSubscriptionRepository(db, cache);
});

final pullListRepositoryProvider = Provider<PullListRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final cache = ref.watch(userStateCacheProvider);
  return LocalPullListRepository(db, cache);
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return LocalFavoritesRepository(db);
});

final localReadingListRepositoryProvider = Provider<LocalReadingListRepository>(
  (ref) {
    return ref.watch(localReadingListLocalDataSourceProvider);
  },
);

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return LocalActivityRepository(db);
});
