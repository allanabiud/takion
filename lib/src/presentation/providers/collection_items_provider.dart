import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/collection_items_page.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

const _collectionPageSize = 25;
const _libraryCacheBoxName = 'library_items_cache_box';
const _libraryAllItemsKey = 'all_items';
const _libraryAllItemsMetaKey = 'library_items:all';
const _maxHydrationConcurrency = 4;

Future<void> invalidateLibraryItemsLocalCacheWithHive(
  HiveService hiveService,
) async {
  final cacheBox = await hiveService.openBox<dynamic>(_libraryCacheBoxName);
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  await cacheBox.delete(_libraryAllItemsKey);
  await metaBox.delete(_libraryAllItemsMetaKey);
}

Future<void> invalidateLibraryItemsLocalCache(Ref ref) {
  return invalidateLibraryItemsLocalCacheWithHive(
    ref.read(hiveServiceProvider),
  );
}

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

Future<List<R>> _mapWithConcurrency<T, R>(
  List<T> items,
  Future<R> Function(T item) mapper, {
  int maxConcurrency = _maxHydrationConcurrency,
}) async {
  if (items.isEmpty) return <R>[];
  final results = List<R?>.filled(items.length, null);
  var cursor = 0;

  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= items.length) return;
      cursor = index + 1;
      results[index] = await mapper(items[index]);
    }
  }

  final workers = List.generate(
    maxConcurrency.clamp(1, items.length),
    (_) => worker(),
  );
  await Future.wait(workers);
  return results.whereType<R>().toList(growable: false);
}

String _ownershipToStorage(LibraryOwnershipStatus status) {
  switch (status) {
    case LibraryOwnershipStatus.owned:
      return 'owned';
    case LibraryOwnershipStatus.notOwned:
      return 'not_owned';
    case LibraryOwnershipStatus.wishlist:
      return 'wishlist';
  }
}

LibraryOwnershipStatus? _ownershipFromStorage(String value) {
  switch (value) {
    case 'owned':
      return LibraryOwnershipStatus.owned;
    case 'not_owned':
      return LibraryOwnershipStatus.notOwned;
    case 'wishlist':
      return LibraryOwnershipStatus.wishlist;
  }
  return null;
}

String _formatToStorage(LibraryItemFormat format) {
  switch (format) {
    case LibraryItemFormat.print:
      return 'print';
    case LibraryItemFormat.digital:
      return 'digital';
    case LibraryItemFormat.both:
      return 'both';
  }
}

LibraryItemFormat? _formatFromStorage(String value) {
  switch (value) {
    case 'print':
      return LibraryItemFormat.print;
    case 'digital':
      return LibraryItemFormat.digital;
    case 'both':
      return LibraryItemFormat.both;
  }
  return null;
}

Map<String, dynamic> _libraryItemToJson(LibraryItem item) {
  return {
    'id': item.id,
    'user_id': item.userId,
    'metron_issue_id': item.metronIssueId,
    'metron_series_id': item.metronSeriesId,
    'ownership_status': _ownershipToStorage(item.ownershipStatus),
    'is_read': item.isRead,
    'rating': item.rating,
    'purchase_date': item.purchaseDate?.toIso8601String(),
    'price_paid': item.pricePaid,
    'quantity_owned': item.quantityOwned,
    'format': _formatToStorage(item.format),
    'first_read_at': item.firstReadAt?.toIso8601String(),
    'condition_grade': item.conditionGrade,
    'acquired_on': item.acquiredOn?.toIso8601String(),
    'notes': item.notes,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };
}

