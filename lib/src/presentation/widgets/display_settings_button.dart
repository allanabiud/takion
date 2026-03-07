import 'package:flutter/material.dart';
import 'package:takion/src/presentation/sorting/content_sorting.dart';

class DisplaySettingsButton extends StatelessWidget {
  const DisplaySettingsButton({
    super.key,
    required this.selectedOption,
    required this.optionLabel,
    required this.onSelected,
    this.options = ContentSortOption.values,
  });

  final ContentSortOption selectedOption;
  final String Function(ContentSortOption option) optionLabel;
  final ValueChanged<ContentSortOption> onSelected;
  final List<ContentSortOption> options;

  Future<void> _showDisplaySettingsSheet(BuildContext context) {
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
                      'Display Settings',
                      style:
                          Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
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
                  children: options.map((option) {
                    return FilterChip(
                      label: Text(optionLabel(option)),
                      selected: selectedOption == option,
                      onSelected: (isSelected) {
                        if (!isSelected) return;
                        onSelected(option);
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
    return IconButton(
      tooltip: 'Display settings',
      icon: const Icon(Icons.tune),
      onPressed: () => _showDisplaySettingsSheet(context),
    );
  }
}
