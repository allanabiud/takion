import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/presentation/providers/providers.dart';

/// Resolves the Metron series ID for an issue using local data and network fallback.
///
/// Falls through five tiers:
///   1. Use [existingSeriesId] (from the library item or caller-supplied context).
///   2. Look up the pull-list entry for this issue in the local DB.
///   3. Look up the library item for this issue in the local DB.
///   4. Look up the issue in the Drift metron_issues table.
///   5. Fetch issue details from Metron API (network fallback).
Future<int?> resolveIssueSeriesId(
  Ref ref,
  int issueId, {
  int? existingSeriesId,
}) async {
  if (existingSeriesId != null && existingSeriesId > 0) {
    AppLogger.debug(
      'resolveIssueSeriesId: resolved $existingSeriesId via existingSeriesId for issue #$issueId',
    );
    return existingSeriesId;
  }

  final pullEntry = await ref
      .read(pullListRepositoryProvider)
      .getEntryByIssueId(issueId);
  final pullSeriesId = pullEntry?.metronSeriesId;
  if (pullSeriesId != null && pullSeriesId > 0) {
    AppLogger.debug(
      'resolveIssueSeriesId: resolved $pullSeriesId via pull list for issue #$issueId',
    );
    return pullSeriesId;
  }

  final libraryItem = await ref
      .read(libraryRepositoryProvider)
      .getItemByIssueId(issueId);
  final libSeriesId = libraryItem?.metronSeriesId;
  if (libSeriesId != null && libSeriesId > 0) {
    AppLogger.debug(
      'resolveIssueSeriesId: resolved $libSeriesId via library item for issue #$issueId',
    );
    return libSeriesId;
  }

  final dbIssue = await ref.read(metronEntityDaoProvider).getIssue(issueId);
  final dbSeriesId = dbIssue?.seriesId;
  if (dbSeriesId != null && dbSeriesId > 0) {
    AppLogger.debug(
      'resolveIssueSeriesId: resolved $dbSeriesId via metron_issues for issue #$issueId',
    );
    return dbSeriesId;
  }

  try {
    AppLogger.debug(
      'resolveIssueSeriesId: falling back to catalog fetch for issue #$issueId',
    );
    final details = await ref
        .read(metronRepositoryProvider)
        .getIssueDetails(issueId);
    final netSeriesId = details.series?.id;
    if (netSeriesId != null && netSeriesId > 0) {
      AppLogger.debug(
        'resolveIssueSeriesId: resolved $netSeriesId via catalog fetch for issue #$issueId',
      );
      return netSeriesId;
    }
  } catch (e) {
    AppLogger.warning(
      'resolveIssueSeriesId: catalog fetch fallback failed for issue #$issueId',
      error: e,
    );
  }

  AppLogger.warning(
    'resolveIssueSeriesId: failed to resolve series ID for issue #$issueId',
  );
  return null;
}

final issueSeriesIdProvider = FutureProvider.family<int?, int>((
  ref,
  issueId,
) async {
  return resolveIssueSeriesId(ref, issueId);
});
