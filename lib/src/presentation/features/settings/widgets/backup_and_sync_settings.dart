import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/data/common/services/local_backup_service.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/features/settings/widgets/settings_helpers.dart";
import "package:takion/src/presentation/providers/providers.dart";

void showBackupAndSyncSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Backup & Restore",
    child: const _BackupContent(),
  );
}

class _BackupContent extends ConsumerStatefulWidget {
  const _BackupContent();

  @override
  ConsumerState<_BackupContent> createState() => _BackupContentState();
}

class _BackupContentState extends ConsumerState<_BackupContent> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isCloudBackingUp = false;
  bool _isCloudRestoring = false;
  bool _isDeletingBackup = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLocalBackupSection(),
          const SizedBox(height: 16),
          _buildCloudBackupSection(),
        ],
      ),
    );
  }

  Widget _buildLocalBackupSection() {
    final theme = Theme.of(context);
    return buildSettingsGroup(context, "Local Backup", [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _isBackingUp
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Icon(Icons.save_outlined, color: theme.colorScheme.primary),
        title: Text(
          _isBackingUp ? "Creating Backup..." : "Create Local Backup",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _isBackingUp ? "Please wait" : "Save a .tkbak file of your data",
        ),
        onTap: _isBackingUp ? null : _createLocalBackup,
        enabled: !_isBackingUp,
      ),
      const Divider(height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _isRestoring
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Icon(
                Icons.folder_open_outlined,
                color: theme.colorScheme.primary,
              ),
        title: Text(
          _isRestoring ? "Restoring..." : "Restore from Local Backup",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _isRestoring ? "Please wait" : "Import data from a .tkbak file",
        ),
        onTap: _isRestoring ? null : _restoreFromLocalBackup,
        enabled: !_isRestoring,
      ),
    ]);
  }

  Widget _buildCloudBackupSection() {
    final theme = Theme.of(context);
    final syncState = ref.watch(driveSyncProvider);
    final driveService = ref.read(driveSyncServiceProvider);

    return buildSettingsGroup(context, "Cloud Backup", [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          "Cloud Backup",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          syncState.enabled
              ? (syncState.email ?? "Connected to Google Drive")
              : "Sign in to enable cloud backups",
        ),
        value: syncState.enabled,
        onChanged: (value) async {
          final syncNotifier = ref.read(driveSyncProvider.notifier);
          if (value) {
            syncNotifier.setSyncing(true);
            try {
              final account = await driveService.signIn();
              if (account == null) return;
              await syncNotifier.enable(email: account.email);
              if (!mounted) return;
              await _cloudBackupNow();
            } finally {
              syncNotifier.setSyncing(false);
            }
          } else {
            syncNotifier.setSyncing(false);
            await driveService.signOut();
            await syncNotifier.disable();
          }
        },
      ),
      if (syncState.enabled) ...[
        const Divider(height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _isCloudBackingUp
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  Icons.cloud_upload_outlined,
                  color: theme.colorScheme.primary,
                ),
          title: Text(
            _isCloudBackingUp ? "Backing up..." : "Create Cloud Backup",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: _buildCloudBackupSubtitle(),
          onTap: _isCloudBackingUp ? null : _cloudBackupNow,
          enabled: !_isCloudBackingUp,
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _isCloudRestoring
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  Icons.cloud_download_outlined,
                  color: theme.colorScheme.primary,
                ),
          title: Text(
            _isCloudRestoring ? "Restoring..." : "Restore from Cloud Backup",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _isCloudRestoring
                ? "Please wait"
                : "Download and restore data from Google Drive",
          ),
          onTap: _isCloudRestoring ? null : _restoreFromCloudBackup,
          enabled: !_isCloudRestoring,
        ),
        const Divider(height: 1),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "Automatic Backups",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text("Backup to Google Drive periodically"),
          value: syncState.autoBackupOnRestart,
          onChanged: (value) {
            ref
                .read(driveSyncProvider.notifier)
                .updateAutoBackupOnRestart(value);
          },
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: !_isDeletingBackup,
          leading: _isDeletingBackup
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete_outline, color: theme.colorScheme.error),
          title: Text(
            _isDeletingBackup
                ? "Deleting Backup..."
                : "Delete Backup from Drive",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _isDeletingBackup
                ? "Please wait"
                : "Remove backup file from Google Drive",
          ),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete Backup"),
                content: const Text(
                  "Are you sure you want to delete the backup file "
                  "from Google Drive? This cannot be undone.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            );
            if (confirm != true) return;
            setState(() => _isDeletingBackup = true);
            try {
              await driveService.deleteRemoteData();
              if (!mounted) return;
              TakionAlerts.success(context, "Backup deleted from Drive");
            } catch (e) {
              if (!mounted) return;
              TakionAlerts.safeError(
                context,
                e,
                userMessage: "Failed to delete backup",
              );
            } finally {
              if (mounted) setState(() => _isDeletingBackup = false);
            }
          },
        ),
      ],
    ]);
  }

  Widget _buildCloudBackupSubtitle() {
    final theme = Theme.of(context);
    final diagnostics = ref.watch(syncDiagnosticsProvider).value;
    final lastSuccess = diagnostics?.lastSuccessTime;
    final lastErrorTime = diagnostics?.lastErrorTime;
    final hasError =
        lastErrorTime != null &&
        (lastSuccess == null || lastErrorTime.isAfter(lastSuccess));

    if (_isCloudBackingUp) {
      return const Text("Please wait");
    }

    final IconData icon;
    final Color color;
    final String text;
    if (hasError) {
      icon = Icons.error_outline;
      color = theme.colorScheme.error;
      text =
          "Last backup failed · ${DateFormatter.relativeShort(lastErrorTime)}";
    } else if (lastSuccess != null) {
      icon = Icons.check_circle_outline;
      color = theme.colorScheme.primary;
      text =
          "Last backup successful · ${DateFormatter.relativeShort(lastSuccess)}";
    } else {
      icon = Icons.info_outline;
      color = theme.colorScheme.onSurfaceVariant;
      text = "No backup yet";
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Future<void> _createLocalBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final service = ref.read(localBackupServiceProvider);
      final bytes = await service.exportBackupData();

      final today = DateTime.now();
      final dateStr = DateFormatter.isoDate(today);

      final result = await FilePicker.saveFile(
        fileName: "takion_backup_$dateStr.tkbak",
        bytes: bytes,
      );
      if (result != null && mounted) {
        TakionAlerts.success(context, "Backup saved successfully");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: "Failed to create backup",
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromLocalBackup() async {
    setState(() => _isRestoring = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isRestoring = false);
        return;
      }

      final file = result.files.single;
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError("Unable to read content from selected backup file");
      }

      final service = ref.read(localBackupServiceProvider);
      final preview = service.previewBackup(bytes);

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Restore Backup"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(preview.summary),
              const SizedBox(height: 8),
              Text(
                "This will merge the backup data into your current data. "
                "Existing records will be kept if they are newer.",
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Restore"),
            ),
          ],
        ),
      );
      if (confirm != true) {
        if (mounted) setState(() => _isRestoring = false);
        return;
      }

      await service.importBackupData(bytes);

      invalidateCacheBackedProviders((p) => ref.invalidate(p));
      await Future<void>.delayed(Duration.zero);
      if (mounted) {
        TakionAlerts.success(context, "Backup restored successfully");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: "Failed to restore backup",
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _cloudBackupNow() async {
    final driveService = ref.read(driveSyncServiceProvider);
    final syncNotifier = ref.read(driveSyncProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);

    syncNotifier.clearError();
    syncNotifier.setSyncing(true);
    setState(() => _isCloudBackingUp = true);
    try {
      await driveService.triggerSync(ignoreThrottle: true);
      await syncNotifier.updateLastSync();
      invalidateCacheBackedProviders(container.invalidate);
      await Future<void>.delayed(Duration.zero);
      if (mounted) TakionAlerts.success(context, "Backup saved to Drive");
    } catch (e) {
      if (mounted) {
        syncNotifier.setError(e.toString());
        TakionAlerts.safeError(context, e, userMessage: "Cloud backup failed");
      }
    } finally {
      syncNotifier.setSyncing(false);
      if (mounted) setState(() => _isCloudBackingUp = false);
    }
  }

  Future<void> _restoreFromCloudBackup() async {
    final driveService = ref.read(driveSyncServiceProvider);
    final container = ProviderScope.containerOf(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Restore from Cloud Backup"),
        content: const Text(
          "This will download your data from Google Drive and merge it "
          "into your current data. Existing records will be kept if they "
          "are newer.\n\nA rollback snapshot will be created before "
          "restoring, allowing you to undo if needed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Restore"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isCloudRestoring = true);
    try {
      await driveService.restoreFromDrive();
      invalidateCacheBackedProviders(container.invalidate);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      final hasRollback = await driveService.getRollbackSnapshot() != null;
      if (!mounted) return;
      if (hasRollback) {
        TakionAlerts.successWithUndo(
          context,
          "Cloud backup restored successfully",
          actionLabel: "Undo",
          onUndo: _performRollback,
        );
      } else {
        TakionAlerts.success(context, "Cloud backup restored successfully");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          e,
          userMessage: "Failed to restore from cloud backup",
        );
      }
    } finally {
      if (mounted) setState(() => _isCloudRestoring = false);
    }
  }

  Future<void> _performRollback() async {
    final driveService = ref.read(driveSyncServiceProvider);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      await driveService.rollback();
      invalidateCacheBackedProviders(container.invalidate);
      await Future<void>.delayed(Duration.zero);
      if (mounted) {
        TakionAlerts.success(context, "Rollback completed");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: "Rollback failed");
      }
    }
  }
}
