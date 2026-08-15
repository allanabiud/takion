import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/features/settings/widgets/appearance_settings.dart";
import "package:takion/src/presentation/providers/providers.dart";

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeAsync = ref.watch(themeProvider);
    final themeSettings =
        themeAsync.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );
    final currentScheme =
        ref.watch(accentSchemeProvider).value ?? FlexScheme.green;

    return OnboardingPageScaffold(
      icon: Icon(
        Icons.palette_outlined,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        "Appearance",
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: "Customize your theme and accent color.",
      content: ListView(
        children: [
          Text(
            "THEME MODE",
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text("AUTO"),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text("LIGHT"),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text("DARK"),
                ),
              ],
              selected: {themeSettings.themeMode},
              onSelectionChanged: (selected) {
                if (selected.isEmpty) return;
                ref.read(themeProvider.notifier).setThemeMode(selected.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "ACCENT COLOR",
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
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
                  onTap: () =>
                      ref.read(accentSchemeProvider.notifier).setScheme(scheme),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
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
          ),
          const SizedBox(height: 16),
          Text(
            "DARK MODE",
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Pure Black",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  "Use a true black background in dark mode",
                ),
                value: themeSettings.darkIsTrueBlack,
                onChanged: (bool value) {
                  ref.read(themeProvider.notifier).setDarkIsTrueBlack(value);
                },
              ),
            ),
          ),
        ],
      ),
      buttons: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }
}