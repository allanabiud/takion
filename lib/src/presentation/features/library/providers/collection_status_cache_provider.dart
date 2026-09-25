import "dart:async";
import "package:async/async.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart";

extension _DebounceStream<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (!controller.isClosed) {
                controller.add(data);
              }
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            timer?.cancel();
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }
}

Map<int, IssueCollectionStatus> buildStatusMap({
  required List<LibraryItemStatusRow> libraryRows,
  required List<WishlistItem> wishlistRows,
}) {
  final map = <int, IssueCollectionStatus>{};

  // 1. Process library rows
  for (final row in libraryRows) {
    if (row.metronIssueId <= 0) continue;
    final isOwned = row.ownershipStatus == "owned";
    final isWishlist = !isOwned && row.ownershipStatus == "wishlist";

    map[row.metronIssueId] = IssueCollectionStatus(
      isCollected: isOwned,
      isWishlisted: isWishlist,
      isRead: row.isRead,
      rating: row.rating,
      syncStatus: row.syncStatus,
    );
  }

  // 2. Process wishlist rows: preserve collection/read status if already present, but mark isWishlisted = true
  for (final w in wishlistRows) {
    if (w.issueId <= 0) continue;
    final existing = map[w.issueId];
    if (existing != null) {
      map[w.issueId] = IssueCollectionStatus(
        isCollected: existing.isCollected,
        isWishlisted: true,
        isRead: existing.isRead,
        rating: existing.rating,
        syncStatus: w.syncStatus == "pending" || w.syncStatus == "failed"
            ? w.syncStatus
            : existing.syncStatus,
      );
    } else {
      map[w.issueId] = IssueCollectionStatus(
        isCollected: false,
        isWishlisted: true,
        isRead: false,
        rating: null,
        syncStatus: w.syncStatus,
      );
    }
  }

  return map;
}

final collectionStatusCacheProvider =
    StreamProvider<Map<int, IssueCollectionStatus>>((ref) {
      final db = ref.watch(driftDatabaseProvider);

      return StreamGroup.merge([
        db.libraryItemDao.watchStatusRows(),
        db.wishlistDao.watchAll(),
      ]).debounce(const Duration(milliseconds: 16)).asyncMap((_) async {
        final rows = await db.libraryItemDao.getStatusRows();
        final wishlistRows = await db.wishlistDao.getAll();
        return buildStatusMap(libraryRows: rows, wishlistRows: wishlistRows);
      });
    });
