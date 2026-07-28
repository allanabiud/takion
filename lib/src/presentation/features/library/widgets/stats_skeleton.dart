import 'package:flutter/material.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SkeletonBox(width: 36, height: 36, borderRadius: 18),
          const SizedBox(height: 8),
          SkeletonBox(width: 60, height: 20, borderRadius: 4),
          const SizedBox(height: 2),
          SkeletonBox(width: 80, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

class SectionHeaderSkeleton extends StatelessWidget {
  const SectionHeaderSkeleton({super.key, this.showChevron = false});

  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SkeletonBox(width: 120, height: 20, borderRadius: 4),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: 8),
          SkeletonBox(width: 24, height: 24, borderRadius: 4),
        ],
      ],
    );
  }
}

class TopEntityTileSkeleton extends StatelessWidget {
  const TopEntityTileSkeleton({super.key, this.isLast = false});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SkeletonBox(width: 28, height: 20, borderRadius: 4),
              const SizedBox(width: 8),
              SkeletonBox(width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 16, borderRadius: 4),
                    const SizedBox(height: 4),
                    SkeletonBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              SkeletonBox(width: 20, height: 20, borderRadius: 4),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

class StatBarTableSkeleton extends StatelessWidget {
  const StatBarTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SkeletonBox(width: 120, height: 14, borderRadius: 4),
              const SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 18, borderRadius: 4)),
              const SizedBox(width: 8),
              SkeletonBox(width: 32, height: 14, borderRadius: 4),
            ],
          ),
        );
      }),
    );
  }
}

class IssueListTileSkeleton extends StatelessWidget {
  const IssueListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 67, height: 98, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonBox(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SkeletonBox(width: 16, height: 16, borderRadius: 4),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 16, height: 16, borderRadius: 4),
                    const SizedBox(width: 8),
                    SkeletonBox(width: 16, height: 16, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
