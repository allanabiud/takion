import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/home/providers/home_content_cache.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class HomeTrendingEntry {
  const HomeTrendingEntry({required this.issue, required this.reason});

  final IssueList issue;
  final String reason;
}

Set<String> _seriesNameTokens(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 4)
      .toSet();
}

Future<List<HomeTrendingEntry>> _computeHomeTrendingEntries(Ref ref) async {
  final weeklyIssues = await ref.watch(weeklyReleasesProvider().future);
  final pullIssues = await ref.watch(currentWeekPullsProvider.future);

  if (weeklyIssues.isEmpty) return const [];

  final seriesFrequency = <String, int>{};
  for (final issue in weeklyIssues) {
    final seriesName = issue.series?.name.trim();
    if (seriesName == null || seriesName.isEmpty) continue;
    final key = seriesName.toLowerCase();
    seriesFrequency[key] = (seriesFrequency[key] ?? 0) + 1;
  }

  final pulledSeriesNames = pullIssues
      .map((issue) => issue.series?.name.trim().toLowerCase())
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toSet();
  final pulledTokens = pullIssues
      .map((issue) => issue.series?.name)
      .whereType<String>()
      .expand(_seriesNameTokens)
      .toSet();

  final bestIssuePerSeries = <String, ({IssueList issue, int score})>{};
  for (final issue in weeklyIssues) {
    final seriesName = issue.series?.name.trim();
    if (seriesName == null || seriesName.isEmpty) continue;

    final key = seriesName.toLowerCase();
    final overlap = _seriesNameTokens(seriesName).intersection(pulledTokens);
    final score =
        (seriesFrequency[key] ?? 0) * 2 +
        (pulledSeriesNames.contains(key) ? 5 : 0) +
        overlap.length;

    final current = bestIssuePerSeries[key];
    if (current == null || score > current.score) {
      bestIssuePerSeries[key] = (issue: issue, score: score);
    }
  }

  final ranked = bestIssuePerSeries.entries.toList()
    ..sort((a, b) => b.value.score.compareTo(a.value.score));

  return ranked.take(10).map((entry) {
    final isPulledSeries = pulledSeriesNames.contains(entry.key);
    final isHot = (seriesFrequency[entry.key] ?? 0) >= 2;
    return HomeTrendingEntry(
      issue: entry.value.issue,
      reason: isPulledSeries
          ? 'In Pulls'
          : (isHot ? 'Hot this week' : 'Trending'),
    );
  }).toList();
}

final homeTrendingProvider = FutureProvider<List<HomeTrendingEntry>>((
  ref,
) async {
  final metrics = AppPerformanceMetrics.instance;
  final cache = ref.read(homeContentCacheProvider);
  DateTime? cachedAt;
  var cached = const <HomeTrendingEntry>[];
  try {
    cachedAt = await cache.getCachedAt(homeTrendingMetaKey);
    final cachedJson = await cache.readJsonList(homeTrendingCacheKey);
    cached =
        cachedJson
            ?.map((json) {
              final issue = issueListFromJson(
                (json['issue'] as Map?)?.cast<String, dynamic>() ?? const {},
              );
              final reason = json['reason'] as String?;
              if (issue == null || reason == null || reason.trim().isEmpty) {
                return null;
              }
              return HomeTrendingEntry(issue: issue, reason: reason);
            })
            .whereType<HomeTrendingEntry>()
            .toList() ??
        const <HomeTrendingEntry>[];
  } catch (e) {
    AppLogger.warning('Failed to load cached home trending', error: e);
  }
  final hasFreshCache =
      cachedAt != null &&
      HomeCachePolicies.seriesSuggestions.isFresh(cachedAt, DateTime.now()) &&
      cached.isNotEmpty;

  if (hasFreshCache) {
    metrics.recordCacheHit(homeTrendingMetaKey);
    return cached;
  }
  metrics.recordCacheMiss(homeTrendingMetaKey);

  try {
    final fresh = await metrics.trackProvider(
      'homeTrendingProvider',
      () => _computeHomeTrendingEntries(ref),
    );
    try {
      await cache.writeJsonList(
        homeTrendingCacheKey,
        fresh
            .map(
              (entry) => {
                'issue': issueListToJson(entry.issue),
                'reason': entry.reason,
              },
            )
            .toList(),
      );
      await cache.writeCachedAtNow(homeTrendingMetaKey);
    } catch (e) {
      AppLogger.warning('Failed to cache home trending', error: e);
    }
    return fresh;
  } catch (e) {
    AppLogger.error('Failed to compute home trending', error: e);
    return cached;
  }
});
