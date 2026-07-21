import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

final collectionStatusCacheProvider =
    NotifierProvider.autoDispose<
      CollectionStatusCacheNotifier,
      AsyncValue<Map<int, IssueCollectionStatus>>
    >(CollectionStatusCacheNotifier.new);

class CollectionStatusCacheNotifier
    extends Notifier<AsyncValue<Map<int, IssueCollectionStatus>>> {
  @override
  AsyncValue<Map<int, IssueCollectionStatus>> build() {
    final allItems = ref.watch(allLibraryItemsProvider);
    return allItems.whenData((items) {
      final map = <int, IssueCollectionStatus>{};
      for (final item in items) {
        final issueId = item.metronIssueId;
        if (issueId <= 0) continue;
        map[issueId] = IssueCollectionStatus(
          isCollected: item.ownershipStatus == LibraryOwnershipStatus.owned,
          isWishlisted: item.ownershipStatus == LibraryOwnershipStatus.wishlist,
          isRead: item.isRead,
          rating: item.rating,
        );
      }
      return map;
    });
  }

  void updateIssue(int issueId, IssueCollectionStatus status) {
    state = state.whenData((map) {
      final updated = Map<int, IssueCollectionStatus>.from(map);
      updated[issueId] = status;
      return updated;
    });
  }

  void removeIssue(int issueId) {
    state = state.whenData((map) {
      final updated = Map<int, IssueCollectionStatus>.from(map);
      updated.remove(issueId);
      return updated;
    });
  }
}
