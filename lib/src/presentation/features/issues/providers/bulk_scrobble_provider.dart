import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_cache_helpers.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

final bulkScrobbleProvider =
    NotifierProvider.autoDispose<BulkScrobbleController, AsyncValue<void>>(
      BulkScrobbleController.new,
    );

class BulkScrobbleController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

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
          final seriesId = await resolveIssueSeriesId(
            ref,
            issueId,
            existingSeriesId: existing?.metronSeriesId,
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
            final catalogRepository = ref.read(catalogRepositoryProvider);
            final imageCache = ref.read(entityImageCacheProvider);
            String? imageUrl;
            String seriesName = 'Unknown Series';
            String issueNumber = '';
            try {
              String? cachedUrl;
              try {
                cachedUrl = await imageCache.get('issue', issueId);
              } catch (_) {}
              if (cachedUrl != null && cachedUrl.isNotEmpty) {
                imageUrl = cachedUrl;
              }
              final details = await catalogRepository.getIssueDetails(issueId);
              seriesName = details.series?.name ?? 'Unknown Series';
              issueNumber = details.number;
              imageUrl ??= details.image;
              if (details.image != null && details.image!.isNotEmpty) {
                await imageCache.set('issue', issueId, details.image!);
              }
            } catch (_) {}
            await activityRepository.addEvent(
              LibraryActivityEvent(
                id: 'act-read-$issueId-${readAt.microsecondsSinceEpoch}',
                userId: 'local-user',
                type: ActivityEventType.read,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
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
            final catalogRepository = ref.read(catalogRepositoryProvider);
            final imageCache = ref.read(entityImageCacheProvider);
            String? imageUrl;
            String seriesName = 'Unknown Series';
            String issueNumber = '';
            try {
              String? cachedUrl;
              try {
                cachedUrl = await imageCache.get('issue', issueId);
              } catch (_) {}
              if (cachedUrl != null && cachedUrl.isNotEmpty) {
                imageUrl = cachedUrl;
              }
              final details = await catalogRepository.getIssueDetails(issueId);
              seriesName = details.series?.name ?? 'Unknown Series';
              issueNumber = details.number;
              imageUrl ??= details.image;
              if (details.image != null && details.image!.isNotEmpty) {
                await imageCache.set('issue', issueId, details.image!);
              }
            } catch (_) {}
            await activityRepository.addEvent(
              LibraryActivityEvent(
                id: 'act-unrd-$issueId-${now.microsecondsSinceEpoch}',
                userId: 'local-user',
                type: ActivityEventType.unread,
                issueId: issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          }
        }

        await invalidateLibraryItemsLocalCache(ref);
      } finally {
        keepAlive.close();
      }
    });
  }
}
