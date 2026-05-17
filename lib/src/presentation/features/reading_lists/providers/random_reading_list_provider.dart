import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/features/reading_lists/providers/reading_lists_provider.dart';

final randomReadingListProvider = Provider<ReadingList?>((ref) {
  final listsAsync = ref.watch(readingListsProvider);
  return listsAsync.when(
    data: (lists) {
      if (lists.isEmpty) return null;

      // Filter out empty and completed lists
      final relevantLists = lists.where((list) {
        if (list.items.isEmpty) return false;

        // Check if list is completed
        // We can't easily use readingListEffectiveStatusProvider here because it's a family
        // and would require watching all lists' status, which is expensive.
        // Instead, we check the simple 'isRead' status on items first as a fast filter,
        // though full validation would require effective status.
        // For a suggestion, a slightly imperfect but fast filter is better.
        final allInitiallyRead = list.items.every((item) => item.isRead);
        if (allInitiallyRead) return false;

        return true;
      }).toList();

      if (relevantLists.isEmpty) return null;
      return relevantLists[Random().nextInt(relevantLists.length)];
    },
    error: (_, _) => null,
    loading: () => null,
  );
});
