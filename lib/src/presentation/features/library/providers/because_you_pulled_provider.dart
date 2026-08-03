import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/home/providers/home_content_cache.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/core/logging/app_logger.dart';

Set<String> _seriesTokens(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 4)
      .toSet();
}

List<int> _scoreBecauseYouPulledCandidates(Map<String, dynamic> input) {
  final weeklySeriesIds = (input['weekly_series_ids'] as List).cast<int?>();
  final weeklyIssueIds = (input['weekly_issue_ids'] as List).cast<int?>();
  final weeklyPublishers = (input['weekly_publishers'] as List).cast<String?>();
  final weeklyNames = (input['weekly_names'] as List).cast<String?>();

  final pulledSeriesIdsSet = (input['pulled_series_ids'] as List)
      .cast<int>()
      .toSet();
  final pulledIssueIdsSet = (input['pulled_issue_ids'] as List)
      .cast<int>()
      .toSet();
  final ownedIssueIdsSet = (input['owned_issue_ids'] as List)
      .cast<int>()
      .toSet();
  final pulledPublishersSet = (input['pulled_publishers'] as List)
      .cast<String>()
      .toSet();
  final pulledTokens = (input['pulled_tokens'] as List).cast<String>().toSet();

  final candidateIndices = <int>[];
  for (var i = 0; i < weeklyIssueIds.length; i++) {
    final issueId = weeklyIssueIds[i];
    final seriesId = weeklySeriesIds[i];
    if (issueId == null || seriesId == null) continue;
    if (pulledIssueIdsSet.contains(issueId) ||
        ownedIssueIdsSet.contains(issueId)) {
      continue;
    }
    candidateIndices.add(i);
  }

  candidateIndices.sort((a, b) {
    final aScore = _scoreSeries(
      weeklySeriesIds[a],
      weeklyPublishers[a],
      weeklyNames[a],
      pulledSeriesIdsSet,
      pulledPublishersSet,
      pulledTokens,
    );
    final bScore = _scoreSeries(
      weeklySeriesIds[b],
      weeklyPublishers[b],
      weeklyNames[b],
      pulledSeriesIdsSet,
      pulledPublishersSet,
      pulledTokens,
    );
    return bScore.compareTo(aScore);
  });

  return candidateIndices.take(10).toList();
}

double _scoreSeries(
  int? seriesId,
  String? publisher,
  String? name,
  Set<int> pulledSeriesIds,
  Set<String> pulledPublishers,
  Set<String> pulledTokens,
) {
  if (name == null || name.isEmpty) return 0;

  var score = 0.0;
  if (seriesId != null && pulledSeriesIds.contains(seriesId)) {
    score += 6;
  }
  final pub = publisher?.trim().toLowerCase();
  if (pub != null && pub.isNotEmpty && pulledPublishers.contains(pub)) {
    score += 4;
  }
  final overlap = _seriesTokens(name).intersection(pulledTokens).length;
  score += overlap.clamp(0, 3).toDouble();
  return score;
}

Future<List<IssueList>> _computeBecauseYouPulledIssues(Ref ref) async {
  final weeklyIssues = await ref.watch(weeklyReleasesProvider().future);
  if (!ref.mounted) return const [];
  final pulledIssues = await ref.watch(currentWeekPullsProvider.future);
  if (!ref.mounted) return const [];
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  if (!ref.mounted) return const [];

  if (pulledIssues.isEmpty) return const [];

  final ownedIssueIds = libraryItems
      .where((item) => item.quantityOwned > 0)
      .map((item) => item.metronIssueId)
      .toSet();

  final pulledIssueIds = pulledIssues
      .map((issue) => issue.id)
      .whereType<int>()
      .toList(growable: false);
  final pulledSeriesIds = pulledIssues
      .map((issue) => issue.series?.id)
      .whereType<int>()
      .toList(growable: false);
  final pulledPublishers = pulledIssues
      .map((issue) => issue.series?.publisherName?.trim().toLowerCase())
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
  final pulledTokens = pulledIssues
      .map((issue) => issue.series?.name)
      .whereType<String>()
      .expand(_seriesTokens)
      .toList(growable: false);

  final weeklyIssueIds = weeklyIssues
      .map((issue) => issue.id)
      .toList(growable: false);
  final weeklySeriesIds = weeklyIssues
      .map((issue) => issue.series?.id)
      .toList(growable: false);
  final weeklyPublishers = weeklyIssues
      .map((issue) => issue.series?.publisherName)
      .toList(growable: false);
  final weeklyNames = weeklyIssues
      .map((issue) => issue.series?.name)
      .toList(growable: false);

  final topIndices = await compute(_scoreBecauseYouPulledCandidates, {
    'weekly_issue_ids': weeklyIssueIds,
    'weekly_series_ids': weeklySeriesIds,
    'weekly_publishers': weeklyPublishers,
    'weekly_names': weeklyNames,
    'pulled_issue_ids': pulledIssueIds,
    'pulled_series_ids': pulledSeriesIds,
    'pulled_publishers': pulledPublishers,
    'pulled_tokens': pulledTokens,
    'owned_issue_ids': ownedIssueIds.toList(growable: false),
  });

  return topIndices.map((i) => weeklyIssues[i]).toList(growable: false);
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
  } catch (e) {
    AppLogger.warning('Failed to load cached because you pulled', error: e);
  }
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
    } catch (e) {
      AppLogger.warning('Failed to cache because you pulled', error: e);
    }
    return fresh;
  } catch (e) {
    AppLogger.error('Failed to compute because you pulled', error: e);
    return cached;
  }
});
