import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

final debugModeProvider = AsyncNotifierProvider<DebugModeNotifier, bool>(
  DebugModeNotifier.new,
);

class DebugModeNotifier extends AsyncNotifier<bool> {
  static const _key = 'debug_mode_enabled';

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return await dao.getBool(_key);
  }

  Future<void> toggle() async {
    final current = state.value ?? false;
    final next = !current;
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, next);
    state = AsyncValue.data(next);
  }
}
