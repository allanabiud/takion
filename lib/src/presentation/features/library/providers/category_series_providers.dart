import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

List<CategorySeriesSummary> _groupBySeries(
  List<CollectionItem> items,
  Map<int, int> issueToSeriesId,
  Map<int, int> issueCounts,
) {
  final groups = <int, List<CollectionItem>>{};
  for (final item in items) {
    final seriesId = issueToSeriesId[item.issue?.id] ?? item.issue?.series?.id;
    if (seriesId == null || seriesId <= 0) continue;
    groups.putIfAbsent(seriesId, () => []).add(item);
  }

  return groups.entries.map((entry) {
    final seriesItems = entry.value;
    String? resolvedName;
    int? volume;
    int? yearBegan;
    String? coverImage;

    for (final item in seriesItems) {
      final name = item.issue?.series?.name.trim();
      if (name != null && name.isNotEmpty) {
        resolvedName = name;
        volume ??= item.issue?.series?.volume;
        yearBegan ??= item.issue?.series?.yearBegan;
      }
      final img = item.issue?.image?.trim();
      if (coverImage == null && img != null && img.isNotEmpty) {
        coverImage = img;
      }
      if (resolvedName != null && coverImage != null) break;
    }

    final seriesName = (resolvedName != null && resolvedName.isNotEmpty)
        ? resolvedName
        : 'Series ${entry.key}';

    return CategorySeriesSummary(
      seriesId: entry.key,
      seriesName: seriesName,
      volume: volume,
      yearBegan: yearBegan,
      coverImage: coverImage,
      categoryCount: seriesItems.length,
      items: seriesItems,
      issueCount: issueCounts[entry.key],
    );
  }).toList();
}

Map<int, int> _buildIssueToSeriesId(List<LibraryItem> libraryItems) {
  final map = <int, int>{};
  for (final item in libraryItems) {
    map[item.metronIssueId] = item.metronSeriesId;
  }
  return map;
}

Future<List<CategorySeriesSummary>> _groupWithIssueCounts(
  MetronEntityDao dao,
  List<CollectionItem> items,
  Map<int, int> issueToSeriesId,
) async {
  final seriesIds = items
      .map((item) => issueToSeriesId[item.issue?.id] ?? item.issue?.series?.id)
      .whereType<int>()
      .where((id) => id > 0)
      .toSet()
      .toList();
  if (seriesIds.isEmpty) return _groupBySeries(items, issueToSeriesId, {});
  final issueCounts = await dao.getSeriesIssueCounts(seriesIds);
  return _groupBySeries(items, issueToSeriesId, issueCounts);
}

final collectedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final collected = collectionItems
          .where((item) => item.quantity > 0)
          .toList();
      return _groupWithIssueCounts(dao, collected, issueToSeriesId);
    });

final readSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(true).future,
      );
      return _groupWithIssueCounts(dao, items, issueToSeriesId);
    });

final wishlistSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(wishlistCollectionItemsProvider.future);
      return _groupWithIssueCounts(dao, items, issueToSeriesId);
    });

final unreadSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(false).future,
      );
      return _groupWithIssueCounts(dao, items, issueToSeriesId);
    });

final unratedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final dao = ref.read(metronEntityDaoProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(unratedCollectionItemsProvider.future);
      return _groupWithIssueCounts(dao, items, issueToSeriesId);
    });

final seriesByCategoryProvider = FutureProvider.autoDispose
    .family<List<CategorySeriesSummary>, String>((ref, category) {
      switch (category) {
        case 'collected':
          return ref.watch(collectedSeriesProvider.future);
        case 'read':
          return ref.watch(readSeriesProvider.future);
        case 'wishlist':
          return ref.watch(wishlistSeriesProvider.future);
        case 'unread':
          return ref.watch(unreadSeriesProvider.future);
        case 'unrated':
          return ref.watch(unratedSeriesProvider.future);
        default:
          return Future.value(<CategorySeriesSummary>[]);
      }
    });
