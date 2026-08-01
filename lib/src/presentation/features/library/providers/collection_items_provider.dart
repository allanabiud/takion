import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/library_items_serialization.dart';

const _collectionPageSize = metronDefaultPageSize;

LibraryOwnershipStatus _ownershipFromRaw(String raw) {
  switch (raw) {
    case 'owned':
      return LibraryOwnershipStatus.owned;
    case 'wishlist':
      return LibraryOwnershipStatus.wishlist;
    default:
      return LibraryOwnershipStatus.notOwned;
  }
}

LibraryItemFormat _formatFromRaw(String raw) {
  switch (raw) {
    case 'digital':
      return LibraryItemFormat.digital;
    case 'both':
      return LibraryItemFormat.both;
    default:
      return LibraryItemFormat.print;
  }
}

LibraryItem _driftItemToDomain(db.LibraryItem d) {
  return LibraryItem(
    id: d.id,
    userId: d.userId,
    metronIssueId: d.metronIssueId,
    metronSeriesId: d.metronSeriesId,
    ownershipStatus: _ownershipFromRaw(d.ownershipStatus),
    isRead: d.isRead,
    rating: d.rating,
    purchaseDate: d.purchaseDate != null
        ? DateTime.tryParse(d.purchaseDate!)
        : null,
    pricePaid: d.pricePaid,
    quantityOwned: d.quantityOwned,
    format: _formatFromRaw(d.format),
    firstReadAt: d.firstReadAt != null
        ? DateTime.tryParse(d.firstReadAt!)
        : null,
    conditionGrade: d.conditionGrade,
    acquiredOn: d.acquiredOn != null ? DateTime.tryParse(d.acquiredOn!) : null,
    notes: d.notes,
    createdAt: DateTime.parse(d.createdAt),
    updatedAt: DateTime.parse(d.updatedAt),
  );
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

final libraryItemsStreamProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref
      .watch(driftDatabaseProvider)
      .libraryItemDao
      .watchAll()
      .map((rows) => rows.map(_driftItemToDomain).toList());
});

final ownedLibraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref
      .watch(driftDatabaseProvider)
      .libraryItemDao
      .watchByOwnershipStatus('owned')
      .map((rows) => rows.map(_driftItemToDomain).toList());
});

final readLibraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref
      .watch(driftDatabaseProvider)
      .libraryItemDao
      .watchByIsRead(true)
      .map((rows) => rows.map(_driftItemToDomain).toList());
});

final metronIssuesStreamProvider = StreamProvider.autoDispose<List<db.MetronIssue>>((ref) {
  return ref
      .watch(driftDatabaseProvider)
      .metronEntityDao
      .watchAllIssues();
});

final collectionItemsProvider = FutureProvider.family<CollectionItemsPage, int>(
  (ref, page) {
    return _loadCollectionPage(ref, page);
  },
);

Future<CollectionItemsPage> _loadCollectionPage(Ref ref, int page) async {
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _collectionPageSize;
  final db = ref.watch(driftDatabaseProvider);
  final totalCount = await db.libraryItemDao.getItemCount(
    ownershipStatus: 'owned',
  );
  final ownedRows = await db.libraryItemDao.getItems(
    ownershipStatus: 'owned',
    limit: _collectionPageSize,
    offset: offset,
  );
  final libraryItems = ownedRows.map(_driftItemToDomain).toList();

  final enriched = await hydrateLibraryItems(ref, libraryItems);

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

final allLibraryItemsProvider = libraryItemsStreamProvider;

final allCollectionItemsProvider = FutureProvider<List<CollectionItem>>((
  ref,
) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final enriched = await hydrateLibraryItems(ref, libraryItems);
  return enriched.where((item) => item.quantity > 0 || item.isRead).toList();
});

final collectionItemsByOwnershipStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, LibraryOwnershipStatus>((ref, status) async {
      final libraryItems = status == LibraryOwnershipStatus.owned
          ? await ref.watch(ownedLibraryItemsProvider.future)
          : await ref.watch(allLibraryItemsProvider.future);
      final filtered = libraryItems
          .where((item) => item.ownershipStatus == status)
          .toList();
      return hydrateLibraryItems(ref, filtered);
    });

final collectionItemsByReadStatusProvider = FutureProvider.autoDispose
    .family<List<CollectionItem>, bool>((ref, isRead) async {
      final libraryItems = isRead
          ? await ref.watch(readLibraryItemsProvider.future)
          : await ref.watch(allLibraryItemsProvider.future);
      final filtered = libraryItems
          .where(
            (item) =>
                item.isRead == isRead && (isRead || item.quantityOwned > 0),
          )
          .toList();
      return hydrateLibraryItems(ref, filtered);
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
