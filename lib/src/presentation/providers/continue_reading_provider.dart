import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

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

final continueReadingSuggestionsProvider =
    FutureProvider.autoDispose<List<ContinueReadingSuggestion>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final readItems = libraryItems.where((item) => item.isRead).toList();
      if (readItems.isEmpty) return const [];

      final readIssueIdsBySeries = <int, Set<int>>{};
      final latestReadAtBySeries = <int, DateTime>{};
      final latestReadIssueIdBySeries = <int, int>{};

      DateTime readTimestamp(LibraryItem item) =>
          item.firstReadAt ?? item.updatedAt;

      for (final item in readItems) {
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
          (a, b) =>
              latestReadAtBySeries[b]!.compareTo(latestReadAtBySeries[a]!),
        );

      final suggestionResults = await Future.wait(
        recentSeriesIds.take(6).map((seriesId) async {
          final lastReadIssueId = latestReadIssueIdBySeries[seriesId];
          if (lastReadIssueId == null) return null;
          final nextIssue = await _findNextUnreadIssueForSeries(
            ref,
            seriesId: seriesId,
            lastReadIssueId: lastReadIssueId,
            readIssueIds: readIssueIdsBySeries[seriesId] ?? const <int>{},
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
    });
