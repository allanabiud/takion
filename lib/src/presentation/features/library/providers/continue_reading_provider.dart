import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class ContinueReadingSuggestion {
  const ContinueReadingSuggestion({
    required this.seriesId,
    required this.issue,
    required this.lastReadAt,
  });

  final int seriesId;
  final IssueList issue;
  final DateTime lastReadAt;
}

const _homeContinueReadingPreviewLimit = 5;

Future<IssueList?> _findNextUnreadIssueForSeries(
  Ref ref, {
  required int seriesId,
  required int lastReadIssueId,
  required Set<int> readIssueIds,
}) async {
  if (readIssueIds.isEmpty) return null;

  final repository = ref.read(metronRepositoryProvider);
  var page = 1;
  var scannedPages = 0;
  var hasSeenLastReadIssue = false;

  while (scannedPages < 8) {
    final issuePage = await repository.getSeriesIssueList(seriesId, page: page);

    for (final issue in issuePage.results) {
      final issueId = issue.id;
      if (issueId == null) continue;
      if (issueId == lastReadIssueId) {
        hasSeenLastReadIssue = true;
        continue;
      }
      if (hasSeenLastReadIssue && !readIssueIds.contains(issueId)) {
        return issue;
      }
    }

    final nextPage = issuePage.nextPage;
    if (nextPage == null) {
      break;
    }
    page = nextPage;
    scannedPages++;
  }

  if (!hasSeenLastReadIssue) return null;
  return null;
}

Future<List<ContinueReadingSuggestion>> _computeContinueReadingSuggestions(
  Ref ref, {
  int? maxSeriesCount,
}) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);

  // Only collected+read items qualify a series for Continue Reading.
  final collectedReadItems = libraryItems
      .where(
        (item) =>
            item.ownershipStatus == LibraryOwnershipStatus.owned && item.isRead,
      )
      .toList();
  if (collectedReadItems.isEmpty) return const [];

  // All read issue IDs (collected or not) are used for the "skip already read" logic.
  final allReadIssueIds = libraryItems
      .where((item) => item.isRead)
      .map((item) => item.metronIssueId)
      .toSet();

  final readIssueIdsBySeries = <int, Set<int>>{};
  final latestReadAtBySeries = <int, DateTime>{};
  final latestReadIssueIdBySeries = <int, int>{};

  DateTime readTimestamp(LibraryItem item) =>
      item.firstReadAt ?? item.updatedAt;

  for (final item in collectedReadItems) {
    readIssueIdsBySeries
        .putIfAbsent(item.metronSeriesId, () => <int>{})
        .add(item.metronIssueId);
    final ts = readTimestamp(item);
    final existing = latestReadAtBySeries[item.metronSeriesId];
    if (existing == null || ts.isAfter(existing)) {
      latestReadAtBySeries[item.metronSeriesId] = ts;
      latestReadIssueIdBySeries[item.metronSeriesId] = item.metronIssueId;
    }
  }

  final recentSeriesIds = latestReadAtBySeries.keys.toList()
    ..sort(
      (a, b) => latestReadAtBySeries[b]!.compareTo(latestReadAtBySeries[a]!),
    );

  final seriesIdsToResolve = maxSeriesCount == null
      ? recentSeriesIds
      : recentSeriesIds.take(maxSeriesCount).toList();

  final suggestionResults = await Future.wait(
    seriesIdsToResolve.map((seriesId) async {
      final lastReadIssueId = latestReadIssueIdBySeries[seriesId];
      if (lastReadIssueId == null) return null;
      final nextIssue = await _findNextUnreadIssueForSeries(
        ref,
        seriesId: seriesId,
        lastReadIssueId: lastReadIssueId,
        readIssueIds: allReadIssueIds,
      );
      if (nextIssue == null) return null;
      return ContinueReadingSuggestion(
        seriesId: seriesId,
        issue: nextIssue,
        lastReadAt: latestReadAtBySeries[seriesId]!,
      );
    }),
  );

  return suggestionResults.whereType<ContinueReadingSuggestion>().toList();
}

final continueReadingSuggestionsProvider =
    FutureProvider<List<ContinueReadingSuggestion>>((ref) async {
      final all = await ref.watch(continueReadingAllSuggestionsProvider.future);
      return all.take(_homeContinueReadingPreviewLimit).toList(growable: false);
    });

final continueReadingAllSuggestionsProvider =
    FutureProvider.autoDispose<List<ContinueReadingSuggestion>>((ref) async {
      try {
        return await _computeContinueReadingSuggestions(ref);
      } catch (e) {
        AppLogger.error('Failed to compute continue reading', error: e);
        return const [];
      }
    });
