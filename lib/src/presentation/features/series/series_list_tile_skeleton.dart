import "package:flutter/material.dart";
import "package:takion/src/presentation/shared/widgets/shimmer_widget.dart";
import "package:takion/src/presentation/shared/widgets/skeleton.dart";

/// Mirrors a [SeriesListTile] layout during loading states.
class SeriesListTileSkeleton extends StatelessWidget {
  const SeriesListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWidget(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SkeletonBox(width: 48, height: 72, borderRadius: 6),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 180, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 110, height: 12, borderRadius: 4),
                  SizedBox(height: 10),
                  SkeletonBox(
                    width: double.infinity,
                    height: 6,
                    borderRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
