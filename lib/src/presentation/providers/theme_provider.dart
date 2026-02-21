import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/storage/hive_service.dart';

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
  static const _boxName = 'settings_box';
  static const _themeKey = 'theme_mode';
  static const _blackKey = 'dark_is_true_black';

  @override
  ThemeSettings build() {
    final hive = ref.read(hiveServiceProvider);
    try {
      final box = hive.getBox(_boxName);
      final index = box.get(_themeKey, defaultValue: ThemeMode.system.index);
      final isTrueBlack = box.get(_blackKey, defaultValue: false);

      return ThemeSettings(
        themeMode: ThemeMode.values[index],
        darkIsTrueBlack: isTrueBlack,
      );
    } catch (_) {
      return const ThemeSettings(
        themeMode: ThemeMode.system,
        darkIsTrueBlack: false,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setDarkIsTrueBlack(bool value) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_blackKey, value);
    state = state.copyWith(darkIsTrueBlack: value);
  }
}
