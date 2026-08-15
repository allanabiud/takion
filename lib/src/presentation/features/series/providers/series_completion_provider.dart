import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/providers/providers.dart";

final seriesOwnedCountProvider = StreamProvider.autoDispose.family<int, int>((
  ref,
  seriesId,
) {
  final db = ref.watch(driftDatabaseProvider);
  return db.libraryItemDao
      .watchBySeriesId(seriesId)
      .map((items) => items.where((i) => i.ownershipStatus == "owned").length);
});

final seriesReadCountProvider = StreamProvider.autoDispose.family<int, int>((
  ref,
  seriesId,
) {
  final db = ref.watch(driftDatabaseProvider);
  return db.libraryItemDao
      .watchBySeriesId(seriesId)
      .map((items) => items.where((i) => i.isRead).length);
});

/// Parent-level lookup so a list watches one Map instead of one provider/DB query per tile.
final seriesOwnedCountsProvider = StreamProvider.autoDispose
    .family<Map<int, int>, List<int>>((ref, seriesIds) {
      final db = ref.watch(driftDatabaseProvider);
      if (seriesIds.isEmpty) {
        return const Stream<Map<int, int>>.empty();
      }
      return db.libraryItemDao.watchCollected().map((items) {
        final counts = <int, int>{};
        for (final item in items) {
          if (seriesIds.contains(item.metronSeriesId)) {
            counts[item.metronSeriesId] =
                (counts[item.metronSeriesId] ?? 0) + 1;
          }
        }
        return counts;
      });
    });
