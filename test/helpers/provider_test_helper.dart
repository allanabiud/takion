import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

/// Creates a test [ProviderContainer] that is automatically disposed after the test.
ProviderContainer createTestContainer({
  ProviderContainer? parent,
  List<dynamic> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides.cast(),
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}
