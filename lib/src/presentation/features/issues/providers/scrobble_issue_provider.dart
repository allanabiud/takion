import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_my_details_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_cache_helpers.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';


final scrobbleIssueProvider =
    NotifierProvider.autoDispose.family<ScrobbleIssueController, AsyncValue<void>, int>(
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

  }) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        AppLogger.info('Scrobble started for issue #$_issueId: collection=$addToCollection, read=$markAsRead, wishlist=$addToWishlist, rating=$rating');
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
          AppLogger.info('Scrobble: deleted item for issue #$_issueId');
          if (wasCollected || wasRead || wasWishlisted) {
            final metadata = await _resolveIssueMetadata();
            if (metadata != null) {
              final repository = ref.read(activityRepositoryProvider);
              if (wasCollected) {
                await repository.addEvent(
                  LibraryActivityEvent(
                    id: 'act-ucol-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
                    userId: 'local-user',
                    type: ActivityEventType.uncollected,
                    issueId: _issueId,
                    seriesId: seriesId,
                    seriesName: metadata.seriesName,
                    issueNumber: metadata.issueNumber,
                    imageUrl: metadata.imageUrl,
                    timestamp: DateTime.now().toUtc(),
                  ),
                );
              }
              if (wasRead) {
                await repository.addEvent(
                  LibraryActivityEvent(
                    id: 'act-unrd-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
                    userId: 'local-user',
                    type: ActivityEventType.unread,
                    issueId: _issueId,
                    seriesId: seriesId,
                    seriesName: metadata.seriesName,
                    issueNumber: metadata.issueNumber,
                    imageUrl: metadata.imageUrl,
                    timestamp: DateTime.now().toUtc(),
                  ),
                );
              }
              if (wasWishlisted) {
                await repository.addEvent(
                  LibraryActivityEvent(
                    id: 'act-uwsh-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
                    userId: 'local-user',
                    type: ActivityEventType.unwishlisted,
                    issueId: _issueId,
                    seriesId: seriesId,
                    seriesName: metadata.seriesName,
                    issueNumber: metadata.issueNumber,
                    imageUrl: metadata.imageUrl,
                    timestamp: DateTime.now().toUtc(),
                  ),
                );
              }
            }
          }
          ref.read(collectionStatusCacheProvider.notifier).removeIssue(_issueId);
          await invalidateLibraryItemsLocalCache(ref);
          ref.invalidate(issueMyDetailsProvider(_issueId));
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
          AppLogger.info('Scrobble: created read log for issue #$_issueId at $readAt');
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
            AppLogger.info('Scrobble: deleted read log for issue #$_issueId');
          }
        }
        await _recordActivityEvents(
          seriesId: seriesId,
          wasCollected: wasCollected,
          isCollected: targetIsCollected,
          wasWishlisted: wasWishlisted,
          isWishlisted: targetIsWishlisted,
          wasRead: wasRead,
          isRead: targetIsRead,
          wasRating: existing?.rating,
          isRating: rating,
        );

        AppLogger.info('Scrobble completed for issue #$_issueId');
        ref.read(collectionStatusCacheProvider.notifier).updateIssue(
          _issueId,
          IssueCollectionStatus(
            isCollected: targetIsCollected,
            isWishlisted: targetIsWishlisted,
            isRead: targetIsRead,
            rating: targetIsRead ? (rating ?? existing?.rating) : null,
          ),
        );
        await invalidateLibraryItemsLocalCache(ref);
        ref.invalidate(issueMyDetailsProvider(_issueId));
      } finally {
        keepAlive.close();
      }
    });
  }

  Future<void> _recordActivityEvents({
    required int seriesId,
    required bool wasCollected,
    required bool isCollected,
    required bool wasWishlisted,
    required bool isWishlisted,
    required bool wasRead,
    required bool isRead,
    int? wasRating,
    int? isRating,
  }) async {
    final metadata = await _resolveIssueMetadata();
    if (metadata == null) return;

    final repository = ref.read(activityRepositoryProvider);

    if (wasCollected != isCollected) {
      await repository.addEvent(
        LibraryActivityEvent(
          id: 'act-${isCollected ? 'col' : 'ucol'}-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
          userId: 'local-user',
          type: isCollected ? ActivityEventType.collected : ActivityEventType.uncollected,
          issueId: _issueId,
          seriesId: seriesId,
          seriesName: metadata.seriesName,
          issueNumber: metadata.issueNumber,
          imageUrl: metadata.imageUrl,
          timestamp: DateTime.now().toUtc(),
        ),
      );
    }

    if (wasRead != isRead) {
      await repository.addEvent(
        LibraryActivityEvent(
          id: 'act-${isRead ? 'read' : 'unrd'}-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
          userId: 'local-user',
          type: isRead ? ActivityEventType.read : ActivityEventType.unread,
          issueId: _issueId,
          seriesId: seriesId,
          seriesName: metadata.seriesName,
          issueNumber: metadata.issueNumber,
          imageUrl: metadata.imageUrl,
          timestamp: DateTime.now().toUtc(),
        ),
      );
    }

    if (wasWishlisted != isWishlisted) {
      await repository.addEvent(
        LibraryActivityEvent(
          id: 'act-${isWishlisted ? 'wsh' : 'uwsh'}-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
          userId: 'local-user',
          type: isWishlisted ? ActivityEventType.wishlisted : ActivityEventType.unwishlisted,
          issueId: _issueId,
          seriesId: seriesId,
          seriesName: metadata.seriesName,
          issueNumber: metadata.issueNumber,
          imageUrl: metadata.imageUrl,
          timestamp: DateTime.now().toUtc(),
        ),
      );
    }

    if (isRating != null && isRating > 0 && isRating != wasRating) {
      await repository.addEvent(
        LibraryActivityEvent(
          id: 'act-rat-$_issueId-${DateTime.now().microsecondsSinceEpoch}',
          userId: 'local-user',
          type: ActivityEventType.rated,
          issueId: _issueId,
          seriesId: seriesId,
          seriesName: metadata.seriesName,
          issueNumber: metadata.issueNumber,
          imageUrl: metadata.imageUrl,
          timestamp: DateTime.now().toUtc(),
          metadata: {'rating': isRating},
        ),
      );
    }
  }


  Future<_IssueMetadata?> _resolveIssueMetadata() async {
    try {
      final details = await ref
          .read(catalogRepositoryProvider)
          .getIssueDetails(_issueId);
      return _IssueMetadata(
        seriesName: details.series?.name ?? 'Unknown Series',
        issueNumber: details.number,
        imageUrl: details.image,
      );
    } catch (_) {
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

class _IssueMetadata {
  const _IssueMetadata({
    required this.seriesName,
    required this.issueNumber,
    this.imageUrl,
  });

  final String seriesName;
  final String issueNumber;
  final String? imageUrl;
}
