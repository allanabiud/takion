import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/series_details.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/issues_provider.dart';
import 'package:takion/src/presentation/providers/pulls_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/subscriptions_provider.dart';

class HomeSeriesSuggestion {
  const HomeSeriesSuggestion({required this.series, required this.reason});

  final SeriesList series;
  final String reason;
}

String _reasonForSeries(SeriesList series) {
  final issueCount = series.issueCount ?? 0;
  final modified = series.modified;
  if (modified != null && DateTime.now().difference(modified).inDays <= 120) {
    return 'Recent';
  }
  if (issueCount >= 100) {
    return 'Classic';
  }
  if (issueCount >= 40) {
    return 'Binge';
  }
  return 'Fresh';
}

Set<String> _seriesNameTokens(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 4)
      .toSet();
}

double _yearRecencyScore(int? yearBegan) {
  if (yearBegan == null) return -2;
  final age = DateTime.now().year - yearBegan;
  if (age <= 2) return 18;
  if (age <= 5) return 14;
  if (age <= 10) return 8;
  if (age <= 15) return 3;
  if (age <= 25) return -2;
  return -14;
}

double _modifiedRecencyScore(DateTime? modified) {
  if (modified == null) return 0;
  final days = DateTime.now().difference(modified).inDays;
  if (days <= 60) return 8;
  if (days <= 180) return 5;
  if (days <= 365) return 2;
  return 0;
}

double _issueCountScore(int? issueCount) {
  final count = issueCount ?? 0;
  if (count == 0) return 0;
  if (count >= 6 && count <= 120) return 3;
  if (count > 250) return -3;
  return 1;
}

double _affinityScore(
  SeriesList series, {
  required Set<String> preferredTokens,
  required List<int> preferredYears,
}) {
  final tokens = _seriesNameTokens(series.name);
  final tokenMatches = tokens.intersection(preferredTokens).length;
  var score = (tokenMatches * 1.5).clamp(0, 6).toDouble();

  if (preferredYears.isNotEmpty && series.yearBegan != null) {
    final year = series.yearBegan!;
    final closest = preferredYears
        .map((preferredYear) => (preferredYear - year).abs())
        .reduce((a, b) => a < b ? a : b);
    if (closest <= 2) {
      score += 4;
    } else if (closest <= 5) {
      score += 2;
    }
  }

  return score;
}

double _scoreSeries(
  SeriesList series, {
  required bool fromNewReleases,
  required bool fromPullList,
  required Set<String> preferredTokens,
  required List<int> preferredYears,
}) {
  var score = 0.0;
  score += _yearRecencyScore(series.yearBegan);
  score += _modifiedRecencyScore(series.modified);
  score += _issueCountScore(series.issueCount);
  score += _affinityScore(
    series,
    preferredTokens: preferredTokens,
    preferredYears: preferredYears,
  );
  if (fromNewReleases) score += 16;
  if (fromPullList) score += 12;
  return score;
}

String _rankedReason({
  required SeriesList series,
  required bool fromNewReleases,
  required bool fromPullList,
  required int tokenMatches,
}) {
  if (fromNewReleases) return 'Weekly';
  if (fromPullList) return 'Pulls';
  if (tokenMatches >= 2) return 'Similar';
  if ((series.yearBegan ?? 0) >= DateTime.now().year - 5) {
    return 'New';
  }
  return _reasonForSeries(series);
}

