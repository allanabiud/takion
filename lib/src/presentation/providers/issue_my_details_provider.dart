import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/domain/entities/library_read_log.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class IssueMyDetailsData {
  const IssueMyDetailsData({required this.item, required this.readLogs});

  final LibraryItem? item;
  final List<LibraryReadLog> readLogs;
}

final issueMyDetailsProvider = FutureProvider.family<IssueMyDetailsData, int>((
  ref,
  issueId,
) async {
  final libraryRepository = ref.read(libraryRepositoryProvider);
  final item = await libraryRepository.getItemByIssueId(issueId);
  final logs = await libraryRepository.getReadLogsByIssueId(issueId);
  return IssueMyDetailsData(item: item, readLogs: logs);
});

final issueMyDetailsControllerProvider =
    NotifierProvider.family<IssueMyDetailsController, AsyncValue<void>, int>(
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
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final libraryRepository = ref.read(libraryRepositoryProvider);
      final catalogRepository = ref.read(catalogRepositoryProvider);

      final existing = await libraryRepository.getItemByIssueId(_issueId);
      final seriesId =
          existing?.metronSeriesId ??
          (await catalogRepository.getIssueDetails(_issueId)).series?.id;

      if (seriesId == null || seriesId <= 0) {
        throw StateError('Unable to determine series for issue $_issueId');
      }

      if (!isCollected && !isRead) {
        if (existing != null) {
          await libraryRepository.deleteItemByIssueId(_issueId);
        }
      } else {
        final now = DateTime.now().toUtc();
        final resolvedRating = isRead ? rating : null;
        final firstReadAt = isRead ? (existing?.firstReadAt ?? now) : null;

        await libraryRepository.upsertItem(
          metronIssueId: _issueId,
          metronSeriesId: seriesId,
          ownershipStatus: isCollected
              ? LibraryOwnershipStatus.owned
              : LibraryOwnershipStatus.wishlist,
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
      }

      ref.invalidate(issueMyDetailsProvider(_issueId));
      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(allCollectionItemsProvider);
      ref.invalidate(collectionItemsProvider);
      ref.invalidate(currentCollectionItemsProvider);
    });
  }

  Future<void> addReadLogAt(DateTime readAt) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
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

      ref.invalidate(issueMyDetailsProvider(_issueId));
      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(allCollectionItemsProvider);
      ref.invalidate(collectionItemsProvider);
      ref.invalidate(currentCollectionItemsProvider);
    });
  }

  Future<void> addReadLogNow() {
    return addReadLogAt(DateTime.now().toUtc());
  }

  Future<void> deleteReadLogById(String readLogId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
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

      ref.invalidate(issueMyDetailsProvider(_issueId));
      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(allCollectionItemsProvider);
      ref.invalidate(collectionItemsProvider);
      ref.invalidate(currentCollectionItemsProvider);
    });
  }
}
