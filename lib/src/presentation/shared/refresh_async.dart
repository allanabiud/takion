import "package:flutter_riverpod/flutter_riverpod.dart";

Future<void> refreshAsync<T>({
  required void Function(AsyncValue<T>) setState,
  required AsyncValue<T> previousState,
  required Future<T> Function() fetch,
}) async {
  // ignore: invalid_use_of_internal_member
  setState(AsyncLoading<T>().copyWithPrevious(previousState));
  final newState = await AsyncValue.guard(fetch);
  setState(newState);
}
