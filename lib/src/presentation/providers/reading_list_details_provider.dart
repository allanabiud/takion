import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/repositories/reading_list_repository_impl.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

final readingListDetailsProvider = FutureProvider.family<ReadingList?, String>((ref, listId) async {
  return ref.read(readingListRepositoryProvider).getListById(listId);
});
