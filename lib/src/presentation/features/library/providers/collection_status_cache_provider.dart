import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_model.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

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
    StreamProvider<Map<int, IssueCollectionStatus>>((ref) async* {
      final db = ref.watch(driftDatabaseProvider);
      yield* db.libraryItemDao.watchStatusRows().asyncMap((rows) async {
        if (rows.isEmpty) return const <int, IssueCollectionStatus>{};

        final itemsJson = rows
            .map(
              (row) => <String, dynamic>{
                'metronIssueId': row.metronIssueId,
                'ownershipStatus': row.ownershipStatus,
                'isRead': row.isRead,
                'rating': row.rating,
              },
            )
            .toList(growable: false);

        final resultMap = await compute(
          _computeCollectionStatusMap,
          itemsJson,
        );

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
    });
