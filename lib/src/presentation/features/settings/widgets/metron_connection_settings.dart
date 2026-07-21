import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/constants/date_formatter.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/network/rate_limit_interceptor.dart';
import 'package:takion/src/presentation/features/settings/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/providers/rate_limit_status_provider.dart';

Future<void> disconnectMetronAccount(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(metronAccountServiceProvider).disconnect();
  ref.invalidate(metronConnectionProvider);
  if (!context.mounted) return;
  TakionAlerts.info(context, 'Disconnected');
}

Future<void> showMetronConnectDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final shouldConnect = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Connect Metron Account'),
        content: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Metron Username'),
                autofillHints: const [AutofillHints.username],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Metron Password'),
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onEditingComplete: () => TextInput.finishAutofillContext(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              TextInput.finishAutofillContext();
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Connect'),
          ),
        ],
      );
    },
  );

  final username = usernameController.text.trim();
  final password = passwordController.text.trim();
  usernameController.dispose();
  passwordController.dispose();

  if (shouldConnect != true) return;
  if (!context.mounted) return;
  if (username.isEmpty || password.isEmpty) {
    TakionAlerts.info(context, 'Enter credentials');
    return;
  }

  try {
    final service = ref.read(metronAccountServiceProvider);
    final connected = await service.connect(username, password);
    if (!context.mounted) return;

    if (!connected) {
      TakionAlerts.error(context, 'Invalid credentials');
    } else {
      TakionAlerts.success(context, 'Connected');
      ref.invalidate(metronConnectionProvider);
    }
  } catch (error) {
    if (!context.mounted) return;
    TakionAlerts.safeError(context, error, userMessage: 'Connection failed');
  }
}

enum _MetronMode { account, catalog }

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
  _MetronMode _mode = _MetronMode.account;

  @override
  Widget build(BuildContext context) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final isConnected = metronConnectionAsync.value != null;
    final appSettings = ref.watch(settingsProvider);

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (appSettings.isBusy)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          appSettings.statusMessage?.trim().isNotEmpty == true
                              ? appSettings.statusMessage!.trim()
                              : 'Refreshing...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(minHeight: 4),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_MetronMode>(
              segments: const [
                ButtonSegment(
                  value: _MetronMode.account,
                  icon: Icon(Icons.person_outline),
                  label: Text('ACCOUNT'),
                ),
                ButtonSegment(
                  value: _MetronMode.catalog,
                  icon: Icon(Icons.download_outlined),
                  label: Text('DATA'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) =>
                  setState(() => _mode = selected.first),
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _MetronMode.account) ...[
            _buildAccountSection(
              context,
              ref,
              metronConnectionAsync,
              isConnected,
              appSettings,
            ),
          ] else ...[
            _buildCatalogSection(context, ref, isConnected, appSettings),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MetronAccountConnection?> metronConnectionAsync,
    bool isConnected,
    AppSettings appSettings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSettingsGroup(context, 'Connection Status', [
          _buildConnectionStatus(
            context,
            ref,
            metronConnectionAsync,
            isConnected,
          ),
        ]),
        const SizedBox(height: 16),
        buildSettingsGroup(context, 'API Usage', [
          _buildRateLimitRow(
            context,
            ref,
            'Rate Limit',
            (state) => '${state.sustainedLimit} requests/day',
          ),
          const Divider(height: 1),
          _buildRateLimitRow(
            context,
            ref,
            'Remaining Today',
            (state) => state.sustainedRemaining.toString(),
          ),
          const Divider(height: 1),
          _buildRateLimitRow(
            context,
            ref,
            'Burst Remaining',
            (state) => '${state.burstRemaining} / min',
          ),
          if (ref.watch(rateLimitStatusProvider).sustainedReset case final reset
              when reset > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reset: ${DateFormatter.relativeDetailed(DateTime.fromMillisecondsSinceEpoch(reset * 1000))}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 16),
        buildSettingsGroup(context, 'Account Actions', [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isConnected
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await showMetronConnectDialog(context, ref);
                    },
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Connect Metron'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: !isConnected
                  ? null
                  : () => disconnectMetronAccount(context, ref),
              child: const Text('Disconnect Metron'),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MetronAccountConnection?> metronConnectionAsync,
    bool isConnected,
  ) {
    final theme = Theme.of(context);
    final connection = metronConnectionAsync.value;

    Color backgroundColor;
    Color foregroundColor;
    String label;

    if (!isConnected) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      foregroundColor = theme.colorScheme.onSurfaceVariant;
      label = 'Not connected';
    } else if (metronConnectionAsync.isLoading) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      foregroundColor = theme.colorScheme.onSurfaceVariant;
      label = 'Checking connection...';
    } else if (metronConnectionAsync.hasError) {
      backgroundColor = theme.colorScheme.errorContainer.withValues(alpha: 0.3);
      foregroundColor = theme.colorScheme.onErrorContainer;
      label = 'Connection check failed';
    } else {
      backgroundColor = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.4,
      );
      foregroundColor = theme.colorScheme.onPrimaryContainer;
      label = 'Connected as ${connection?.username ?? 'Unknown'}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }

  Widget _buildCatalogSection(
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
              Icons.download_rounded,
              color: isConnected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: const Text(
              'Refresh All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              !isConnected
                  ? 'Connect Metron account to refresh'
                  : appSettings.isBusy
                  ? 'Refresh running...'
                  : 'Re-fetch all catalog data from Metron',
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
                      .refreshAllCatalogData(),
          ),
          const Divider(),
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
                  : 'Re-fetch only stale or missing data',
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

Widget _buildRateLimitRow(
  BuildContext context,
  WidgetRef ref,
  String label,
  String Function(RateLimitState state) valueBuilder,
) {
  final state = ref.watch(rateLimitStatusProvider);
  final theme = Theme.of(context);
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
    trailing: Text(
      valueBuilder(state),
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}
