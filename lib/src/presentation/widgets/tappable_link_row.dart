import 'package:flutter/material.dart';

class TappableLinkRow extends StatelessWidget {
  const TappableLinkRow({
    super.key,
    required this.label,
    required this.onTap,
    this.isCurrent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = onTap == null;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: disabled
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: disabled
                      ? Theme.of(context).disabledColor
                      : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isCurrent ? Icons.check_circle_outline : Icons.chevron_right,
              size: 20,
              color: disabled
                  ? Theme.of(context).disabledColor
                  : colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
