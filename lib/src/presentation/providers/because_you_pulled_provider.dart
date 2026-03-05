import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/perf/performance_metrics.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/home_content_cache.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';

Set<String> _seriesTokens(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 4)
      .toSet();
}

double _scoreIssue(
  IssueList issue, {
  required Set<int> pulledSeriesIds,
  required Set<String> pulledPublishers,
  required Set<String> pulledTokens,
}) {
  final series = issue.series;
  if (series == null) return 0;

  var score = 0.0;
  if (series.id != null && pulledSeriesIds.contains(series.id!)) {
    score += 6;
  }
  final publisher = series.publisherName?.trim().toLowerCase();
  if (publisher != null &&
      publisher.isNotEmpty &&
      pulledPublishers.contains(publisher)) {
    score += 4;
  }
  final overlap = _seriesTokens(series.name).intersection(pulledTokens).length;
  score += overlap.clamp(0, 3).toDouble();
  return score;
}

Future<List<IssueList>> _computeBecauseYouPulledIssues(Ref ref) async {
  final weeklyIssues = await ref.watch(currentWeeklyReleasesProvider.future);
  final pulledIssues = await ref.watch(currentWeekPullsProvider.future);
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);

  if (pulledIssues.isEmpty) return const [];

  final pulledIssueIds = pulledIssues
      .map((issue) => issue.id)
      .whereType<int>()
      .toSet();
  final ownedIssueIds = libraryItems
      .where((item) => item.quantityOwned > 0)
      .map((item) => item.metronIssueId)
      .toSet();
  final pulledSeriesIds = pulledIssues
      .map((issue) => issue.series?.id)
      .whereType<int>()
      .toSet();
  final pulledPublishers = pulledIssues
      .map((issue) => issue.series?.publisherName?.trim().toLowerCase())
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toSet();
  final pulledTokens = pulledIssues
      .map((issue) => issue.series?.name)
      .whereType<String>()
      .expand(_seriesTokens)
      .toSet();

  final candidates = weeklyIssues.where((issue) {
    final issueId = issue.id;
    final series = issue.series;
    if (issueId == null || series == null) return false;
    if (pulledIssueIds.contains(issueId) || ownedIssueIds.contains(issueId)) {
      return false;
    }
    return true;
  }).toList();

  candidates.sort((a, b) {
    final aScore = _scoreIssue(
      a,
      pulledSeriesIds: pulledSeriesIds,
      pulledPublishers: pulledPublishers,
      pulledTokens: pulledTokens,
    );
    final bScore = _scoreIssue(
      b,
      pulledSeriesIds: pulledSeriesIds,
      pulledPublishers: pulledPublishers,
      pulledTokens: pulledTokens,
    );
    return bScore.compareTo(aScore);
  });

  return candidates.take(10).toList();
}

final becauseYouPulledIssuesProvider = FutureProvider<List<IssueList>>((
  ref,
) async {
  final metrics = AppPerformanceMetrics.instance;
  final cache = ref.read(homeContentCacheProvider);
  DateTime? cachedAt;
  var cached = const <IssueList>[];
  try {
    cachedAt = await cache.getCachedAt(homeBecauseYouPulledMetaKey);
    final cachedJson = await cache.readJsonList(homeBecauseYouPulledCacheKey);
    cached =
        cachedJson?.map(issueListFromJson).whereType<IssueList>().toList() ??
        const <IssueList>[];
  } catch (_) {}
  final hasFreshCache =
      cachedAt != null &&
      HomeCachePolicies.becauseYouPulled.isFresh(cachedAt, DateTime.now()) &&
      cached.isNotEmpty;

  if (hasFreshCache) {
    metrics.recordCacheHit(homeBecauseYouPulledMetaKey);
    return cached;
  }
  metrics.recordCacheMiss(homeBecauseYouPulledMetaKey);

  try {
    final fresh = await metrics.trackProvider(
      'becauseYouPulledIssuesProvider',
      () => _computeBecauseYouPulledIssues(ref),
    );
    try {
      await cache.writeJsonList(
        homeBecauseYouPulledCacheKey,
        fresh.map(issueListToJson).toList(),
      );
      await cache.writeCachedAtNow(homeBecauseYouPulledMetaKey);
    } catch (_) {}
    return fresh;
  } catch (_) {
    return cached;
  }
});
