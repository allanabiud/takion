import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class TakionFlash {
  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          behavior: FlashBehavior.floating,
          position: FlashPosition.top,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
          ),
          margin: const EdgeInsets.fromLTRB(24, 56, 24, 0),
          clipBehavior: Clip.antiAlias,
          icon: Icon(icon, color: color),
          content: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          elevation: 4,
        );
      },
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      icon: Icons.check_circle_outline,
      color: Colors.greenAccent,
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
