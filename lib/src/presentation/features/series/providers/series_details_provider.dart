import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';

final cachedSeriesIssueCountProvider = StreamProvider.autoDispose
    .family<int?, int>((ref, id) {
      ref.keepAlive();
      final db = ref.read(driftDatabaseProvider);
      return db.metronEntityDao.watchSeries(id).map((row) => row?.issueCount);
    });

/// Exposes the complete series response instead of a reduced database row.
final seriesDetailsProvider = FutureProvider.autoDispose
    .family<SeriesDetails, int>((ref, id) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final series = await ref
          .watch(metronRepositoryProvider)
          .getSeriesDetails(id);
      if (series.image != null && series.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('series', id, series.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }

      timer = Timer(const Duration(minutes: 5), () => link.close());
      return series;
    });

/// Full response for the detail screen, where associated series/genres must not be dropped by normalization.
final seriesFullDetailsProvider = FutureProvider.autoDispose
    .family<SeriesDetails, int>((ref, id) async {
      final link = ref.keepAlive();
      Timer? timer;
      ref.onDispose(() => timer?.cancel());

      final series = await ref
          .watch(metronRepositoryProvider)
          .getSeriesDetails(id);
      if (series.image != null && series.image!.trim().isNotEmpty) {
        ref.read(entityImageCacheProvider).set('series', id, series.image!);
        ref
            .read(entityImageVersionProvider.notifier)
            .update((value) => value + 1);
      }

      timer = Timer(const Duration(minutes: 5), () => link.close());
      return series;
    });
