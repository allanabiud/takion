import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/network/metron_account_service.dart';

import 'package:takion/src/presentation/features/settings/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/rate_limit_status_provider.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/core/router/app_router.gr.dart';

Future<void> disconnectMetronAccount(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(metronAccountServiceProvider).disconnect();
  ref.invalidate(metronConnectionProvider);
  ref.invalidate(authStateProvider);
  if (!context.mounted) return;
  TakionAlerts.info(context, 'Disconnected');
}

void showMetronConnectionSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Metron',
    child: const _MetronConnectionContent(),
  );
}

class _MetronConnectionContent extends ConsumerStatefulWidget {
  const _MetronConnectionContent();

  @override
  ConsumerState<_MetronConnectionContent> createState() =>
      _MetronConnectionContentState();
}

class _MetronConnectionContentState
    extends ConsumerState<_MetronConnectionContent> {
  String? _maskedToken;

  @override
  Widget build(BuildContext context) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final isConnected = metronConnectionAsync.value == true;
    final appSettings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (!context.mounted) return;
      final justFinishedSync = (previous?.isBusy ?? false) && !next.isBusy;
      if (!justFinishedSync) return;

      final message = next.statusMessage?.trim();
      if (message == null || message.isEmpty) return;

      final normalized = message.toLowerCase();
      if (normalized.contains('failed')) {
        TakionAlerts.error(context, message);
        return;
      }
      if (normalized.contains('completed')) {
        TakionAlerts.success(context, message);
      }
    });

    ref.listen(metronConnectionProvider, (previous, next) {
      if (next.value == false) {
        setState(() => _maskedToken = null);
      }
    });

    if (isConnected && _maskedToken == null) {
      Future.microtask(() async {
        final token = await ref
            .read(metronAccountServiceProvider)
            .getStoredToken();
        if (token != null && mounted) {
          setState(() => _maskedToken = maskMetronToken(token));
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              buildMetronAccountCard(
                context: context,
                isConnected: isConnected,
                maskedToken: _maskedToken ?? '',
                onConnect: () {
                  Navigator.of(context).pop();
                  context.pushRoute(const AuthorizeMetronRoute());
                },
                onDisconnect: () => disconnectMetronAccount(context, ref),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 16),
            const _ApiUsageCard(),
            const SizedBox(height: 16),
            _buildDataSection(context, ref, isConnected, appSettings),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context,
    WidgetRef ref,
    bool isConnected,
    AppSettings appSettings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSettingsGroup(context, 'Data', [
          ListTile(
            contentPadding: EdgeInsets.zero,
            enabled: isConnected && !appSettings.isBusy,
            leading: Icon(
              Icons.downloading_rounded,
              color: isConnected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: const Text(
              'Refresh Stale',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              !isConnected
                  ? 'Connect Metron account to refresh'
                  : appSettings.isBusy
                  ? 'Refresh running...'
                  : 'Re-fetch only data modified on Metron since last fetch',
            ),
            trailing: appSettings.isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: !isConnected || appSettings.isBusy
                ? null
                : () => ref
                      .read(settingsProvider.notifier)
                      .refreshStaleCatalogData(),
          ),
        ]),
      ],
    );
  }
}

class _ApiUsageCard extends ConsumerWidget {
  const _ApiUsageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rateLimitStatusProvider);
    final theme = Theme.of(context);
    final used = state.sustainedLimit - state.sustainedRemaining;
    final ratio = used / state.sustainedLimit;
    final progressColor = switch (state.sustainedRemaining /
        state.sustainedLimit) {
      > 0.5 => Colors.green,
      > 0.2 => Colors.orange,
      _ => Colors.red,
    };

    return buildSettingsGroup(context, 'API Usage', [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.sustainedRemaining}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  'of ${state.sustainedLimit} requests remaining',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${state.burstRemaining}/min',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(progressColor),
        ),
      ),
      if (state.sustainedReset > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Reset ${DateFormatter.relativeDetailed(DateTime.fromMillisecondsSinceEpoch(state.sustainedReset * 1000))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
    ]);
  }
}
