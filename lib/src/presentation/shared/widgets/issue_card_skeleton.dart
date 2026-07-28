import 'package:flutter/material.dart';
import 'package:takion/src/presentation/shared/widgets/skeleton.dart';

/// Mirrors an [IssueCard] instead of using one tall placeholder rectangle.
class IssueCardSkeleton extends StatelessWidget {
  const IssueCardSkeleton({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    final coverHeight = width / (2 / 3);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonBox(width: width, height: coverHeight, borderRadius: 8),
          const SizedBox(height: 6),
          SkeletonBox(width: width * .7, height: 12, borderRadius: 4),
          const SizedBox(height: 8),
          SkeletonBox(width: width * .85, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}