final homeSeriesSuggestionsProvider =
    FutureProvider.autoDispose<List<HomeSeriesSuggestion>>((ref) async {
      final metronRepository = ref.watch(metronRepositoryProvider);
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final subscriptions = await ref.watch(activeSubscriptionsProvider.future);
      final subscribedSeries = await ref.watch(
        subscribedSeriesListProvider.future,
      );
      final weeklyIssues = await ref.watch(
        currentWeeklyReleasesProvider.future,
      );
      final pullIssues = await ref.watch(currentWeekPullsProvider.future);

      final excludedSeriesIds = <int>{
        for (final item in libraryItems) item.metronSeriesId,
        for (final sub in subscriptions) sub.metronSeriesId,
      };
      final preferredTokens = <String>{};
      final preferredYears = <int>[];
      for (final series in subscribedSeries) {
        preferredTokens.addAll(_seriesNameTokens(series.name));
        if (series.yearBegan != null) preferredYears.add(series.yearBegan!);
      }
      for (final issue in pullIssues) {
        final series = issue.series;
        if (series == null) continue;
        preferredTokens.addAll(_seriesNameTokens(series.name));
        if (series.yearBegan != null) preferredYears.add(series.yearBegan!);
      }

      final newReleaseSeriesIds = weeklyIssues
          .map((issue) => issue.series?.id)
          .whereType<int>()
          .toSet();
      final pullSeriesIds = pullIssues
          .map((issue) => issue.series?.id)
          .whereType<int>()
          .toSet();
      final boostedSeriesIds = <int>{...newReleaseSeriesIds, ...pullSeriesIds};

      final pages = await Future.wait(
        [1, 2, 3].map((page) => metronRepository.getSeriesList(page: page)),
      );

      final candidatesById = <int, SeriesList>{};

      for (final page in pages) {
        for (final series in page.results) {
          if (excludedSeriesIds.contains(series.id)) {
            continue;
          }
          candidatesById[series.id] = series;
        }
      }

      final explicitBoostSeriesIds = boostedSeriesIds
          .where((id) => !excludedSeriesIds.contains(id))
          .take(6)
          .toList();
      final boostedDetails = await Future.wait<SeriesDetails?>(
        explicitBoostSeriesIds.map((seriesId) async {
          try {
            return await metronRepository.getSeriesDetails(seriesId);
          } catch (_) {
            return null;
          }
        }),
      );

      for (final details in boostedDetails.whereType<SeriesDetails>()) {
        final id = details.id;
        candidatesById[id] = SeriesList(
          id: id,
          name: details.name,
          yearBegan: details.yearBegan,
          volume: details.volume,
          issueCount: details.issueCount,
          modified: details.modified,
        );
      }

      final rankedCandidates = candidatesById.values.where((series) {
        final year = series.yearBegan;
        if (year == null) return true;
        final tooOld = year < DateTime.now().year - 25;
        final hasStrongSignal =
            newReleaseSeriesIds.contains(series.id) ||
            pullSeriesIds.contains(series.id);
        return !tooOld || hasStrongSignal;
      }).toList();

      rankedCandidates.sort((a, b) {
        final aScore = _scoreSeries(
          a,
          fromNewReleases: newReleaseSeriesIds.contains(a.id),
          fromPullList: pullSeriesIds.contains(a.id),
          preferredTokens: preferredTokens,
          preferredYears: preferredYears,
        );
        final bScore = _scoreSeries(
          b,
          fromNewReleases: newReleaseSeriesIds.contains(b.id),
          fromPullList: pullSeriesIds.contains(b.id),
          preferredTokens: preferredTokens,
          preferredYears: preferredYears,
        );
        return bScore.compareTo(aScore);
      });

      return rankedCandidates.take(10).map((series) {
        return HomeSeriesSuggestion(
          series: series,
          reason: _rankedReason(
            series: series,
            fromNewReleases: newReleaseSeriesIds.contains(series.id),
            fromPullList: pullSeriesIds.contains(series.id),
            tokenMatches: _seriesNameTokens(
              series.name,
            ).intersection(preferredTokens).length,
          ),
        );
      }).toList();
    });

final seriesSuggestionBackdropProvider = FutureProvider.family<String?, int>((
  ref,
  seriesId,
) async {
  final metronRepository = ref.watch(metronRepositoryProvider);
  try {
    final issuePage = await metronRepository.getSeriesIssueList(seriesId);
    return issuePage.results
        .map((issue) => issue.image?.trim())
        .whereType<String>()
        .firstWhere((url) => url.isNotEmpty);
  } catch (_) {
    return null;
  }
});
