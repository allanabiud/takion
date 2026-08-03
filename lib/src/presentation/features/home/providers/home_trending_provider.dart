import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/performance/performance_metrics.dart';
import 'package:takion/src/domain/entities.dart';
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

List<Map<String, dynamic>> _scoreTrendingEntries(Map<String, dynamic> input) {
  final weeklyNames = (input['weekly_names'] as List).cast<String>();
  final pullNames = (input['pull_names'] as List).cast<String>();

  if (weeklyNames.isEmpty) return const [];

  final seriesFrequency = <String, int>{};
  for (final name in weeklyNames) {
    if (name.isEmpty) continue;
    final key = name.toLowerCase();
    seriesFrequency[key] = (seriesFrequency[key] ?? 0) + 1;
  }

  final pulledSeriesNames = pullNames
      .map((n) => n.toLowerCase())
      .where((n) => n.isNotEmpty)
      .toSet();
  final pulledTokens = pullNames.expand((n) => _seriesNameTokens(n)).toSet();

  final bestScores = <String, int>{};
  final bestIndices = <String, int>{};
  final bestReasons = <String, String>{};

  for (var i = 0; i < weeklyNames.length; i++) {
    final seriesName = weeklyNames[i];
    if (seriesName.isEmpty) continue;

    final key = seriesName.toLowerCase();
    final overlap = _seriesNameTokens(seriesName).intersection(pulledTokens);
    final score =
        (seriesFrequency[key] ?? 0) * 2 +
        (pulledSeriesNames.contains(key) ? 5 : 0) +
        overlap.length;

    final current = bestScores[key];
    if (current == null || score > current) {
      bestScores[key] = score;
      bestIndices[key] = i;
      final isPulledSeries = pulledSeriesNames.contains(key);
      final isHot = (seriesFrequency[key] ?? 0) >= 2;
      bestReasons[key] = isPulledSeries
          ? 'In Pulls'
          : (isHot ? 'Hot this week' : 'Trending');
    }
  }

  final ranked = bestScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return ranked.take(10).map((entry) {
    return <String, dynamic>{
      'index': bestIndices[entry.key],
      'reason': bestReasons[entry.key],
    };
  }).toList();
}

Future<List<HomeTrendingEntry>> _computeHomeTrendingEntries(Ref ref) async {
  final weeklyIssues = await ref.watch(weeklyReleasesProvider().future);
  if (!ref.mounted) return const [];
  final pullIssues = await ref.watch(currentWeekPullsProvider.future);
  if (!ref.mounted) return const [];

  if (weeklyIssues.isEmpty) return const [];

  final weeklyNames = weeklyIssues
      .map((issue) => issue.series?.name.trim() ?? '')
      .toList(growable: false);
  final pullNames = pullIssues
      .map((issue) => issue.series?.name ?? '')
      .toList(growable: false);

  final results = await compute(_scoreTrendingEntries, {
    'weekly_names': weeklyNames,
    'pull_names': pullNames,
  });

  return results.map((r) {
    final index = r['index'] as int;
    return HomeTrendingEntry(
      issue: weeklyIssues[index],
      reason: r['reason'] as String,
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
