import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';

enum CategoryType { owned, read, wishlist }

List<LibraryItem> _filterByCategory(List<LibraryItem> items, CategoryType category) {
  switch (category) {
    case CategoryType.owned:
      return items
          .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
          .toList();
    case CategoryType.read:
      return items.where((item) => item.isRead).toList();
    case CategoryType.wishlist:
      return items
          .where((item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist)
          .toList();
  }
}

final categoryInsightsProvider = FutureProvider.autoDispose
    .family<ProfileInsights, CategoryType>((ref, category) async {
  ref.keepAlive();
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final collectionItems = await ref.watch(allCollectionItemsProvider.future);

  final filteredLibrary = _filterByCategory(libraryItems, category);
  final filteredCollection = collectionItems.where((item) {
    return filteredLibrary.any((lib) => lib.metronIssueId == item.issue?.id);
  }).toList();

  final totalOwned = filteredLibrary.fold<int>(
    0,
    (sum, item) => sum + item.quantityOwned,
  );

  final readCount = filteredLibrary.where((item) => item.isRead).length;
  final readPercent = filteredLibrary.isEmpty
      ? 0.0
      : ((readCount / filteredLibrary.length) * 100).toDouble();

  final wishlistCount = category == CategoryType.wishlist
      ? filteredLibrary.length
      : filteredLibrary
          .where(
            (item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist,
          )
          .length;

  final ratings = filteredLibrary
      .map((entry) => entry.rating)
      .whereType<int>()
      .toList();
  final averageRating = ratings.isEmpty
      ? 0.0
      : (ratings.reduce((a, b) => a + b) / ratings.length).toDouble();

  final readSeries = <String, int>{};
  final readSeriesYear = <String, int?>{};
  for (final item in filteredCollection.where((entry) => entry.isRead)) {
    final seriesName = item.issue?.series?.name.trim();
    if (seriesName == null || seriesName.isEmpty) continue;
    final yearBegan = item.issue?.series?.yearBegan;
    readSeries.update(seriesName, (value) => value + 1, ifAbsent: () => 1);
    if (!readSeriesYear.containsKey(seriesName)) {
      readSeriesYear[seriesName] = yearBegan;
    }
  }
  final mostReadSeriesEntry = readSeries.entries.isEmpty
      ? null
      : (readSeries.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first;
  final mostReadSeries = mostReadSeriesEntry?.key;
  final mostReadSeriesYear = mostReadSeriesEntry == null
      ? null
      : readSeriesYear[mostReadSeriesEntry.key];

  return ProfileInsights(
    totalOwned: totalOwned,
    readPercent: readPercent,
    wishlistCount: wishlistCount,
    subscriptionsCount: 0,
    pullsInPeriod: 0,
    readsInPeriod: readCount,
    topPublishers: <MapEntry<String, int>>[],
    topCharacters: <EntityStat>[],
    allCharacters: <EntityStat>[],
    topCreators: <EntityStat>[],
    allCreators: <EntityStat>[],
    streakDays: 0,
    averageRating: averageRating,
    mostReadSeries: mostReadSeries,
    mostReadSeriesYear: mostReadSeriesYear,
    readingTrends: <ReadingTrendPoint>[],
    recentlyFinished: <CollectionItem>[],
    filter: ProfileFilter.allTime,
  );
});
