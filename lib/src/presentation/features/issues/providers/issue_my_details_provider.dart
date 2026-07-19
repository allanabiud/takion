import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_series_resolver.dart';
import 'package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_cache_helpers.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class IssueMyDetailsData {
  const IssueMyDetailsData({required this.item, required this.readLogs});

  final LibraryItem? item;
  final List<LibraryReadLog> readLogs;
}

final issueMyDetailsProvider = FutureProvider.autoDispose.family<IssueMyDetailsData, int>((
  ref,
  issueId,
) async {
  final libraryRepository = ref.read(libraryRepositoryProvider);
  final item = await libraryRepository.getItemByIssueId(issueId);
  final logs = await libraryRepository.getReadLogsByIssueId(issueId);
  return IssueMyDetailsData(item: item, readLogs: logs);
});

final issueMyDetailsControllerProvider =
    NotifierProvider.autoDispose.family<IssueMyDetailsController, AsyncValue<void>, int>(
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

        if (!isCollected && !isRead) {
          if (existing != null) {
            await libraryRepository.deleteItemByIssueId(_issueId);
          }
          ref.read(collectionStatusCacheProvider.notifier).removeIssue(_issueId);
          await invalidateLibraryItemsLocalCache(ref);
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

          if (isRead && !(existing?.isRead ?? false)) {
            await libraryRepository.addReadLog(
              metronIssueId: _issueId,
              readAt: now,
            );
          }

          ref.read(collectionStatusCacheProvider.notifier).updateIssue(
            _issueId,
            IssueCollectionStatus(
              isCollected: isCollected,
              isWishlisted: existing?.ownershipStatus == LibraryOwnershipStatus.wishlist,
              isRead: isRead,
              rating: resolvedRating,
            ),
          );
        }
        await invalidateLibraryItemsLocalCache(ref);
        ref.invalidate(issueMyDetailsProvider(_issueId));
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
          throw StateError('Add the issue to your library before logging reads.');
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
        ref.read(collectionStatusCacheProvider.notifier).updateIssue(
          _issueId,
          IssueCollectionStatus(
            isCollected: item.ownershipStatus == LibraryOwnershipStatus.owned,
            isWishlisted: item.ownershipStatus == LibraryOwnershipStatus.wishlist,
            isRead: true,
            rating: item.rating,
          ),
        );
        await invalidateLibraryItemsLocalCache(ref);
        ref.invalidate(issueMyDetailsProvider(_issueId));
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
        await invalidateLibraryItemsLocalCache(ref);
        ref.invalidate(issueMyDetailsProvider(_issueId));
      } finally {
        keepAlive.close();
      }
    });
  }
}
