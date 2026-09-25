import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
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
      final db = ref.watch(driftDatabaseProvider);
      final engine = ref.watch(collectionAnalyticsEngineProvider);
      final controller = StreamController<LibraryBasicStats>();
      final debounced = DebouncedWorker();

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

      int totalOwned = 0;
      int totalRead = 0;
      int readsInPeriod = 0;
      double averageRating = 0;
      ({String name, int yearBegan, int count})? mostReadSeries;
      int streakDays = 0;
      int wishlistCount = 0;
      int subscriptionsCount = 0;
      int pullsInPeriod = 0;

      void emitStats() {
        if (controller.isClosed) return;
        final readPercent = totalOwned == 0
            ? 0.0
            : ((totalRead / totalOwned) * 100).toDouble();
        controller.add(
          LibraryBasicStats(
            totalOwned: totalOwned,
            readPercent: readPercent,
            wishlistCount: wishlistCount,
            subscriptionsCount: subscriptionsCount,
            pullsInPeriod: pullsInPeriod,
            readsInPeriod: readsInPeriod,
            streakDays: streakDays,
            averageRating: averageRating,
            mostReadSeries: mostReadSeries?.name,
            mostReadSeriesYear: mostReadSeries?.yearBegan,
            filter: filter,
          ),
        );
      }

      final streamSubscriptions = <StreamSubscription>[];

      streamSubscriptions.add(
        db.libraryItemDao.watchOwnedCount().listen((count) {
          totalOwned = count;
          debounced.schedule(emitStats);
        }),
      );

      streamSubscriptions.add(
        db.libraryItemDao.watchReadsCount().listen((count) {
          totalRead = count;
          debounced.schedule(emitStats);
        }),
      );

      streamSubscriptions.add(
        db.libraryItemDao
            .watchReadsCount(
              startDate: startDate?.toUtc().toIso8601String(),
            )
            .listen((count) {
              readsInPeriod = count;
              debounced.schedule(emitStats);
            }),
      );

      streamSubscriptions.add(
        db.libraryItemDao.watchAverageRating().listen((rating) {
          averageRating = rating;
          debounced.schedule(emitStats);
        }),
      );

      streamSubscriptions.add(
        db.libraryItemDao.watchMostReadSeries().listen((series) {
          mostReadSeries = series;
          debounced.schedule(emitStats);
        }),
      );

      streamSubscriptions.add(
        engine.watchReadingStreak().listen((streak) {
          streakDays = streak.currentDays;
          debounced.schedule(emitStats);
        }),
      );

      streamSubscriptions.add(
        db.wishlistDao.watchAll().map((items) => items.length).listen((count) {
          wishlistCount = count;
          debounced.schedule(emitStats);
        }),
      );

      Future<void> fetchAsyncData() async {
        try {
          final subs = await ref.read(activeSubscriptionsProvider.future);
          subscriptionsCount = subs.length;
        } catch (_) {
          subscriptionsCount = 0;
        }
        try {
          pullsInPeriod = (await pullRepository.listEntries(
            fromDate: startDate,
            toDate: endDate,
            limit: 10000,
          )).length;
        } catch (_) {
          pullsInPeriod = 0;
        }
        debounced.schedule(emitStats);
      }

      fetchAsyncData();

      ref.onDispose(() {
        for (final sub in streamSubscriptions) {
          sub.cancel();
        }
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });

final libraryReadingTrendsProvider = StreamProvider.autoDispose
    .family<List<ReadingTrendPoint>, LibraryFilter>((ref, filter) {
      final db = ref.watch(driftDatabaseProvider);
      final controller = StreamController<List<ReadingTrendPoint>>();
      final debounced = DebouncedWorker();

      StreamSubscription<List<DateTime>>? sub;

      void computeTrends(List<DateTime> readDates) {
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

        if (!controller.isClosed) {
          controller.add(
            _computeReadingTrends(readDates, filter, now, startDate),
          );
        }
      }

      sub = db.libraryItemDao.watchAllReadDates().listen((dates) {
        debounced.schedule(() => computeTrends(dates));
      });

      ref.onDispose(() {
        sub?.cancel();
        debounced.cancel();
        controller.close();
      });

      return controller.stream;
    });

final librarySpendingTrendsProvider = StreamProvider.autoDispose
    .family<List<SpendingTrendPoint>, LibraryFilter>((ref, filter) {
      final db = ref.watch(driftDatabaseProvider);
      final controller = StreamController<List<SpendingTrendPoint>>();
      final debounced = DebouncedWorker();

      final now = DateTime.now().toLocal();
      DateTime? startDate;
      DateTime? endDate;
      String groupBy;

      switch (filter) {
        case LibraryFilter.week:
          startDate = _atStartOfWeek(now);
          endDate = startDate.add(const Duration(days: 7));
          groupBy = "day";
          break;
        case LibraryFilter.month:
          startDate = _atStartOfMonth(now);
          endDate = DateTime(startDate.year, startDate.month + 1);
          groupBy = "day";
          break;
        case LibraryFilter.year:
          startDate = _atStartOfYear(now);
          endDate = DateTime(startDate.year + 1);
          groupBy = "month";
          break;
        case LibraryFilter.allTime:
          final start = DateTime(now.year, now.month - 5, 1);
          startDate = start;
          endDate = DateTime(now.year, now.month + 1);
          groupBy = "month";
          break;
      }

      final startDateIso = startDate.toUtc().toIso8601String();
      final endDateIso = endDate.toUtc().toIso8601String();

      StreamSubscription<List<({String label, double amount, DateTime date})>>?
      sub;

      if (groupBy == "day") {
        sub = db.libraryItemDao
            .watchSpendingTrendsByDay(startDateIso, endDateIso)
            .listen((data) {
              debounced.schedule(() {
                if (!controller.isClosed) {
                  controller.add(
                    data
                        .map(
                          (d) => SpendingTrendPoint(
                            label: d.label,
                            amount: d.amount,
                            date: d.date,
                          ),
                        )
                        .toList(),
                  );
                }
              });
            });
      } else {
        sub = db.libraryItemDao
            .watchSpendingTrendsByMonth(
              startDate.year,
              startMonth: startDate.month,
              endMonth: endDate.month,
            )
            .listen((data) {
              debounced.schedule(() {
                if (!controller.isClosed) {
                  controller.add(
                    data
                        .map(
                          (d) => SpendingTrendPoint(
                            label: d.label,
                            amount: d.amount,
                            date: d.date,
                          ),
                        )
                        .toList(),
                  );
                }
              });
            });
      }

      ref.onDispose(() {
        sub?.cancel();
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
