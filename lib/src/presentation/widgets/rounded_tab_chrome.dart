import 'package:flutter/material.dart';

class RoundedHeaderSurface extends StatelessWidget {
  const RoundedHeaderSurface({
    required this.child,
    required this.topColor,
    required this.bottomColor,
    this.bottomRadius = 24,
    super.key,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class SegmentedTabSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  SegmentedTabSliverHeaderDelegate({required this.child, this.extent = 68});

  final Widget child;
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SegmentedTabSliverHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.extent != extent;
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    required this.labels,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.unselectedColor,
    required this.unselectedTextColor,
    this.gap = 8,
    this.verticalPadding = 12,
    super.key,
  });

  final List<String> labels;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final Color unselectedTextColor;
  final double gap;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final controller = DefaultTabController.of(context);
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final selected = controller.index;
            return Row(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => controller.animateTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: selected == i
                              ? selectedColor
                              : unselectedColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: selected == i
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow
                                        .withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: selected == i
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: selected == i
                                      ? selectedTextColor
                                      : unselectedTextColor,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
