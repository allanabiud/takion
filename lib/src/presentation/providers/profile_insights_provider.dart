import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';

class MonthlyReadPoint {
  const MonthlyReadPoint({required this.label, required this.count});

  final String label;
  final int count;
}

class ProfileInsights {
  const ProfileInsights({
    required this.totalOwned,
    required this.readPercent,
    required this.wishlistCount,
    required this.subscriptionsCount,
    required this.pullsThisMonth,
    required this.topPublishers,
    required this.streakDays,
    required this.averageRating,
    required this.mostReadSeries,
    required this.monthlyReads,
    required this.recentlyFinished,
  });

  final int totalOwned;
  final double readPercent;
  final int wishlistCount;
  final int subscriptionsCount;
  final int pullsThisMonth;
  final List<String> topPublishers;
  final int streakDays;
  final double averageRating;
  final String? mostReadSeries;
  final List<MonthlyReadPoint> monthlyReads;
  final List<CollectionItem> recentlyFinished;
}

DateTime _atStartOfMonth(DateTime date) => DateTime(date.year, date.month);

int _streakDays(List<DateTime> readDates) {
  if (readDates.isEmpty) return 0;
  final sorted =
      readDates
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
  var streak = 1;
  for (var i = 1; i < sorted.length; i++) {
    final expected = sorted[i - 1].subtract(const Duration(days: 1));
    if (sorted[i] == expected) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

final profileInsightsProvider = FutureProvider.autoDispose<ProfileInsights>((
  ref,
) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  final collectionItems = await ref.watch(allCollectionItemsProvider.future);
  final subscriptions = await ref.watch(activeSubscriptionsProvider.future);
  final pullRepository = ref.watch(pullListRepositoryProvider);
  final catalogRepository = ref.watch(catalogRepositoryProvider);

  final owned = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
      .toList();
  final readOwned = owned.where((item) => item.isRead).toList();
  final totalOwned = owned.fold<int>(
    0,
    (sum, item) => sum + item.quantityOwned,
  );
  final readPercent = owned.isEmpty
      ? 0.0
      : ((readOwned.length / owned.length) * 100).toDouble();
  final wishlistCount = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist)
      .length;

  final ratings = readOwned
      .map((entry) => entry.rating)
      .whereType<int>()
      .toList();
  final averageRating = ratings.isEmpty
      ? 0.0
      : (ratings.reduce((a, b) => a + b) / ratings.length).toDouble();

  final readSeries = <String, int>{};
  for (final item in collectionItems.where((entry) => entry.isRead)) {
    final seriesName = item.issue?.series?.name.trim();
    if (seriesName == null || seriesName.isEmpty) continue;
    readSeries.update(seriesName, (value) => value + 1, ifAbsent: () => 1);
  }
  final mostReadSeries = readSeries.entries.isEmpty
      ? null
      : (readSeries.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

  final monthStart = _atStartOfMonth(DateTime.now());
  final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
  final pullsThisMonth = (await pullRepository.listEntries(
    fromDate: monthStart,
    toDate: monthEnd,
    limit: 500,
  )).length;

  final readDates = readOwned
      .map((item) => item.firstReadAt)
      .whereType<DateTime>()
      .toList();

  final monthlyReads = <MonthlyReadPoint>[];
  final now = DateTime.now();
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final count = readDates
        .where((date) => !date.isBefore(month) && date.isBefore(nextMonth))
        .length;
    monthlyReads.add(
      MonthlyReadPoint(label: DateFormat.MMM().format(month), count: count),
    );
  }

  final readDateByIssueId = {
    for (final item in readOwned)
      if (item.firstReadAt != null) item.metronIssueId: item.firstReadAt!,
  };
  final recentlyFinished =
      collectionItems
          .where(
            (item) =>
                item.issue != null &&
                readDateByIssueId.containsKey(item.issue!.id),
          )
          .toList()
        ..sort((a, b) {
          final aDate = readDateByIssueId[a.issue!.id]!;
          final bDate = readDateByIssueId[b.issue!.id]!;
          return bDate.compareTo(aDate);
        });

  final topPublisherCounts = <String, int>{};
  final ownedIssueIds = owned
      .map((item) => item.metronIssueId)
      .toSet()
      .toList();
  final sampleIssueIds = ownedIssueIds.take(30).toList();
  for (final issueId in sampleIssueIds) {
    try {
      final details = await catalogRepository.getIssueDetails(issueId);
      final name = details.publisher?.name.trim();
      if (name == null || name.isEmpty) continue;
      topPublisherCounts.update(name, (value) => value + 1, ifAbsent: () => 1);
    } catch (_) {
      // ignore single-item fetch failures in profile aggregate view
    }
  }
  final topPublishers =
      (topPublisherCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(3)
          .map((entry) => entry.key)
          .toList();

  return ProfileInsights(
    totalOwned: totalOwned,
    readPercent: readPercent,
    wishlistCount: wishlistCount,
    subscriptionsCount: subscriptions.length,
    pullsThisMonth: pullsThisMonth,
    topPublishers: topPublishers,
    streakDays: _streakDays(readDates),
    averageRating: averageRating,
    mostReadSeries: mostReadSeries,
    monthlyReads: monthlyReads,
    recentlyFinished: recentlyFinished.take(5).toList(),
  );
});
