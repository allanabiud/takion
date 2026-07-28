import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.count,
    required this.unit,
    this.pluralUnit,
    this.pageCount,
    this.sortLabel,
    this.onSortTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.enabled = true,
  });

  final int count;
  final String unit;
  final String? pluralUnit;
  final int? pageCount;
  final String? sortLabel;
  final VoidCallback? onSortTap;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 $unit' : '$count ${pluralUnit ?? '${unit}s'}';
    final pageLabel = pageCount == null
        ? null
        : pageCount == 1
        ? '1 item on this page'
        : '$pageCount items on this page';

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                if (pageLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    pageLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onSortTap != null && sortLabel != null)
            TextButton.icon(
              onPressed: enabled ? onSortTap : null,
              icon: const Icon(Icons.swap_vert),
              label: Text(sortLabel!),
            ),
        ],
      ),
    );
  }
}
