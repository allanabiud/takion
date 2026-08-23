import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_items_serialization.dart";
import "package:takion/src/presentation/features/library/providers/stats_debounce.dart";

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

List<ReadingTrendPoint> _computeReadingTrends(
  List<DateTime> readDates,
  LibraryFilter filter,
  DateTime now,
  DateTime? startDate,
) {
  final trends = <ReadingTrendPoint>[];
  if (filter == LibraryFilter.week && startDate != null) {
    for (var i = 0; i < 7; i++) {
      final day = startDate.add(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));
      final count = readDates
          .where((date) => !date.isBefore(day) && date.isBefore(nextDay))
          .length;
      trends.add(
        ReadingTrendPoint(
          label: DateFormatter.weekdayAbbrev(day),
          count: count,
          date: day,
        ),
      );
    }
  } else if (filter == LibraryFilter.month && startDate != null) {
    final daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
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
      trends.add(
        ReadingTrendPoint(
          label: shouldShowLabel ? "$i" : "",
          count: count,
          date: day,
        ),
      );
    }
  } else if (filter == LibraryFilter.year && startDate != null) {
    for (var i = 1; i <= 12; i++) {
      final month = DateTime(startDate.year, i, 1);
      final nextMonth = DateTime(startDate.year, i + 1, 1);
      final count = readDates
          .where((date) => !date.isBefore(month) && date.isBefore(nextMonth))
          .length;
      trends.add(
        ReadingTrendPoint(
          label: DateFormatter.monthAbbrev(month),
          count: count,
          date: month,
        ),
      );
    }
  } else if (filter == LibraryFilter.allTime) {
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(month.year, month.month + 1, 1);
      final count = readDates
          .where((date) => !date.isBefore(month) && date.isBefore(nextMonth))
          .length;
      trends.add(
        ReadingTrendPoint(
          label: DateFormatter.monthAbbrev(month),
          count: count,
          date: month,
        ),
      );
    }
  }
  return trends;
}

