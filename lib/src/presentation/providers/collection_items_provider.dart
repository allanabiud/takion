import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

const _collectionPageSize = 25;

CollectionItem _toCollectionItem(
  LibraryItem item,
  String? seriesName,
  int? seriesVolume,
  int? seriesYearBegan,
  String issueNumber,
  String? issueImage,
  DateTime? coverDate,
  DateTime? storeDate,
  DateTime? modified,
) {
  return CollectionItem(
    id: item.id.hashCode,
    issue: CollectionIssueRef(
      id: item.metronIssueId,
      number: issueNumber,
      series: CollectionIssueSeriesRef(
        name: (seriesName != null && seriesName.trim().isNotEmpty)
            ? seriesName.trim()
            : 'Series ${item.metronSeriesId}',
        volume: seriesVolume,
        yearBegan: seriesYearBegan,
      ),
      image: issueImage,
      coverDate: coverDate,
      storeDate: storeDate,
      modified: modified,
    ),
    quantity: item.ownershipStatus == LibraryOwnershipStatus.owned
      ? item.quantityOwned
      : 0,
    grade: item.conditionGrade == null
      ? null
      : double.tryParse(item.conditionGrade!.trim()),
    purchaseDate: item.purchaseDate ?? item.acquiredOn,
    isRead: item.isRead,
    readCount: item.isRead ? 1 : 0,
    rating: item.rating,
    modified: item.updatedAt,
  );
}

Future<CollectionItem> _enrichLibraryItem(
  Ref ref,
  LibraryItem item,
) async {
  final catalogRepository = ref.read(catalogRepositoryProvider);

  try {
    final details = await catalogRepository.getIssueDetails(item.metronIssueId);
    return _toCollectionItem(
      item,
      details.series?.name,
      details.series?.volume,
      details.series?.yearBegan,
      details.number,
      details.image,
      details.coverDate,
      details.storeDate,
      details.modified,
    );
  } catch (_) {
    return _toCollectionItem(
      item,
      null,
      null,
      null,
      '',
      null,
      null,
      null,
      null,
    );
  }
}

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
  return _loadCollectionPage(ref, page);
});

Future<CollectionItemsPage> _loadCollectionPage(Ref ref, int page) async {
  final repository = ref.read(libraryRepositoryProvider);
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _collectionPageSize;

  final totalCount = await repository.getItemCount();
  final libraryItems = await repository.listItems(
    limit: _collectionPageSize,
    offset: offset,
  );

  final enriched = await Future.wait(
    libraryItems.map((item) => _enrichLibraryItem(ref, item)),
  );

  final totalPages = totalCount == 0
      ? 1
      : ((totalCount / _collectionPageSize).ceil()).clamp(1, 9999);
  final hasPrevious = safePage > 1;
  final hasNext = safePage < totalPages;

  String? pageUrl(int pageNumber) => 'app://collection?page=$pageNumber';

  return CollectionItemsPage(
    count: totalCount,
    currentPage: safePage,
    previous: hasPrevious ? pageUrl(safePage - 1) : null,
    next: hasNext ? pageUrl(safePage + 1) : null,
    results: enriched,
  );
}

final currentCollectionItemsProvider =
    FutureProvider.autoDispose<CollectionItemsPage>((ref) {
  final page = ref.watch(selectedCollectionItemsPageProvider);
  return ref.watch(collectionItemsProvider(page).future);
});

final allCollectionItemsProvider = FutureProvider<List<CollectionItem>>((ref) async {
  final repository = ref.read(libraryRepositoryProvider);
  final totalCount = await repository.getItemCount();
  if (totalCount <= 0) return <CollectionItem>[];

  final items = <CollectionItem>[];
  var offset = 0;

  while (items.length < totalCount) {
    final libraryItems = await repository.listItems(
      limit: _collectionPageSize,
      offset: offset,
    );
    if (libraryItems.isEmpty) break;

    final enriched = await Future.wait(
      libraryItems.map((item) => _enrichLibraryItem(ref, item)),
    );
    items.addAll(enriched);
    offset += libraryItems.length;
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
