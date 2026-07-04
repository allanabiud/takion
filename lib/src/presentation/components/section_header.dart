import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.onViewAll,
  });

  final String title;
  final int? count;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = Text(
      count != null ? '$title ($count)' : title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );

    return Row(
      children: [
        titleText,
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            height: 1,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onViewAll,
            child: Icon(
              Icons.chevron_right,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
