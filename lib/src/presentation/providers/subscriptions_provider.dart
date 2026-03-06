import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/domain/entities/series_list_page.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

const _subscriptionsPageSize = 25;
const _subscriptionsCacheBoxName = 'subscriptions_cache_box';

String _subscriptionsPageKey(int page) => 'active_series:p$page';
String _subscriptionsPageMetaKey(int page) =>
    'subscriptions:active_series:p$page';

Future<void> invalidateSubscriptionsLocalCacheWithHive(
  HiveService hiveService,
) async {
  final cacheBox = await hiveService.openBox<dynamic>(
    _subscriptionsCacheBoxName,
  );
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  final cacheKeys = cacheBox.keys
      .whereType<String>()
      .where((key) => key.startsWith('active_series:'))
      .toList(growable: false);
  for (final key in cacheKeys) {
    await cacheBox.delete(key);
  }
  final metaKeys = metaBox.keys
      .whereType<String>()
      .where((key) => key.startsWith('subscriptions:active_series:'))
      .toList(growable: false);
  for (final key in metaKeys) {
    await metaBox.delete(key);
  }
}

Future<void> invalidateSubscriptionsLocalCache(Ref ref) {
  return invalidateSubscriptionsLocalCacheWithHive(
    ref.read(hiveServiceProvider),
  );
}

void invalidateSubscriptionProviders(Ref ref) {
  ref.invalidate(activeSubscriptionsProvider);
  ref.invalidate(activeSubscriptionsCountProvider);
  ref.invalidate(subscribedSeriesListProvider);
  ref.invalidate(subscribedSeriesPageProvider);
}

Map<String, dynamic> _seriesListToJson(SeriesList series) {
  return {
    'id': series.id,
    'name': series.name,
    'year_began': series.yearBegan,
    'volume': series.volume,
    'issue_count': series.issueCount,
    'modified': series.modified?.toIso8601String(),
  };
}

SeriesList? _seriesListFromJson(Map<String, dynamic> json) {
  final id = (json['id'] as num?)?.toInt();
  final name = json['name'] as String?;
  if (id == null || name == null || name.trim().isEmpty) return null;

  return SeriesList(
    id: id,
    name: name,
    yearBegan: (json['year_began'] as num?)?.toInt(),
    volume: (json['volume'] as num?)?.toInt(),
    issueCount: (json['issue_count'] as num?)?.toInt(),
    modified: DateTime.tryParse(json['modified'] as String? ?? ''),
  );
}

SeriesList _seriesListFromSubscriptionFallback(int seriesId) {
  return SeriesList(id: seriesId, name: 'Series $seriesId');
}

Future<SeriesList> _loadSeriesListItem(Ref ref, int seriesId) async {
  final localDataSource = ref.read(metronLocalDataSourceProvider);
  final localDetails = await localDataSource.getSeriesDetails(seriesId);
  if (localDetails != null) {
    return SeriesList(
      id: localDetails.id,
      name: localDetails.name,
      yearBegan: localDetails.yearBegan,
      volume: localDetails.volume,
      issueCount: localDetails.issueCount,
      modified: DateTime.tryParse(localDetails.modified ?? ''),
    );
  }

  final remoteDetails = await ref
      .read(metronRepositoryProvider)
      .getSeriesDetails(seriesId);
  return SeriesList(
    id: remoteDetails.id,
    name: remoteDetails.name,
    yearBegan: remoteDetails.yearBegan,
    volume: remoteDetails.volume,
    issueCount: remoteDetails.issueCount,
    modified: remoteDetails.modified,
  );
}

Future<SeriesListPage> _loadSubscribedSeriesPage(Ref ref, int page) async {
  final safePage = page < 1 ? 1 : page;
  final offset = (safePage - 1) * _subscriptionsPageSize;
  final hiveService = ref.read(hiveServiceProvider);
  final cacheBox = await hiveService.openBox<dynamic>(
    _subscriptionsCacheBoxName,
  );
  final metaBox = await hiveService.openBox<int>('cache_meta_box');
  final cacheKey = _subscriptionsPageKey(safePage);
  final metaKey = _subscriptionsPageMetaKey(safePage);
  final cachedAtEpoch = metaBox.get(metaKey);
  final cachedAt = cachedAtEpoch == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(cachedAtEpoch);
  final cachedRaw = cacheBox.get(cacheKey);
  final cachedMap = cachedRaw is Map ? cachedRaw.cast<String, dynamic>() : null;
  final cachedSeries =
      ((cachedMap?['results'] as List?)
          ?.whereType<Map>()
          .map((item) => _seriesListFromJson(item.cast<String, dynamic>()))
          .whereType<SeriesList>()
          .toList()) ??
      <SeriesList>[];
  final cachedHasNext = cachedMap?['has_next'] as bool? ?? false;
  final hasFreshCache =
      cachedAt != null &&
      SupabaseCachePolicies.subscriptions.isFresh(cachedAt, DateTime.now());
  if (hasFreshCache) {
    AppPerformanceMetrics.instance.recordCacheHit(metaKey);
    return SeriesListPage(
      count: cachedHasNext
          ? (safePage * _subscriptionsPageSize) + 1
          : offset + cachedSeries.length,
      currentPage: safePage,
      previous: safePage > 1
          ? 'app://subscriptions?page=${safePage - 1}'
          : null,
      next: cachedHasNext ? 'app://subscriptions?page=${safePage + 1}' : null,
      results: cachedSeries,
    );
  }
  AppPerformanceMetrics.instance.recordCacheMiss(metaKey);

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
    final seriesList = await Future.wait(
      pagedSubscriptions.map((subscription) async {
        final seriesId = subscription.metronSeriesId;
        try {
          return await _loadSeriesListItem(ref, seriesId);
        } catch (_) {
          return _seriesListFromSubscriptionFallback(seriesId);
        }
      }),
    );

    await cacheBox.put(cacheKey, {
      'results': seriesList.map(_seriesListToJson).toList(),
      'has_next': hasNext,
    });
    await metaBox.put(metaKey, DateTime.now().millisecondsSinceEpoch);

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
  } catch (_) {
    if (cachedSeries.isNotEmpty || safePage == 1) {
      return SeriesListPage(
        count: cachedHasNext
            ? (safePage * _subscriptionsPageSize) + 1
            : offset + cachedSeries.length,
        currentPage: safePage,
        previous: safePage > 1
            ? 'app://subscriptions?page=${safePage - 1}'
            : null,
        next: cachedHasNext ? 'app://subscriptions?page=${safePage + 1}' : null,
        results: cachedSeries,
      );
    }
    rethrow;
  }
}

final activeSubscriptionsProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.listSubscriptions(limit: 500);
});

final activeSubscriptionsCountProvider = Provider<int>((ref) {
  final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) => subscriptions.length,
    orElse: () => 0,
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
