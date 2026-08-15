import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/cache/entity_image_cache.dart";
import "package:takion/src/presentation/providers/providers.dart";

const seriesCoverFetchBudgetPerSession = 12;

final seriesCoverImageProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, seriesId) {
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final entityCache = ref.read(entityImageCacheProvider);
      final repository = ref.watch(metronRepositoryProvider);

      unawaited(repository.getSeriesIssueList(seriesId, page: 1, limit: 1));

      return localCatalog.watchSeriesCoverUrl(seriesId).map((coverUrl) {
        if (coverUrl != null && coverUrl.trim().isNotEmpty) {
          entityCache.set("series", seriesId, coverUrl.trim());
          ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
        }
        return coverUrl;
      });
    });
