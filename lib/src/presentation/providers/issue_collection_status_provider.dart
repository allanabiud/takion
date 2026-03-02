import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';

class IssueCollectionStatus {
  const IssueCollectionStatus({
    required this.isCollected,
    required this.isWishlisted,
    required this.isRead,
    this.rating,
  });

  final bool isCollected;
  final bool isWishlisted;
  final bool isRead;
  final int? rating;
}

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

final issueCollectionStatusProvider =
    Provider.family<IssueCollectionStatus?, int?>((ref, issueId) {
      if (issueId == null || issueId <= 0) return null;

      final statusMapAsync = ref.watch(collectionIssueStatusMapProvider);
      return statusMapAsync.maybeWhen(
        data: (statusMap) => statusMap[issueId],
        orElse: () => null,
      );
    });
