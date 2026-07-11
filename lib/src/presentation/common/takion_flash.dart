import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class TakionFlash {
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showFlash(
      context: context,
      duration: Duration(seconds: onAction != null ? 3 : 2),
      builder: (context, controller) {
        final theme = Theme.of(context);
        return FlashBar(
          controller: controller,
          behavior: FlashBehavior.floating,
          position: FlashPosition.bottom,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.15), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          icon: Icon(icon, color: color, size: 20),
          content: actionLabel != null && onAction != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        onAction();
                        controller.dismiss();
                      },
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                )
              : Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          elevation: 4,
        );
      },
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      icon: Icons.check_circle,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      icon: Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      icon: Icons.info_outline,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
