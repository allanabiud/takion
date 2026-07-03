import 'package:flutter/material.dart';

class InfoGridItem {
  final String label;
  final String value;

  const InfoGridItem({required this.label, required this.value});
}

class InfoGrid extends StatelessWidget {
  final List<InfoGridItem> items;

  const InfoGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final cells = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final rowChildren = <Widget>[
        Expanded(child: _GridCell(item: items[i])),
      ];

      if (i + 1 < items.length) {
        rowChildren.add(const SizedBox(width: 8));
        rowChildren.add(Expanded(child: _GridCell(item: items[i + 1])));
      } else {
        rowChildren.add(const Spacer(flex: 2));
      }

      cells.add(Row(children: rowChildren));
      if (i + 2 < items.length) {
        cells.add(const SizedBox(height: 10));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cells,
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final InfoGridItem item;

  const _GridCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
