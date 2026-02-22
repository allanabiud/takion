import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/widgets/takion_flash.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  final void Function(bool success)? onResult;

  const LoginScreen({super.key, this.onResult});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchSignup() async {
    final url = Uri.parse('https://metron.cloud/accounts/signup/');
    if (!await launchUrl(url)) {
      if (mounted) {
        TakionFlash.error(context, 'Could not launch signup page');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen for auth state changes for notifications and resolving guards
    ref.listen(authStateProvider, (previous, next) {
      if (next.isLoading) return;

      next.when(
        data: (status) {
          if (status == AuthStatus.authenticated &&
              previous?.value != AuthStatus.authenticated) {
            TakionFlash.success(context, 'Successfully logged in!');
            // Resolve the guard if it exists
            if (widget.onResult != null) {
              widget.onResult!(true);
            } else {
              // Manual fallback if we navigated here directly (e.g. after logout)
              context.router.replaceAll([const MainRoute()]);
            }
          } else if (status == AuthStatus.unauthenticated &&
              previous?.value == AuthStatus.authenticated) {
            TakionFlash.info(context, 'Logged out successfully');
            _usernameController.clear();
            _passwordController.clear();
          }
        },
        error: (error, _) {
          TakionFlash.error(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 48.0,
            ),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/images/takion_logo.svg',
                    height: 60,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Log In',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log In with your Metron account.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No Account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Create Account',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _launchSignup,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();

                              if (username.isEmpty || password.isEmpty) {
                                TakionFlash.info(
                                  context,
                                  'Please enter both username and password',
                                );
                                return;
                              }

                              await ref
                                  .read(authStateProvider.notifier)
                                  .login(username, password);
                              TextInput.finishAutofillContext();
                            },
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Log In'),
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
