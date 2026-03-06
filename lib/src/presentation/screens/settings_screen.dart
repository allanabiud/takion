import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/providers/performance_metrics_provider.dart';
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

  Future<void> _launchGitHubRepo(BuildContext context) async {
    final url = Uri.parse('https://github.com/allanabiud/takion');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      TakionAlerts.couldNotOpenInBrowser(context, 'repository');
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Account Actions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _showMetronConnectDialog(context, ref);
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Connect / Reconnect Metron'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  _disconnectMetronAccount(context, ref),
                              child: const Text('Disconnect Metron'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _launchMetronSignup(context),
                      child: const Text('Create Metron Account'),
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

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    if (ref.read(authStateProvider).isLoading) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.logout,
            color: Theme.of(dialogContext).colorScheme.error,
          ),
          title: const Text('Log Out?'),
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
              child: const Text('Log Out'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(Icons.settings_brightness),
                              label: Text(
                                'System',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode),
                              label: Text(
                                'Light',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode),
                              label: Text(
                                'Dark',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: SwitchListTile(
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
              title: 'Library',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Add Format',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.tune),
                            title: Text('Default format when adding issues'),
                            subtitle: Text(
                              'Applied when a new item is added to your collection',
                            ),
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
                                          .read(
                                            collectionDefaultFormatProvider
                                                .notifier,
                                          )
                                          .setDefaultFormat(newSelection.first);
                                    },
                            ),
                          ),
                        ],
                      ),
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

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final enabledAsync = ref.watch(
              pushPullNotificationsEnabledProvider,
            );
            final timingAsync = ref.watch(pullNotificationTimingProvider);
            final enabled = enabledAsync.maybeWhen(
              data: (value) => value,
              orElse: () => false,
            );
            final timing = timingAsync.maybeWhen(
              data: (value) => value,
              orElse: () => PullNotificationTiming.releaseDay,
            );

            String labelForTiming(PullNotificationTiming value) {
              switch (value) {
                case PullNotificationTiming.dayBefore:
                  return 'Day before';
                case PullNotificationTiming.releaseDay:
                  return 'Release day';
                case PullNotificationTiming.dayAfter:
                  return 'Day after';
              }
            }

            return SettingsBottomSheet(
              title: 'Notifications',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pull Notifications',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      secondary: const Icon(
                        Icons.notifications_active_outlined,
                      ),
                      title: const Text('Push Notifications for Pulls'),
                      value: enabled,
                      onChanged: enabledAsync.isLoading
                          ? null
                          : (value) => ref
                                .read(
                                  pushPullNotificationsEnabledProvider.notifier,
                                )
                                .setEnabled(value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Notification Timing',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.schedule_outlined),
                            title: const Text('When to Notify'),
                            subtitle: Text(labelForTiming(timing)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Day before'),
                                selected:
                                    timing == PullNotificationTiming.dayBefore,
                                onSelected: (!enabled || timingAsync.isLoading)
                                    ? null
                                    : (_) => ref
                                          .read(
                                            pullNotificationTimingProvider
                                                .notifier,
                                          )
                                          .setTiming(
                                            PullNotificationTiming.dayBefore,
                                          ),
                              ),
                              ChoiceChip(
                                label: const Text('Release day'),
                                selected:
                                    timing == PullNotificationTiming.releaseDay,
                                onSelected: (!enabled || timingAsync.isLoading)
                                    ? null
                                    : (_) => ref
                                          .read(
                                            pullNotificationTimingProvider
                                                .notifier,
                                          )
                                          .setTiming(
                                            PullNotificationTiming.releaseDay,
                                          ),
                              ),
                              ChoiceChip(
                                label: const Text('Day after'),
                                selected:
                                    timing == PullNotificationTiming.dayAfter,
                                onSelected: (!enabled || timingAsync.isLoading)
                                    ? null
                                    : (_) => ref
                                          .read(
                                            pullNotificationTimingProvider
                                                .notifier,
                                          )
                                          .setTiming(
                                            PullNotificationTiming.dayAfter,
                                          ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Sync Options',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
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
                        const Divider(height: 1),
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Local Cache',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.red,
                      ),
                      title: const Text('Clear Local Cache'),
                      subtitle: const Text(
                        'Remove fetched cached releases, issues, and series data',
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SettingsBottomSheet(
          title: 'About',
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/takion_logo.svg',
                  height: 86,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Takion',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.hasData
                        ? snapshot.data!.buildNumber.isEmpty
                              ? snapshot.data!.version
                              : '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                        : '...';
                    return Text(
                      'Version $versionText',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Made by allanabiud',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                IconButton(
                  tooltip: 'GitHub',
                  onPressed: () => _launchGitHubRepo(context),
                  icon: Icon(
                    Icons.code,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPerformanceMetrics(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final metrics = ref.watch(performanceMetricsProvider);
            return AnimatedBuilder(
              animation: metrics,
              builder: (context, _) {
                Widget metricSection(String title, Map<String, int> values) {
                  final entries = values.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        Text(
                          'No data yet.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ...entries
                          .take(12)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${entry.key}: ${entry.value}'),
                            ),
                          ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final providerAvg = <String, int>{};
                for (final entry in metrics.providerCalls.entries) {
                  final total = metrics.providerTotalMs[entry.key] ?? 0;
                  providerAvg[entry.key] = entry.value <= 0
                      ? 0
                      : (total / entry.value).round();
                }

                return SettingsBottomSheet(
                  title: 'Performance Metrics',
                  content: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HTTP 429: ${metrics.http429Count}'),
                          Text('429 retries: ${metrics.retryAfter429Count}'),
                          const SizedBox(height: 16),
                          metricSection('Cache Hits', metrics.cacheHits),
                          metricSection('Cache Misses', metrics.cacheMisses),
                          metricSection('API Calls', metrics.apiCalls),
                          metricSection('Provider Avg ms', providerAvg),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () {
                                ref.read(performanceMetricsProvider).clear();
                              },
                              child: const Text('Reset Metrics'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggingOut = authState.isLoading;

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
              Icons.link,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Metron Connection'),
            subtitle: const Text('View connected account and disconnect'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMetronConnectionSettings(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.collections_bookmark_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Library'),
            subtitle: const Text(
              'Library defaults and item detail preferences',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCollectionSettings(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_none_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Push alerts for pulls and notify timing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationSettings(context, ref),
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
              Icons.analytics_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Performance Metrics'),
            subtitle: const Text('View cache/network/provider timing metrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPerformanceMetrics(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('About'),
            subtitle: const Text('App info and version'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutSettings(context),
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
              icon: isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: isLoggingOut
                  ? null
                  : () => _confirmAndLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
