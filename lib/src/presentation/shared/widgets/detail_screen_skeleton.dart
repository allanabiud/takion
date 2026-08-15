import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/widgets/components.dart";

class DetailScreenSkeleton extends StatelessWidget {
  const DetailScreenSkeleton({
    super.key,
    required this.header,
    this.initialChildSize = 0.60,
    this.headerRadius = 20,
    this.body,
  });

  final Widget header;
  final double initialChildSize;
  final double headerRadius;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 350,
            child: Stack(fit: StackFit.expand, children: [header]),
          ),
          DraggableScrollableSheet(
            initialChildSize: initialChildSize,
            minChildSize: initialChildSize,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: [initialChildSize, 0.9],
            builder: (context, scrollController) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(headerRadius),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child:
                          body ??
                          ShimmerWidget(
                            child: Column(
                              children: [
                                _buildSkeletonRow(),
                                const SizedBox(height: 16),
                                _buildSkeletonRow(),
                                const SizedBox(height: 16),
                                _buildSkeletonRow(),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSkeletonRow() {
  return const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBox(width: 60, height: 80, borderRadius: 8),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 14),
            SizedBox(height: 10),
            SkeletonBox(height: 12, width: 200),
            SizedBox(height: 10),
            SkeletonBox(height: 12, width: 140),
          ],
        ),
      ),
    ],
  );
}
