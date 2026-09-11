import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/date_formatter.dart";
import "package:takion/src/core/network/metron_account_service.dart";

import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";
import "package:takion/src/presentation/features/settings/widgets/settings_helpers.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:takion/src/presentation/providers/rate_limit_status_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

Future<void> disconnectMetronAccount(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(metronAccountServiceProvider).disconnect();
  ref.invalidate(metronConnectionProvider);
  ref.invalidate(authStateProvider);
  if (!context.mounted) return;
  TakionAlerts.info(context, "Disconnected");
}

void showMetronConnectionSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Metron",
    child: const MetronConnectionContent(),
  );
}

class MetronConnectionContent extends ConsumerStatefulWidget {
  const MetronConnectionContent({super.key});

  @override
  ConsumerState<MetronConnectionContent> createState() =>
      _MetronConnectionContentState();
}

class _MetronConnectionContentState
    extends ConsumerState<MetronConnectionContent> {
  String? _maskedToken;

  @override
  Widget build(BuildContext context) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final isConnected = metronConnectionAsync.value == true;
    final theme = Theme.of(context);

    ref.listen(metronConnectionProvider, (previous, next) {
      if (next.value == false) {
        setState(() => _maskedToken = null);
      }
    });

    if (isConnected && _maskedToken == null) {
      Future.microtask(() async {
        final token = await ref
            .read(metronAccountServiceProvider)
            .getStoredToken();
        if (token != null && mounted) {
          setState(() => _maskedToken = maskMetronToken(token));
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ACCOUNT",
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.95,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: buildMetronAccountCard(
                    key: ValueKey("metron_card_$isConnected"),
                    context: context,
                    isConnected: isConnected,
                    maskedToken: _maskedToken ?? "",
                    onConnect: () {
                      Navigator.of(context).pop();
                      context.pushRoute(const AuthorizeMetronRoute());
                    },
                    onDisconnect: () => disconnectMetronAccount(context, ref),
                  ),
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 16),
            const _MetronSyncCard(),
            const SizedBox(height: 16),
            const _ApiUsageCard(),
          ],
        ],
      ),
    );
  }
}

class _MetronSyncCard extends ConsumerStatefulWidget {
  const _MetronSyncCard();

  @override
  ConsumerState<_MetronSyncCard> createState() => _MetronSyncCardState();
}

class _MetronSyncCardState extends ConsumerState<_MetronSyncCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _syncAnimController;
  late final Animation<double> _syncRotation;
  bool _isManualSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncRotation = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _syncAnimController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _syncAnimController.dispose();
    super.dispose();
  }

  Future<void> _triggerMetronSync() async {
    setState(() => _isManualSyncing = true);
    _syncAnimController.repeat();
    try {
      final syncManager = ref.read(metronSyncManagerProvider);
      final result = await syncManager.syncAll(forceFullSync: true);
      if (!mounted) return;
      if (result.hasError) {
        TakionAlerts.error(
          context,
          result.errorMessage ?? "Sync completed with errors",
        );
      } else {
        TakionAlerts.success(context, "Metron sync complete");
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: "Metron sync failed");
      }
    } finally {
      if (mounted) {
        _syncAnimController.reset();
        setState(() => _isManualSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncStateAsync = ref.watch(metronSyncStateProvider);
    final syncManager = ref.watch(metronSyncManagerProvider);
    final syncState = syncStateAsync.value ?? syncManager.currentState;
    final pendingCount =
        ref.watch(pendingOfflineWritesCountProvider).value ?? 0;
    final failedCount =
        ref.watch(failedOfflineWritesCountProvider).value ?? 0;
    final isSyncing = syncState.isSyncing || _isManualSyncing;

    if (isSyncing && !_syncAnimController.isAnimating) {
      _syncAnimController.repeat();
    } else if (!isSyncing && _syncAnimController.isAnimating) {
      _syncAnimController.reset();
    }

    final rateLimitState = ref.watch(rateLimitStatusProvider);
    final isRateLimited = isSyncing && rateLimitState.burstRemaining <= 0;

    final String syncSubtitleText;
    final TextStyle? syncSubtitleStyle;
    if (isRateLimited) {
      syncSubtitleText =
          "Rate limit reached (${rateLimitState.burstLimit} req/min) · Waiting for next slot...";
      syncSubtitleStyle = theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.tertiary,
        fontWeight: FontWeight.w500,
      );
    } else if (isSyncing) {
      syncSubtitleText = "Please wait while data is synchronizing";
      syncSubtitleStyle = null;
    } else if (syncState.hasError) {
      syncSubtitleText = syncState.errorMessage ?? "An error occurred during sync";
      syncSubtitleStyle = theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      );
    } else if (pendingCount > 0) {
      syncSubtitleText =
          "$pendingCount change${pendingCount == 1 ? '' : 's'} not synced";
      syncSubtitleStyle = theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.tertiary,
        fontWeight: FontWeight.w500,
      );
    } else {
      syncSubtitleText = "No changes to sync";
      syncSubtitleStyle = null;
    }

    final statusColor = syncState.hasError
        ? theme.colorScheme.error
        : isSyncing
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return buildSettingsGroup(context, "Metron Synchronization", [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: isSyncing
            ? RotationTransition(
                turns: _syncRotation,
                child: Icon(Icons.sync, color: theme.colorScheme.primary),
              )
            : Icon(
                syncState.hasError
                    ? Icons.sync_problem
                    : Icons.cloud_done_outlined,
                color: statusColor,
              ),
        title: Text(
          isSyncing
              ? (syncState.currentPhase ?? "Syncing with Metron...")
              : syncState.hasError
              ? "Sync Error"
              : "Metron Sync",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          syncSubtitleText,
          style: syncSubtitleStyle,
        ),
      ),
      if (isRateLimited)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 14,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Metron limit: ${rateLimitState.burstLimit} requests/min. Pacing automatically to prevent errors.",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: isSyncing ? null : _triggerMetronSync,
          child: isSyncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Sync Now"),
        ),
      ),
      if (failedCount > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$failedCount change${failedCount == 1 ? '' : 's'} failed",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showFailedChangesSheet(context, ref),
                child: const Text("Details"),
              ),
              TextButton(
                onPressed: isSyncing
                    ? null
                    : () async {
                        final queue = ref.read(offlineWriteQueueProvider);
                        await queue.retryFailedEntries();
                        if (context.mounted) {
                          await _triggerMetronSync();
                        }
                      },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
    ]);
  }
}

