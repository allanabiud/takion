import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/settings/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/metron_connected_state.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AuthorizeMetronScreen extends ConsumerStatefulWidget {
  const AuthorizeMetronScreen({super.key});

  @override
  ConsumerState<AuthorizeMetronScreen> createState() =>
      _AuthorizeMetronScreenState();
}

class _AuthorizeMetronScreenState extends ConsumerState<AuthorizeMetronScreen> {
  final _tokenController = TextEditingController();
  bool _isConnecting = false;
  bool _didAutoRedirect = false;
  String? _maskedToken;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_redirectIfAlreadyConnected);
  }

  Future<void> _redirectIfAlreadyConnected() async {
    if (_didAutoRedirect || !mounted || !context.mounted) return;

    final hasConnection = await ref
        .read(metronAccountServiceProvider)
        .getConnection();

    if (!mounted || !context.mounted || !hasConnection) return;

    _didAutoRedirect = true;
    await context.router.replaceAll([const MainRoute()]);
    NotificationService.instance.tryNavigateToMyPulls();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connectMetronAccount() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      TakionAlerts.info(context, 'Enter your API token');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      AppLogger.info('Metron connect attempt from authorize screen');
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(token);
      if (!mounted || !context.mounted) return;

      if (!connected) {
        AppLogger.warning('Metron connect failed: invalid token');
        TakionAlerts.error(context, 'Invalid token');
        return;
      }

      AppLogger.info('Metron connect succeeded from authorize screen');
      setState(() => _maskedToken = maskMetronToken(token));
      ref.invalidate(metronConnectionProvider);
      ref.invalidate(authStateProvider);
      if (!mounted) return;
      _tokenController.clear();
      _didAutoRedirect = true;
      await context.router.replaceAll([const MainRoute()]);
      NotificationService.instance.tryNavigateToMyPulls();
    } catch (error) {
      if (!mounted || !context.mounted) return;
      AppLogger.error('Metron connect exception', error: error);
      TakionAlerts.safeError(context, error, userMessage: 'Connection failed');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _showApiKeyHelp() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Get a Metron API Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpStep(
              ctx,
              1,
              'Create or log into your ',
              'Metron account',
              'https://metron.cloud/accounts/signup/',
              theme,
            ),
            const SizedBox(height: 16),
            _helpStep(
              ctx,
              2,
              'Go to your account page and create an API Token for the app.',
              null,
              null,
              theme,
            ),
            const SizedBox(height: 16),
            _helpStep(
              ctx,
              3,
              'Copy the token and paste it here.',
              null,
              null,
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _helpStep(
    BuildContext ctx,
    int number,
    String text,
    String? linkText,
    String? linkUrl,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: linkText != null && linkUrl != null
              ? Text.rich(
                  TextSpan(
                    text: text,
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: linkText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final uri = Uri.parse(linkUrl);
                            final launched = await launchUrl(uri);
                            if (!launched && ctx.mounted) {
                              TakionAlerts.signupLaunchFailed(ctx);
                            }
                          },
                      ),
                    ],
                  ),
                )
              : Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;
    final isConnected = metronConnectionAsync.value == true;

    return PopScope(
      canPop: isConnected,
      child: Scaffold(
        appBar: AppBar(
          title: null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
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
                isConnected
                    ? 'Your Metron account is linked.'
                    : 'Enter your Metron API token to fetch comic metadata and enhance your library.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isOffline && !isConnected)
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
                          begin: 0.94,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isConnected
                      ? buildMetronAccountCard(
                          key: const ValueKey('metron_connected_card'),
                          context: context,
                          isConnected: isConnected,
                          maskedToken: _maskedToken ?? '',
                          onConnect: _connectMetronAccount,
                          onDisconnect: () async {
                            await ref
                                .read(metronAccountServiceProvider)
                                .disconnect();
                            setState(() => _maskedToken = null);
                            ref.invalidate(metronConnectionProvider);
                            ref.invalidate(authStateProvider);
                            _tokenController.clear();
                          },
                        )
                      : Column(
                          key: const ValueKey('metron_input_form'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            TextField(
                              controller: _tokenController,
                              autofillHints: const [AutofillHints.password],
                              decoration: const InputDecoration(
                                labelText: 'Metron API Token',
                                prefixIcon: Icon(Icons.key),
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: isOffline ? null : _showApiKeyHelp,
                              child: const Text(
                                'Don\'t have a Metron API Token?',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isConnected
                      ? () => context.router.replaceAll([const MainRoute()])
                      : _isConnecting || isOffline
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
                      : Text(isConnected ? 'Continue' : 'Connect Metron'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
