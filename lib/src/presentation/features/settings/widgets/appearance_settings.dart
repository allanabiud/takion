import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

const accentSchemes = [
  FlexScheme.green,
  FlexScheme.blackWhite,
  FlexScheme.aquaBlue,
  FlexScheme.blueM3,
  FlexScheme.indigo,
  FlexScheme.deepPurple,
  FlexScheme.sakura,
  FlexScheme.mandyRed,
  FlexScheme.vesuviusBurn,
  FlexScheme.gold,
];

void showAppearanceSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Appearance',
    child: Consumer(
      builder: (context, ref, _) {
        final themeAsync = ref.watch(themeProvider);
        final themeSettings =
            themeAsync.value ??
            const ThemeSettings(
              themeMode: ThemeMode.system,
              darkIsTrueBlack: false,
            );
        final currentScheme =
            ref.watch(accentSchemeProvider).value ?? FlexScheme.green;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSettingsGroup(context, 'Theme Mode', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Mode',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Choose your preferred interface theme',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RadioGroup<ThemeMode>(
                  groupValue: themeSettings.themeMode,
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(themeProvider.notifier).setThemeMode(value);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        title: Text('System'),
                        secondary: Icon(Icons.brightness_auto_outlined),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        title: Text('Light'),
                        secondary: Icon(Icons.light_mode_outlined),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        title: Text('Dark'),
                        secondary: Icon(Icons.dark_mode_outlined),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              buildSettingsGroup(context, 'Accent Color', [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: accentSchemes.map((scheme) {
                    final schemeData = FlexColor.schemes[scheme];
                    final primary = schemeData?.light.primary ?? Colors.blue;
                    final selected = currentScheme == scheme;
                    final luminance = primary.computeLuminance();
                    final tickColor = luminance > 0.5
                        ? Colors.black87
                        : Colors.white;
                    return GestureDetector(
                      onTap: () => ref
                          .read(accentSchemeProvider.notifier)
                          .setScheme(scheme),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.39),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check, color: tickColor, size: 22)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ]),
              const SizedBox(height: 16),
              buildSettingsGroup(context, 'Dark Mode', [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Pure Black',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Use a true black background in dark mode',
                  ),
                  value: themeSettings.darkIsTrueBlack,
                  onChanged: (bool value) {
                    ref.read(themeProvider.notifier).setDarkIsTrueBlack(value);
                  },
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}
