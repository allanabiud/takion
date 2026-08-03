import 'package:flutter/material.dart';

/// A pinned, compact header bar for list screens.
///
/// Wraps [child] (typically a [ListHeader]) in a pinned + floating
/// [SliverPersistentHeader] that stays at the top while idle, slides away on
/// scroll-down, and re-emerges on any scroll-up. Its background matches the
/// scaffold so it blends seamlessly with the page behind it.
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

  /// Height of the bar once it is fully pinned (scrolled to the top).
  static const double compactHeight = 48;

  /// Height of the bar when the list is at the top of the scroll view.
  static const double expandedHeight = 56;

  /// Fixed height used while loading to make room for progress indicators.
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
