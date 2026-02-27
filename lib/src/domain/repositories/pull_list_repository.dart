import 'package:takion/src/domain/entities/pull_list_entry.dart';

abstract class PullListRepository {
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

  Future<int> regenerateFromSubscriptions({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
