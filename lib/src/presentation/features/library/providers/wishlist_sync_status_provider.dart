import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";

final allWishlistSeriesSyncStatusesProvider =
    StreamProvider<Map<int, String>>((ref) {
      final db = ref.watch(driftDatabaseProvider);
      return db.wishlistDao.watchSyncStatusSummaryBySeries();
    });

final wishlistSeriesSyncStatusProvider =
    StreamProvider.family<String, int>((ref, seriesId) async* {
      final allStatuses =
          await ref.watch(allWishlistSeriesSyncStatusesProvider.future);
      yield allStatuses[seriesId] ?? "synced";
    });
