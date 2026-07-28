import 'package:flutter/material.dart';

String maskMetronToken(String token) {
  if (token.length <= 8) {
    return '${token.substring(0, 2)}…${token.substring(token.length - 2)}';
  }
  return '${token.substring(0, 3)}…${token.substring(token.length - 4)}';
}

Widget buildMetronAccountCard({
  required BuildContext context,
  required bool isConnected,
  required String maskedToken,
  required VoidCallback onConnect,
  required VoidCallback onDisconnect,
}) {
  final theme = Theme.of(context);
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: isConnected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'Connected' : 'Not connected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isConnected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Metron API Key',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isConnected ? maskedToken : '-',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isConnected ? onDisconnect : onConnect,
            borderRadius: BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Center(
                child: Text(
                  isConnected ? 'Disconnect' : 'Connect',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
