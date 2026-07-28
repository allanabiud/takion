import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/entities.dart';

final readingListsProvider =
    AsyncNotifierProvider<ReadingListsNotifier, List<ReadingList>>(() {
      return ReadingListsNotifier();
    });

class ReadingListsNotifier extends AsyncNotifier<List<ReadingList>> {
  @override
  Future<List<ReadingList>> build() async {
    return ref.read(readingListRepositoryProvider).getAllLists();
  }

  Future<void> addList(ReadingList list) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(readingListRepositoryProvider).createList(list);
      return ref.read(readingListRepositoryProvider).getAllLists();
    });
  }

  Future<void> updateList(ReadingList list) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(readingListRepositoryProvider).updateList(list);
      return ref.read(readingListRepositoryProvider).getAllLists();
    });
  }

  Future<void> deleteList(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(readingListRepositoryProvider).deleteList(id);
      return ref.read(readingListRepositoryProvider).getAllLists();
    });
  }
}
