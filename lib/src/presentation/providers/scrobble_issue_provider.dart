import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/presentation/providers/settings_provider.dart';

final scrobbleIssueProvider = NotifierProvider.autoDispose
    .family<ScrobbleIssueController, AsyncValue<void>, int>(
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
    bool? markAsRead,
    bool refreshReadingSuggestion = false,
    bool refreshRateSuggestion = false,
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

      final wasCollected =
          existing?.ownershipStatus == LibraryOwnershipStatus.owned;
      final targetIsRead = markAsRead ?? (dateRead != null || (existing?.isRead ?? false));
      final targetIsCollected = addToCollection ?? wasCollected;
      final wasRead = existing?.isRead ?? false;
      final readAt = dateRead ?? DateTime.now().toUtc();
      final readLogs = await libraryRepository.getReadLogsByIssueId(_issueId);

      if (!targetIsCollected && !targetIsRead) {
        if (existing != null) {
          await libraryRepository.deleteItemByIssueId(_issueId);
        }

        ref.invalidate(collectionIssueStatusMapProvider);
        ref.invalidate(collectionStatsProvider);
        ref.invalidate(allCollectionItemsProvider);
        ref.invalidate(collectionItemsProvider);
        ref.invalidate(currentCollectionItemsProvider);
        if (refreshReadingSuggestion) {
          ref.invalidate(readingSuggestionProvider);
          ref.invalidate(readingSuggestionIssueProvider);
        }
        if (refreshRateSuggestion) {
          ref.invalidate(rateSuggestionProvider);
          ref.invalidate(rateSuggestionIssueProvider);
        }
        return;
      }

      await libraryRepository.upsertItem(
        metronIssueId: _issueId,
        metronSeriesId: seriesId,
        ownershipStatus: targetIsCollected
            ? LibraryOwnershipStatus.owned
            : LibraryOwnershipStatus.wishlist,
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
            existing?.acquiredOn ??
            dateRead ??
            DateTime.now().toUtc(),
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

      ref.invalidate(collectionIssueStatusMapProvider);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(allCollectionItemsProvider);
      ref.invalidate(collectionItemsProvider);
      ref.invalidate(currentCollectionItemsProvider);
      if (refreshReadingSuggestion) {
        ref.invalidate(readingSuggestionProvider);
        ref.invalidate(readingSuggestionIssueProvider);
      }
      if (refreshRateSuggestion) {
        ref.invalidate(rateSuggestionProvider);
        ref.invalidate(rateSuggestionIssueProvider);
      }
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
