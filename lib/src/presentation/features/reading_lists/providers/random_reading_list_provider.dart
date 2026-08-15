import "dart:math";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/features/reading_lists/providers/local_reading_lists_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";

final randomReadingListProvider = Provider<LocalReadingList?>((ref) {
  final listsAsync = ref.watch(localReadingListsProvider);
  final statusMapAsync = ref.watch(collectionIssueStatusMapProvider);

  return listsAsync.when(
    data: (lists) {
      if (lists.isEmpty) return null;

      final statusMap = statusMapAsync.value;

      final relevantLists = lists.where((list) {
        if (list.items.isEmpty) return false;

        bool allRead = true;
        for (final item in list.items) {
          bool effectiveIsRead = item.isRead;

          if (!item.isSeries) {
            final idString = item.targetId.replaceAll(RegExp(r"^.*-"), "");
            final id = int.tryParse(idString) ?? 0;
            if (id > 0) {
              if (statusMap != null) {
                // Not in library (status == null) means unread.
                final status = statusMap[id];
                effectiveIsRead = status?.isRead ?? false;
              } else {
                // Status map still loading, fallback to internal state.
                effectiveIsRead = item.isRead;
              }
            }
          }
          // Series items use item.isRead to avoid async lookups here.

          if (!effectiveIsRead) {
            allRead = false;
            break;
          }
        }

        return !allRead;
      }).toList();

      if (relevantLists.isEmpty) return null;
      return relevantLists[Random().nextInt(relevantLists.length)];
    },
    error: (_, _) => null,
    loading: () => null,
  );
});
