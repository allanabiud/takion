import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

final selectedCollectionItemsPageProvider =
    NotifierProvider<SelectedCollectionItemsPage, int>(
  SelectedCollectionItemsPage.new,
);

class SelectedCollectionItemsPage extends Notifier<int> {
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

final collectionItemsProvider =
    FutureProvider.autoDispose.family<CollectionItemsPage, int>((ref, page) {
  final repository = ref.watch(metronRepositoryProvider);
  return repository.getCollectionItems(page: page);
});

final currentCollectionItemsProvider =
    FutureProvider.autoDispose<CollectionItemsPage>((ref) {
  final page = ref.watch(selectedCollectionItemsPageProvider);
  return ref.watch(collectionItemsProvider(page).future);
});

final allCollectionItemsProvider = FutureProvider<List<CollectionItem>>((ref) async {
  final repository = ref.watch(metronRepositoryProvider);

  final firstPage = await repository.getCollectionItems(page: 1);
  final items = <CollectionItem>[...firstPage.results];

  if (firstPage.results.isEmpty) return items;

  final pageSize = firstPage.results.length;
  final totalPages = ((firstPage.count / pageSize).ceil()).clamp(1, 9999);

  for (var page = 2; page <= totalPages; page++) {
    final pageData = await repository.getCollectionItems(page: page);
    items.addAll(pageData.results);
  }

  return items;
});

final collectionItemsByReadStatusProvider =
    FutureProvider.autoDispose.family<List<CollectionItem>, bool>(
      (
        ref,
        isRead,
      ) async {
        final items = await ref.watch(allCollectionItemsProvider.future);
        return items.where((item) => item.isRead == isRead).toList();
      },
    );

String _normalizeSeriesName(String name) {
  return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String _seriesKey({
  required String name,
  required int? volume,
  required int? yearBegan,
}) {
  return '${_normalizeSeriesName(name)}|${volume ?? -1}|${yearBegan ?? -1}';
}

final collectionSeriesKeysProvider =
    FutureProvider.autoDispose<Set<String>>((ref) async {
      final items = await ref.watch(allCollectionItemsProvider.future);
      final keys = <String>{};

      for (final item in items) {
        if (item.quantity <= 0) continue;
        final series = item.issue?.series;
        final name = series?.name.trim();
        if (name == null || name.isEmpty) continue;
        keys.add(
          _seriesKey(
            name: name,
            volume: series?.volume,
            yearBegan: series?.yearBegan,
          ),
        );
      }

      return keys;
    });
