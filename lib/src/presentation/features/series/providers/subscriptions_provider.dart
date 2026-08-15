import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/constants/pagination.dart";

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
  _loadSubscribedSeriesPage,
);

class SubscriptionSeriesCardData {
  const SubscriptionSeriesCardData({
    this.mostRecentIssueImage,
    this.nextIssueDate,
    this.seriesName,
  });

  final String? mostRecentIssueImage;
  final DateTime? nextIssueDate;
  final String? seriesName;
}

final seriesStreamProvider = StreamProvider.autoDispose
    .family<SeriesList?, int>((ref, seriesId) {
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      return localCatalog.watchSeries(seriesId);
    });

/// Reads a subscription's cover, series name, and next release purely from the local cache (no network).
final subscriptionSeriesCardProvider = StreamProvider
    .family<SubscriptionSeriesCardData?, int>((ref, seriesId) {
      ref.keepAlive();
      final localCatalog = ref.watch(localCatalogRepositoryProvider);
      final seriesAsync = ref.watch(seriesStreamProvider(seriesId));
      final seriesName = seriesAsync.value?.name;

      return localCatalog.watchIssuesBySeries(seriesId).map((issues) {
        String? mostRecentImage;
        String? nextIssueImage;
        DateTime? nextIssueDate;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (final issue in issues) {
          final imageUrl = issue.imageUrl?.trim();
          final hasImage = imageUrl != null && imageUrl.isNotEmpty;
          if (mostRecentImage == null && hasImage) {
            mostRecentImage = issue.imageUrl;
          }

          final releaseDate = issue.storeDate ?? issue.coverDate;
          if (releaseDate == null) continue;
          final day = DateTime(
            releaseDate.year,
            releaseDate.month,
            releaseDate.day,
          );
          if (day.isBefore(today)) continue;
          if (nextIssueDate != null && !day.isBefore(nextIssueDate)) continue;
          nextIssueDate = day;
          nextIssueImage = hasImage ? issue.imageUrl : null;
        }

        return SubscriptionSeriesCardData(
          mostRecentIssueImage: nextIssueImage ?? mostRecentImage,
          nextIssueDate: nextIssueDate,
          seriesName: seriesName,
        );
      });
    });

Future<SeriesList> _loadSeriesListItem(Ref ref, int seriesId) async {
  final localCatalog = ref.read(localCatalogRepositoryProvider);
  final localSeries = await localCatalog.getSeries(seriesId);
  if (localSeries != null) {
    return localSeries;
  }

  return _seriesListFromSubscriptionFallback(seriesId);
}

SeriesList _seriesListFromSubscriptionFallback(int seriesId) {
  return SeriesList(
    id: seriesId,
    name: "Series $seriesId",
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
            "Failed to load subscription series list item $seriesId",
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
          ? "app://subscriptions?page=${safePage - 1}"
          : null,
      next: hasNext ? "app://subscriptions?page=${safePage + 1}" : null,
      results: seriesList,
    );
  } catch (e) {
    AppLogger.error("Failed to load subscriptions page", error: e);
    rethrow;
  }
}
