import "package:flutter/material.dart";
import "package:takion/src/domain/entities.dart";

class RoleBadge extends StatelessWidget {
  final ItemRole role;

  const RoleBadge({super.key, required this.role});

  Color _getRoleColor(BuildContext context, ItemRole role) {
    final theme = Theme.of(context);
    switch (role) {
      case ItemRole.core:
        return Colors.red;
      case ItemRole.prologue:
        return Colors.orange;
      case ItemRole.tieIn:
        return Colors.blue;
      case ItemRole.epilogue:
        return Colors.purple;
      case ItemRole.standard:
        return theme.colorScheme.primary;
    }
  }

  String _getRoleLabel(ItemRole role) {
    switch (role) {
      case ItemRole.standard:
        return "Standard";
      case ItemRole.prologue:
        return "Prologue";
      case ItemRole.core:
        return "Core";
      case ItemRole.tieIn:
        return "Tie-In";
      case ItemRole.epilogue:
        return "Epilogue";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(context, role);
    final isLight =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _getRoleLabel(role).toUpperCase(),
        style: TextStyle(
          color: isLight ? Colors.black : Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
