import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/features/library/providers/category_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class IssueMyDetailsData {
  const IssueMyDetailsData({required this.item, required this.readLogs});

  final LibraryItem? item;
  final List<LibraryReadLog> readLogs;
}

final issueMyDetailsProvider = FutureProvider.autoDispose
    .family<IssueMyDetailsData, int>((ref, issueId) async {
      final libraryRepository = ref.read(libraryRepositoryProvider);
      final item = await libraryRepository.getItemByIssueId(issueId);
      final logs = await libraryRepository.getReadLogsByIssueId(issueId);
      return IssueMyDetailsData(item: item, readLogs: logs);
    });

final issueMyDetailsControllerProvider = NotifierProvider.autoDispose
    .family<IssueMyDetailsController, AsyncValue<void>, int>(
      IssueMyDetailsController.new,
    );

class IssueMyDetailsController extends Notifier<AsyncValue<void>> {
  IssueMyDetailsController(this._issueId);

  final int _issueId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> saveDetails({
    required bool isCollected,
    required bool isRead,
    required int? rating,
    required DateTime? purchaseDate,
    required double? pricePaid,
    required int quantityOwned,
    required LibraryItemFormat format,
    required String? conditionGrade,
    required String? notes,
  }) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final libraryRepository = ref.read(libraryRepositoryProvider);
        final activityRepository = ref.read(activityRepositoryProvider);

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
        final wasRead = existing?.isRead ?? false;

