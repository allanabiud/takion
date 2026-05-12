import 'package:flutter/material.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';

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
    this.selectedSortOption,
    this.onSortOptionChanged,
    this.sortOptionLabel,
    this.sortOptions = ContentSortOption.values,
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

  // Complex sorting props
  final ContentSortOption? selectedSortOption;
  final ValueChanged<ContentSortOption>? onSortOptionChanged;
  final String Function(ContentSortOption)? sortOptionLabel;
  final List<ContentSortOption> sortOptions;

  Future<void> _showSortSettingsSheet(BuildContext context) {
    if (!enabled || onSortOptionChanged == null || sortOptionLabel == null || selectedSortOption == null) {
      return Future.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Options',
                      style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Sorting',
                  style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortOptions.map((option) {
                    return FilterChip(
                      label: Text(sortOptionLabel!(option)),
                      selected: selectedSortOption == option,
                      onSelected: (isSelected) {
                        if (!isSelected) return;
                        onSortOptionChanged!(option);
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

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
          else if (selectedSortOption != null && onSortOptionChanged != null && sortOptionLabel != null)
            TextButton.icon(
              onPressed: enabled ? () => _showSortSettingsSheet(context) : null,
              icon: const Icon(Icons.swap_vert),
              label: Text(sortOptionLabel!(selectedSortOption!)),
            )
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
