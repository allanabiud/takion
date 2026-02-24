import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

class IssueCollectionStatus {
  const IssueCollectionStatus({
    required this.isCollected,
    required this.isRead,
    this.rating,
  });

  final bool isCollected;
  final bool isRead;
  final int? rating;
}

final collectionIssueStatusMapProvider =
    FutureProvider<Map<int, IssueCollectionStatus>>((ref) async {
  final repository = ref.watch(metronRepositoryProvider);

  final firstPage = await repository.getCollectionItems(page: 1);
  final pageSize = firstPage.results.isEmpty ? 1 : firstPage.results.length;
  final totalPages = ((firstPage.count / pageSize).ceil()).clamp(1, 9999);

  final map = <int, IssueCollectionStatus>{};

  void mergePage(List<CollectionItem> items) {
    for (final item in items) {
      final issueId = item.issue?.id;
      if (issueId == null || issueId <= 0) continue;
      map[issueId] = IssueCollectionStatus(
        isCollected: item.quantity > 0,
        isRead: item.isRead,
        rating: item.rating,
      );
    }
  }

  mergePage(firstPage.results);

  for (var page = 2; page <= totalPages; page++) {
    final pageData = await repository.getCollectionItems(page: page);
    mergePage(pageData.results);
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
