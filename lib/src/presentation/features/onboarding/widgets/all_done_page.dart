import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

import "package:takion/src/presentation/shared/widgets/animated_counter_text.dart";

class AllDonePage extends ConsumerStatefulWidget {
  const AllDonePage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  ConsumerState<AllDonePage> createState() => _AllDonePageState();
}

class _AllDonePageState extends ConsumerState<AllDonePage> {
  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    final isConnected = ref.read(metronConnectionProvider).value == true;
    if (isConnected) {
      _syncStarted = true;
      ref.read(metronSyncManagerProvider).syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = ref.watch(metronConnectionProvider).value == true;
    final syncState =
        ref.watch(metronSyncStateProvider).value ?? const MetronSyncState();

    final isSyncing = _syncStarted || (isConnected && syncState.isSyncing);
    if (_syncStarted && !syncState.isSyncing) {
      _syncStarted = false;
    }

    final phase = (syncState.currentPhase ?? "").toLowerCase();
    final isCollectionActive = isSyncing && phase.contains("collection");
    final isPullListActive = isSyncing && phase.contains("pull list");
    final isWishlistActive = isSyncing && phase.contains("wishlist");

    final isCollectionDone = !isCollectionActive &&
        (syncState.collectionItemsSynced > 0 || isPullListActive || isWishlistActive || !isSyncing);
    final isPullListDone = !isPullListActive &&
        (syncState.pullListSeriesSynced > 0 || isWishlistActive || !isSyncing);
    final isWishlistDone = !isWishlistActive &&
        (syncState.wishlistItemsSynced > 0 || (!isSyncing && !isWishlistActive));

    return PopScope(
      canPop: false,
      child: OnboardingPageScaffold(
        icon: isSyncing
            ? SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * -0.26,
                    child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                  ),
                ),
                child: Icon(
                  Icons.verified,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
        title: Text(
          isSyncing
              ? "Syncing Your Comics..."
              : "All Done!",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: isSyncing
            ? (syncState.currentPhase ?? "Fetching your collection, pull list and wishlist from Metron...")
            : "All set to start discovering, tracking and collecting comics.",
        content: isConnected
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSyncCounterRow(
                        context,
                        icon: Icons.inventory_2_outlined,
                        label: "Collected Issues",
                        count: syncState.collectionItemsSynced,
                        isActive: isCollectionActive,
                        isDone: isCollectionDone,
                      ),
                      const Divider(height: 16),
                      _buildSyncCounterRow(
                        context,
                        icon: Icons.notifications_active_outlined,
                        label: "Subscriptions / Pulls",
                        count: syncState.pullListSeriesSynced,
                        isActive: isPullListActive,
                        isDone: isPullListDone,
                      ),
                      const Divider(height: 16),
                      _buildSyncCounterRow(
                        context,
                        icon: Icons.turned_in_not,
                        label: "Wishlist Items",
                        count: syncState.wishlistItemsSynced,
                        isActive: isWishlistActive,
                        isDone: isWishlistDone,
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
        buttons: [
          if (!isSyncing)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: widget.onFinish,
                child: const Text("Finish Setup"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncCounterRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required bool isDone,
  }) {
    final theme = Theme.of(context);
    final isHighlighted = isActive || isDone || count > 0;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlighted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: isHighlighted
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
            ] else if (isDone) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            AnimatedCounterText(
              value: count,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
