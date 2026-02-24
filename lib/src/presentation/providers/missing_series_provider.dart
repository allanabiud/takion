import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/missing_series_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final selectedMissingSeriesPageProvider =
    NotifierProvider<SelectedMissingSeriesPage, int>(
  SelectedMissingSeriesPage.new,
);

class SelectedMissingSeriesPage extends Notifier<int> {
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

final missingSeriesProvider =
    FutureProvider.autoDispose.family<MissingSeriesPage, int>((ref, page) {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getMissingSeries(page: page);
});

final currentMissingSeriesProvider =
    FutureProvider.autoDispose<MissingSeriesPage>((ref) {
  final page = ref.watch(selectedMissingSeriesPageProvider);
  return ref.watch(missingSeriesProvider(page).future);
});
