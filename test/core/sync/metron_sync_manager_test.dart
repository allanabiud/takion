import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
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

void main() {
  group("MetronSyncManager", () {
    late MockCollectionSyncManager collectionSync;
    late MockPullListSyncManager pullListSync;
    late MockWishlistSyncManager wishlistSync;
    late MockOfflineWriteQueue offlineQueue;
    late MetronSyncManager syncManager;

    setUp(() {
      collectionSync = MockCollectionSyncManager();
      pullListSync = MockPullListSyncManager();
      wishlistSync = MockWishlistSyncManager();
      offlineQueue = MockOfflineWriteQueue();

      when(
        () => offlineQueue.watchPendingCount(),
      ).thenAnswer((_) => Stream.value(0));
      when(() => offlineQueue.processQueue()).thenAnswer((_) async => 0);
      when(() => offlineQueue.processAllEntries()).thenAnswer((_) async => 0);
      when(
        () => collectionSync.syncCollection(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      ).thenAnswer(
        (_) async => const CollectionSyncResult(
          itemsFetched: 5,
          itemsUpdated: 5,
          isFullSync: false,
        ),
      );
      when(
        () => pullListSync.syncPullList(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      ).thenAnswer(
        (_) async => const PullListSyncResult(
          seriesFetched: 2,
          issuesFetched: 3,
          isSuccess: true,
          isFullSync: true,
        ),
      );
      when(
        () => wishlistSync.syncWishlist(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      ).thenAnswer(
        (_) async => const WishlistSyncResult(
          itemsFetched: 4,
          itemsUpdated: 4,
          isSuccess: true,
          isFullSync: true,
        ),
      );

      syncManager = MetronSyncManager(
        collectionSyncManager: collectionSync,
        pullListSyncManager: pullListSync,
        wishlistSyncManager: wishlistSync,
        offlineWriteQueue: offlineQueue,
      );
    });

    tearDown(() {
      syncManager.dispose();
    });

    test(
      "syncAll orchestrates all domain sync managers and emits success",
      () async {
        final states = <MetronSyncState>[];
        final subscription = syncManager.stateStream.listen(states.add);

        final result = await syncManager.syncAll();

        expect(result.status, SyncStatus.success);
        expect(result.collectionItemsSynced, 5);
        expect(result.pullListSeriesSynced, 2);
        expect(result.pullListIssuesSynced, 3);
        expect(result.wishlistItemsSynced, 4);

        verify(() => offlineQueue.processAllEntries()).called(1);
        verify(
          () => collectionSync.syncCollection(
            forceFullSync: false,
            onProgress: any(named: "onProgress"),
          ),
        ).called(1);
        verify(
          () => pullListSync.syncPullList(
            forceFullSync: false,
            onProgress: any(named: "onProgress"),
          ),
        ).called(1);
        verify(
          () => wishlistSync.syncWishlist(
            forceFullSync: false,
            onProgress: any(named: "onProgress"),
          ),
        ).called(1);

        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();
        expect(states.any((s) => s.status == SyncStatus.syncing), isTrue);
        expect(states.last.status, SyncStatus.success);
      },
    );

    test("syncAll handles failure in a domain manager gracefully", () async {
      when(
        () => collectionSync.syncCollection(
          forceFullSync: false,
          onProgress: any(named: "onProgress"),
        ),
      ).thenAnswer(
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

    test(
      "syncAll emits live incremental progress updates during sync phases",
      () async {
        when(
          () => collectionSync.syncCollection(
            forceFullSync: any(named: "forceFullSync"),
            onProgress: any(named: "onProgress"),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onProgress] as void Function(int)?;
          onProgress?.call(20);
          onProgress?.call(40);
          return const CollectionSyncResult(
            itemsFetched: 40,
            itemsUpdated: 40,
            isFullSync: true,
          );
        });

        final states = <MetronSyncState>[];
        final subscription = syncManager.stateStream.listen(states.add);

        await syncManager.syncAll();
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();

        expect(states.any((s) => s.collectionItemsSynced == 20), isTrue);
        expect(states.any((s) => s.collectionItemsSynced == 40), isTrue);
      },
    );

    test("dispose cancels a pending debounced sync", () async {
      syncManager.scheduleSync(debounce: const Duration(milliseconds: 50));
      syncManager.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 120));

      verifyNever(
        () => collectionSync.syncCollection(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      );
    });

    test(
      "re-scheduling cancels the previous debounce so only one sync runs",
      () async {
        syncManager.scheduleSync(debounce: const Duration(milliseconds: 60));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        syncManager.scheduleSync(debounce: const Duration(milliseconds: 60));

        // First timer would have fired at t=60ms, second at t=90ms.
        await Future<void>.delayed(const Duration(milliseconds: 180));

        verify(
          () => collectionSync.syncCollection(
            forceFullSync: any(named: "forceFullSync"),
            onProgress: any(named: "onProgress"),
          ),
        ).called(1);
      },
    );

    test("syncAll while a sync is running returns the in-flight state "
        "without re-entering", () async {
      final gate = Completer<void>();
      when(
        () => collectionSync.syncCollection(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return const CollectionSyncResult(
          itemsFetched: 1,
          itemsUpdated: 1,
          isFullSync: false,
        );
      });

      final first = syncManager.syncAll();
      await Future<void>.delayed(Duration.zero);

      final second = await syncManager.syncAll();
      expect(second.status, SyncStatus.syncing);

      gate.complete();
      final firstResult = await first;
      expect(firstResult.status, SyncStatus.success);

      verify(
        () => collectionSync.syncCollection(
          forceFullSync: any(named: "forceFullSync"),
          onProgress: any(named: "onProgress"),
        ),
      ).called(1);
    });
  });
}
