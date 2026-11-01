import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/migration/migration_state.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

void showMigrationSheet(BuildContext context) {
  TakionBottomSheet.show(
    context: context,
    title: "Migrate to Metron",
    child: const _MigrationContent(),
  );
}

class _MigrationContent extends ConsumerStatefulWidget {
  const _MigrationContent();

  @override
  ConsumerState<_MigrationContent> createState() => _MigrationContentState();
}

class _MigrationContentState extends ConsumerState<_MigrationContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manager = ref.watch(migrationManagerProvider);

    return StreamBuilder<MigrationProgress>(
      stream: manager.progressStream,
      initialData: manager.currentProgress,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? manager.currentProgress;
        final isRunning = progress.isMigrating;
        final isDone = progress.isCompleted || progress.hasFailed;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRunning) ...[
              LinearProgressIndicator(
                value: progress.progressFraction,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 16),
              _ProgressRow(
                label: "Collection",
                migrated: progress.migratedCollection,
                failed: progress.failedCollection,
                total: progress.totalCollection,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 8),
              _ProgressRow(
                label: "Subscriptions",
                migrated: progress.migratedSubscriptions,
                failed: progress.failedSubscriptions,
                total: progress.totalSubscriptions,
                icon: Icons.notifications_outlined,
              ),
              if (progress.currentStep != null) ...[
                const SizedBox(height: 12),
                Text(
                  progress.currentStep!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (progress.estimatedRemaining != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Estimated time remaining: ${_formatDuration(progress.estimatedRemaining!)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: manager.cancel,
                  child: const Text("Cancel"),
                ),
              ),
            ] else if (isDone) ...[
              if (progress.isCompleted) ...[
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "Migration Complete",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  progress.hasFailed && progress.errorMessage != null
                      ? Icons.error_outline
                      : Icons.cancel_outlined,
                  size: 48,
                  color: progress.hasFailed
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    progress.hasFailed
                        ? "Migration Failed"
                        : "Migration Cancelled",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _SummaryRow(
                label: "Collection",
                migrated: progress.migratedCollection,
                failed: progress.failedCollection,
                total: progress.totalCollection,
              ),
              const SizedBox(height: 4),
              _SummaryRow(
                label: "Subscriptions",
                migrated: progress.migratedSubscriptions,
                failed: progress.failedSubscriptions,
                total: progress.totalSubscriptions,
              ),
              if (progress.elapsedMs > 0) ...[
                const SizedBox(height: 8),
                Text(
                  "Completed in ${_formatDuration(progress.elapsed)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (progress.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  progress.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (progress.failedItems > 0) ...[
                const SizedBox(height: 12),
                Text(
                  "${progress.failedItems} item${progress.failedItems == 1 ? '' : 's'} failed to migrate. They will be included in the next sync.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (progress.failedItems > 0) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await manager.runMigration();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: const Text("Retry Failed Items"),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Done"),
                ),
              ),
            ] else ...[
              Text(
                "This will upload your local collection and subscriptions to your Metron account.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "Items are uploaded one at a time with a short delay between each to respect API rate limits.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await manager.runMigration();
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Text("Start Migration"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes >= 1) {
      return "${d.inMinutes}m ${d.inSeconds.remainder(60)}s";
    }
    return "${d.inSeconds}s";
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.migrated,
    required this.failed,
    required this.total,
    required this.icon,
  });

  final String label;
  final int migrated;
  final int failed;
  final int total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final processed = migrated + failed;
    final fraction = total > 0 ? processed / total : 1.0;

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    failed > 0
                        ? "$migrated/$total ($failed failed)"
                        : "$processed/$total",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: failed > 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: fraction,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.migrated,
    required this.failed,
    required this.total,
  });

  final String label;
  final int migrated;
  final int failed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          failed > 0
              ? "$migrated migrated, $failed failed of $total"
              : "$migrated of $total migrated",
          style: theme.textTheme.bodySmall?.copyWith(
            color: failed > 0 ? theme.colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}
