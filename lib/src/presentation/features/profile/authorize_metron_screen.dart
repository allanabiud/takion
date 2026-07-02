import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/common/floating_icons_background.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AuthorizeMetronScreen extends ConsumerStatefulWidget {
  const AuthorizeMetronScreen({super.key});

  @override
  ConsumerState<AuthorizeMetronScreen> createState() =>
      _AuthorizeMetronScreenState();
}

class _AuthorizeMetronScreenState extends ConsumerState<AuthorizeMetronScreen> {
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
      TakionAlerts.info(context, 'Enter credentials');
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
        TakionAlerts.error(context, 'Invalid credentials');
        return;
      }

      ref.invalidate(metronConnectionProvider);
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(displayName: username);
      if (!mounted) return;
      _passwordController.clear();
      _didAutoRedirect = true;
      context.router.replaceAll([const MainRoute()]);
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

  Future<void> _launchMetronSignup() async {
    final url = Uri.parse('https://metron.cloud/accounts/signup/');
    final launched = await launchUrl(url);
    if (!launched && mounted) {
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
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const FloatingIconsBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'metron-atom-icon',
                        child: Icon(
                          LucideIcons.atom,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Metron',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Connect with The Metron Comic Database to fetch comic metadata and enhance your library.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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
                            'You are offline. Internet is required to verify and authorize your Metron account.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ],
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Metron Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () =>
                            TextInput.finishAutofillContext(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isConnecting || isOffline || isConnected
                        ? null
                        : () async {
                            if (isOffline) {
                              TakionAlerts.info(
                                context,
                                'No internet connection',
                              );
                              return;
                            }

                            await _connectMetronAccount();
                            TextInput.finishAutofillContext();
                          },
                    child: _isConnecting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Connect Metron'),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: isOffline ? null : _launchMetronSignup,
                    child: const Text('Don\'t have an account? Create one'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
