import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/domain/entities.dart';

part 'local_reading_list_details_provider.g.dart';

@riverpod
Future<LocalReadingList?> localReadingListDetails(
  Ref ref,
  String listId,
) async {
  return ref.read(localReadingListRepositoryProvider).getListById(listId);
}

@riverpod
class LocalReadingListEditMode extends _$LocalReadingListEditMode {
  @override
  bool build(String listId) => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}
