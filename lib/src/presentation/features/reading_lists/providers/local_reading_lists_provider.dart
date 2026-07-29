import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/entities.dart';

final localReadingListsProvider =
    AsyncNotifierProvider<LocalReadingListsNotifier, List<LocalReadingList>>(
      () {
        return LocalReadingListsNotifier();
      },
    );

class LocalReadingListsNotifier extends AsyncNotifier<List<LocalReadingList>> {
  @override
  Future<List<LocalReadingList>> build() async {
    return ref.read(localReadingListRepositoryProvider).getAllLists();
  }

  Future<void> addList(LocalReadingList list) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(localReadingListRepositoryProvider).createList(list);
      return ref.read(localReadingListRepositoryProvider).getAllLists();
    });
  }

  Future<void> updateList(LocalReadingList list) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(localReadingListRepositoryProvider).updateList(list);
      return ref.read(localReadingListRepositoryProvider).getAllLists();
    });
  }

  Future<void> deleteList(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(localReadingListRepositoryProvider).deleteList(id);
      return ref.read(localReadingListRepositoryProvider).getAllLists();
    });
  }
}
