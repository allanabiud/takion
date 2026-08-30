import "dart:async";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/data/common/drift/daos/library_item_dao.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";

class LibraryBatchHydrator {
  LibraryBatchHydrator(this._ref);

  final Ref _ref;
  final Set<int> _hydratedSeriesIds = <int>{};
  final Set<int> _inFlightSeriesIds = <int>{};
  final Set<int> _inFlightIssueIds = <int>{};
  final Set<int> _failedSeriesIds = <int>{};
  final Set<int> _failedIssueIds = <int>{};
  bool _isProcessing = false;

  void onHydratedRowsUpdated(List<HydratedLibraryItemRow> rows) {
    if (_isProcessing) return;
    _scheduleBatchHydration(rows);
  }

  void _scheduleBatchHydration(List<HydratedLibraryItemRow> rows) {
    _isProcessing = true;
    Future.microtask(() async {
      try {
        await _processBatch(rows);
      } catch (e) {
        AppLogger.warning("Error during batch background hydration", error: e);
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _processBatch(List<HydratedLibraryItemRow> rows) async {
    final metronRepo = _ref.read(metronRepositoryProvider);

    final unhydratedBySeries = <int, Set<int>>{};
    final unhydratedStandaloneIssues = <int>{};

    for (final row in rows) {
      final libraryItem = row.libraryItem;
      final issue = row.issue;
      final seriesId = libraryItem.metronSeriesId;
      final issueId = libraryItem.metronIssueId;

      final needsHydration =
          issue == null || issue.imageUrl == null || issue.number.isEmpty;

      if (!needsHydration) continue;

      if (seriesId > 0) {
        if (!_hydratedSeriesIds.contains(seriesId) &&
            !_inFlightSeriesIds.contains(seriesId) &&
            !_failedSeriesIds.contains(seriesId)) {
          unhydratedBySeries.putIfAbsent(seriesId, () => <int>{}).add(issueId);
        }
      } else {
        if (!_inFlightIssueIds.contains(issueId) &&
            !_failedIssueIds.contains(issueId)) {
          unhydratedStandaloneIssues.add(issueId);
        }
      }
    }

    for (final seriesId in unhydratedBySeries.keys) {
      _inFlightSeriesIds.add(seriesId);
      try {
        AppLogger.info(
          "LibraryBatchHydrator: Fetching series issue list for series $seriesId",
        );
        await metronRepo.getSeriesIssueList(seriesId, page: 1, limit: 100);
        _hydratedSeriesIds.add(seriesId);
      } catch (e) {
        _failedSeriesIds.add(seriesId);
        AppLogger.warning(
          "LibraryBatchHydrator: Failed to fetch issue list for series $seriesId",
          error: e,
        );
      } finally {
        _inFlightSeriesIds.remove(seriesId);
      }
    }

    final standaloneToFetch = unhydratedStandaloneIssues.take(5).toList();
    for (final issueId in standaloneToFetch) {
      _inFlightIssueIds.add(issueId);
      try {
        await metronRepo.getIssueDetails(issueId);
      } catch (e) {
        _failedIssueIds.add(issueId);
        AppLogger.warning(
          "LibraryBatchHydrator: Failed to fetch standalone issue $issueId",
          error: e,
        );
      } finally {
        _inFlightIssueIds.remove(issueId);
      }
    }
  }

  void reset() {
    _hydratedSeriesIds.clear();
    _inFlightSeriesIds.clear();
    _inFlightIssueIds.clear();
    _failedSeriesIds.clear();
    _failedIssueIds.clear();
  }
}

final libraryBatchHydratorProvider = Provider.autoDispose<LibraryBatchHydrator>(
  (ref) {
    final hydrator = LibraryBatchHydrator(ref);

    ref.listen<AsyncValue<List<HydratedLibraryItemRow>>>(
      hydratedLibraryItemsStreamProvider,
      (_, next) {
        next.whenData(hydrator.onHydratedRowsUpdated);
      },
    );

    return hydrator;
  },
);
