import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          }
        }

        await invalidateLibraryItemsLocalCache(ref);
      } finally {
        keepAlive.close();
      }
    });
  }
}
