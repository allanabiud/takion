import 'package:flutter/material.dart';

class RatingPicker extends StatelessWidget {
  const RatingPicker({
    super.key,
    required this.selectedRating,
    required this.enabled,
    required this.onChanged,
    required this.onReset,
    this.iconSize = 44,
  });

  final int selectedRating;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final VoidCallback onReset;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showReset = selectedRating > 0;

    Widget resetButton() {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: BoxConstraints.tightFor(
            width: iconSize,
            height: iconSize,
          ),
          iconSize: iconSize * 0.8,
          onPressed: enabled ? onReset : null,
          icon: Icon(
            Icons.do_not_disturb_on_outlined,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    Widget stars() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var starValue = 1; starValue <= 5; starValue++)
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              constraints: BoxConstraints.tightFor(
                width: iconSize,
                height: iconSize,
              ),
              iconSize: iconSize,
              onPressed: enabled ? () => onChanged(starValue) : null,
              icon: Icon(
                starValue <= selectedRating ? Icons.star : Icons.star_border,
                color: starValue <= selectedRating
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) {
          return SizedBox(
            width: double.infinity,
            height: iconSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                stars(),
                if (showReset) Positioned(left: 0, child: resetButton()),
              ],
            ),
          );
        }

        return SizedBox(
          height: iconSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              stars(),
              if (showReset)
                Positioned(
                  left: -(iconSize + 12),
                  child: resetButton(),
                ),
            ],
          ),
        );
      },
    );
  }
}
