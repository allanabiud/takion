import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

List<CategorySeriesSummary> _groupBySeries(
  List<CollectionItem> items,
  Map<int, int> issueToSeriesId,
) {
  final groups = <int, List<CollectionItem>>{};
  for (final item in items) {
    final seriesId = issueToSeriesId[item.issue?.id];
    if (seriesId == null) continue;
    groups.putIfAbsent(seriesId, () => []).add(item);
  }

  return groups.entries.map((entry) {
    final firstItem = entry.value.first;
    final series = firstItem.issue?.series;
    return CategorySeriesSummary(
      seriesId: entry.key,
      seriesName: series?.name.isNotEmpty == true ? series!.name : 'Unknown',
      volume: series?.volume,
      yearBegan: series?.yearBegan,
      coverImage: firstItem.issue?.image,
      categoryCount: entry.value.length,
      items: entry.value,
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

final collectedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final collected = collectionItems
          .where((item) => item.quantity > 0)
          .toList();
      return _groupBySeries(collected, issueToSeriesId);
    });

final readSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(true).future,
      );
      return _groupBySeries(items, issueToSeriesId);
    });

final wishlistSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(wishlistCollectionItemsProvider.future);
      return _groupBySeries(items, issueToSeriesId);
    });

final unreadSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(
        collectionItemsByReadStatusProvider(false).future,
      );
      return _groupBySeries(items, issueToSeriesId);
    });

final unratedSeriesProvider =
    FutureProvider.autoDispose<List<CategorySeriesSummary>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final issueToSeriesId = _buildIssueToSeriesId(libraryItems);
      final items = await ref.watch(unratedCollectionItemsProvider.future);
      return _groupBySeries(items, issueToSeriesId);
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
