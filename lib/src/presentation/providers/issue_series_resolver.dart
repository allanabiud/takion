import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

Future<int?> resolveIssueSeriesId(
  Ref ref,
  int issueId, {
  int? existingSeriesId,
}) async {
  if (existingSeriesId != null && existingSeriesId > 0) {
    return existingSeriesId;
  }

  final detailsSeriesId =
      (await ref.read(catalogRepositoryProvider).getIssueDetails(issueId))
          .series
          ?.id;
  if (detailsSeriesId != null && detailsSeriesId > 0) {
    return detailsSeriesId;
  }

  final pullEntry = await ref
      .read(pullListRepositoryProvider)
      .getEntryByIssueId(issueId);
  final pullSeriesId = pullEntry?.metronSeriesId;
  if (pullSeriesId != null && pullSeriesId > 0) {
    return pullSeriesId;
  }

  return null;
}
