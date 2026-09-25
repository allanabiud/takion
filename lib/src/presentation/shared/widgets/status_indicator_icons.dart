import "package:flutter/material.dart";

class StatusIndicatorIcons extends StatelessWidget {
  final bool isCollected;
  final bool isRead;
  final bool isPulled;
  final bool isWishlisted;
  final String? syncStatus;
  final double iconSize;
  final double spacing;
  final MainAxisSize mainAxisSize;

  const StatusIndicatorIcons({
    super.key,
    required this.isCollected,
    required this.isRead,
    required this.isPulled,
    required this.isWishlisted,
    this.syncStatus,
    this.iconSize = 16,
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: mainAxisSize,
      children: [
        _buildIcon(
          context,
          icon: isPulled ? Icons.shopping_bag : Icons.shopping_bag_outlined,
          isActive: isPulled,
          activeColor: theme.colorScheme.secondary,
          tooltip: isPulled ? "Pulled" : "Not pulled",
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          icon: isCollected ? Icons.inventory_2 : Icons.inventory_2_outlined,
          isActive: isCollected,
          activeColor: theme.colorScheme.primary,
          tooltip: isCollected ? "In collection" : "Not in collection",
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          icon: isRead ? Icons.bookmark_added : Icons.bookmark_added_outlined,
          isActive: isRead,
          activeColor: theme.colorScheme.primary,
          tooltip: isRead ? "Read" : "Unread",
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          icon: isWishlisted ? Icons.turned_in : Icons.turned_in_not,
          isActive: isWishlisted,
          activeColor: theme.colorScheme.tertiary,
          tooltip: isWishlisted ? "Wishlisted" : "Not wishlisted",
        ),
      ],
    );
  }

  Widget _buildIcon(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: iconSize,
        color: isActive
            ? activeColor
            : theme.colorScheme.outline.withValues(alpha: 0.6),
      ),
    );
  }
}