final libraryBasicStatsProvider = StreamProvider.autoDispose
    .family<LibraryBasicStats, LibraryFilter>((ref, filter) {
      final pullRepository = ref.watch(pullListRepositoryProvider);
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final controller = StreamController<LibraryBasicStats>();
      final debounced = DebouncedWorker();

      Future<void> emitStats(List<LibraryItem> libraryItems) async {
        try {
          // Fall back to empty subscriptions if provider is unavailable.
          List<SeriesSubscription> subscriptions;
          try {
            subscriptions = await ref.read(activeSubscriptionsProvider.future);
          } catch (_) {
            subscriptions = const [];
          }

          final now = DateTime.now().toLocal();
          DateTime? startDate;
          DateTime? endDate;

          switch (filter) {
            case LibraryFilter.week:
              startDate = _atStartOfWeek(now);
              endDate = startDate.add(const Duration(days: 6));
              break;
            case LibraryFilter.month:
              startDate = _atStartOfMonth(now);
              endDate = DateTime(startDate.year, startDate.month + 1, 0);
              break;
            case LibraryFilter.year:
              startDate = _atStartOfYear(now);
              endDate = DateTime(startDate.year, 12, 31);
              break;
            case LibraryFilter.allTime:
              startDate = null;
              endDate = null;
              break;
          }

          final owned = libraryItems
              .where(
                (item) => item.ownershipStatus == LibraryOwnershipStatus.owned,
              )
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
                (item) =>
                    item.ownershipStatus == LibraryOwnershipStatus.wishlist,
              )
              .length;

          final readsInPeriod = allRead.where((item) {
            final readAt = item.firstReadAt?.toLocal();
            if (readAt == null) return false;
            if (startDate == null) return true;
            return !readAt.isBefore(startDate);
          }).length;

          int pullsInPeriod;
          try {
            pullsInPeriod = (await pullRepository.listEntries(
              fromDate: startDate,
              toDate: endDate,
              limit: 10000,
            )).length;
          } catch (_) {
            pullsInPeriod = 0;
          }

          final ratings = allRead
              .map((entry) => entry.rating)
              .whereType<int>()
              .toList();
          final averageRating = ratings.isEmpty
              ? 0.0
              : (ratings.reduce((a, b) => a + b) / ratings.length).toDouble();

          final readSeriesIds = allRead
              .map((item) => item.metronSeriesId)
              .where((id) => id > 0)
              .toSet()
              .toList();

          Map<int, SeriesList> seriesMap;
          try {
            seriesMap = await localCatalog.getSeriesByIds(readSeriesIds);
          } catch (_) {
            seriesMap = const {};
          }

          final readSeries = <String, int>{};
          final readSeriesYear = <String, int?>{};
          for (final item in allRead) {
            final series = seriesMap[item.metronSeriesId];
            final seriesName = series?.name.trim();
            if (seriesName == null || seriesName.isEmpty) continue;
            readSeries.update(
              seriesName,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
            if (!readSeriesYear.containsKey(seriesName)) {
              readSeriesYear[seriesName] = series?.yearBegan;
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

          final readDates = allRead
              .map((item) => item.firstReadAt)
              .whereType<DateTime>()
              .map((date) => date.toLocal())
              .toList();

          if (!controller.isClosed) {
            controller.add(
              LibraryBasicStats(
                totalOwned: totalOwned,
                readPercent: readPercent,
                wishlistCount: wishlistCount,
                subscriptionsCount: subscriptions.length,
                pullsInPeriod: pullsInPeriod,
                readsInPeriod: readsInPeriod,
                streakDays: _streakDays(readDates),
                averageRating: averageRating,
                mostReadSeries: mostReadSeries,
                mostReadSeriesYear: mostReadSeriesYear,
                filter: filter,
              ),
            );
          }
        } catch (e) {
          // Emit zero stats on error so cards remain visible.
          if (!controller.isClosed) {
            controller.add(LibraryBasicStats.zero(filter));
          }
        }
      }

      ref.listen<AsyncValue<List<LibraryItem>>>(allLibraryItemsProvider, (
        _,
        next,
      ) {
        next.whenOrNull(
          data: (libraryItems) {
            // Debounce rapid-fire emissions from bulk operations.
            debounced.schedule(() => emitStats(libraryItems));
          },
        );
      });

      ref
          .read(allLibraryItemsProvider)
          .whenOrNull(
            data: (libraryItems) {
              emitStats(libraryItems);
            },
          );

      ref.onDispose(() {
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });

final libraryReadingTrendsProvider = StreamProvider.autoDispose
    .family<List<ReadingTrendPoint>, LibraryFilter>((ref, filter) {
      final controller = StreamController<List<ReadingTrendPoint>>();
      final debounced = DebouncedWorker();

      void computeTrends(List<LibraryItem> libraryItems) {
        final now = DateTime.now().toLocal();
        DateTime? startDate;

        switch (filter) {
          case LibraryFilter.week:
            startDate = _atStartOfWeek(now);
            break;
          case LibraryFilter.month:
            startDate = _atStartOfMonth(now);
            break;
          case LibraryFilter.year:
            startDate = _atStartOfYear(now);
            break;
          case LibraryFilter.allTime:
            startDate = null;
            break;
        }

        final allRead = libraryItems.where((item) => item.isRead).toList();
        final readDates = allRead
            .map((item) => item.firstReadAt)
            .whereType<DateTime>()
            .map((date) => date.toLocal())
            .toList();

        if (!controller.isClosed) {
          controller.add(
            _computeReadingTrends(readDates, filter, now, startDate),
          );
        }
      }

      ref.listen<AsyncValue<List<LibraryItem>>>(allLibraryItemsProvider, (
        _,
        next,
      ) {
        next.whenOrNull(
          data: (libraryItems) {
            debounced.schedule(() => computeTrends(libraryItems));
          },
        );
      });

      ref
          .read(allLibraryItemsProvider)
          .whenOrNull(
            data: (libraryItems) {
              computeTrends(libraryItems);
            },
          );

      ref.onDispose(() {
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });

final libraryRecentlyFinishedProvider = StreamProvider.autoDispose
    .family<List<CollectionItem>, LibraryFilter>((ref, filter) {
      final controller = StreamController<List<CollectionItem>>();
      final debounced = DebouncedWorker();

      Future<void> computeRecent(List<LibraryItem> libraryItems) async {
        try {
          final allReadWithDate =
              libraryItems
                  .where((item) => item.isRead && item.firstReadAt != null)
                  .toList()
                ..sort((a, b) => b.firstReadAt!.compareTo(a.firstReadAt!));

          final recentItems = allReadWithDate.take(5).toList();
          final enriched = await hydrateLibraryItems(ref, recentItems);

          if (!controller.isClosed) {
            controller.add(enriched);
          }
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      }

      ref.listen<AsyncValue<List<LibraryItem>>>(allLibraryItemsProvider, (
        _,
        next,
      ) {
        next.whenOrNull(
          data: (libraryItems) {
            debounced.schedule(() => computeRecent(libraryItems));
          },
        );
      });

      ref
          .read(allLibraryItemsProvider)
          .whenOrNull(
            data: (libraryItems) {
              computeRecent(libraryItems);
            },
          );

      ref.onDispose(() {
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });
