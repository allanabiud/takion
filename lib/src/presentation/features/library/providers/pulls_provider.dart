import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/common/drift/database.dart' as db;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';

DateTime weekStart(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final offset = normalized.weekday % 7;
  return normalized.subtract(Duration(days: offset));
}

DateTime weekEnd(DateTime date) => weekStart(date).add(const Duration(days: 6));

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

PullListEntryStatus _statusFromRaw(String raw) {
  switch (raw) {
    case 'upcoming':
      return PullListEntryStatus.upcoming;
    case 'skipped':
      return PullListEntryStatus.skipped;
    default:
      return PullListEntryStatus.upcoming;
  }
}

PullListEntrySource _sourceFromRaw(String raw) {
  switch (raw) {
    case 'subscription':
      return PullListEntrySource.subscription;
    case 'manual':
      return PullListEntrySource.manual;
    default:
      return PullListEntrySource.subscription;
  }
}

PullListEntry _toDomain(db.PullListEntry d) {
  return PullListEntry(
    id: d.id,
    userId: d.userId,
    metronIssueId: d.metronIssueId,
    metronSeriesId: d.metronSeriesId,
    source: _sourceFromRaw(d.source),
    releaseDate: d.releaseDate,
    entryStatus: _statusFromRaw(d.entryStatus),
    generatedAt: DateTime.parse(d.generatedAt),
    createdAt: DateTime.parse(d.createdAt),
    updatedAt: DateTime.parse(d.updatedAt),
  );
}

final issuePullListEntryProvider = StreamProvider.family<PullListEntry?, int>((
  ref,
  issueId,
) {
  final dao = ref.watch(driftDatabaseProvider).pullListDao;
  return dao.watchByIssueId(issueId).map((row) {
    if (row == null) return null;
    final entry = _toDomain(row);
    if (entry.entryStatus == PullListEntryStatus.skipped) return null;
    return entry;
  });
});

final seriesSubscriptionProvider =
    StreamProvider.family<SeriesSubscription?, int>((ref, seriesId) {
      final dao = ref.watch(driftDatabaseProvider).subscriptionDao;
      return dao.watchBySeriesId(seriesId).map((row) {
        if (row == null) return null;
        return SeriesSubscription(
          id: row.id,
          userId: row.userId,
          metronSeriesId: row.metronSeriesId,
          isActive: row.isActive,
          autoAddToPullList: row.autoAddPull,
          subscribedAt: DateTime.parse(row.subscribedAt),
          createdAt: DateTime.parse(row.createdAt),
          updatedAt: DateTime.parse(row.updatedAt),
        );
      });
    });

final pullListEntriesForWeekProvider = FutureProvider.autoDispose
    .family<List<PullListEntry>, DateTime>((ref, date) async {
      final repository = ref.watch(pullListRepositoryProvider);
      return repository.listEntries(
        fromDate: weekStart(date),
        toDate: weekEnd(date),
        status: PullListEntryStatus.upcoming,
        limit: 500,
      );
    });

final pullsIssuesForWeekProvider = FutureProvider.autoDispose
    .family<List<IssueList>, DateTime>((ref, date) async {
      final weeklyIssues = await ref.watch(weeklyReleasesProvider(date).future);
      final pullEntries = await ref.watch(
        pullListEntriesForWeekProvider(date).future,
      );
      final issueIds = pullEntries.map((entry) => entry.metronIssueId).toSet();

      final repository = ref.watch(pullListRepositoryProvider);
      final dismissedEntries = await repository.listEntries(
        fromDate: weekStart(date),
        toDate: weekEnd(date),
        status: PullListEntryStatus.skipped,
        limit: 500,
      );
      final dismissedIssueIds = dismissedEntries
          .map((entry) => entry.metronIssueId)
          .toSet();

      final activeSubscriptions = await ref.watch(
        activeSubscriptionsProvider.future,
      );
      final subscribedSeriesIds = activeSubscriptions
          .map((s) => s.metronSeriesId)
          .toSet();

      final issuesToPull = <IssueList>[];

      for (final issue in weeklyIssues) {
        final issueId = issue.id;
        if (issueId == null) continue;

        if (issueIds.contains(issueId)) {
          issuesToPull.add(issue);
          continue;
        }

        final seriesId = issue.series?.id;
        if (seriesId != null &&
            subscribedSeriesIds.contains(seriesId) &&
            !dismissedIssueIds.contains(issueId)) {
          issuesToPull.add(issue);
        }
      }

      return issuesToPull;
    });

final currentWeekPullsProvider = FutureProvider.autoDispose<List<IssueList>>((
  ref,
) async {
  final pulls = await ref.watch(
    pullsIssuesForWeekProvider(dateOnly(DateTime.now())).future,
  );
  return pulls;
});

final currentWeekPullsCountProvider = Provider<int>((ref) {
  final pullsAsync = ref.watch(currentWeekPullsProvider);
  return pullsAsync.maybeWhen(data: (pulls) => pulls.length, orElse: () => 0);
});
