import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final cachedSeriesIssueCountProvider = FutureProvider.autoDispose
    .family<int?, int>((ref, id) async {
      ref.keepAlive();
      final db = ref.read(driftDatabaseProvider);
      final row = await db.metronEntityDao.getSeries(id);
      return row?.issueCount;
    });

/// Exposes the complete series response instead of a reduced database row.
final seriesDetailsProvider = FutureProvider.autoDispose
    .family<SeriesDetails, int>((ref, id) async {
      final series = await ref
          .watch(metronRepositoryProvider)
          .getSeriesDetails(id);
      if (series.image != null && series.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('series', id, series.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }
      return series;
    });

/// Used by the detail screen, where associated series and genres must not be
/// dropped by the normalized cache representation.
final seriesFullDetailsProvider = FutureProvider.autoDispose
    .family<SeriesDetails, int>((ref, id) async {
      final series = await ref
          .watch(metronRepositoryProvider)
          .getSeriesDetails(id);
      if (series.image != null && series.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('series', id, series.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }
      return series;
    });