class _ApiUsageCard extends ConsumerWidget {
  const _ApiUsageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rateLimitStatusProvider);
    final theme = Theme.of(context);
    final used = state.sustainedLimit - state.sustainedRemaining;
    final ratio = used / state.sustainedLimit;
    final progressColor = switch (state.sustainedRemaining /
        state.sustainedLimit) {
      > 0.5 => theme.colorScheme.primary,
      > 0.2 => theme.colorScheme.tertiary,
      _ => theme.colorScheme.error,
    };

    return buildSettingsGroup(context, "API Usage", [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${state.sustainedRemaining}",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  "of ${state.sustainedLimit} requests remaining",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${state.burstRemaining}/${state.burstLimit}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(progressColor),
        ),
      ),
      if (state.sustainedReset > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                "Reset ${DateFormatter.relativeDetailed(DateTime.fromMillisecondsSinceEpoch(state.sustainedReset * 1000))}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
    ]);
  }
}

void _showFailedChangesSheet(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Failed Sync Changes",
    child: _FailedChangesSheetContent(ref: ref),
  );
}

class _FailedChangesSheetContent extends StatefulWidget {
  final WidgetRef ref;
  const _FailedChangesSheetContent({required this.ref});

  @override
  State<_FailedChangesSheetContent> createState() =>
      _FailedChangesSheetContentState();
}

class _FailedChangesSheetContentState
    extends State<_FailedChangesSheetContent> {
  List<OfflineWriteQueueData>? _failedEntries;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final queue = widget.ref.read(offlineWriteQueueProvider);
    final entries = await queue.getFailedEntries();
    if (mounted) {
      setState(() {
        _failedEntries = entries;
        _isLoading = false;
      });
    }
  }

  String _formatOperation(OfflineWriteQueueData entry) {
    final entity = switch (entry.entityType) {
      "collection" => "Collection",
      "pull_list" => "Pull List",
      "wish_list" => "Wishlist",
      _ => entry.entityType,
    };
    final op = switch (entry.operation) {
      "create" => "Add to",
      "delete" => "Remove from",
      "update" => "Update in",
      "scrobble" => "Mark read in",
      "acquire" => "Acquire in",
      _ => entry.operation,
    };
    final idStr = entry.entityId != null ? " (#${entry.entityId})" : "";
    return "$op $entity$idStr";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final entries = _failedEntries ?? [];
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text("No failed changes in queue"),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "The following changes could not be synced after multiple attempts. "
          "Review the error reason below to resolve the issue, retry, or remove invalid items.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, index) {
              final entry = entries[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                title: Text(
                  _formatOperation(entry),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.lastError ?? "Unknown error",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Attempted ${entry.retryCount} times",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: "Remove from queue",
                  onPressed: () async {
                    final queue = widget.ref.read(offlineWriteQueueProvider);
                    await queue.deleteEntry(entry.id);
                    await _loadEntries();
                    if (entries.length <= 1 && ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final queue = widget.ref.read(offlineWriteQueueProvider);
                  await queue.clearFailedEntries();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text("Clear All"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final queue = widget.ref.read(offlineWriteQueueProvider);
                  await queue.retryFailedEntries();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    final syncManager = widget.ref.read(metronSyncManagerProvider);
                    syncManager.syncAll();
                  }
                },
                child: const Text("Retry All"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
