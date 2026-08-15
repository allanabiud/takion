import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";

class ReadingHistoryEntry {
  const ReadingHistoryEntry({required this.item, required this.readAt});

  final CollectionItem item;
  final DateTime? readAt;
}

final readingHistoryCollectionItemsProvider =
    FutureProvider.autoDispose<List<ReadingHistoryEntry>>((ref) async {
      final libraryItems = await ref.watch(allLibraryItemsProvider.future);
      final collectionItems = await ref.watch(
        allCollectionItemsProvider.future,
      );

      final readAtByIssueId = <int, DateTime?>{
        for (final item in libraryItems)
          if (item.isRead) item.metronIssueId: item.firstReadAt,
      };

      final entries =
          collectionItems
              .where((item) {
                final issueId = item.issue?.id;
                return issueId != null && readAtByIssueId.containsKey(issueId);
              })
              .map(
                (item) => ReadingHistoryEntry(
                  item: item,
                  readAt: readAtByIssueId[item.issue!.id],
                ),
              )
              .toList()
            ..sort((a, b) {
              final aDate = a.readAt;
              final bDate = b.readAt;
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate);
            });

      return entries;
    });
