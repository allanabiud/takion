import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/providers/providers.dart";

const seriesCoverFetchBudgetPerSession = 12;

final seriesCoverImageProvider = StreamProvider.autoDispose
    .family<String?, int>((ref, seriesId) {
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final repository = ref.watch(metronRepositoryProvider);

      unawaited(
        repository.getSeriesIssueList(
          seriesId,
          page: 1,
          limit: 1,
          ordering: "-cover_date",
        ),
      );

      return localCatalog.watchSeriesCoverUrl(seriesId);
    });
