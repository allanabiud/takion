import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/presentation/components/detail_screen_skeleton.dart';
import 'package:takion/src/presentation/components/shimmer_widget.dart';
import 'package:takion/src/presentation/components/skeleton.dart';

class IssueDetailsSkeleton extends StatelessWidget {
  const IssueDetailsSkeleton({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DetailScreenSkeleton(
      headerRadius: 16,
      body: _buildShimmerBody(),
      header: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
              ),
            )
          else
            ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.75),
                  Colors.transparent,
                  theme.colorScheme.surface.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 180,
              height: 270,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 48),
                      )
                    : const Icon(Icons.image, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildShimmerBody() {
    return ShimmerWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 22, width: 300, borderRadius: 4),
          const SizedBox(height: 8),
          const SkeletonBox(height: 16, width: 180, borderRadius: 4),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(4, (_) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 22, height: 22, borderRadius: 4),
              )),
              const Spacer(),
              ...List.generate(5, (_) => const Padding(
                padding: EdgeInsets.only(left: 4),
                child: SkeletonBox(width: 16, height: 16, borderRadius: 2),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(flex: 3, child: SkeletonBox(height: 48, borderRadius: 12)),
              SizedBox(width: 6),
              Expanded(flex: 1, child: SkeletonBox(height: 48, borderRadius: 12)),
              SizedBox(width: 6),
              Expanded(flex: 1, child: SkeletonBox(height: 48, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 90, borderRadius: 4),
          const SizedBox(height: 12),
          const SkeletonBox(height: 14, width: double.infinity, borderRadius: 4),
          const SizedBox(height: 8),
          const SkeletonBox(height: 14, width: 280, borderRadius: 4),
          const SizedBox(height: 8),
          const SkeletonBox(height: 14, width: 220, borderRadius: 4),
          const SizedBox(height: 8),
          const SkeletonBox(height: 14, width: 120, borderRadius: 4),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 80, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 95, height: 150, borderRadius: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 100, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 95, height: 130, borderRadius: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 70, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 100, height: 155, borderRadius: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 90, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 100, height: 140, borderRadius: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 70, borderRadius: 4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (_) => const SkeletonBox(
              height: 28, width: 80, borderRadius: 14,
            )),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 60, borderRadius: 4),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.zero,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonBox(width: 100, height: 140, borderRadius: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 18, width: 80, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(6, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 80, child: SkeletonBox(height: 14, borderRadius: 4)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(height: 14, borderRadius: 4)),
              ],
            ),
          )),
          const SizedBox(height: 12),
          const SkeletonBox(height: 12, width: 160, borderRadius: 4),
        ],
      ),
    );
  }
}
