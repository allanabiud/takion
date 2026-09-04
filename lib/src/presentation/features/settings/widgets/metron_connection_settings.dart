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
              const SizedBox(height: 12),
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
  bool _isMigrating = false;

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

  Future<void> _triggerMigration() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Migrate Local Data to Metron"),
        content: const Text(
          "This will upload any local collection items, pull lists, and wish lists "
          "to your Metron cloud account.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Migrate"),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isMigrating = true);
    try {
      final migrationManager = ref.read(migrationManagerProvider);
      final result = await migrationManager.runMigration();
      if (!mounted) return;
      if (result.hasFailed) {
        TakionAlerts.error(
          context,
          "Migration failed: ${result.errorMessage ?? 'Unknown error'}",
        );
      } else {
        TakionAlerts.success(
          context,
          "Migration complete (${result.migratedCollection} collection, ${result.migratedSubscriptions} pull list, ${result.migratedWishlist} wishlist)",
        );
      }
    } catch (e) {
      if (mounted) {
        TakionAlerts.safeError(context, e, userMessage: "Migration failed");
      }
    } finally {
      if (mounted) setState(() => _isMigrating = false);
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
    final isSyncing = syncState.isSyncing || _isManualSyncing;

    if (isSyncing && !_syncAnimController.isAnimating) {
      _syncAnimController.repeat();
    } else if (!isSyncing && _syncAnimController.isAnimating) {
      _syncAnimController.reset();
    }

    final lastSyncText = syncState.lastSyncedAt != null
        ? "Last synced ${DateFormatter.relativeShort(syncState.lastSyncedAt!)}"
        : "Not synced yet";

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
          isSyncing
              ? "Please wait while data is synchronizing"
              : syncState.hasError
              ? (syncState.errorMessage ?? "An error occurred during sync")
              : lastSyncText,
          style: syncState.hasError
              ? theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                )
              : null,
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: isSyncing || _isMigrating ? null : _triggerMetronSync,
          child: isSyncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Sync Now"),
        ),
      ),
      if (pendingCount > 0) ...[
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$pendingCount offline write${pendingCount == 1 ? '' : 's'} queued to push",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const Divider(height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _isMigrating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.upload_file_outlined, color: theme.colorScheme.primary),
        title: Text(
          _isMigrating ? "Migrating Data..." : "Migrate Local Data to Metron",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          "Upload existing local comics, subscriptions, and wishlist to Metron",
        ),
        enabled: !isSyncing && !_isMigrating,
        onTap: isSyncing || _isMigrating ? null : _triggerMigration,
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
              "${state.burstRemaining}/min",
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
