import "package:flutter/material.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/presentation/features/library/export/collection_csv_export.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/settings/widgets/settings_helpers.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";

void showDataStorageSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Data & Storage",
    child: Consumer(
      builder: (context, ref, _) {
        final appSettings = ref.watch(settingsProvider);
        final cacheSizeAsync = ref.watch(cacheSizeProvider);
        final imageCacheSizeAsync = ref.watch(imageCacheSizeProvider);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSettingsGroup(context, "Cache", [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.storage_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Metadata Cache"),
                  trailing: Text(
                    cacheSizeAsync.when(
                      data: _formatBytes,
                      loading: () => "...",
                      error: (error, _) => "Unknown",
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.image_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Image Cache"),
                  trailing: Text(
                    imageCacheSizeAsync.when(
                      data: _formatBytes,
                      loading: () => "...",
                      error: (error, _) => "Unknown",
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.sd_card_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    () {
                      final metadata = cacheSizeAsync.value;
                      final images = imageCacheSizeAsync.value;
                      if (metadata == null || images == null) return "...";
                      return _formatBytes(metadata + images);
                    }(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.image_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text(
                    "Clear Image Cache",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    "Remove cached cover images (memory & disk) only",
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Clear Image Cache?"),
                        content: const Text(
                          "This will remove all cached cover images. They will be re-downloaded when needed.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      PaintingBinding.instance.imageCache.clear();
                      PaintingBinding.instance.imageCache.clearLiveImages();
                      try {
                        await DefaultCacheManager().emptyCache();
                      } catch (e) {
                        AppLogger.warning(
                          "Failed to clear on-disk image cache: $e",
                        );
                      }
                      ref.invalidate(imageCacheSizeProvider);
                      if (context.mounted) {
                        TakionAlerts.success(context, "Image Cache Cleared");
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_sweep_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text(
                    "Rebuild Cache",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    "Rebuilds network metadata and image cache. Your library, "
                    "reading lists, and offline changes are completely preserved.",
                  ),
                  onTap: appSettings.isBusy
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Rebuild Cache?"),
                              content: const Text(
                                "This clears the network metadata cache and cover images so they re-sync from Metron. "
                                "Your library, reading lists, and offline changes waiting to sync are completely preserved.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Rebuild"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(settingsProvider.notifier)
                                .clearCache();
                            ref.invalidate(cacheSizeProvider);
                            ref.invalidate(imageCacheSizeProvider);
                            if (context.mounted) {
                              TakionAlerts.success(
                                context,
                                "Cache Rebuilt - library preserved",
                              );
                            }
                          }
                        },
                ),
              ]),
              const SizedBox(height: 8),
              buildSettingsGroup(context, "Export", [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.file_download_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Export Collection"),
                  subtitle: const Text("Save collection as CSV file"),
                  onTap: () => exportCollectionToCsv(ref),
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return "$bytes B";
  if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
  if (bytes < 1024 * 1024 * 1024) {
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
  return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
}
