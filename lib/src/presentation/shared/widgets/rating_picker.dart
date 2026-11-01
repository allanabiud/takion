import "package:flutter/material.dart";
import "package:flutter/services.dart";

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

  void _updateRatingFromOffset(double localX, double totalWidth) {
    if (!enabled || totalWidth <= 0) return;
    final star = ((localX / totalWidth) * 5).floor() + 1;
    final clamped = star.clamp(1, 5);
    if (clamped != selectedRating) {
      if ((clamped - selectedRating).abs() >= 1) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
      onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showReset = selectedRating > 0;
    final totalWidth = iconSize * 5;

    Widget resetButton() {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: IconButton(
          padding: EdgeInsets.zero,
          tooltip: "Clear rating",
          visualDensity: VisualDensity.compact,
          constraints: BoxConstraints.tightFor(
            width: iconSize,
            height: iconSize,
          ),
          iconSize: iconSize * 0.8,
          onPressed: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onReset();
                }
              : null,
          icon: Icon(
            Icons.do_not_disturb_on_outlined,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    Widget stars() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          _updateRatingFromOffset(details.localPosition.dx, totalWidth);
        },
        onHorizontalDragStart: (details) {
          _updateRatingFromOffset(details.localPosition.dx, totalWidth);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var starValue = 1; starValue <= 5; starValue++)
              IconButton(
                padding: EdgeInsets.zero,
                tooltip: "$starValue ${starValue == 1 ? 'star' : 'stars'}",
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
                onPressed: enabled
                    ? () {
                        HapticFeedback.lightImpact();
                        onChanged(starValue);
                      }
                    : null,
                icon: AnimatedScale(
                  scale: starValue <= selectedRating ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    starValue <= selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: starValue <= selectedRating
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
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
                Positioned(left: -(iconSize + 12), child: resetButton()),
            ],
          ),
        );
      },
    );
  }
}
