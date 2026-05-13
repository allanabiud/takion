import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
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
              title: 'Metron',
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
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Account Actions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
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
                    ],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  const SizedBox(height: 20),
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
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
                                    collectionDefaultFormatProvider.notifier,
                                  )
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
                  Text(
                    'Sync Options',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sync),
                    title: const Text('Full Sync'),
                    subtitle: const Text('Update all application data'),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerFullSync(),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sync_problem),
                    title: const Text('Quick Sync'),
                    subtitle: const Text('Update modified data only'),
                    onTap: appSettings.isSyncing
                        ? null
                        : () => ref
                              .read(settingsProvider.notifier)
                              .triggerQuickSync(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Local Cache',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
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
                        onPressed: () => launchUrl(
                          Uri.parse('https://github.com/allanabiud'),
                        ),
                        icon: const Icon(Icons.open_in_new),
                      ),
                    ],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _SettingsNavTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme mode and color settings',
            onTap: () => _showAppearanceSettings(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingsNavTile(
            icon: Icons.collections_bookmark_outlined,
            title: 'Library',
            subtitle: 'Library defaults and item detail preferences',
            onTap: () => _showCollectionSettings(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingsNavTile(
            icon: Icons.storage_outlined,
            title: 'Data and Storage',
            subtitle: 'Manage local database and storage',
            onTap: () => _showDataStorageSettings(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingsNavTile(
            icon: Icons.link,
            title: 'Metron',
            subtitle: 'View connected account and disconnect',
            onTap: () => _showMetronConnectionSettings(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingsNavTile(
            icon: Icons.analytics_outlined,
            title: 'Performance Metrics',
            subtitle: 'View cache/network/provider timing metrics',
            onTap: () => _showPerformanceMetrics(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SettingsNavTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App info and version',
            onTap: () => _showAboutSettings(context),
          ),
        ],
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