        Future<void> recordEvents() async {
          final now = DateTime.now().toUtc();
          final imageCache = ref.read(entityImageCacheProvider);
          String? imageUrl;
          String seriesName = 'Unknown Series';
          String issueNumber = '#$_issueId';
          try {
            final cachedUrl = await imageCache.get('issue', _issueId);
            if (cachedUrl != null && cachedUrl.isNotEmpty) {
              imageUrl = cachedUrl;
            }
          } catch (_) {}
          try {
            final catalogRepository = ref.read(catalogRepositoryProvider);
            final details = await catalogRepository.getIssueDetails(_issueId);
            seriesName = details.series?.name ?? seriesName;
            issueNumber = details.number.isNotEmpty
                ? details.number
                : issueNumber;
            imageUrl ??= details.image;
            if (details.image != null && details.image!.isNotEmpty) {
              try {
                await imageCache.set('issue', _issueId, details.image!);
              } catch (_) {}
            }
          } catch (_) {}

          if (isCollected && !wasCollected) {
            await activityRepository.addEvent(
              LibraryActivityEvent(
                id: 'act-col-$_issueId-${now.microsecondsSinceEpoch}',
                userId: 'local-user',
                type: ActivityEventType.collected,
                issueId: _issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          } else if (!isCollected && wasCollected) {
            await activityRepository.deleteEventsByIssueIds([
              _issueId,
            ], type: ActivityEventType.collected);
          }

          if (isRead && !wasRead) {
            await activityRepository.addEvent(
              LibraryActivityEvent(
                id: 'act-read-$_issueId-${now.microsecondsSinceEpoch}',
                userId: 'local-user',
                type: ActivityEventType.read,
                issueId: _issueId,
                seriesId: seriesId,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                timestamp: now,
              ),
            );
          } else if (!isRead && wasRead) {
            await activityRepository.deleteEventsByIssueIds([
              _issueId,
            ], type: ActivityEventType.read);
          }
        }

        if (!isCollected && !isRead) {
          if (existing != null) {
            await libraryRepository.deleteItemByIssueId(_issueId);
          }
          await recordEvents();
        } else {
          final now = DateTime.now().toUtc();
          final resolvedRating = isRead ? rating : null;
          final firstReadAt = isRead ? (existing?.firstReadAt ?? now) : null;

          await libraryRepository.upsertItem(
            metronIssueId: _issueId,
            metronSeriesId: seriesId,
            ownershipStatus: isCollected
                ? LibraryOwnershipStatus.owned
                : LibraryOwnershipStatus.notOwned,
            isRead: isRead,
            rating: resolvedRating,
            purchaseDate: purchaseDate,
            pricePaid: pricePaid,
            quantityOwned: quantityOwned,
            format: format,
            firstReadAt: firstReadAt,
            conditionGrade: conditionGrade,
            notes: notes,
            acquiredOn: existing?.acquiredOn ?? now,
          );

          if (isRead && !wasRead) {
            await libraryRepository.addReadLog(
              metronIssueId: _issueId,
              readAt: now,
            );
          }

          await recordEvents();
        }
        ref.invalidate(issueMyDetailsProvider(_issueId));
        ref.invalidate(libraryBasicStatsProvider);
        ref.invalidate(libraryEntityStatsProvider);
        ref.invalidate(libraryReadingTrendsProvider);
        ref.invalidate(libraryRecentlyFinishedProvider);
        ref.invalidate(collectionStatsProvider);
        ref.invalidate(categoryInsightsProvider);
      } finally {
        keepAlive.close();
      }
    });
  }

  Future<void> addReadLogAt(DateTime readAt) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final libraryRepository = ref.read(libraryRepositoryProvider);
        final item = await libraryRepository.getItemByIssueId(_issueId);
        if (item == null) {
          throw StateError(
            'Add the issue to your library before logging reads.',
          );
        }

        final normalizedReadAt = readAt.toUtc();

        await libraryRepository.upsertItem(
          metronIssueId: item.metronIssueId,
          metronSeriesId: item.metronSeriesId,
          ownershipStatus: item.ownershipStatus,
          isRead: true,
          rating: item.rating,
          purchaseDate: item.purchaseDate,
          pricePaid: item.pricePaid,
          quantityOwned: item.quantityOwned,
          format: item.format,
          firstReadAt: item.firstReadAt ?? normalizedReadAt,
          conditionGrade: item.conditionGrade,
          notes: item.notes,
          acquiredOn: item.acquiredOn,
        );

        await libraryRepository.addReadLog(
          metronIssueId: _issueId,
          readAt: normalizedReadAt,
        );

        final activityRepository = ref.read(activityRepositoryProvider);
        final imageCache = ref.read(entityImageCacheProvider);
        String? imageUrl;
        String seriesName = 'Unknown Series';
        String issueNumber = '#$_issueId';
        try {
          final cachedUrl = await imageCache.get('issue', _issueId);
          if (cachedUrl != null && cachedUrl.isNotEmpty) {
            imageUrl = cachedUrl;
          }
        } catch (_) {}
        try {
          final catalogRepository = ref.read(catalogRepositoryProvider);
          final details = await catalogRepository.getIssueDetails(_issueId);
          seriesName = details.series?.name ?? seriesName;
          issueNumber = details.number.isNotEmpty
              ? details.number
              : issueNumber;
          imageUrl ??= details.image;
          if (details.image != null && details.image!.isNotEmpty) {
            try {
              await imageCache.set('issue', _issueId, details.image!);
            } catch (_) {}
          }
        } catch (_) {}
        await activityRepository.addEvent(
          LibraryActivityEvent(
            id: 'act-read-$_issueId-${normalizedReadAt.microsecondsSinceEpoch}',
            userId: 'local-user',
            type: ActivityEventType.read,
            issueId: _issueId,
            seriesId: item.metronSeriesId,
            seriesName: seriesName,
            issueNumber: issueNumber,
            imageUrl: imageUrl,
            timestamp: normalizedReadAt,
          ),
        );

        ref.invalidate(issueMyDetailsProvider(_issueId));
        ref.invalidate(libraryBasicStatsProvider);
        ref.invalidate(libraryEntityStatsProvider);
        ref.invalidate(libraryReadingTrendsProvider);
        ref.invalidate(libraryRecentlyFinishedProvider);
        ref.invalidate(collectionStatsProvider);
        ref.invalidate(categoryInsightsProvider);
      } finally {
        keepAlive.close();
      }
    });
  }

  Future<void> addReadLogNow() {
    return addReadLogAt(DateTime.now().toUtc());
  }

  Future<void> deleteReadLogById(String readLogId) async {
    final keepAlive = ref.keepAlive();
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final libraryRepository = ref.read(libraryRepositoryProvider);
        final item = await libraryRepository.getItemByIssueId(_issueId);
        if (item == null) {
          throw StateError('No library item found for this issue.');
        }

        await libraryRepository.deleteReadLogById(readLogId);

        final remainingLogs = await libraryRepository.getReadLogsByIssueId(
          _issueId,
        );
        remainingLogs.sort((a, b) => a.readAt.compareTo(b.readAt));
        final nextFirstReadAt = remainingLogs.isEmpty
            ? null
            : remainingLogs.first.readAt;

        await libraryRepository.upsertItem(
          metronIssueId: item.metronIssueId,
          metronSeriesId: item.metronSeriesId,
          ownershipStatus: item.ownershipStatus,
          isRead: item.isRead,
          rating: item.rating,
          purchaseDate: item.purchaseDate,
          pricePaid: item.pricePaid,
          quantityOwned: item.quantityOwned,
          format: item.format,
          firstReadAt: nextFirstReadAt,
          conditionGrade: item.conditionGrade,
          notes: item.notes,
          acquiredOn: item.acquiredOn,
        );

        if (remainingLogs.isEmpty) {
          final activityRepository = ref.read(activityRepositoryProvider);
          await activityRepository.deleteEventsByIssueIds([
            _issueId,
          ], type: ActivityEventType.read);
        }

        ref.invalidate(issueMyDetailsProvider(_issueId));
        ref.invalidate(libraryBasicStatsProvider);
        ref.invalidate(libraryEntityStatsProvider);
        ref.invalidate(libraryReadingTrendsProvider);
        ref.invalidate(libraryRecentlyFinishedProvider);
        ref.invalidate(collectionStatsProvider);
        ref.invalidate(categoryInsightsProvider);
      } finally {
        keepAlive.close();
      }
    });
  }
}
