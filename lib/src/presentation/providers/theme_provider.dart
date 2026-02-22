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
  FutureOr<ThemeSettings> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    
    final index = box.get(_themeKey, defaultValue: ThemeMode.system.index);
    final isTrueBlack = box.get(_blackKey, defaultValue: false);

    return ThemeSettings(
      themeMode: ThemeMode.values[index],
      darkIsTrueBlack: isTrueBlack,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_themeKey, mode.index);
    
    final currentSettings = state.value ?? const ThemeSettings(themeMode: ThemeMode.system, darkIsTrueBlack: false);
    state = AsyncValue.data(currentSettings.copyWith(themeMode: mode));
  }

  Future<void> setDarkIsTrueBlack(bool value) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_blackKey, value);
    
    final currentSettings = state.value ?? const ThemeSettings(themeMode: ThemeMode.system, darkIsTrueBlack: false);
    state = AsyncValue.data(currentSettings.copyWith(darkIsTrueBlack: value));
  }
}
