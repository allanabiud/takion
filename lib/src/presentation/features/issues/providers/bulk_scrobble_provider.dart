import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

/// Lightweight metadata for a single issue so the bulk scrobble controller
/// doesn't need to fetch full issue details from the network.
class BulkScrobbleIssueContext {
  const BulkScrobbleIssueContext({
    this.seriesId,
    this.seriesName,
    this.issueNumber,
    this.imageUrl,
  });

  final int? seriesId;
  final String? seriesName;
  final String? issueNumber;
  final String? imageUrl;
}

final bulkScrobbleProvider =
    NotifierProvider.autoDispose<BulkScrobbleController, AsyncValue<void>>(
      BulkScrobbleController.new,
    );

class BulkScrobbleController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<({String seriesName, String issueNumber, String? imageUrl})>
  _resolveIssueMetadata(int issueId, BulkScrobbleIssueContext? ctx) async {
    String seriesName = ctx?.seriesName ?? 'Unknown Series';
    String issueNumber = ctx?.issueNumber ?? '#$issueId';
    String? imageUrl = ctx?.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      try {
        imageUrl = await ref
            .read(entityImageCacheProvider)
            .get('issue', issueId);
      } catch (_) {}
    }

    return (
      seriesName: seriesName,
      issueNumber: issueNumber,
      imageUrl: imageUrl,
    );
  }

  LibraryItemFormat _resolveDefaultFormat() {
    final setting = ref
        .read(collectionDefaultFormatProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    switch (setting) {
      case CollectionDefaultFormat.digital:
        return LibraryItemFormat.digital;
      case CollectionDefaultFormat.both:
        return LibraryItemFormat.both;
      case CollectionDefaultFormat.print:
      case null:
        return LibraryItemFormat.print;
    }
  }

  Future<void> scrobbleIssues({
    required List<int> issueIds,
    bool? markAsRead,
    DateTime? dateRead,
    Map<int, BulkScrobbleIssueContext>? issueContexts,
  }) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final libraryRepository = ref.read(libraryRepositoryProvider);
        final defaultFormat = _resolveDefaultFormat();
        final now = DateTime.now().toUtc();
        final readAt = dateRead ?? now;

        for (final issueId in issueIds) {
          final existing = await libraryRepository.getItemByIssueId(issueId);
          final ctx = issueContexts?[issueId];
          final seriesId = await resolveIssueSeriesId(
            ref,
            issueId,
            existingSeriesId: ctx?.seriesId ?? existing?.metronSeriesId,
          );

          if (seriesId == null || seriesId <= 0) continue;

          final wasCollected =
              existing?.ownershipStatus == LibraryOwnershipStatus.owned;
          final wasWishlisted =
              existing?.ownershipStatus == LibraryOwnershipStatus.wishlist;

          final targetIsRead =
              markAsRead ?? (dateRead != null || (existing?.isRead ?? false));
          final targetIsCollected =
              wasCollected; // Keep existing collection status
          final targetIsWishlisted = targetIsCollected ? false : wasWishlisted;
          final wasRead = existing?.isRead ?? false;

          await libraryRepository.upsertItem(
            metronIssueId: issueId,
            metronSeriesId: seriesId,
            ownershipStatus: targetIsCollected
                ? LibraryOwnershipStatus.owned
                : (targetIsWishlisted
                      ? LibraryOwnershipStatus.wishlist
                      : LibraryOwnershipStatus.notOwned),
            isRead: targetIsRead,
            rating: targetIsRead ? existing?.rating : null,
            firstReadAt: targetIsRead
                ? (existing?.firstReadAt ?? readAt)
                : existing?.firstReadAt,
            format: existing?.format ?? defaultFormat,
            acquiredOn: existing?.acquiredOn ?? dateRead ?? now,
          );

          if (targetIsRead && !wasRead) {
            await libraryRepository.addReadLog(
              metronIssueId: issueId,
              readAt: readAt,
            );
            final activityRepository = ref.read(activityRepositoryProvider);
            final meta = await _resolveIssueMetadata(issueId, ctx);
            await activityRepository.addEvent(
              LibraryActivityEvent(
                id: 'act-read-$issueId-${readAt.microsecondsSinceEpoch}',
                userId: 'local-user',
                type: ActivityEventType.read,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: meta.seriesName,
                issueNumber: meta.issueNumber,
                imageUrl: meta.imageUrl,
                timestamp: readAt,
              ),
            );
          } else if (!targetIsRead &&
              wasRead &&
              existing?.firstReadAt != null) {
            final readLogs = await libraryRepository.getReadLogsByIssueId(
              issueId,
            );
            final firstLog = readLogs
                .where(
                  (log) =>
                      log.readAt.toUtc().toIso8601String() ==
                      existing!.firstReadAt!.toUtc().toIso8601String(),
                )
                .cast()
                .toList();
            if (firstLog.isNotEmpty) {
              await libraryRepository.deleteReadLogById(firstLog.first.id);
            }
            final activityRepository = ref.read(activityRepositoryProvider);
            await activityRepository.deleteEventsByIssueIds([
              issueId,
            ], type: ActivityEventType.read);
          }
        }
      } finally {
        keepAlive.close();
      }
    });
  }
}
