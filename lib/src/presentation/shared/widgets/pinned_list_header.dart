import "package:flutter/material.dart";

/// Pinned + floating header bar that stays at the top, slides away on scroll-down, and re-emerges on scroll-up.
class PinnedListHeader extends StatelessWidget {
  const PinnedListHeader({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: PinnedListHeaderDelegate(child: child, isLoading: isLoading),
    );
  }
}

/// [SliverPersistentHeaderDelegate] backing [PinnedListHeader].
class PinnedListHeaderDelegate extends SliverPersistentHeaderDelegate {
  PinnedListHeaderDelegate({required this.child, this.isLoading = false});

  final Widget child;
  final bool isLoading;

  static const double compactHeight = 48;
  static const double expandedHeight = 56;
  static const double loadingHeight = 72;

  @override
  double get minExtent => isLoading ? loadingHeight : compactHeight;

  @override
  double get maxExtent => isLoading ? loadingHeight : expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(PinnedListHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || isLoading != oldDelegate.isLoading;
}
