import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

final pendingQueueCountProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.offlineQueueDao.watchPendingCount();
});

class SyncStatusIndicator extends ConsumerStatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  ConsumerState<SyncStatusIndicator> createState() =>
      _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends ConsumerState<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _showQueueInspector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.read(driftDatabaseProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => FutureBuilder(
          future: db.offlineQueueDao.getPendingEntries(limit: 50),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.sync, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        "Offline Sync Queue",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "${entries.length} pending",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_done_outlined,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "All changes synced with cloud",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: entries.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return ListTile(
                                leading: Icon(
                                  entry.operation == "delete"
                                      ? Icons.delete_outline
                                      : Icons.upload_outlined,
                                  color: entry.operation == "delete"
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                ),
                                title: Text(
                                  "${entry.entityType.toUpperCase()} ${entry.operation.toUpperCase()}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("Entity #${entry.entityId} • Retries: ${entry.retryCount}"),
                                trailing: entry.lastError != null
                                    ? Tooltip(
                                        message: entry.lastError!,
                                        child: Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                                      )
                                    : const Icon(Icons.schedule, size: 20),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncStateAsync = ref.watch(metronSyncStateProvider);
    final syncManager = ref.watch(metronSyncManagerProvider);
    final syncState = syncStateAsync.value ?? syncManager.currentState;
    final pendingCountAsync = ref.watch(pendingQueueCountProvider);
    final pendingCount = pendingCountAsync.value ?? 0;
    final theme = Theme.of(context);

    final isSyncing = syncState.status == SyncStatus.syncing;

    if (pendingCount == 0 && !isSyncing) {
      return const SizedBox.shrink();
    }

    if (isSyncing && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!isSyncing && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _showQueueInspector(context, ref),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSyncing
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSyncing
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
              ),
              boxShadow: isSyncing
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15 + (_glowAnimation.value * 0.2),
                        ),
                        blurRadius: 6 + (_glowAnimation.value * 6),
                        spreadRadius: _glowAnimation.value * 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                else
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: 6),
                Text(
                  isSyncing ? "Syncing..." : "$pendingCount pending",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSyncing
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
