import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/network/metron_account_service.dart';

import 'package:takion/src/presentation/features/settings/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/shared/widgets/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
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
    final theme = Theme.of(context);

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
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.95,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: buildMetronAccountCard(
                    key: ValueKey('metron_card_$isConnected'),
                    context: context,
                    isConnected: isConnected,
                    maskedToken: _maskedToken ?? '',
                    onConnect: () {
                      Navigator.of(context).pop();
                      context.pushRoute(const AuthorizeMetronRoute());
                    },
                    onDisconnect: () => disconnectMetronAccount(context, ref),
                  ),
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 16),
            const _ApiUsageCard(),
          ],
        ],
      ),
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
      > 0.5 => theme.colorScheme.primary,
      > 0.2 => theme.colorScheme.tertiary,
      _ => theme.colorScheme.error,
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
