import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:takion/src/core/sync/connectivity_monitor.dart";
import "package:takion/src/core/sync/metron_sync_manager.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/core/sync/offline_queue/offline_write_queue.dart";
import "package:takion/src/data/collection/sync/collection_sync_manager.dart";
import "package:takion/src/data/pull_list/sync/pull_list_sync_manager.dart";
import "package:takion/src/data/wishlist/sync/wishlist_sync_manager.dart";

class MockCollectionSyncManager extends Mock implements CollectionSyncManager {}

class MockPullListSyncManager extends Mock implements PullListSyncManager {}

class MockWishlistSyncManager extends Mock implements WishlistSyncManager {}

class MockOfflineWriteQueue extends Mock implements OfflineWriteQueue {}

class MockConnectivityMonitor extends Mock implements ConnectivityMonitor {}

void main() {
  group("MetronSyncManager", () {
    late MockCollectionSyncManager collectionSync;
    late MockPullListSyncManager pullListSync;
    late MockWishlistSyncManager wishlistSync;
    late MockOfflineWriteQueue offlineQueue;
    late MockConnectivityMonitor connectivityMonitor;
    late MetronSyncManager syncManager;

    setUp(() {
      collectionSync = MockCollectionSyncManager();
      pullListSync = MockPullListSyncManager();
      wishlistSync = MockWishlistSyncManager();
      offlineQueue = MockOfflineWriteQueue();
      connectivityMonitor = MockConnectivityMonitor();

      when(() => offlineQueue.processQueue()).thenAnswer((_) async => 0);
      when(
        () => collectionSync.syncCollection(
          forceFullSync: any(named: "forceFullSync"),
        ),
      ).thenAnswer(
        (_) async => const CollectionSyncResult(
          itemsFetched: 5,
          itemsUpdated: 5,
          isFullSync: false,
        ),
      );
      when(() => pullListSync.syncPullList()).thenAnswer(
        (_) async => const PullListSyncResult(
          seriesFetched: 2,
          issuesFetched: 3,
          isSuccess: true,
        ),
      );
      when(() => wishlistSync.syncWishlist()).thenAnswer(
        (_) async => const WishlistSyncResult(
          itemsFetched: 4,
          itemsUpdated: 4,
          isSuccess: true,
        ),
      );

      syncManager = MetronSyncManager(
        collectionSyncManager: collectionSync,
        pullListSyncManager: pullListSync,
        wishlistSyncManager: wishlistSync,
        offlineWriteQueue: offlineQueue,
        connectivityMonitor: connectivityMonitor,
      );
    });

    tearDown(() {
      syncManager.dispose();
    });

    test("syncAll orchestrates all domain sync managers and emits success",
        () async {
      final states = <MetronSyncState>[];
      final subscription = syncManager.stateStream.listen(states.add);

      final result = await syncManager.syncAll();

      expect(result.status, SyncStatus.success);
      expect(result.collectionItemsSynced, 5);
      expect(result.pullListSeriesSynced, 2);
      expect(result.pullListIssuesSynced, 3);
      expect(result.wishlistItemsSynced, 4);

      verify(() => offlineQueue.processQueue()).called(1);
      verify(() => collectionSync.syncCollection(forceFullSync: false))
          .called(1);
      verify(() => pullListSync.syncPullList()).called(1);
      verify(() => wishlistSync.syncWishlist()).called(1);

      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(states.any((s) => s.status == SyncStatus.syncing), isTrue);
      expect(states.last.status, SyncStatus.success);
    });

    test("syncAll handles failure in a domain manager gracefully", () async {
      when(() => collectionSync.syncCollection(forceFullSync: false))
          .thenAnswer(
        (_) async => const CollectionSyncResult(
          itemsFetched: 0,
          itemsUpdated: 0,
          isFullSync: false,
          errorMessage: "Network timeout",
        ),
      );

      final result = await syncManager.syncAll();

      expect(result.status, SyncStatus.error);
      expect(result.errorMessage, "Network timeout");
    });
  });
}
