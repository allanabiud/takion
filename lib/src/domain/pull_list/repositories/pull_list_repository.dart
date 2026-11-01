import "dart:async";

import "package:takion/src/core/network/remote_page.dart";
import "package:takion/src/domain/entities.dart";

abstract class PullListRepository {
  Stream<PullListEntry?> watchEntryByIssueId(int metronIssueId);

  Future<List<PullListEntry>> listEntries({
    DateTime? fromDate,
    DateTime? toDate,
    PullListEntryStatus? status,
    int limit = 100,
    int offset = 0,
  });

  Future<PullListEntry?> getEntryByIssueId(int metronIssueId);

  Future<PullListEntry> upsertManualEntry({
    required int metronSeriesId,
    required int metronIssueId,
    DateTime? releaseDate,
    PullListEntryStatus entryStatus = PullListEntryStatus.upcoming,
  });

  Future<PullListEntry> updateEntryStatus({
    required int metronIssueId,
    required PullListEntryStatus status,
  });

  Future<void> deleteEntryByIssueId(int metronIssueId);

  Future<List<PullListEntry>> deleteEntriesBySeriesId(int metronSeriesId);

  Future<void> upsertSubscriptionEntries(
    List<({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>
    entries,
  );
}

abstract class MetronPullListRepository {
  Future<RemotePage<PullListSeriesItem>> getPullListSeriesPage({Uri? pageUrl});

  Future<RemotePage<PullListIssueItem>> getPullListIssuesPage({
    Uri? pageUrl,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
  });

  Future<List<PullListSeriesItem>> getPullListSeries({
    int page = 1,
    DateTime? modifiedGt,
  });

  Future<PullListSeriesItem> addSeriesToPullList(int seriesId);

  Future<void> removeSeriesFromPullList(int seriesId);

  Future<List<PullListIssueItem>> getPullListIssues({
    int page = 1,
    DateTime? storeDateAfter,
    DateTime? storeDateBefore,
  });
}
