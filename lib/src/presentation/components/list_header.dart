import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.count,
    required this.unit,
    this.pluralUnit,
    this.sortLabel,
    this.onSortTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.enabled = true,
  });

  final int count;
  final String unit;
  final String? pluralUnit;
  final String? sortLabel;
  final VoidCallback? onSortTap;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 $unit' : '$count ${pluralUnit ?? '${unit}s'}';

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
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
