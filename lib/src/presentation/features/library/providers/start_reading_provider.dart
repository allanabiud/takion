import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';

class StartReadingSuggestion {
  const StartReadingSuggestion({
    required this.seriesId,
    required this.issue,
  });

  final int seriesId;
  final IssueList issue;
}

const _homeStartReadingPreviewLimit = 5;

Future<IssueList?> _findFirstUnreadCollectedIssueForSeries(
  Ref ref, {
  required int seriesId,
  required Set<int> ownedIssueIds,
  required Set<int> unreadIssueIds,
}) async {
  final repository = ref.read(metronRepositoryProvider);
  var page = 1;
  var scannedPages = 0;

  while (scannedPages < 8) {
    final issuePage = await repository.getSeriesIssueList(seriesId, page: page);

    for (final issue in issuePage.results) {
      final issueId = issue.id;
      if (issueId == null) continue;
      if (ownedIssueIds.contains(issueId) && unreadIssueIds.contains(issueId)) {
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

  return null;
}

Future<List<StartReadingSuggestion>> _computeStartReadingSuggestions(
  Ref ref, {
  int? maxSeriesCount,
}) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  if (libraryItems.isEmpty) return const [];

  final ownedItems = libraryItems
      .where((item) => item.ownershipStatus == LibraryOwnershipStatus.owned)
      .toList(growable: false);
  if (ownedItems.isEmpty) return const [];

  final ownedIssueIds = <int>{};
  final unreadIssueIds = <int>{};
  final seriesIds = <int>{};

  for (final item in ownedItems) {
    final issueId = item.metronIssueId;
    final seriesId = item.metronSeriesId;
    ownedIssueIds.add(issueId);
    seriesIds.add(seriesId);
    if (!item.isRead) {
      unreadIssueIds.add(issueId);
    }
  }

  if (unreadIssueIds.isEmpty) return const [];

  final seriesIdsToResolve = maxSeriesCount == null
      ? seriesIds.toList()
      : seriesIds.toList().take(maxSeriesCount).toList();

  final suggestionResults = await Future.wait(
    seriesIdsToResolve.map((seriesId) async {
      final firstUnread = await _findFirstUnreadCollectedIssueForSeries(
        ref,
        seriesId: seriesId,
        ownedIssueIds: ownedIssueIds,
        unreadIssueIds: unreadIssueIds,
      );
      if (firstUnread == null) return null;
      return StartReadingSuggestion(
        seriesId: seriesId,
        issue: firstUnread,
      );
    }),
  );

  return suggestionResults.whereType<StartReadingSuggestion>().toList();
}

final startReadingSuggestionsProvider =
    FutureProvider<List<StartReadingSuggestion>>((ref) async {
      final all = await ref.watch(startReadingAllSuggestionsProvider.future);
      return all.take(_homeStartReadingPreviewLimit).toList(growable: false);
    });

final startReadingAllSuggestionsProvider =
    FutureProvider.autoDispose<List<StartReadingSuggestion>>((ref) async {
      try {
        return await _computeStartReadingSuggestions(ref);
      } catch (e) {
        AppLogger.error('Failed to compute start reading', error: e);
        return const [];
      }
    });
