import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';
import 'package:takion/src/presentation/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class MetronConnectScreen extends ConsumerStatefulWidget {
  const MetronConnectScreen({super.key});

  @override
  ConsumerState<MetronConnectScreen> createState() =>
      _MetronConnectScreenState();
}

class _MetronConnectScreenState extends ConsumerState<MetronConnectScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  bool _didAutoRedirect = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_redirectIfAlreadyConnected);
  }

  Future<void> _redirectIfAlreadyConnected() async {
    if (_didAutoRedirect || !mounted || !context.mounted) return;

    final connection = await ref
        .read(metronAccountServiceProvider)
        .getConnection();

    if (!mounted || !context.mounted || connection == null) return;

    _didAutoRedirect = true;
    context.router.replaceAll([const MainRoute()]);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connectMetronAccount() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      TakionAlerts.info(context, 'Please enter Metron username and password.');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(username, password);
      if (!mounted || !context.mounted) return;

      if (!connected) {
        TakionAlerts.error(context, 'Invalid Metron username or password.');
        return;
      }

      TakionAlerts.success(context, 'Metron account connected.');
      ref.invalidate(metronConnectionProvider);
      _passwordController.clear();
    } catch (error) {
      if (!mounted || !context.mounted) return;
      TakionAlerts.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _continueToHome() {
    context.router.replaceAll([const MainRoute()]);
  }

  Future<void> _launchMetronSignup() async {
    final url = Uri.parse('https://metron.cloud/accounts/signup/');
    if (!await launchUrl(url)) {
      if (!mounted || !context.mounted) return;
      TakionAlerts.signupLaunchFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;
    final isConnected = metronConnectionAsync.value != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Metron')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Connect your Metron account so Takion can access comic data from the Metron Comic Book Database.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          if (isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are offline. Internet is required to verify and connect your Metron account.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: isOffline ? null : _launchMetronSignup,
              child: const Text('Create Metron Account'),
            ),
          ),
          const SizedBox(height: 16),
          AutofillGroup(
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Metron Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Metron Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isConnecting || isOffline
                  ? null
                  : () async {
                      if (isOffline) {
                        TakionAlerts.info(
                          context,
                          'No internet connection. Please reconnect and try again.',
                        );
                        return;
                      }

                      await _connectMetronAccount();
                      TextInput.finishAutofillContext();
                    },
              child: _isConnecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Connect Metron Account'),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Connection Status'),
              subtitle: metronConnectionAsync.when(
                data: (connection) => connection == null
                    ? const Text('Not connected')
                    : Text('Connected as ${connection.username}'),
                loading: () => const Text('Checking...'),
                error: (error, _) => Text(error.toString()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: isConnected ? _continueToHome : null,
              child: const Text('Go to Home'),
            ),
          ),
        ],
      ),
    );
  }
}
