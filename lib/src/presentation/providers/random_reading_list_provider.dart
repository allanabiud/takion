import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/reading_list.dart';
import 'package:takion/src/presentation/providers/reading_lists_provider.dart';

final randomReadingListProvider = Provider<ReadingList?>((ref) {
  final listsAsync = ref.watch(readingListsProvider);
  return listsAsync.when(
    data: (lists) {
      if (lists.isEmpty) return null;
      return lists[Random().nextInt(lists.length)];
    },
    error: (_, __) => null,
    loading: () => null,
  );
});
