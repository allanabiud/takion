import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/constants/pagination.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";

part "series_list_provider.g.dart";

final selectedSeriesListPageProvider =
    NotifierProvider<SelectedSeriesListPage, int>(SelectedSeriesListPage.new);

class SelectedSeriesListPage extends Notifier<int> {
  @override
  int build() => 1;

  void setPage(int page) {
    state = page < 1 ? 1 : page;
  }

  void nextPage() {
    state = state + 1;
  }

  void previousPage() {
    state = state > 1 ? state - 1 : 1;
  }
}

@riverpod
class SeriesList extends _$SeriesList {
  @override
  Future<SeriesListPage> build(int page) async {
    final repository = ref.watch(metronRepositoryProvider);
    final cancelToken = CancelToken();
    ref.onDispose(cancelToken.cancel);
    return repository.getSeriesList(
      page: page,
      limit: metronDefaultPageSize,
      cancelToken: cancelToken,
    );
  }

  Future<int> refresh({DateTime? modifiedGt}) async {
    final settings = ref.read(settingsProvider.notifier);
    final lastSync =
        modifiedGt ?? await settings.getListSyncTimestamp("series_list");
    final repository = ref.read(metronRepositoryProvider);
    final count = await repository.refreshSeriesListDelta(modifiedGt: lastSync);
    await settings.setListSyncTimestamp("series_list", DateTime.now());
    ref.invalidateSelf();
    return count;
  }
}

final currentSeriesListProvider =
    Provider.autoDispose<AsyncValue<SeriesListPage>>((ref) {
      final page = ref.watch(selectedSeriesListPageProvider);
      return ref.watch(seriesListProvider(page));
    });
