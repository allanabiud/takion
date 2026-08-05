import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/constants/pagination.dart';

const _subscriptionsPageSize = metronDefaultPageSize;

final activeSubscriptionsProvider =
    StreamProvider.autoDispose<List<SeriesSubscription>>((ref) {
      final dao = ref.watch(driftDatabaseProvider).subscriptionDao;
      return dao.watchActive().map(
        (rows) => rows.map((row) {
          return SeriesSubscription(
            id: row.id,
            userId: row.userId,
            metronSeriesId: row.metronSeriesId,
            isActive: row.isActive,
            autoAddToPullList: row.autoAddPull,
            subscribedAt: DateTime.parse(row.subscribedAt),
            createdAt: DateTime.parse(row.createdAt),
            updatedAt: DateTime.parse(row.updatedAt),
          );
        }).toList(),
      );
    });

final activeSubscriptionsCountProvider = Provider<int>((ref) {
  final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) => subscriptions.length,
    orElse: () => 0,
  );
});

final subscribedSeriesIdsSetProvider = Provider.autoDispose<Set<int>>((ref) {
  final activeAsync = ref.watch(activeSubscriptionsProvider);
  return activeAsync.maybeWhen(
    data: (subscriptions) => subscriptions.map((s) => s.metronSeriesId).toSet(),
    orElse: () => const <int>{},
  );
});

final subscribedSeriesListProvider =
    FutureProvider.autoDispose<List<SeriesList>>((ref) async {
      return ref
          .watch(subscribedSeriesPageProvider(1).future)
          .then((page) => page.results);
    });

final subscribedSeriesPageProvider = FutureProvider.family<SeriesListPage, int>(
  (ref, page) {
    return _loadSubscribedSeriesPage(ref, page);
  },
);

class SubscriptionSeriesCardData {
  const SubscriptionSeriesCardData({
    this.mostRecentIssueImage,
    this.nextIssueDate,
  });

  final String? mostRecentIssueImage;
  final DateTime? nextIssueDate;
}

/// Reads a subscription's cover and next release purely from the local cache (no network).
final subscriptionSeriesCardProvider = StreamProvider.autoDispose
    .family<SubscriptionSeriesCardData?, int>((ref, seriesId) {
      final dao = ref.watch(metronEntityDaoProvider);
      return dao.watchIssuesBySeries(seriesId).map((issues) {
        String? mostRecentImage;
        DateTime? nextIssueDate;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (final issue in issues) {
          if (mostRecentImage == null &&
              (issue.imageUrl?.trim().isNotEmpty ?? false)) {
            mostRecentImage = issue.imageUrl;
          }

          DateTime? releaseDate;
          if (issue.storeDate != null) {
            releaseDate = DateTime.tryParse(issue.storeDate!);
          }
          releaseDate ??= issue.coverDate != null
              ? DateTime.tryParse(issue.coverDate!)
              : null;
          if (releaseDate != null) {
            final day = DateTime(
              releaseDate.year,
              releaseDate.month,
              releaseDate.day,
            );
            if (!day.isBefore(today)) {
              if (nextIssueDate == null || day.isBefore(nextIssueDate)) {
                nextIssueDate = day;
              }
            }
          }
        }

        return SubscriptionSeriesCardData(
          mostRecentIssueImage: mostRecentImage,
          nextIssueDate: nextIssueDate,
        );
      });
    });

Future<SeriesList> _loadSeriesListItem(Ref ref, int seriesId) async {
  final db = ref.read(driftDatabaseProvider);
  final localSeries = await db.metronEntityDao.getSeries(seriesId);
  if (localSeries != null) {
    return SeriesList(
      id: localSeries.id,
      name: localSeries.name,
      yearBegan: localSeries.yearBegan,
      volume: localSeries.volume,
      issueCount: localSeries.issueCount,
      modified: localSeries.modified != null
          ? DateTime.tryParse(localSeries.modified!)
          : null,
    );
  }

  return _seriesListFromSubscriptionFallback(seriesId);
}

SeriesList _seriesListFromSubscriptionFallback(int seriesId) {
  return SeriesList(
    id: seriesId,
    name: 'Series $seriesId',
    yearBegan: 0,
    volume: 1,
  );
}

Future<SeriesListPage> _loadSubscribedSeriesPage(Ref ref, int page) async {
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _subscriptionsPageSize;

  ref.watch(activeSubscriptionsProvider);

  try {
    final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    final subscriptions = await subscriptionRepository.listSubscriptions(
      limit: _subscriptionsPageSize + 1,
      offset: offset,
    );
    final hasNext = subscriptions.length > _subscriptionsPageSize;
    final pagedSubscriptions = subscriptions
        .take(_subscriptionsPageSize)
        .toList();
    final results = List<SeriesList?>.filled(pagedSubscriptions.length, null);
    var cursor = 0;
    Future<void> worker() async {
      while (true) {
        final index = cursor;
        if (index >= pagedSubscriptions.length) return;
        cursor = index + 1;
        final seriesId = pagedSubscriptions[index].metronSeriesId;
        try {
          results[index] = await _loadSeriesListItem(ref, seriesId);
        } catch (e) {
          AppLogger.warning(
            'Failed to load subscription series list item $seriesId',
            error: e,
          );
          results[index] = _seriesListFromSubscriptionFallback(seriesId);
        }
      }
    }

    final workerCount = pagedSubscriptions.length < 4
        ? pagedSubscriptions.length
        : 4;
    if (workerCount > 0) {
      await Future.wait(List.generate(workerCount, (_) => worker()));
    }
    final seriesList = results.whereType<SeriesList>().toList(growable: false);

    return SeriesListPage(
      count: hasNext
          ? (safePage * _subscriptionsPageSize) + 1
          : offset + seriesList.length,
      currentPage: safePage,
      previous: safePage > 1
          ? 'app://subscriptions?page=${safePage - 1}'
          : null,
      next: hasNext ? 'app://subscriptions?page=${safePage + 1}' : null,
      results: seriesList,
    );
  } catch (e) {
    AppLogger.error('Failed to load subscriptions page', error: e);
    rethrow;
  }
}
