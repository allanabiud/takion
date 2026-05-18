import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/providers/performance_metrics_provider.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/theme_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchGitHubRepo(BuildContext context) async {
    final url = Uri.parse('https://github.com/allanabiud/takion');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      TakionAlerts.couldNotOpenInBrowser(context, 'repository');
    }
  }

  void _showMetronConnectionSettings(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: 'Metron',
      child: Consumer(
        builder: (context, ref, _) {
          final metronConnectionAsync = ref.watch(metronConnectionProvider);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingsGroup(context, 'Connection Status', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
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
              ]),
              const SizedBox(height: 16),
              _buildSettingsGroup(context, 'Account Actions', [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: metronConnectionAsync.value != null
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await _showMetronConnectDialog(context, ref);
                          },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Connect Metron'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: metronConnectionAsync.value == null
                        ? null
                        : () => _disconnectMetronAccount(context, ref),
                    child: const Text('Disconnect Metron'),
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showMetronConnectDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

  Future<void> _disconnectMetronAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(metronAccountServiceProvider).disconnect();
    ref.invalidate(metronConnectionProvider);
    if (!context.mounted) return;
    TakionAlerts.info(context, 'Metron account disconnected.');
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: 'Notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingsGroup(context, 'Pull List Notifications', [
            Consumer(
              builder: (context, ref, _) {
                final enabledAsync = ref.watch(
                  pushPullNotificationsEnabledProvider,
                );
                final enabled = enabledAsync.value ?? false;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Enable Weekly Pull List Reminder',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Get weekly notification on pull list.',
                  ),
                  value: enabled,
                  onChanged: enabledAsync.isLoading
                      ? null
                      : (bool value) async {
                          await ref
                              .read(
                                pushPullNotificationsEnabledProvider.notifier,
                              )
                              .setEnabled(value);
                          if (!context.mounted) return;
                          if (value) {
                            TakionAlerts.success(
                              context,
                              'Pull list reminders enabled.',
                            );
                          } else {
                            TakionAlerts.info(
                              context,
                              'Pull list reminders disabled.',
                            );
                          }
                        },
                );
              },
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final scheduleAsync = ref.watch(pullReminderScheduleProvider);
                final schedule = scheduleAsync.value ?? const PullReminderSchedule(weekday: 2, hour: 20, minute: 0);
                final enabled = (ref.watch(pushPullNotificationsEnabledProvider).value ?? false);

                final dayLabels = const {
                  1: 'Mon',
                  2: 'Tue',
                  3: 'Wed',
                  4: 'Thu',
                  5: 'Fri',
                  6: 'Sat',
                  7: 'Sun',
                };

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<int>(
                                    value: schedule.weekday,
                                    underline: const SizedBox.shrink(),
                                    items: dayLabels.entries
                                        .map(
                                          (e) => DropdownMenuItem<int>(
                                            value: e.key,
                                            child: Text(e.value),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: enabled
                                        ? (val) async {
                                            if (val == null) return;
                                            final newSchedule = PullReminderSchedule(
                                              weekday: val,
                                              hour: schedule.hour,
                                              minute: schedule.minute,
                                            );
                                            await ref
                                                .read(pullReminderScheduleProvider.notifier)
                                                .setSchedule(newSchedule);
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: enabled
                                      ? () async {
                                          final picked = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
                                          );
                                          if (picked == null) return;
                                          final newSchedule = PullReminderSchedule(
                                            weekday: schedule.weekday,
                                            hour: picked.hour,
                                            minute: picked.minute,
                                          );
                                          await ref
                                              .read(pullReminderScheduleProvider.notifier)
                                              .setSchedule(newSchedule);
                                        }
                                      : null,
                                  icon: const Icon(Icons.access_time),
                                  label: Text('${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}'),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            if (!enabled)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Enable reminders to change schedule',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context, WidgetRef ref) {
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingsGroup(context, 'Theme Mode', [
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: RadioGroup<ThemeMode>(
                    groupValue: themeSettings.themeMode,
                    onChanged: (value) {
                      if (value == null) return;
                      ref.read(themeProvider.notifier).setThemeMode(value);
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          title: Text('System'),
                          secondary: Icon(Icons.brightness_auto_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          title: Text('Light'),
                          secondary: Icon(Icons.light_mode_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          title: Text('Dark'),
                          secondary: Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildSettingsGroup(context, 'Dark Mode', [
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
          );
        },
      ),
    );
  }

  void _showCollectionSettings(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: 'Library',
      child: Consumer(
        builder: (context, ref, _) {
          final formatAsync = ref.watch(collectionDefaultFormatProvider);
          final selected = formatAsync.maybeWhen(
            data: (value) => value,
            orElse: () => CollectionDefaultFormat.print,
          );

          return _buildSettingsGroup(context, 'Library Defaults', [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Default format',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Applied when adding new collection items',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: RadioGroup<CollectionDefaultFormat>(
                groupValue: selected,
                onChanged: (value) {
                  if (formatAsync.isLoading || value == null) return;
                  ref
                      .read(collectionDefaultFormatProvider.notifier)
                      .setDefaultFormat(value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<CollectionDefaultFormat>(
                      value: CollectionDefaultFormat.digital,
                      title: const Text('Digital'),
                      enabled: !formatAsync.isLoading,
                    ),
                    RadioListTile<CollectionDefaultFormat>(
                      value: CollectionDefaultFormat.print,
                      title: const Text('Print'),
                      enabled: !formatAsync.isLoading,
                    ),
                    RadioListTile<CollectionDefaultFormat>(
                      value: CollectionDefaultFormat.both,
                      title: const Text('Both'),
                      enabled: !formatAsync.isLoading,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Auto-Collect on Read',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Automatically add to collection when marked as read',
              ),
              value: ref.watch(autoCollectOnReadProvider).value ?? false,
              onChanged: (v) =>
                  ref.read(autoCollectOnReadProvider.notifier).setEnabled(v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Auto-Pull to Collection',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Automatically move released pull list items to owned collection',
              ),
              value: ref.watch(autoPullToCollectionProvider).value ?? false,
              onChanged: (v) =>
                  ref.read(autoPullToCollectionProvider.notifier).setEnabled(v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Read Tick Overlay on Cards',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Show a checkmark overlay on issue covers when marked as read',
              ),
              value: ref.watch(showReadIssueTickOverlayProvider).value ?? false,
              onChanged: (v) => ref
                  .read(showReadIssueTickOverlayProvider.notifier)
                  .setEnabled(v),
            ),
          ]);
        },
      ),
    );
  }

  void _showDataStorageSettings(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: 'Data and Storage',
      child: Consumer(
        builder: (context, ref, _) {
          final appSettings = ref.watch(settingsProvider);
          ref.listen<AppSettings>(settingsProvider, (previous, next) {
            if (!context.mounted) return;
            final justFinishedSync =
                (previous?.isSyncing ?? false) && !next.isSyncing;
            if (!justFinishedSync) return;

            final message = next.lastSyncMessage?.trim();
            if (message == null || message.isEmpty) return;

            final normalized = message.toLowerCase();
            if (normalized.contains('failed')) {
              TakionAlerts.error(context, message);
              return;
            }
            if (normalized.contains('completed')) {
              TakionAlerts.success(context, message);
            }
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appSettings.isSyncing)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                appSettings.lastSyncMessage
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? appSettings.lastSyncMessage!.trim()
                                    : 'Sync in progress...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(minHeight: 4),
                      ],
                    ),
                  ),
                _buildSettingsGroup(context, 'Sync Options', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: !appSettings.isSyncing,
                    leading: Icon(
                      Icons.sync_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'Full Sync',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      appSettings.isSyncing
                          ? 'Sync currently running...'
                          : 'Update all app data from Metron',
                    ),
                    trailing: appSettings.isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerFullSync(),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: !appSettings.isSyncing,
                    leading: Icon(
                      Icons.sync_problem_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'Quick Sync',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      appSettings.isSyncing
                          ? 'Sync currently running...'
                          : 'Update modified data only',
                    ),
                    trailing: appSettings.isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerQuickSync(),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSettingsGroup(context, 'Backup and Restore', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.backup_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'Create Local Backup',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Save your local app data to a backup file (coming soon)',
                    ),
                    onTap: () => TakionAlerts.info(
                      context,
                      'Local backup creation is coming soon.',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.restore_page_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'Restore from Backup',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Restore local app data from a backup file (coming soon)',
                    ),
                    onTap: () => TakionAlerts.info(
                      context,
                      'Backup restore is coming soon.',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSettingsGroup(context, 'Local Cache', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_sweep_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text(
                      'Clear Local Cache',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: const Text(
                      'Remove all cached metadata and images',
                    ),
                    onTap: appSettings.isSyncing
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Clear Cache?'),
                                content: const Text(
                                  'This will remove fetched cached local data. Your account and preferences remain.',
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
                              if (context.mounted) {
                                TakionAlerts.success(
                                  context,
                                  'Local cache cleared.',
                                );
                              }
                            }
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

  void _showAboutSettings(BuildContext context) {
    TakionBottomSheet.show(
      context: context,
      title: 'About',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/takion_logo.svg',
                  height: 64,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Takion',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            final versionText = snapshot.hasData
                                ? snapshot.data!.buildNumber.isEmpty
                                      ? snapshot.data!.version
                                      : '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                                : '...';
                            return Text(
                              'Version $versionText',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _launchGitHubRepo(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.code,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'GitHub Repository',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsGroup(context, 'Developer', [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: const CachedNetworkImageProvider(
                      'https://avatars.githubusercontent.com/u/66108188?s=96&v=4',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'allanabiud',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Creator and maintainer',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        launchUrl(Uri.parse('https://github.com/allanabiud')),
                    icon: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showPerformanceMetrics(BuildContext context, WidgetRef ref) {
    TakionBottomSheet.show(
      context: context,
      title: 'Performance Metrics',
      actions: [
        IconButton(
          onPressed: () => ref.read(performanceMetricsProvider).clear(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset Metrics',
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final metrics = ref.watch(performanceMetricsProvider);
          return ListenableBuilder(
            listenable: metrics,
            builder: (context, _) {
              final cacheHitRate = metrics.cacheHits.values.fold(
                0,
                (a, b) => a + b,
              );
              final cacheMissRate = metrics.cacheMisses.values.fold(
                0,
                (a, b) => a + b,
              );
              final totalCacheRequests = cacheHitRate + cacheMissRate;
              final cacheEfficiency = totalCacheRequests == 0
                  ? 0.0
                  : cacheHitRate / totalCacheRequests;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsGroup(context, 'Network Health', [
                      _buildSettingsRow(
                        'Total Requests',
                        '${metrics.totalApiRequests}',
                      ),
                      _buildSettingsRow(
                        'Rate Limit Hits (429)',
                        '${metrics.http429Count}',
                        color: metrics.http429Count > 0 ? Colors.red : null,
                      ),
                      _buildSettingsRow(
                        'Retries after 429',
                        '${metrics.retryAfter429Count}',
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(context, 'Cache Efficiency', [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Hit Rate'),
                              Text(
                                '${(cacheEfficiency * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: cacheEfficiency,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsRow('Total Hits', '$cacheHitRate'),
                      _buildSettingsRow('Total Misses', '$cacheMissRate'),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      context,
                      'Recent Network Activity',
                      metrics.recentApiRecords.isEmpty
                          ? [
                              const Text(
                                'No recent activity',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ]
                          : metrics.recentApiRecords
                                .map(
                                  (record) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color:
                                                record.statusCode != null &&
                                                    record.statusCode! < 300
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.path,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${record.duration.inMilliseconds}ms • HTTP ${record.statusCode ?? '???'}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      context,
                      'Provider Latency (Avg)',
                      metrics.providerCalls.isEmpty
                          ? [
                              const Text(
                                'No provider metrics',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ]
                          : metrics.providerCalls.entries.map((e) {
                              final avg =
                                  (metrics.providerTotalMs[e.key] ?? 0) /
                                  e.value;
                              return _buildSettingsRow(
                                e.key,
                                '${avg.toStringAsFixed(0)}ms',
                              );
                            }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 60),
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(context, 'PREFERENCES'),
          _SettingsNavTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Themes and colors',
            onTap: () => _showAppearanceSettings(context, ref),
          ),
          _SettingsNavTile(
            icon: Icons.collections_bookmark_outlined,
            title: 'Library',
            subtitle: 'Defaults and content preferences',
            onTap: () => _showCollectionSettings(context, ref),
          ),
          _SettingsNavTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Notification preferences',
            onTap: () => _showNotificationSettings(context, ref),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'ACCOUNT & DATA'),
          _SettingsNavTile(
            icon: LucideIcons.atom,
            title: 'Metron',
            subtitle: 'Account connection status',
            onTap: () => _showMetronConnectionSettings(context, ref),
          ),
          _SettingsNavTile(
            icon: Icons.storage_outlined,
            title: 'Data and Storage',
            subtitle: 'Database management',
            onTap: () => _showDataStorageSettings(context, ref),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'ADVANCED'),
          _SettingsNavTile(
            icon: Icons.analytics_outlined,
            title: 'Performance Metrics',
            subtitle: 'System timing and cache stats',
            onTap: () => _showPerformanceMetrics(context, ref),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'APP INFO'),
          _SettingsNavTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Takion version and info',
            onTap: () => _showAboutSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
