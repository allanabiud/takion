import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/data/repositories/reading_list_repository_impl.dart';
import 'package:takion/src/domain/entities/reading_list.dart';

part 'reading_list_details_provider.g.dart';

@riverpod
Future<ReadingList?> readingListDetails(Ref ref, String listId) async {
  return ref.read(readingListRepositoryProvider).getListById(listId);
}

@riverpod
class ReadingListEditMode extends _$ReadingListEditMode {
  @override
  bool build(String listId) => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}
