import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String maskMetronToken(String token) {
  if (token.length <= 8) {
    return '${token.substring(0, 2)}…${token.substring(token.length - 2)}';
  }
  return '${token.substring(0, 3)}…${token.substring(token.length - 4)}';
}

Widget buildMetronAccountCard({
  Key? key,
  required BuildContext context,
  required bool isConnected,
  required String maskedToken,
  required VoidCallback onConnect,
  required VoidCallback onDisconnect,
}) {
  return MetronAccountCard(
    key: key,
    isConnected: isConnected,
    maskedToken: maskedToken,
    onConnect: onConnect,
    onDisconnect: onDisconnect,
  );
}

class MetronAccountCard extends StatefulWidget {
  final bool isConnected;
  final String maskedToken;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const MetronAccountCard({
    super.key,
    required this.isConnected,
    required this.maskedToken,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  State<MetronAccountCard> createState() => _MetronAccountCardState();
}

class _MetronAccountCardState extends State<MetronAccountCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = widget.isConnected;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? primaryColor.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          if (isConnected)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // Header Row: Brand Icon & Status
             Padding(
               padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
               child: Row(
                 children: [
                   Container(
                     width: 38,
                     height: 38,
                     decoration: BoxDecoration(
                       color: isConnected
                           ? primaryColor.withValues(alpha: 0.15)
                           : theme.colorScheme.surfaceContainerHighest,
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                       LucideIcons.atom,
                       size: 20,
                       color: isConnected
                           ? primaryColor
                           : theme.colorScheme.onSurfaceVariant,
                     ),
                   ),
                   const SizedBox(width: 12),
                   Text(
                     isConnected ? 'Connected' : 'Disconnected',
                     style: theme.textTheme.bodyLarge?.copyWith(
                       color: isConnected
                           ? primaryColor
                           : theme.colorScheme.error,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ],
               ),
             ),

            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            // API Key Row (display only, no copy)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.key,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'API Key',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isConnected ? widget.maskedToken : '—',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            // Action Footer
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isConnected ? widget.onDisconnect : widget.onConnect,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isConnected ? LucideIcons.unlink : LucideIcons.link,
                        size: 16,
                        color: isConnected
                            ? theme.colorScheme.error
                            : primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'Disconnect Account' : 'Connect Account',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isConnected
                              ? theme.colorScheme.error
                              : primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
