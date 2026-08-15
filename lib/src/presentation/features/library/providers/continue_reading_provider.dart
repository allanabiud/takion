import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";

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

Map<String, dynamic> _filterContinueReadingData(
  List<Map<String, dynamic>> itemsJson,
) {
  final collectedReadIndices = <int>[];
  final allReadIssueIds = <int>{};

  for (var i = 0; i < itemsJson.length; i++) {
    final item = itemsJson[i];
    final isRead = item["isRead"] as bool;
    final issueId = item["metronIssueId"] as int;
    if (isRead) {
      allReadIssueIds.add(issueId);
    }
    if (item["ownershipStatus"] == "owned" && isRead) {
      collectedReadIndices.add(i);
    }
  }

  final latestReadAtBySeries = <int, String>{};
  final latestReadIssueIdBySeries = <int, int>{};

  for (final idx in collectedReadIndices) {
    final item = itemsJson[idx];
    final seriesId = item["metronSeriesId"] as int;
    final issueId = item["metronIssueId"] as int;
    final firstReadAt = item["firstReadAt"] as String?;
    final updatedAt = item["updatedAt"] as String;
    final ts = firstReadAt ?? updatedAt;

    final existing = latestReadAtBySeries[seriesId];
    if (existing == null || ts.compareTo(existing) > 0) {
      latestReadAtBySeries[seriesId] = ts;
      latestReadIssueIdBySeries[seriesId] = issueId;
    }
  }

  final recentSeriesIds = latestReadAtBySeries.keys.toList()
    ..sort(
      (a, b) => latestReadAtBySeries[b]!.compareTo(latestReadAtBySeries[a]!),
    );

  return {
    "collectedReadIndices": collectedReadIndices,
    "allReadIssueIds": allReadIssueIds.toList(),
    "latestReadAtBySeries": latestReadAtBySeries.map(
      (k, v) => MapEntry(k.toString(), v),
    ),
    "latestReadIssueIdBySeries": latestReadIssueIdBySeries.map(
      (k, v) => MapEntry(k.toString(), v),
    ),
    "recentSeriesIds": recentSeriesIds,
  };
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

Future<List<ContinueReadingSuggestion>> _computeContinueReadingSuggestions(
  Ref ref, {
  int? maxSeriesCount,
}) async {
  final libraryItems = await ref.watch(allLibraryItemsProvider.future);
  if (libraryItems.isEmpty) return const [];

  final itemsJson = libraryItems
      .map(
        (item) => <String, dynamic>{
          "metronIssueId": item.metronIssueId,
          "metronSeriesId": item.metronSeriesId,
          "ownershipStatus": item.ownershipStatus.name,
          "isRead": item.isRead,
          "firstReadAt": item.firstReadAt?.toIso8601String(),
          "updatedAt": item.updatedAt.toIso8601String(),
        },
      )
      .toList(growable: false);

  final filtered = await compute(_filterContinueReadingData, itemsJson);

  final collectedReadIndices = (filtered["collectedReadIndices"] as List)
      .cast<int>();
  if (collectedReadIndices.isEmpty) return const [];

  final allReadIssueIds = (filtered["allReadIssueIds"] as List)
      .cast<int>()
      .toSet();

  final latestReadAtBySeries = (filtered["latestReadAtBySeries"] as Map).map(
    (k, v) => MapEntry(int.parse(k as String), DateTime.parse(v as String)),
  );
  final latestReadIssueIdBySeries =
      (filtered["latestReadIssueIdBySeries"] as Map).map(
        (k, v) => MapEntry(int.parse(k as String), v as int),
      );
  final recentSeriesIds = (filtered["recentSeriesIds"] as List).cast<int>();

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
        AppLogger.error("Failed to compute continue reading", error: e);
        return const [];
      }
    });
