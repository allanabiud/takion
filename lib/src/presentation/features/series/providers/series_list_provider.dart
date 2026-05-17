import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

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

final seriesListProvider =
    FutureProvider.autoDispose.family<SeriesListPage, int>((ref, page) {
      final repository = ref.watch(metronRepositoryProvider);
      return repository.getSeriesList(page: page);
    });

final currentSeriesListProvider = FutureProvider.autoDispose<SeriesListPage>((
  ref,
) {
  final page = ref.watch(selectedSeriesListPageProvider);
  return ref.watch(seriesListProvider(page).future);
});
