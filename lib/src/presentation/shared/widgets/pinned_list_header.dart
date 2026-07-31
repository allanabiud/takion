import 'package:flutter/material.dart';

/// A pinned, compact header bar for list screens.
///
/// Wraps [child] (typically a [ListHeader]) in a pinned [SliverPersistentHeader]
/// that vertically centers its content and is visually separated from the
/// content below (and from any other pinned bars, such as the week picker) by
/// a subtle bottom border.
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(PinnedListHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || isLoading != oldDelegate.isLoading;
}
