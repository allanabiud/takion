import 'package:flutter/material.dart';

class InfoGridItem {
  final String label;
  final String value;
  final IconData? icon;
  final bool spanFull;

  const InfoGridItem({
    required this.label,
    required this.value,
    this.icon,
    this.spanFull = false,
  });
}

class InfoGrid extends StatelessWidget {
  final List<InfoGridItem> items;

  const InfoGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final cells = <Widget>[];
    var i = 0;
    while (i < items.length) {
      final item = items[i];
      if (item.spanFull) {
        cells.add(_GridCell(item: item));
        i++;
      } else {
        final rowChildren = <Widget>[Expanded(child: _GridCell(item: item))];
        if (i + 1 < items.length && !items[i + 1].spanFull) {
          rowChildren.add(const SizedBox(width: 8));
          rowChildren.add(Expanded(child: _GridCell(item: items[i + 1])));
          i += 2;
        } else {
          rowChildren.add(const Spacer(flex: 2));
          i++;
        }
        cells.add(Row(children: rowChildren));
      }
      if (i < items.length) {
        cells.add(const SizedBox(height: 10));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cells,
    );
  }
}

class _GridCell extends StatelessWidget {
  final InfoGridItem item;

  const _GridCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(
      item.label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
    final valueWidget = Text(
      item.value,
      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (item.icon != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 20,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, const SizedBox(height: 2), valueWidget],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [labelWidget, const SizedBox(height: 2), valueWidget],
    );
  }
}
