import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';

Map<int, Map<String, dynamic>> _computeCollectionStatusMap(
  List<Map<String, dynamic>> itemsJson,
) {
  final map = <int, Map<String, dynamic>>{};
  for (final item in itemsJson) {
    final issueId = item['metronIssueId'] as int;
    if (issueId <= 0) continue;
    final ownershipStatus = item['ownershipStatus'] as String;
    map[issueId] = {
      'isCollected': ownershipStatus == 'owned',
      'isWishlisted': ownershipStatus == 'wishlist',
      'isRead': item['isRead'] as bool,
      'rating': item['rating'],
    };
  }
  return map;
}

final collectionStatusCacheProvider =
    FutureProvider<Map<int, IssueCollectionStatus>>((ref) async {
      final items = await ref.watch(libraryItemsStreamProvider.future);
      if (items.isEmpty) return const {};

      final itemsJson = items
          .map(
            (item) => <String, dynamic>{
              'metronIssueId': item.metronIssueId,
              'ownershipStatus': item.ownershipStatus.name,
              'isRead': item.isRead,
              'rating': item.rating,
            },
          )
          .toList(growable: false);

      final resultMap = await compute(_computeCollectionStatusMap, itemsJson);

      return resultMap.map(
        (issueId, value) => MapEntry(
          issueId,
          IssueCollectionStatus(
            isCollected: (value['isCollected'] as bool?) ?? false,
            isWishlisted: (value['isWishlisted'] as bool?) ?? false,
            isRead: (value['isRead'] as bool?) ?? false,
            rating: value['rating'] as int?,
          ),
        ),
      );
    });
