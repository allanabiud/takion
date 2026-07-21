import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

final debugModeProvider = AsyncNotifierProvider<DebugModeNotifier, bool>(
  DebugModeNotifier.new,
);

class DebugModeNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'debug_mode_enabled';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return (box.get(_key, defaultValue: false) as bool?) ?? false;
  }

  Future<void> toggle() async {
    final current = state.value ?? false;
    final next = !current;
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, next);
    state = AsyncValue.data(next);
  }
}
