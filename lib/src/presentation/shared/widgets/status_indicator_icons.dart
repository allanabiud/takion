import 'package:flutter/material.dart';

class StatusIndicatorIcons extends StatelessWidget {
  final bool isCollected;
  final bool isRead;
  final bool isPulled;
  final bool isWishlisted;
  final double iconSize;
  final double spacing;
  final MainAxisSize mainAxisSize;

  const StatusIndicatorIcons({
    super.key,
    required this.isCollected,
    required this.isRead,
    required this.isPulled,
    required this.isWishlisted,
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
          isCollected ? Icons.inventory_2 : Icons.inventory_2_outlined,
          isCollected,
          theme.colorScheme.primary,
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          isRead ? Icons.bookmark_added : Icons.bookmark_added_outlined,
          isRead,
          theme.colorScheme.primary,
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          isPulled ? Icons.shopping_bag : Icons.shopping_bag_outlined,
          isPulled,
          theme.colorScheme.secondary,
        ),
        SizedBox(width: spacing),
        _buildIcon(
          context,
          isWishlisted ? Icons.turned_in : Icons.turned_in_not,
          isWishlisted,
          theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildIcon(
    BuildContext context,
    IconData icon,
    bool isActive,
    Color activeColor,
  ) {
    final theme = Theme.of(context);
    return Icon(
      icon,
      size: iconSize,
      color: isActive ? activeColor : theme.colorScheme.outline,
    );
  }
}
