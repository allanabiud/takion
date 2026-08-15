import "package:flutter/material.dart";

class HorizontalPreviewSection extends StatelessWidget {
  const HorizontalPreviewSection({
    super.key,
    required this.title,
    this.onViewAll,
    required this.itemCount,
    required this.itemBuilder,
    this.count,
    this.height = 250,
    this.emptyText = "No items available.",
    this.separatorWidth = 12,
  });

  final String title;
  final int? count;
  final VoidCallback? onViewAll;
  final double height;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String emptyText;
  final double separatorWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  count != null ? "$title ($count)" : title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        if (onViewAll != null) const SizedBox(height: 12),
        if (itemCount == 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              emptyText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          SizedBox(
            height: height,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              separatorBuilder: (_, _) => SizedBox(width: separatorWidth),
              itemBuilder: itemBuilder,
            ),
          ),
      ],
    );
  }
}
