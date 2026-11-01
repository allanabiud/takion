import "dart:math";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
export "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/catalog/datasources/local/metron_local_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source.dart";
import "package:takion/src/data/catalog/datasources/remote/metron_remote_data_source_impl.dart";
import "package:takion/src/data/collection/analytics/collection_analytics_engine.dart";
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
import "package:takion/src/core/commands/command_services.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/core/migration/collection_migrator.dart";
import "package:takion/src/core/migration/migration_manager.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/core/migration/pull_list_migrator.dart";
import "package:takion/src/core/migration/wishlist_migrator.dart";
import "package:takion/src/core/sync/adapters/adapters.dart";
import "package:takion/src/core/sync/connectivity_monitor.dart";
import "package:takion/src/core/sync/metron_sync_manager.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/core/sync/outbox/outbox_executor.dart";
import "package:takion/src/core/sync/outbox/outbox_projection_applier.dart";
import "package:takion/src/core/sync/outbox/outbox_remote_dispatcher.dart";
import "package:takion/src/core/sync/sync_engine.dart";
import "package:takion/src/core/cache/cache_pinning_service.dart";
import "package:takion/src/data/common/drift/daos/sync_conflict_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_cursor_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_job_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_lease_dao.dart";
import "package:takion/src/data/pull_list/repositories/metron_pull_list_repository_impl.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/repositories/local_wishlist_repository.dart";
import "package:takion/src/data/wishlist/repositories/metron_wishlist_repository_impl.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";
import "package:takion/src/domain/repositories.dart";

final offlineQueueDaoProvider = Provider<OfflineQueueDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.offlineQueueDao;
});

final offlineQueueProcessorProvider = Provider<OfflineQueueProcessor>((ref) {
  final dao = ref.watch(offlineQueueDaoProvider);
  final db = ref.watch(driftDatabaseProvider);
  final collectionRemote = ref.watch(metronCollectionRemoteDataSourceProvider);
  final pullListRemote = ref.watch(metronPullListRemoteDataSourceProvider);
  final wishlistRemote = ref.watch(metronWishlistRemoteDataSourceProvider);
  final interceptor = ref.watch(rateLimitInterceptorProvider);
  return OfflineQueueProcessor(
    dao: dao,
    database: db,
    collectionRemote: collectionRemote,
    pullListRemote: pullListRemote,
    wishlistRemote: wishlistRemote,
    rateLimitDelay: () =>
        rateLimitDelayFromBurstLimit(interceptor.state.burstLimit),
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

  return MetronRepositoryImpl(
    remoteDataSource,
    localDataSource,
    entityDao,
    junctionDao,
    seriesNameIndex,
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return ref.watch(metronRepositoryProvider);
});

final metronCollectionRepositoryProvider = Provider<CollectionRepository>((
  ref,
) {
  final remote = ref.watch(metronCollectionRemoteDataSourceProvider);
  return MetronCollectionRepositoryImpl(remote);
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return ref.watch(metronCollectionRepositoryProvider);
});

final collectionSyncManagerProvider = Provider<CollectionSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronCollectionRepositoryProvider);
  return CollectionSyncManager(database: db, collectionRepository: repo);
});

final collectionAnalyticsEngineProvider = Provider<CollectionAnalyticsEngine>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return CollectionAnalyticsEngine(db);
});

final outboxDaoProvider = Provider<OutboxDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.outboxDao;
});

final collectionCommandServiceProvider = Provider<CollectionCommandService>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return CollectionCommandService(db);
});

final pullListCommandServiceProvider = Provider<PullListCommandService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return PullListCommandService(db);
});

final wishlistCommandServiceProvider = Provider<WishlistCommandService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return WishlistCommandService(db);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  final commandService = ref.watch(collectionCommandServiceProvider);
  return LocalLibraryRepository(
    db,
    offlineQueue: offlineQueue,
    commandService: commandService,
  );
});

final metronPullListRepositoryProvider = Provider<MetronPullListRepository>((
  ref,
) {
  final remote = ref.watch(metronPullListRemoteDataSourceProvider);
  return MetronPullListRepositoryImpl(remote);
});

