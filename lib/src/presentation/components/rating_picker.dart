import 'package:flutter/material.dart';

class RatingPicker extends StatelessWidget {
  const RatingPicker({
    super.key,
    required this.selectedRating,
    required this.enabled,
    required this.onChanged,
    required this.onReset,
    this.iconSize = 44,
    this.resetIconEdgeInset = 0,
  });

  final int selectedRating;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final VoidCallback onReset;
  final double iconSize;
  final double resetIconEdgeInset;

  @override
  Widget build(BuildContext context) {
    final stars = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
            iconSize: iconSize,
            onPressed: enabled ? () => onChanged(starValue) : null,
            icon: Icon(
              starValue <= selectedRating ? Icons.star : Icons.star_border,
              color: starValue <= selectedRating
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      }),
    );

    return SizedBox(
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          stars,
          if (selectedRating > 0)
            Positioned(
              left: resetIconEdgeInset,
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  iconSize: iconSize * 0.8,
                  onPressed: enabled ? onReset : null,
                  icon: Icon(
                    Icons.do_not_disturb_on_outlined,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
