import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/presentation/features/series/providers/series_completion_provider.dart";
import "package:takion/src/presentation/shared/widgets/shimmer_widget.dart";
import "package:takion/src/presentation/shared/widgets/skeleton.dart";

class SeriesProgressCards extends ConsumerWidget {
  final int seriesId;
  final int total;

  const SeriesProgressCards({
    super.key,
    required this.seriesId,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedAsync = ref.watch(seriesOwnedCountProvider(seriesId));
    final readAsync = ref.watch(seriesReadCountProvider(seriesId));

    final owned = ownedAsync.value;
    final read = readAsync.value;
    if (owned == null || read == null) {
      if (ownedAsync.hasError || readAsync.hasError) {
        return const SizedBox.shrink();
      }
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ShimmerWidget(
          child: Row(
            children: [
              Expanded(child: SkeletonBox(height: 64, borderRadius: 12)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 64, borderRadius: 12)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: ProgressStatCard(
              value: owned,
              total: total,
              label: "COLLECTED",
              icon: Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProgressStatCard(
              value: read,
              total: total,
              label: "READ",
              icon: Icons.bookmark_added,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressStatCard extends StatelessWidget {
  final int value;
  final int total;
  final String label;
  final IconData icon;

  const ProgressStatCard({
    super.key,
    required this.value,
    required this.total,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final percent = (fraction * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Center(
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$value/$total",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: " · $percent%",
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