final pullListSyncManagerProvider = Provider<PullListSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronPullListRepositoryProvider);
  return PullListSyncManager(database: db, pullListRepository: repo);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  final commandService = ref.watch(pullListCommandServiceProvider);
  return LocalSubscriptionRepository(
    db,
    offlineQueue: offlineQueue,
    commandService: commandService,
  );
});

final pullListRepositoryProvider = Provider<PullListRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return LocalPullListRepository(db);
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

final metronWishlistRepositoryProvider = Provider<MetronWishlistRepository>((
  ref,
) {
  final remote = ref.watch(metronWishlistRemoteDataSourceProvider);
  return MetronWishlistRepositoryImpl(remoteDataSource: remote);
});

final wishlistSyncManagerProvider = Provider<WishlistSyncManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final repo = ref.watch(metronWishlistRepositoryProvider);
  return WishlistSyncManager(database: db, wishlistRepository: repo);
});

final localWishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);
  final commandService = ref.watch(wishlistCommandServiceProvider);
  return LocalWishlistRepository(
    db,
    offlineQueue: offlineQueue,
    commandService: commandService,
  );
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return ref.watch(localWishlistRepositoryProvider);
});

final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  final syncEngine = ref.watch(syncEngineProvider);
  final random = Random();

  monitor.startMonitoring(
    onReconnected: () {
      final jitterSeconds = 1 + random.nextInt(4);
      syncEngine.scheduleSync(
        debounce: Duration(seconds: jitterSeconds),
        reason: "reconnect",
      );
    },
  );

  ref.onDispose(monitor.dispose);
  return monitor;
});

final syncLeaseDaoProvider = Provider<SyncLeaseDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.syncLeaseDao;
});

final syncJobDaoProvider = Provider<SyncJobDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.syncJobDao;
});

final syncCursorDaoProvider = Provider<SyncCursorDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.syncCursorDao;
});

final syncConflictDaoProvider = Provider<SyncConflictDao>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.syncConflictDao;
});

final outboxRemoteDispatcherProvider = Provider<OutboxRemoteDispatcher>((ref) {
  return OutboxRemoteDispatcher(
    collectionRemote: ref.watch(metronCollectionRemoteDataSourceProvider),
    pullListRemote: ref.watch(metronPullListRemoteDataSourceProvider),
    wishlistRemote: ref.watch(metronWishlistRemoteDataSourceProvider),
  );
});

final outboxProjectionApplierProvider = Provider<OutboxProjectionApplier>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return OutboxProjectionApplier(db);
});

final outboxExecutorProvider = Provider<OutboxExecutor>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return OutboxExecutor(
    db: db,
    outboxDao: ref.watch(outboxDaoProvider),
    dispatcher: ref.watch(outboxRemoteDispatcherProvider),
    projectionApplier: ref.watch(outboxProjectionApplierProvider),
    conflictDao: ref.watch(syncConflictDaoProvider),
  );
});

final collectionDeltaAdapterProvider = Provider<CollectionDeltaAdapter>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return CollectionDeltaAdapter(
    db: db,
    remoteDataSource: ref.watch(metronCollectionRemoteDataSourceProvider),
    libraryItemDao: db.libraryItemDao,
    cursorDao: ref.watch(syncCursorDaoProvider),
  );
});

final pullSeriesSnapshotAdapterProvider = Provider<PullSeriesSnapshotAdapter>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return PullSeriesSnapshotAdapter(
    db: db,
    remoteDataSource: ref.watch(metronPullListRemoteDataSourceProvider),
    subscriptionDao: db.subscriptionDao,
    cursorDao: ref.watch(syncCursorDaoProvider),
  );
});

final wishlistSnapshotAdapterProvider = Provider<WishlistSnapshotAdapter>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return WishlistSnapshotAdapter(
    db: db,
    remoteDataSource: ref.watch(metronWishlistRemoteDataSourceProvider),
    wishlistDao: db.wishlistDao,
    cursorDao: ref.watch(syncCursorDaoProvider),
  );
});

