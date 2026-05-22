import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';

enum ProfileFilter { week, month, year, allTime }

class ReadingTrendPoint {
  const ReadingTrendPoint({
    required this.label,
    required this.count,
    required this.date,
  });

  final String label;
  final int count;
  final DateTime date;
}

class ProfileInsights {
  const ProfileInsights({
    required this.totalOwned,
    required this.readPercent,
    required this.wishlistCount,
    required this.subscriptionsCount,
    required this.pullsInPeriod,
    required this.readsInPeriod,
    required this.topPublishers,
    required this.streakDays,
    required this.averageRating,
    required this.mostReadSeries,
    required this.readingTrends,
    required this.recentlyFinished,
    required this.filter,
  });

  final int totalOwned;
  final double readPercent;
  final int wishlistCount;
  final int subscriptionsCount;
  final int pullsInPeriod;
  final int readsInPeriod;
  final List<MapEntry<String, int>> topPublishers;
  final int streakDays;
  final double averageRating;
  final String? mostReadSeries;
  final List<ReadingTrendPoint> readingTrends;
  final List<CollectionItem> recentlyFinished;
  final ProfileFilter filter;
}

DateTime _atStartOfWeek(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day,
).subtract(Duration(days: date.weekday - 1));
DateTime _atStartOfMonth(DateTime date) => DateTime(date.year, date.month);
DateTime _atStartOfYear(DateTime date) => DateTime(date.year);

int _streakDays(List<DateTime> readDates) {
  if (readDates.isEmpty) return 0;
  final sorted =
      readDates
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (sorted.isEmpty || (today.difference(sorted[0]).inDays > 1)) {
    return 0;
  }

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

final profileInsightsProvider = FutureProvider.autoDispose
    .family<ProfileInsights, ProfileFilter>((ref, filter) async {
      final libraryItemsFuture = ref.watch(allLibraryItemsProvider.future);
      final collectionItemsFuture = ref.watch(
        allCollectionItemsProvider.future,
      );
      final subscriptionsFuture = ref.watch(activeSubscriptionsProvider.future);
      final pullRepository = ref.watch(pullListRepositoryProvider);
      final localDataSource = ref.watch(metronLocalDataSourceProvider);

      final libraryItems = await libraryItemsFuture;
      final collectionItems = await collectionItemsFuture;
      final subscriptions = await subscriptionsFuture;

      final now = DateTime.now().toLocal();
      DateTime? startDate;
      final endDate = now;

      switch (filter) {
        case ProfileFilter.week:
          startDate = _atStartOfWeek(now);
          break;
        case ProfileFilter.month:
          startDate = _atStartOfMonth(now);
          break;
        case ProfileFilter.year:
          startDate = _atStartOfYear(now);
          break;
        case ProfileFilter.allTime:
          startDate = null;
          break;
      }

      final owned = libraryItems
          .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
          .toList();
      final allRead = libraryItems.where((item) => item.isRead).toList();

      final totalOwned = owned.fold<int>(
        0,
        (sum, item) => sum + item.quantityOwned,
      );

      final readPercent = owned.isEmpty
          ? 0.0
          : ((allRead.length / owned.length) * 100).toDouble();

      final wishlistCount = libraryItems
          .where(
            (item) => item.ownershipStatus == LibraryOwnershipStatus.wishlist,
          )
          .length;

      final readsInPeriod = allRead.where((item) {
        final readAt = item.firstReadAt?.toLocal();
        if (readAt == null) return false;
        if (startDate == null) return true;
        return !readAt.isBefore(startDate);
      }).length;

      final pullsInPeriod = startDate == null
          ? owned.length
          : (await pullRepository.listEntries(
              fromDate: startDate,
              toDate: endDate,
              limit: 1000,
            )).length;

      final ratings = allRead
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

      final readDates = allRead
          .map((item) => item.firstReadAt)
          .whereType<DateTime>()
          .map((date) => date.toLocal())
          .toList();

      final readingTrends = <ReadingTrendPoint>[];
      if (filter == ProfileFilter.week && startDate != null) {
        for (var i = 0; i < 7; i++) {
          final day = startDate.add(Duration(days: i));
          final nextDay = day.add(const Duration(days: 1));
          final count = readDates
              .where((date) => !date.isBefore(day) && date.isBefore(nextDay))
              .length;
          readingTrends.add(
            ReadingTrendPoint(
              label: DateFormat.E().format(day),
              count: count,
              date: day,
            ),
          );
        }
      } else if (filter == ProfileFilter.month && startDate != null) {
        final daysInMonth = DateTime(
          startDate.year,
          startDate.month + 1,
          0,
        ).day;
        for (var i = 1; i <= daysInMonth; i++) {
          final day = DateTime(startDate.year, startDate.month, i);
          final nextDay = day.add(const Duration(days: 1));
          final count = readDates
              .where((date) => !date.isBefore(day) && date.isBefore(nextDay))
              .length;
          final isFirst = i == 1;
          final isLast = i == daysInMonth;
          final isEveryFifth = i % 5 == 0;
          final isPenultimateWhenLastIs31 = daysInMonth == 31 && i == 30;
          final shouldShowLabel =
              isFirst || isLast || (isEveryFifth && !isPenultimateWhenLastIs31);
          if (shouldShowLabel) {
            readingTrends.add(
              ReadingTrendPoint(label: '$i', count: count, date: day),
            );
          } else {
            readingTrends.add(
              ReadingTrendPoint(label: '', count: count, date: day),
            );
          }
        }
      } else if (filter == ProfileFilter.year && startDate != null) {
        for (var i = 1; i <= 12; i++) {
          final month = DateTime(startDate.year, i, 1);
          final nextMonth = DateTime(startDate.year, i + 1, 1);
          final count = readDates
              .where(
                (date) => !date.isBefore(month) && date.isBefore(nextMonth),
              )
              .length;
          readingTrends.add(
            ReadingTrendPoint(
              label: DateFormat.MMM().format(month),
              count: count,
              date: month,
            ),
          );
        }
      } else if (filter == ProfileFilter.allTime) {
        for (var i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final nextMonth = DateTime(month.year, month.month + 1, 1);
          final count = readDates
              .where(
                (date) => !date.isBefore(month) && date.isBefore(nextMonth),
              )
              .length;
          readingTrends.add(
            ReadingTrendPoint(
              label: DateFormat.MMM().format(month),
              count: count,
              date: month,
            ),
          );
        }
      }

      final readDateByIssueId = {
        for (final item in allRead)
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
      final insightIssueIds = (owned.map((item) => item.metronIssueId).toSet()
            ..addAll(allRead.map((item) => item.metronIssueId)))
          .toList();
      final sampleIssueIds = insightIssueIds.take(120).toList();
      final cachedDetails = await Future.wait(
        sampleIssueIds.map(localDataSource.getIssueDetails),
      );
      for (final details in cachedDetails) {
        final name = details?.publisher?.name.trim();
        if (name == null || name.isEmpty) continue;
        topPublisherCounts.update(
          name,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      final topPublishers =
          (topPublisherCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .take(5)
              .toList();

      return ProfileInsights(
        totalOwned: totalOwned,
        readPercent: readPercent,
        wishlistCount: wishlistCount,
        subscriptionsCount: subscriptions.length,
        pullsInPeriod: pullsInPeriod,
        readsInPeriod: readsInPeriod,
        topPublishers: topPublishers,
        streakDays: _streakDays(readDates),
        averageRating: averageRating,
        mostReadSeries: mostReadSeries,
        readingTrends: readingTrends,
        recentlyFinished: recentlyFinished.take(5).toList(),
        filter: filter,
      );
    });
