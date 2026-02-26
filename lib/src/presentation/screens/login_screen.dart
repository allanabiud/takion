import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  final void Function(bool success)? onResult;

  const LoginScreen({super.key, this.onResult});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _logoHeroTag = 'takion-app-logo';
  static const _settingsBoxName = 'settings_box';
  static const _seenOnboardingKey = 'has_seen_onboarding';
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeenAfterFirstLogin() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    final hasSeen =
        settingsBox.get(_seenOnboardingKey, defaultValue: false) == true;
    if (!hasSeen) {
      await settingsBox.put(_seenOnboardingKey, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;

    // Listen for auth state changes for notifications and resolving guards
    ref.listen(authStateProvider, (previous, next) {
      if (next.isLoading) return;

      next.when(
        data: (status) {
          if (status == AuthStatus.authenticated &&
              previous?.value != AuthStatus.authenticated) {
            Future<void>(() async {
              await _markOnboardingSeenAfterFirstLogin();
              if (!mounted || !context.mounted) return;

              TakionAlerts.authLoginSuccess(context);
              // Resolve the guard if it exists
              if (widget.onResult != null) {
                widget.onResult!(true);
                if (context.mounted && context.router.canPop()) {
                  context.router.pop();
                }
              } else {
                final metronService = ref.read(metronAccountServiceProvider);
                final connection = await metronService.getConnection();
                if (!mounted || !context.mounted) return;

                if (connection != null) {
                  context.router.replaceAll([const MainRoute()]);
                } else {
                  context.router.replaceAll([const MetronConnectRoute()]);
                }
              }
            });
          } else if (status == AuthStatus.unauthenticated &&
              previous?.value == AuthStatus.authenticated) {
            _usernameController.clear();
            _passwordController.clear();
          }
        },
        error: (error, _) {
          TakionAlerts.authError(context, error);
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
            child: AutofillGroup(
              key: ValueKey(_isSignUpMode),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: _logoHeroTag,
                    child: SvgPicture.asset(
                      'assets/images/takion_logo.svg',
                      height: 60,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSignUpMode ? 'Create Account' : 'Log In',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUpMode
                        ? 'Create your Takion account.'
                        : 'Log in to your Takion account.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isOffline)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                              'You appear to be offline. Internet is required to log in or create an account.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isSignUpMode) ...[
                    TextField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    autofillHints: _isSignUpMode
                        ? const [
                            AutofillHints.newUsername,
                            AutofillHints.username,
                            AutofillHints.email,
                          ]
                        : const [AutofillHints.username, AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    autofillHints: _isSignUpMode
                        ? const [
                            AutofillHints.newPassword,
                            AutofillHints.password,
                          ]
                        : const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isSignUpMode
                            ? 'Already have an account?'
                            : 'No account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isLoading || isOffline
                            ? null
                            : () {
                                setState(() {
                                  _isSignUpMode = !_isSignUpMode;
                                });
                              },
                        child: Text(
                          _isSignUpMode ? 'Back to Log In' : 'Create Account',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: authState.isLoading || isOffline
                          ? null
                          : () async {
                              if (isOffline) {
                                TakionAlerts.info(
                                  context,
                                  'No internet connection. Please reconnect and try again.',
                                );
                                return;
                              }

                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();
                              final displayName = _displayNameController.text
                                  .trim();

                              if (_isSignUpMode) {
                                if (displayName.isEmpty ||
                                    username.isEmpty ||
                                    password.isEmpty) {
                                  TakionAlerts.info(
                                    context,
                                    'Please fill in all fields.',
                                  );
                                  return;
                                }
                              } else {
                                if (username.isEmpty || password.isEmpty) {
                                  TakionAlerts.authMissingCredentials(context);
                                  return;
                                }
                              }

                              if (_isSignUpMode) {
                                try {
                                  final message = await ref
                                      .read(authStateProvider.notifier)
                                      .signUp(
                                        email: username,
                                        password: password,
                                        displayName: displayName,
                                      );

                                  if (!context.mounted) return;

                                  TakionAlerts.info(context, message);
                                  setState(() {
                                    _isSignUpMode = false;
                                  });
                                  _passwordController.clear();
                                } catch (_) {
                                  // Error alert is handled by auth state listener.
                                }
                              } else {
                                await ref
                                    .read(authStateProvider.notifier)
                                    .login(username, password);
                              }

                              TextInput.finishAutofillContext();
                            },
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isSignUpMode ? 'Create Account' : 'Log In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