final pullIssuesWindowAdapterProvider = Provider<PullIssuesWindowAdapter>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return PullIssuesWindowAdapter(
    db: db,
    remoteDataSource: ref.watch(metronPullListRemoteDataSourceProvider),
    pullListDao: db.pullListDao,
    cursorDao: ref.watch(syncCursorDaoProvider),
  );
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    leaseDao: ref.watch(syncLeaseDaoProvider),
    jobDao: ref.watch(syncJobDaoProvider),
    outboxDao: ref.watch(outboxDaoProvider),
    outboxExecutor: ref.watch(outboxExecutorProvider),
    adapters: [
      ref.watch(collectionDeltaAdapterProvider),
      ref.watch(pullSeriesSnapshotAdapterProvider),
      ref.watch(wishlistSnapshotAdapterProvider),
      ref.watch(pullIssuesWindowAdapterProvider),
    ],
    scheduler: ref.watch(rateLimitInterceptorProvider).scheduler,
    runnerId: "foreground-isolate",
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final metronSyncManagerProvider = Provider<MetronSyncManager>((ref) {
  final syncEngine = ref.watch(syncEngineProvider);
  final colSync = ref.watch(collectionSyncManagerProvider);
  final pullSync = ref.watch(pullListSyncManagerProvider);
  final wishSync = ref.watch(wishlistSyncManagerProvider);
  final migrationManager = ref.watch(migrationManagerProvider);
  final offlineQueue = ref.watch(offlineWriteQueueProvider);

  final manager = MetronSyncManager(
    syncEngine: syncEngine,
    collectionSyncManager: colSync,
    pullListSyncManager: pullSync,
    wishlistSyncManager: wishSync,
    migrationManager: migrationManager,
    offlineWriteQueue: offlineQueue,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final metronSyncStateProvider = StreamProvider<MetronSyncState>((ref) {
  final manager = ref.watch(metronSyncManagerProvider);
  return manager.stateStream;
});

final collectionMigratorProvider = Provider<CollectionMigrator>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final remote = ref.watch(metronCollectionRemoteDataSourceProvider);
  final interceptor = ref.watch(rateLimitInterceptorProvider);
  return CollectionMigrator(
    database: db,
    remoteDataSource: remote,
    rateLimitDelay: () =>
        rateLimitDelayFromBurstLimit(interceptor.state.burstLimit),
  );
});

final pullListMigratorProvider = Provider<PullListMigrator>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final remote = ref.watch(metronPullListRemoteDataSourceProvider);
  final interceptor = ref.watch(rateLimitInterceptorProvider);
  return PullListMigrator(
    database: db,
    remoteDataSource: remote,
    rateLimitDelay: () =>
        rateLimitDelayFromBurstLimit(interceptor.state.burstLimit),
  );
});

final wishlistMigratorProvider = Provider<WishlistMigrator>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final remote = ref.watch(metronWishlistRemoteDataSourceProvider);
  final interceptor = ref.watch(rateLimitInterceptorProvider);
  return WishlistMigrator(
    database: db,
    remoteDataSource: remote,
    rateLimitDelay: () =>
        rateLimitDelayFromBurstLimit(interceptor.state.burstLimit),
  );
});

final migrationManagerProvider = Provider<MigrationManager>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final colMigrator = ref.watch(collectionMigratorProvider);
  final pullMigrator = ref.watch(pullListMigratorProvider);
  final wishMigrator = ref.watch(wishlistMigratorProvider);

  final manager = MigrationManager(
    database: db,
    collectionMigrator: colMigrator,
    pullListMigrator: pullMigrator,
    wishlistMigrator: wishMigrator,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final migrationProgressProvider = StreamProvider<MigrationProgress>((ref) {
  final manager = ref.watch(migrationManagerProvider);
  return manager.progressStream;
});

final migrationNeededProvider = FutureProvider<bool>((ref) async {
  final manager = ref.watch(migrationManagerProvider);
  return manager.isMigrationNeeded();
});

final pendingOfflineWritesCountProvider = StreamProvider<int>((ref) {
  final queue = ref.watch(offlineWriteQueueProvider);
  return queue.watchPendingCount();
});

final failedOfflineWritesCountProvider = StreamProvider<int>((ref) {
  final queue = ref.watch(offlineWriteQueueProvider);
  return queue.watchFailedCount();
});

final cachePinningServiceProvider = Provider<CachePinningService>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return CachePinningService(db);
});
