import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

part 'theme_provider.freezed.dart';
part 'theme_provider.g.dart';

@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const factory ThemeSettings({
    required ThemeMode themeMode,
    required bool darkIsTrueBlack,
  }) = _ThemeSettings;
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _themeKey = 'theme_mode';
  static const _blackKey = 'dark_is_true_black';

  @override
  FutureOr<ThemeSettings> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final index = await dao.getInt(
      _themeKey,
      defaultValue: ThemeMode.system.index,
    );
    final isTrueBlack = await dao.getBool(_blackKey);

    return ThemeSettings(
      themeMode: ThemeMode.values[index],
      darkIsTrueBlack: isTrueBlack,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setInt(_themeKey, mode.index);

    final currentSettings =
        state.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );
    state = AsyncValue.data(currentSettings.copyWith(themeMode: mode));
  }

  Future<void> setDarkIsTrueBlack(bool value) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_blackKey, value);

    final currentSettings =
        state.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );
    state = AsyncValue.data(currentSettings.copyWith(darkIsTrueBlack: value));
  }
}
