import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_status_cache_provider.dart';

final collectionIssueStatusMapProvider =
    FutureProvider<Map<int, IssueCollectionStatus>>((ref) async {
      final items = await ref.watch(allLibraryItemsProvider.future);

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

final issueCollectionStatusProvider = Provider.family<IssueCollectionStatus?, int>((ref, issueId) {
  if (issueId <= 0) return null;
  final cache = ref.watch(collectionStatusCacheProvider);
  return cache.maybeWhen(
    data: (map) => map[issueId],
    orElse: () => null,
  );
});
