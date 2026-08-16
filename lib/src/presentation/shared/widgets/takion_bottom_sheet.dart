import "package:flutter/material.dart";

class TakionBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? titleHeader;
  final bool showHandle;
  final double horizontalPadding;

  const TakionBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.titleHeader,
    this.showHandle = true,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final safeAreaBottom = mediaQuery.padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 10,
        bottom:
            viewInsets.bottom +
            (viewInsets.bottom > 0 ? 8 : safeAreaBottom + 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHandle)
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          if (titleHeader != null)
            titleHeader!
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...?actions,
              ],
            ),
          ],
          const SizedBox(height: 14),
          Flexible(child: child),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    Widget? titleHeader,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TakionBottomSheet(
        title: title,
        actions: actions,
        titleHeader: titleHeader,
        child: child,
      ),
    );
  }
}
