import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:takion/src/core/network/superhero_account_service.dart";
import "package:takion/src/presentation/features/integrations/providers/superhero_providers.dart";
import "package:takion/src/presentation/features/integrations/widgets/superhero_integration_settings.dart";
import "package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart";

void showIntegrationsSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: "Integrations",
    child: const _IntegrationsContent(),
  );
}

class _IntegrationsContent extends ConsumerWidget {
  const _IntegrationsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabledAsync = ref.watch(superheroEnabledProvider);
    final connectionAsync = ref.watch(superheroConnectionProvider);
    final enabled = enabledAsync.value ?? false;

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        Text(
          "Connect third-party data sources to enrich your library. "
          "Each integration is optional and can be configured independently.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 8, right: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.shield, size: 20),
            ),
            title: const Text(
              "SuperHero API",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_statusLabel(connectionAsync.value)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (enabled)
                  IconButton(
                    onPressed: () =>
                        showSuperHeroIntegrationSettings(context, ref),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: "Configure",
                  ),
                Switch(
                  value: enabled,
                  onChanged: (value) async {
                    await ref
                        .read(superheroEnabledProvider.notifier)
                        .setEnabled(value);
                    ref.invalidate(superheroConnectionProvider);
                  },
                ),
              ],
            ),
            onTap: () => showSuperHeroIntegrationSettings(context, ref),
          ),
        ),
      ],
    );
  }

  String _statusLabel(SuperHeroConnectionStatus? status) {
    switch (status) {
      case SuperHeroConnectionStatus.valid:
        return "Connected";
      case SuperHeroConnectionStatus.missing:
        return "Not connected";
      case SuperHeroConnectionStatus.invalid:
        return "Invalid token";
      case SuperHeroConnectionStatus.unreachable:
        return "Cannot reach API";
      case null:
        return "Checking…";
    }
  }
}
