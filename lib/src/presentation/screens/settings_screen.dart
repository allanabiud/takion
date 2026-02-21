import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/theme_provider.dart';
import 'package:takion/src/presentation/widgets/settings_bottom_sheet.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showAppearanceSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final themeSettings = ref.watch(themeProvider);
            return SettingsBottomSheet(
              title: 'Appearance',
              content: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_brightness),
                          label: Text('System'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode),
                          label: Text('Light'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {themeSettings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref
                            .read(themeProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Pure Black'),
                    subtitle: const Text(
                      'Use a true black background in dark mode',
                    ),
                    secondary: const Icon(Icons.brightness_2),
                    value: themeSettings.darkIsTrueBlack,
                    onChanged: (bool value) {
                      ref
                          .read(themeProvider.notifier)
                          .setDarkIsTrueBlack(value);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSyncSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final appSettings = ref.watch(settingsProvider);
            return SettingsBottomSheet(
              title: 'Sync',
              content: Column(
                children: [
                  if (appSettings.isSyncing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (appSettings.lastSyncMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        appSettings.lastSyncMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Full Sync'),
                    subtitle: const Text('Update all application data'),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerFullSync(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync_problem),
                    title: const Text('Quick Sync'),
                    subtitle: const Text('Update modified data only'),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerQuickSync(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDataStorageSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final appSettings = ref.watch(settingsProvider);
            return SettingsBottomSheet(
              title: 'Data and Storage',
              content: Column(
                children: [
                  if (appSettings.isSyncing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.red,
                    ),
                    title: const Text('Clear Local Cache'),
                    subtitle: const Text(
                      'Remove all cached comics and history',
                    ),
                    onTap: appSettings.isSyncing
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Clear Cache?'),
                                content: const Text(
                                  'This will remove all downloaded data and history. Your login will remain.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref.read(settingsProvider.notifier).clearCache();
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Appearance'),
            subtitle: const Text('Theme mode and color settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAppearanceSettings(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.sync,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Sync'),
            subtitle: const Text('Collection and metadata sync settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSyncSettings(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.storage_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Data and Storage'),
            subtitle: const Text('Manage local database and storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDataStorageSettings(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
              context.router.replaceAll([LoginRoute()]);
            },
          ),
        ],
      ),
    );
  }
}
