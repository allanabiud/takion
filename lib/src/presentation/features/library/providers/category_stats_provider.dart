import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_insights_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

enum CategoryType { owned, read, wishlist }

List<LibraryItem> _filterByCategory(
  List<LibraryItem> items,
  CategoryType category,
) {
  switch (category) {
    case CategoryType.owned:
      return items
          .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
          .toList();
    case CategoryType.read:
      return items.where((item) => item.isRead).toList();
    case CategoryType.wishlist:
      return items
          .where(
            (item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist,
          )
          .toList();
  }
}

final categoryInsightsProvider = FutureProvider.autoDispose
    .family<LibraryInsights, CategoryType>((ref, category) async {
      ref.keepAlive();
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );

      final filteredLibrary = _filterByCategory(libraryItems, category);
      final filteredCollection = collectionItems.where((item) {
        return filteredLibrary.any(
          (lib) => lib.metronIssueId == item.issue?.id,
        );
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
                  (item) =>
                      item.ownershipStatus == LibraryOwnershipStatus.wishlist,
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

      final db = ref.watch(driftDatabaseProvider);
      final mapper = ref.watch(entityMapperProvider);

      final topPublisherCounts = <String, int>{};
      final characterCounts = <int, int>{};
      final characterNames = <int, String>{};
      final creatorCounts = <int, int>{};
      final creatorNames = <int, String>{};
      final insightIssueIds = filteredLibrary
          .map((item) => item.metronIssueId)
          .toSet();

      final cachedDetails = <IssueDetails>[];
      for (final issueId in insightIssueIds) {
        var issue = await db.metronEntityDao.getIssue(issueId);
        if (issue == null || !issue.isFullyHydrated) {
          try {
            await ref.read(metronRepositoryProvider).getIssueDetails(issueId);
            issue = await db.metronEntityDao.getIssue(issueId);
          } catch (_) {}
        }
        if (issue != null) {
          cachedDetails.add(await mapper.issueToEntity(issue));
        }
      }

      for (final details in cachedDetails) {
        final name = details.publisher?.name.trim();
        if (name != null && name.isNotEmpty) {
          topPublisherCounts.update(
            name,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
        for (final char in details.characters) {
          final charName = char.name.trim();
          if (charName.isEmpty) continue;
          characterCounts.update(
            char.id,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          characterNames[char.id] = charName;
        }
        final seenCreatorIds = <int>{};
        for (final credit in details.credits) {
          final creatorId = (credit.creatorId != null && credit.creatorId! > 0)
              ? credit.creatorId!
              : credit.id;
          if (creatorId <= 0 || !seenCreatorIds.add(creatorId)) {
            continue;
          }
          final rawName = credit.creator?.trim();
          if (rawName != null && rawName.isNotEmpty) {
            creatorNames[creatorId] = rawName;
          } else {
            final c = await db.metronEntityDao.getCreator(creatorId);
            final daoName = c?.name;
            creatorNames[creatorId] =
                (daoName != null && daoName.trim().isNotEmpty)
                ? daoName.trim()
                : 'Unknown';
          }
          creatorCounts.update(
            creatorId,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final topPublishers =
          (topPublisherCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .take(5)
              .toList();
      final allCharacters =
          characterCounts.entries
              .map(
                (e) => EntityStat(
                  id: e.key,
                  name: characterNames[e.key] ?? 'Unknown',
                  count: e.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));
      final topCharacters = allCharacters.take(5).toList();
      final allCreators =
          creatorCounts.entries
              .map(
                (e) => EntityStat(
                  id: e.key,
                  name: creatorNames[e.key] ?? 'Unknown',
                  count: e.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));
      final topCreators = allCreators.take(5).toList();

      return LibraryInsights(
        totalOwned: totalOwned,
        readPercent: readPercent,
        wishlistCount: wishlistCount,
        subscriptionsCount: 0,
        pullsInPeriod: 0,
        readsInPeriod: readCount,
        topPublishers: topPublishers,
        topCharacters: topCharacters,
        allCharacters: allCharacters,
        topCreators: topCreators,
        allCreators: allCreators,
        streakDays: 0,
        averageRating: averageRating,
        mostReadSeries: mostReadSeries,
        mostReadSeriesYear: mostReadSeriesYear,
        readingTrends: <ReadingTrendPoint>[],
        recentlyFinished: <CollectionItem>[],
        filter: LibraryFilter.allTime,
      );
    });
