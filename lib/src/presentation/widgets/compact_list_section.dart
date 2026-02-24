import 'package:flutter/material.dart';
import 'package:takion/src/presentation/widgets/compact_list_tile.dart';

class CompactListSectionItem {
  const CompactListSectionItem({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
}

class CompactListSection extends StatelessWidget {
  const CompactListSection({
    super.key,
    required this.items,
    this.title,
  });

  final String? title;
  final List<CompactListSectionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...List.generate(items.length, (index) {
          final item = items[index];
          return CompactListTile(
            icon: item.icon,
            label: item.label,
            value: item.value,
            onTap: item.onTap,
            isFirst: index == 0,
            isLast: index == items.length - 1,
          );
        }),
      ],
    );
  }
}