import 'package:takion/src/domain/entities/entities.dart';

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

  Future<void> deleteEntriesBySeriesId(int metronSeriesId);

  Future<void> upsertSubscriptionEntries(
    List<({int metronSeriesId, int metronIssueId, DateTime? releaseDate})>
    entries,
  );

  Future<int> regenerateFromSubscriptions({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
