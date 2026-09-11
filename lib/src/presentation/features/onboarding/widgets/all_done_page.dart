import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/sync/metron_sync_state.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

class AllDonePage extends ConsumerStatefulWidget {
  const AllDonePage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  ConsumerState<AllDonePage> createState() => _AllDonePageState();
}

class _AllDonePageState extends ConsumerState<AllDonePage> {
  bool _syncTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerInitialSyncIfNeeded();
    });
  }

  void _triggerInitialSyncIfNeeded() {
    if (_syncTriggered) return;
    final isConnected = ref.read(metronConnectionProvider).value == true;
    if (isConnected) {
      _syncTriggered = true;
      ref.read(metronSyncManagerProvider).syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = ref.watch(metronConnectionProvider).value == true;
    final syncState =
        ref.watch(metronSyncStateProvider).value ?? const MetronSyncState();

    final isSyncing = isConnected && syncState.isSyncing;

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
              : isConnected
                  ? "All Synced & Ready!"
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
                        icon: Icons.auto_stories_outlined,
                        label: "Collected Issues",
                        count: syncState.collectionItemsSynced,
                        isSyncing: isSyncing,
                      ),
                      const Divider(height: 16),
                      _buildSyncCounterRow(
                        context,
                        icon: Icons.bookmark_added_outlined,
                        label: "Subscriptions / Pulls",
                        count: syncState.pullListSeriesSynced,
                        isSyncing: isSyncing,
                      ),
                      const Divider(height: 16),
                      _buildSyncCounterRow(
                        context,
                        icon: Icons.favorite_border,
                        label: "Wishlist Items",
                        count: syncState.wishlistItemsSynced,
                        isSyncing: isSyncing,
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
        buttons: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: widget.onFinish,
              child: Text(
                isSyncing
                    ? "Enter Takion (Sync in Background)"
                    : "Finish Setup",
              ),
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
    required bool isSyncing,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isSyncing && count == 0)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Text(
            "$count",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
