import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/theme_provider.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:takion/src/presentation/widgets/settings_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchMetronSignup(BuildContext context) async {
    final url = Uri.parse('https://metron.cloud/accounts/signup/');
    if (!await launchUrl(url)) {
      if (!context.mounted) return;
      TakionAlerts.signupLaunchFailed(context);
    }
  }

  void _showMetronConnectionSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final metronConnectionAsync = ref.watch(metronConnectionProvider);

            return SettingsBottomSheet(
              title: 'Metron Connection',
              content: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('Status'),
                    subtitle: metronConnectionAsync.when(
                      data: (connection) => connection == null
                          ? const Text('Not connected')
                          : Text('Connected as ${connection.username}'),
                      loading: () => const Text('Checking connection...'),
                      error: (error, _) => Text(error.toString()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _showMetronConnectDialog(context, ref);
                      },
                      child: const Text('Connect / Reconnect Metron'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _launchMetronSignup(context),
                      child: const Text('Create Metron Account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => _disconnectMetronAccount(context, ref),
                      child: const Text('Disconnect Metron'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMetronConnectDialog(BuildContext context, WidgetRef ref) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    final shouldConnect = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Connect Metron Account'),
          content: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Metron Username',
                  ),
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Metron Password',
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                TextInput.finishAutofillContext();
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    usernameController.dispose();
    passwordController.dispose();

    if (shouldConnect != true) return;
    if (!context.mounted) return;
    if (username.isEmpty || password.isEmpty) {
      TakionAlerts.info(context, 'Please enter Metron username and password.');
      return;
    }

    try {
      final service = ref.read(metronAccountServiceProvider);
      final connected = await service.connect(username, password);
      if (!context.mounted) return;

      if (!connected) {
        TakionAlerts.error(context, 'Invalid Metron username or password.');
      } else {
        TakionAlerts.success(context, 'Metron account connected.');
        ref.invalidate(metronConnectionProvider);
      }
    } catch (error) {
      if (!context.mounted) return;
      TakionAlerts.error(context, error.toString());
    }
  }

  Future<void> _disconnectMetronAccount(BuildContext context, WidgetRef ref) async {
    await ref.read(metronAccountServiceProvider).disconnect();
    ref.invalidate(metronConnectionProvider);
    if (!context.mounted) return;
    TakionAlerts.info(context, 'Metron account disconnected.');
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.logout,
            color: Theme.of(dialogContext).colorScheme.error,
          ),
          title: const Text('Logout?'),
          content: const Text(
            'You will be signed out and returned to the login screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
                backgroundColor: Theme.of(
                  dialogContext,
                ).colorScheme.errorContainer.withValues(alpha: 0.5),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    await ref.read(authStateProvider.notifier).logout();
    if (!context.mounted) return;

    TakionAlerts.authLogoutSuccess(context);
    context.router.replaceAll([LoginRoute()]);
  }

  void _showAppearanceSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final themeAsync = ref.watch(themeProvider);
            final themeSettings =
                themeAsync.value ??
                const ThemeSettings(
                  themeMode: ThemeMode.system,
                  darkIsTrueBlack: false,
                );

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

  void _showCollectionSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final formatAsync = ref.watch(collectionDefaultFormatProvider);
            final selected = formatAsync.maybeWhen(
              data: (value) => value,
              orElse: () => CollectionDefaultFormat.print,
            );

            return SettingsBottomSheet(
              title: 'Collection',
              content: Column(
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.tune),
                    title: Text('Default format when adding issues'),
                    subtitle: Text('Applied when a new item is added to your collection'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<CollectionDefaultFormat>(
                      segments: const [
                        ButtonSegment<CollectionDefaultFormat>(
                          value: CollectionDefaultFormat.print,
                          label: Text('Print'),
                        ),
                        ButtonSegment<CollectionDefaultFormat>(
                          value: CollectionDefaultFormat.digital,
                          label: Text('Digital'),
                        ),
                        ButtonSegment<CollectionDefaultFormat>(
                          value: CollectionDefaultFormat.both,
                          label: Text('Both'),
                        ),
                      ],
                      selected: {selected},
                      onSelectionChanged: formatAsync.isLoading
                          ? null
                          : (newSelection) {
                              ref
                                  .read(collectionDefaultFormatProvider.notifier)
                                  .setDefaultFormat(newSelection.first);
                            },
                    ),
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
                              await ref
                                  .read(settingsProvider.notifier)
                                  .clearCache();
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
              Icons.collections_bookmark_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Collection'),
            subtitle: const Text('Default format for newly added issues'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCollectionSettings(context, ref),
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
          ListTile(
            leading: Icon(
              Icons.link,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Metron Connection'),
            subtitle: const Text('View connected account and disconnect'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMetronConnectionSettings(context, ref),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Theme.of(context).colorScheme.error,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.5),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () => _confirmAndLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
