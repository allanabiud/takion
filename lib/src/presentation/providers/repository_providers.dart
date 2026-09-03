import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/metron_metadata_cache.dart";
export "package:takion/src/core/cache/metron_metadata_cache.dart";
import "package:takion/src/core/cache/user_state_cache.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
export "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source_impl.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source.dart";
import "package:takion/src/data/collection/datasources/remote/metron_collection_remote_data_source_impl.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source.dart";
import "package:takion/src/data/pull_list/datasources/remote/metron_pull_list_remote_data_source_impl.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source.dart";
import "package:takion/src/data/wishlist/datasources/remote/metron_wishlist_remote_data_source_impl.dart";
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
import "package:takion/src/core/sync/offline_queue/offline_queue_processor.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/common/drift/daos/offline_queue_dao.dart";
import "package:takion/src/data/collection/repositories/metron_collection_repository_impl.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/core/sync/connectivity_monitor.dart";
import "package:takion/src/core/sync/metron_sync_manager.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/data/pull_list/repositories/metron_pull_list_repository_impl.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/repositories/local_wishlist_repository.dart";
import "package:takion/src/data/wishlist/repositories/metron_wishlist_repository_impl.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";
import "package:takion/src/domain/repositories.dart";

final userStateCacheProvider = Provider<UserStateCache>((ref) {
  return UserStateCache();
});

final offlineQueueDaoProvider = Provider<OfflineQueueDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.offlineQueueDao;
});

final offlineQueueProcessorProvider = Provider<OfflineQueueProcessor>((ref) {
  final dao = ref.watch(offlineQueueDaoProvider);
  final collectionRemote = ref.watch(metronCollectionRemoteDataSourceProvider);
  final pullListRemote = ref.watch(metronPullListRemoteDataSourceProvider);
  final wishlistRemote = ref.watch(metronWishlistRemoteDataSourceProvider);
  return OfflineQueueProcessor(
    dao: dao,
    collectionRemote: collectionRemote,
    pullListRemote: pullListRemote,
    wishlistRemote: wishlistRemote,
  );
});

final offlineWriteQueueProvider = Provider<OfflineWriteQueue>((ref) {
  final dao = ref.watch(offlineQueueDaoProvider);
  final processor = ref.watch(offlineQueueProcessorProvider);
  return OfflineWriteQueue(dao: dao, processor: processor);
});

final metronRemoteDataSourceProvider = Provider<MetronRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronRemoteDataSourceImpl(dio);
});

final metronCollectionRemoteDataSourceProvider =
    Provider<MetronCollectionRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronCollectionRemoteDataSourceImpl(dio);
});

final metronPullListRemoteDataSourceProvider =
    Provider<MetronPullListRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronPullListRemoteDataSourceImpl(dio);
});

final metronWishlistRemoteDataSourceProvider =
    Provider<MetronWishlistRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MetronWishlistRemoteDataSourceImpl(dio);
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

final metronCollectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final remote = ref.watch(metronCollectionRemoteDataSourceProvider);
  return MetronCollectionRepositoryImpl(remote);
});

final collectionSyncManagerProvider = Provider<CollectionSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronCollectionRepositoryProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return CollectionSyncManager(
    database: db,
    collectionRepository: repo,
    offlineWriteQueue: offlineQueue,
  );
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final cache = ref.watch(userStateCacheProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return LocalLibraryRepository(db, cache, offlineQueue: offlineQueue);
});

final metronPullListRepositoryProvider = Provider<MetronPullListRepository>((ref) {
  final remote = ref.watch(metronPullListRemoteDataSourceProvider);
  return MetronPullListRepositoryImpl(remote);
});

final pullListSyncManagerProvider = Provider<PullListSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronPullListRepositoryProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return PullListSyncManager(
    database: db,
    pullListRepository: repo,
    offlineWriteQueue: offlineQueue,
  );
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final cache = ref.watch(userStateCacheProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return LocalSubscriptionRepository(db, cache, offlineQueue: offlineQueue);
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

final metronWishlistRepositoryProvider =
    Provider<MetronWishlistRepository>((ref) {
  final remote = ref.watch(metronWishlistRemoteDataSourceProvider);
  return MetronWishlistRepositoryImpl(remoteDataSource: remote);
});

final wishlistSyncManagerProvider = Provider<WishlistSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronWishlistRepositoryProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return WishlistSyncManager(
    database: db,
    wishlistRepository: repo,
    offlineWriteQueue: offlineQueue,
  );
});

final localWishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  return LocalWishlistRepository(db, offlineQueue: offlineQueue);
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return ref.watch(localWishlistRepositoryProvider);
});

final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final metronSyncManagerProvider = Provider<MetronSyncManager>((ref) {
  final colSync = ref.watch(collectionSyncManagerProvider);
  final pullSync = ref.watch(pullListSyncManagerProvider);
  final wishSync = ref.watch(wishlistSyncManagerProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  final monitor = ref.watch(connectivityMonitorProvider);

  final manager = MetronSyncManager(
    collectionSyncManager: colSync,
    pullListSyncManager: pullSync,
    wishlistSyncManager: wishSync,
    offlineWriteQueue: offlineQueue,
    connectivityMonitor: monitor,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final metronSyncStateProvider = StreamProvider<MetronSyncState>((ref) {
  final manager = ref.watch(metronSyncManagerProvider);
  return manager.stateStream;
});


