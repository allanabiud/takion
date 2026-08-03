import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.badge,
    this.onViewAll,
  });

  final String title;
  final int? count;
  final String? badge;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = Text(
      (count != null ? '$title ($count)' : title).toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );

    final row = Row(
      children: [
        titleText,
        if (badge != null) ...[
          const SizedBox(width: 4),
          Text(
            badge!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 28, color: theme.colorScheme.primary),
        ],
      ],
    );

    if (onViewAll != null) {
      return InkWell(
        onTap: onViewAll,
        borderRadius: BorderRadius.circular(4),
        child: row,
      );
    }

    return row;
  }
}
