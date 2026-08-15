import "package:flutter_riverpod/flutter_riverpod.dart";

/// Runs a force-refresh for a Riverpod [AsyncNotifier]: switches [setState]
/// to a loading value that retains the previous data, awaits [fetch], then
/// writes the result. Centralizes the `copyWithPrevious` internal-member
/// workaround used by provider refresh methods.
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