LibraryItem? _libraryItemFromJson(Map<String, dynamic> json) {
  final id = json['id'] as String?;
  final userId = json['user_id'] as String?;
  final metronIssueId = (json['metron_issue_id'] as num?)?.toInt();
  final metronSeriesId = (json['metron_series_id'] as num?)?.toInt();
  final ownershipStatus = _ownershipFromStorage(
    json['ownership_status'] as String? ?? '',
  );
  final format = _formatFromStorage(json['format'] as String? ?? '');
  final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');
  final updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  if (id == null ||
      userId == null ||
      metronIssueId == null ||
      metronSeriesId == null ||
      ownershipStatus == null ||
      format == null ||
      createdAt == null ||
      updatedAt == null) {
    return null;
  }

  return LibraryItem(
    id: id,
    userId: userId,
    metronIssueId: metronIssueId,
    metronSeriesId: metronSeriesId,
    ownershipStatus: ownershipStatus,
    isRead: json['is_read'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toInt(),
    purchaseDate: DateTime.tryParse(json['purchase_date'] as String? ?? ''),
    pricePaid: (json['price_paid'] as num?)?.toDouble(),
    quantityOwned: (json['quantity_owned'] as num?)?.toInt() ?? 1,
    format: format,
    firstReadAt: DateTime.tryParse(json['first_read_at'] as String? ?? ''),
    conditionGrade: json['condition_grade'] as String?,
    acquiredOn: DateTime.tryParse(json['acquired_on'] as String? ?? ''),
    notes: json['notes'] as String?,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

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

Future<CollectionItem> _enrichLibraryItem(Ref ref, LibraryItem item) async {
  final localDataSource = ref.read(metronLocalDataSourceProvider);

  try {
    final details = await localDataSource.getIssueDetails(item.metronIssueId);
    if (details == null) {
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
    return _toCollectionItem(
      item,
      details.series?.name,
      details.series?.volume,
      details.series?.yearBegan,
      details.number,
      details.image,
      details.coverDate != null ? DateTime.tryParse(details.coverDate!) : null,
      details.storeDate != null ? DateTime.tryParse(details.storeDate!) : null,
      details.modified != null ? DateTime.tryParse(details.modified!) : null,
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

final collectionItemsProvider = FutureProvider.family<CollectionItemsPage, int>(
  (ref, page) {
    return _loadCollectionPage(ref, page);
  },
);

Future<CollectionItemsPage> _loadCollectionPage(Ref ref, int page) async {
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _collectionPageSize;
  final allItems = await ref.watch(allLibraryItemsProvider.future);
  final totalCount = allItems.length;
  final libraryItems = allItems.skip(offset).take(_collectionPageSize).toList();

  final enriched = await _mapWithConcurrency<LibraryItem, CollectionItem>(
    libraryItems,
    (item) => _enrichLibraryItem(ref, item),
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
  final cacheBox = await hiveService.openBox<dynamic>(_libraryCacheBoxName);
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  final cachedAtEpoch = metaBox.get(_libraryAllItemsMetaKey);
  final cachedAt = cachedAtEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(cachedAtEpoch);
  final cachedRaw = cacheBox.get(_libraryAllItemsKey);
  final cachedItems = (cachedRaw is List
      ? cachedRaw
            .whereType<Map>()
            .map((entry) => _libraryItemFromJson(entry.cast<String, dynamic>()))
            .whereType<LibraryItem>()
            .toList()
      : <LibraryItem>[]);
  final isFresh =
      cachedAt != null &&
      SupabaseCachePolicies.collectionItems.isFresh(cachedAt, DateTime.now());
  if (isFresh) {
    metrics.recordCacheHit(_libraryAllItemsMetaKey);
    return cachedItems;
  }
  metrics.recordCacheMiss(_libraryAllItemsMetaKey);

  try {
    final totalCount = await repository.getItemCount();
    if (totalCount <= 0) {
      await cacheBox.put(_libraryAllItemsKey, const <Map<String, dynamic>>[]);
      await metaBox.put(
        _libraryAllItemsMetaKey,
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
      _libraryAllItemsKey,
      items.map(_libraryItemToJson).toList(),
    );
    await metaBox.put(
      _libraryAllItemsMetaKey,
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
  final enriched = await _mapWithConcurrency<LibraryItem, CollectionItem>(
    libraryItems,
    (item) => _enrichLibraryItem(ref, item),
  );
  return enriched;
});

final collectionItemsByOwnershipStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, LibraryOwnershipStatus>((ref, status) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final filtered = libraryItems
          .where((item) => item.ownershipStatus == status)
          .toList();
      return Future.wait(filtered.map((item) => _enrichLibraryItem(ref, item)));
    });

final collectionItemsByReadStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, bool>((ref, isRead) async {
      final items = await ref.watch(allCollectionItemsProvider.future);
      return items.where((item) => item.isRead == isRead).toList();
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

class ReadingHistoryEntry {
  const ReadingHistoryEntry({required this.item, required this.readAt});

  final CollectionItem item;
  final DateTime? readAt;
}

final readingHistoryCollectionItemsProvider =
    FutureProvider.autoDispose<List<ReadingHistoryEntry>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );

      final readAtByIssueId = <int, DateTime?>{
        for (final item in libraryItems)
          if (item.isRead) item.metronIssueId: item.firstReadAt,
      };

      final entries =
          collectionItems
              .where((item) {
                final issueId = item.issue?.id;
                return issueId != null && readAtByIssueId.containsKey(issueId);
              })
              .map(
                (item) => ReadingHistoryEntry(
                  item: item,
                  readAt: readAtByIssueId[item.issue!.id],
                ),
              )
              .toList()
            ..sort((a, b) {
              final aDate = a.readAt;
              final bDate = b.readAt;
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });

      return entries;
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
