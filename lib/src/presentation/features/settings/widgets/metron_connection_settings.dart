import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

Future<void> disconnectMetronAccount(BuildContext context, WidgetRef ref) async {
  await ref.read(metronAccountServiceProvider).disconnect();
  ref.invalidate(metronConnectionProvider);
  if (!context.mounted) return;
  TakionAlerts.info(context, 'Metron account disconnected.');
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
    TakionAlerts.info(context, 'Please enter Metron username and password.');
    return;
  }

  try {
    final service = ref.read(metronAccountServiceProvider);
    final connected = await service.connect(username, password);
    if (!context.mounted) return;

    if (!connected) {
      TakionAlerts.error(context, 'Invalid Metron username or password.');
    } else {
      TakionAlerts.success(context, 'Metron account connected.');
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            buildSettingsGroup(context, 'Account Actions', [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: metronConnectionAsync.value != null
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
                  onPressed: metronConnectionAsync.value == null
                      ? null
                      : () => disconnectMetronAccount(context, ref),
                  child: const Text('Disconnect Metron'),
                ),
              ),
            ]),
          ],
        );
      },
    ),
  );
}
