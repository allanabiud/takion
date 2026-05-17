import 'package:flutter/material.dart';

class RatingPicker extends StatelessWidget {
  const RatingPicker({
    super.key,
    required this.selectedRating,
    required this.enabled,
    required this.onChanged,
    required this.onReset,
    this.iconSize = 36,
  });

  final int selectedRating;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final VoidCallback onReset;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              iconSize: iconSize,
              onPressed: enabled ? () => onChanged(starValue) : null,
              icon: Icon(
                starValue <= selectedRating ? Icons.star : Icons.star_border,
                color: starValue <= selectedRating
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            );
          }),
        ),
        if (selectedRating > 0) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: enabled ? onReset : null,
              child: const Text('Reset rating'),
            ),
          ),
        ],
      ],
    );
  }
}
