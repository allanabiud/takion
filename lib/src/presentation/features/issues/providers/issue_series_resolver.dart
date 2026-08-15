import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/presentation/providers/providers.dart";

/// Resolves a Metron series ID via five tiers: existing ID, pull list, library, local DB, then network.
Future<int?> resolveIssueSeriesId(
  Ref ref,
  int issueId, {
  int? existingSeriesId,
}) async {
  if (existingSeriesId != null && existingSeriesId > 0) {
    AppLogger.debug(
      "resolveIssueSeriesId: resolved $existingSeriesId via existingSeriesId for issue #$issueId",
    );
    return existingSeriesId;
  }

  final pullEntry = await ref
      .read(pullListRepositoryProvider)
      .getEntryByIssueId(issueId);
  final pullSeriesId = pullEntry?.metronSeriesId;
  if (pullSeriesId != null && pullSeriesId > 0) {
    AppLogger.debug(
      "resolveIssueSeriesId: resolved $pullSeriesId via pull list for issue #$issueId",
    );
    return pullSeriesId;
  }

  final libraryItem = await ref
      .read(libraryRepositoryProvider)
      .getItemByIssueId(issueId);
  final libSeriesId = libraryItem?.metronSeriesId;
  if (libSeriesId != null && libSeriesId > 0) {
    AppLogger.debug(
      "resolveIssueSeriesId: resolved $libSeriesId via library item for issue #$issueId",
    );
    return libSeriesId;
  }

  final dbIssue = await ref
      .read(localCatalogRepositoryProvider)
      .getIssue(issueId);
  final dbSeriesId = dbIssue?.seriesId;
  if (dbSeriesId != null && dbSeriesId > 0) {
    AppLogger.debug(
      "resolveIssueSeriesId: resolved $dbSeriesId via metron_issues for issue #$issueId",
    );
    return dbSeriesId;
  }

  try {
    AppLogger.debug(
      "resolveIssueSeriesId: falling back to catalog fetch for issue #$issueId",
    );
    final details = await ref
        .read(metronRepositoryProvider)
        .getIssueDetails(issueId);
    final netSeriesId = details.series?.id;
    if (netSeriesId != null && netSeriesId > 0) {
      AppLogger.debug(
        "resolveIssueSeriesId: resolved $netSeriesId via catalog fetch for issue #$issueId",
      );
      return netSeriesId;
    }
  } catch (e) {
    AppLogger.warning(
      "resolveIssueSeriesId: catalog fetch fallback failed for issue #$issueId",
      error: e,
    );
  }

  AppLogger.warning(
    "resolveIssueSeriesId: failed to resolve series ID for issue #$issueId",
  );
  return null;
}

final issueSeriesIdProvider = FutureProvider.family<int?, int>((
  ref,
  issueId,
) async {
  return resolveIssueSeriesId(ref, issueId);
});
