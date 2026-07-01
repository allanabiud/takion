import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/library/providers/library_items_serialization.dart';
import 'package:takion/src/presentation/features/library/providers/collection_cache_helpers.dart';

const _collectionPageSize = metronDefaultPageSize;

void invalidateLibraryCollectionProviders(Ref ref) {
  ref.invalidate(allLibraryItemsProvider);
  ref.invalidate(allCollectionItemsProvider);
  ref.invalidate(collectionItemsProvider);
  ref.invalidate(currentCollectionItemsProvider);
}

void invalidateLibraryCollectionProvidersForWidget(WidgetRef ref) {
  ref.invalidate(allLibraryItemsProvider);
  ref.invalidate(allCollectionItemsProvider);
  ref.invalidate(collectionItemsProvider);
  ref.invalidate(currentCollectionItemsProvider);
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

final collectionItemsProvider = FutureProvider.family<CollectionItemsPage, int>(
  (ref, page) {
    return _loadCollectionPage(ref, page);
  },
);

Future<CollectionItemsPage> _loadCollectionPage(Ref ref, int page) async {
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _collectionPageSize;
  final allItems = await ref.watch(allLibraryItemsProvider.future);
  final ownedItems = allItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
      .toList();
  final totalCount = ownedItems.length;
  final libraryItems = ownedItems.skip(offset).take(_collectionPageSize).toList();

  final enriched = await mapWithConcurrency<LibraryItem, CollectionItem>(
    libraryItems,
    (item) => enrichLibraryItem(ref, item),
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

final currentCollectionItemsProvider = FutureProvider<CollectionItemsPage>((
  ref,
) {
  final page = ref.watch(selectedCollectionItemsPageProvider);
  return ref.watch(collectionItemsProvider(page).future);
});

Future<List<LibraryItem>> _loadAllLibraryItems(Ref ref) async {
  final metrics = AppPerformanceMetrics.instance;
  final hiveService = ref.read(hiveServiceProvider);
  final repository = ref.read(libraryRepositoryProvider);
  final cacheBox = await hiveService.openBox<dynamic>(libraryCacheBoxName);
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  final cachedAtEpoch = metaBox.get(libraryAllItemsMetaKey);
  final cachedAt = cachedAtEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(cachedAtEpoch);
  final cachedRaw = cacheBox.get(libraryAllItemsKey);
  final cachedItems = (cachedRaw is List
      ? cachedRaw
            .whereType<Map>()
            .map((entry) => libraryItemFromJson(entry.cast<String, dynamic>()))
            .whereType<LibraryItem>()
            .toList()
      : <LibraryItem>[]);
  final isFresh =
      cachedAt != null &&
      LocalDataCachePolicies.collectionItems.isFresh(cachedAt, DateTime.now());
  if (isFresh) {
    metrics.recordCacheHit(libraryAllItemsMetaKey);
    return cachedItems;
  }
  metrics.recordCacheMiss(libraryAllItemsMetaKey);

  try {
    final totalCount = await repository.getItemCount();
    if (totalCount <= 0) {
      await cacheBox.put(libraryAllItemsKey, const <Map<String, dynamic>>[]);
      await metaBox.put(
        libraryAllItemsMetaKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return <LibraryItem>[];
    }

    final items = <LibraryItem>[];
    var offset = 0;

    while (items.length < totalCount) {
      final libraryItems = await repository.listItems(
        limit: _collectionPageSize,
        offset: offset,
      );
      if (libraryItems.isEmpty) break;
      items.addAll(libraryItems);
      offset += libraryItems.length;
    }

    await cacheBox.put(
      libraryAllItemsKey,
      items.map(libraryItemToJson).toList(),
    );
    await metaBox.put(
      libraryAllItemsMetaKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    return items;
  } catch (_) {
    if (cachedItems.isNotEmpty) return cachedItems;
    rethrow;
  }
}

final allLibraryItemsProvider = FutureProvider<List<LibraryItem>>((ref) async {
  return AppPerformanceMetrics.instance.trackProvider(
    'allLibraryItemsProvider',
    () => _loadAllLibraryItems(ref),
  );
});

final allCollectionItemsProvider = FutureProvider<List<CollectionItem>>((
  ref,
) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final enriched = await mapWithConcurrency<LibraryItem, CollectionItem>(
    libraryItems,
    (item) => enrichLibraryItem(ref, item),
  );
  return enriched
      .where((item) => item.quantity > 0 || item.isRead)
      .toList();
});

final collectionItemsByOwnershipStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, LibraryOwnershipStatus>((ref, status) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final filtered = libraryItems
          .where((item) => item.ownershipStatus == status)
          .toList();
      return Future.wait(filtered.map((item) => enrichLibraryItem(ref, item)));
    });

final collectionItemsByReadStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, bool>((ref, isRead) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final filtered = libraryItems
          .where((item) => item.isRead == isRead && (isRead || item.quantityOwned > 0))
          .toList();
      return Future.wait(filtered.map((item) => enrichLibraryItem(ref, item)));
    });

final unratedCollectionItemsProvider =
    FutureProvider.autoDispose<List<CollectionItem>>((ref) async {
      final items = await ref.watch(allCollectionItemsProvider.future);
      return items
          .where(
            (item) => item.isRead && (item.rating == null || item.rating! <= 0),
          )
          .toList();
    });

final wishlistCollectionItemsProvider =
    FutureProvider.autoDispose<List<CollectionItem>>((ref) async {
      return ref.watch(
        collectionItemsByOwnershipStatusProvider(
          LibraryOwnershipStatus.wishlist,
        ).future,
      );
    });

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

final collectionSeriesKeysProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
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
