import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/features/library/providers/collection_cache_helpers.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_my_details_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

final scrobbleIssueProvider =
    NotifierProvider.family<ScrobbleIssueController, AsyncValue<void>, int>(
      ScrobbleIssueController.new,
    );

class ScrobbleIssueController extends Notifier<AsyncValue<void>> {
  ScrobbleIssueController(this._issueId);

  final int _issueId;

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

  Future<void> scrobble({
    DateTime? dateRead,
    int? rating,
    bool? addToCollection,
    bool? addToWishlist,
    bool? markAsRead,
    bool refreshReadingSuggestion = false,
    bool refreshRateSuggestion = false,
  }) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final libraryRepository = ref.read(libraryRepositoryProvider);

        final existing = await libraryRepository.getItemByIssueId(_issueId);
        final seriesId = await resolveIssueSeriesId(
          ref,
          _issueId,
          existingSeriesId: existing?.metronSeriesId,
        );

        if (seriesId == null || seriesId <= 0) {
          throw StateError(
            'Could not save this issue because its series metadata is unavailable. '
            'Try refreshing the issue details, then save again.',
          );
        }

        final wasCollected =
            existing?.ownershipStatus == LibraryOwnershipStatus.owned;
        final wasWishlisted =
            existing?.ownershipStatus == LibraryOwnershipStatus.wishlist;
        final targetIsRead =
            markAsRead ?? (dateRead != null || (existing?.isRead ?? false));

        // Honor Auto-Collect on Read setting
        var targetIsCollected = addToCollection ?? wasCollected;
        if (targetIsRead && !targetIsCollected) {
          final autoCollectSetting = ref
              .read(autoCollectOnReadProvider)
              .maybeWhen(data: (v) => v, orElse: () => false);
          if (autoCollectSetting) {
            targetIsCollected = true;
          }
        }

        final targetIsWishlisted = targetIsCollected
            ? false
            : (addToWishlist ?? wasWishlisted);
        final wasRead = existing?.isRead ?? false;
        final readAt = dateRead ?? DateTime.now().toUtc();
        final readLogs = await libraryRepository.getReadLogsByIssueId(_issueId);

        if (!targetIsCollected && !targetIsRead && !targetIsWishlisted) {
          if (existing != null) {
            await libraryRepository.deleteItemByIssueId(_issueId);
          }
          await invalidateLibraryItemsLocalCache(ref);

          ref.invalidate(issueMyDetailsProvider(_issueId));
          ref.invalidate(collectionIssueStatusMapProvider);
          ref.invalidate(collectionStatsProvider);
          invalidateLibraryCollectionProviders(ref);
          return;
        }

        await libraryRepository.upsertItem(
          metronIssueId: _issueId,
          metronSeriesId: seriesId,
          ownershipStatus: targetIsCollected
              ? LibraryOwnershipStatus.owned
              : (targetIsWishlisted
                    ? LibraryOwnershipStatus.wishlist
                    : LibraryOwnershipStatus.notOwned),
          isRead: targetIsRead,
          rating: targetIsRead ? (rating ?? existing?.rating) : null,
          firstReadAt: targetIsRead
              ? (existing?.firstReadAt ?? readAt)
              : (() {
                  if (existing?.firstReadAt == null) return null;
                  final remaining = readLogs
                      .where(
                        (log) =>
                            log.readAt.toUtc().toIso8601String() !=
                            existing!.firstReadAt!.toUtc().toIso8601String(),
                      )
                      .toList();
                  if (remaining.isEmpty) return null;
                  remaining.sort((a, b) => a.readAt.compareTo(b.readAt));
                  return remaining.first.readAt;
                })(),
          format: existing?.format ?? _resolveDefaultFormat(),
          acquiredOn:
              existing?.acquiredOn ?? dateRead ?? DateTime.now().toUtc(),
        );

        if (targetIsRead && !wasRead) {
          await libraryRepository.addReadLog(
            metronIssueId: _issueId,
            readAt: readAt,
          );
        } else if (!targetIsRead && wasRead && existing?.firstReadAt != null) {
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
        await invalidateLibraryItemsLocalCache(ref);

        ref.invalidate(issueMyDetailsProvider(_issueId));
        ref.invalidate(collectionIssueStatusMapProvider);
        ref.invalidate(collectionStatsProvider);
        invalidateLibraryCollectionProviders(ref);
        ref.invalidate(readingSuggestionProvider);
        ref.invalidate(readingSuggestionIssueProvider);
        ref.invalidate(rateSuggestionProvider);
        ref.invalidate(rateSuggestionIssueProvider);
      } finally {
        keepAlive.close();
      }
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
