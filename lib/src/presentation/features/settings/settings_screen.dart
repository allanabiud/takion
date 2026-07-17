import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_nav_tile.dart';
import 'package:takion/src/presentation/features/settings/widgets/metron_connection_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/appearance_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/collection_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/backup_and_sync_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/data_storage_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/about_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/notification_settings.dart';
import 'package:takion/src/presentation/features/settings/widgets/performance_metrics_settings.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          buildSettingsSectionHeader(context, 'PREFERENCES'),
          SettingsNavTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'App theme and colors',
            onTap: () => showAppearanceSettings(context, ref),
          ),
          SettingsNavTile(
            icon: Icons.collections_bookmark_outlined,
            title: 'Library',
            subtitle: 'Defaults and content preferences',
            onTap: () => showCollectionSettings(context, ref),
          ),
          const SizedBox(height: 16),
          buildSettingsSectionHeader(context, 'NOTIFICATIONS'),
          SettingsNavTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Weekly pull notifications',
            onTap: () => showNotificationSettings(context, ref),
          ),
          const SizedBox(height: 16),
          buildSettingsSectionHeader(context, 'ACCOUNT & DATA'),
          SettingsNavTile(
            icon: LucideIcons.atom,
            title: 'Metron',
            subtitle: 'Account connection status',
            onTap: () => showMetronConnectionSettings(context, ref),
          ),
          SettingsNavTile(
            icon: Icons.backup_outlined,
            title: 'Backup & Sync',
            subtitle: 'Local and cloud backup & sync',
            onTap: () => showBackupAndSyncSettings(context, ref),
          ),
          SettingsNavTile(
            icon: Icons.storage_outlined,
            title: 'Data & Storage',
            subtitle: 'Cache and data management',
            onTap: () => showDataStorageSettings(context, ref),
          ),
          const SizedBox(height: 16),
          buildSettingsSectionHeader(context, 'ADVANCED'),
          SettingsNavTile(
            icon: Icons.analytics_outlined,
            title: 'Performance Metrics',
            subtitle: 'System timing and cache stats',
            onTap: () => showPerformanceMetrics(context, ref),
          ),
          const SizedBox(height: 16),
          buildSettingsSectionHeader(context, 'APP INFO'),
          SettingsNavTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Takion version and info',
            onTap: () => showAboutSettings(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
