import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

Future<void> disconnectMetronAccount(BuildContext context, WidgetRef ref) async {
  await ref.read(metronAccountServiceProvider).disconnect();
  ref.invalidate(metronConnectionProvider);
  if (!context.mounted) return;
  TakionAlerts.info(context, 'Disconnected');
}

Future<void> showMetronConnectDialog(BuildContext context, WidgetRef ref) async {
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
                decoration: const InputDecoration(
                  labelText: 'Metron Username',
                ),
                autofillHints: const [AutofillHints.username],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Metron Password',
                ),
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
    TakionAlerts.error(context, error.toString());
  }
}

void showMetronConnectionSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'Metron',
    child: Consumer(
      builder: (context, ref, _) {
        final metronConnectionAsync = ref.watch(metronConnectionProvider);
        final isConnected = metronConnectionAsync.value != null;
        final appSettings = ref.watch(settingsProvider);

        ref.listen<AppSettings>(settingsProvider, (previous, next) {
          if (!context.mounted) return;
          final justFinishedSync =
              (previous?.isSyncing ?? false) && !next.isSyncing;
          if (!justFinishedSync) return;

          final message = next.lastSyncMessage?.trim();
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
              if (appSettings.isSyncing)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
                              appSettings.lastSyncMessage?.trim().isNotEmpty == true
                                  ? appSettings.lastSyncMessage!.trim()
                                  : 'Sync in progress...',
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
              buildSettingsGroup(context, 'Connection Status', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link),
                  title: const Text('Status'),
                  subtitle: metronConnectionAsync.when(
                    data: (connection) => connection == null
                        ? const Text('Not connected')
                        : Text('Connected as ${connection.username}'),
                    loading: () => const Text('Checking connection...'),
                    error: (error, _) => Text(error.toString()),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              buildSettingsGroup(context, 'Sync Options', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: isConnected && !appSettings.isSyncing,
                  leading: Icon(
                    Icons.sync_rounded,
                    color: isConnected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: const Text(
                    'Full Sync',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    !isConnected
                        ? 'Connect Metron account to sync'
                        : appSettings.isSyncing
                            ? 'Sync currently running...'
                            : 'Update all app data from Metron',
                  ),
                  trailing: appSettings.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: !isConnected || appSettings.isSyncing
                      ? null
                      : () => ref
                            .read(settingsProvider.notifier)
                            .triggerFullSync(),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: isConnected && !appSettings.isSyncing,
                  leading: Icon(
                    Icons.sync_problem_rounded,
                    color: isConnected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: const Text(
                    'Quick Sync',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    !isConnected
                        ? 'Connect Metron account to sync'
                        : appSettings.isSyncing
                            ? 'Sync currently running...'
                            : 'Update modified data only',
                  ),
                  trailing: appSettings.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: !isConnected || appSettings.isSyncing
                      ? null
                      : () => ref
                            .read(settingsProvider.notifier)
                            .triggerQuickSync(),
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
          ),
        );
      },
    ),
  );
}
