import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";
import "package:takion/src/presentation/features/settings/providers/metron_account_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/shared/widgets/metron_connected_state.dart";
import "package:url_launcher/url_launcher.dart";

class MetronInfoPage extends ConsumerStatefulWidget {
  const MetronInfoPage({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<MetronInfoPage> createState() => _MetronInfoPageState();
}

class _MetronInfoPageState extends ConsumerState<MetronInfoPage> {
  final _tokenController = TextEditingController();
  bool _isConnectingMetron = false;
  String? _maskedToken;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<bool> _connectMetronAccount() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      TakionAlerts.info(context, "Enter your API token");
      return false;
    }

    setState(() => _isConnectingMetron = true);

    try {
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(token);
      if (!mounted || !context.mounted) return false;

      if (!connected) {
        TakionAlerts.error(context, "Invalid token");
        return false;
      }

      setState(() => _maskedToken = maskMetronToken(token));
      ref.invalidate(metronConnectionProvider);
      ref.invalidate(authStateProvider);
      return true;
    } catch (error) {
      if (mounted) {
        TakionAlerts.safeError(
          context,
          error,
          userMessage: "Failed to connect to Metron",
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isConnectingMetron = false);
      }
    }
  }

  Future<void> _disconnect() async {
    await ref.read(metronAccountServiceProvider).disconnect();
    setState(() => _maskedToken = null);
    ref.invalidate(metronConnectionProvider);
    ref.invalidate(authStateProvider);
    _tokenController.clear();
  }

  Future<void> _showApiKeyHelp() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Get a Metron API Token"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpStep(
              ctx,
              1,
              "Create or log into your ",
              "Metron account",
              "https://metron.cloud/accounts/signup/",
              theme,
            ),
            const SizedBox(height: 16),
            _helpStep(
              ctx,
              2,
              "Go to your account page and create an API Token for the app.",
              null,
              null,
              theme,
            ),
            const SizedBox(height: 16),
            _helpStep(
              ctx,
              3,
              "Copy the token and paste it here.",
              null,
              null,
              theme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Got it"),
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
            "$number",
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
    final theme = Theme.of(context);
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final isConnected = metronConnectionAsync.value == true;
    final isOffline =
        ref.watch(connectivityStatusProvider).asData?.value ==
        AppConnectivityStatus.offline;

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

    return OnboardingPageScaffold(
      icon: Icon(LucideIcons.atom, size: 48, color: theme.colorScheme.primary),
      title: Text(
        "Metron",
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: isConnected
          ? "Your Metron account is linked."
          : "Enter your Metron API token to fetch comic data.",
      content: AnimatedSize(
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
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: isConnected
              ? buildMetronAccountCard(
                  key: const ValueKey("metron_connected_card"),
                  context: context,
                  isConnected: isConnected,
                  maskedToken: _maskedToken ?? "",
                  onConnect: _connectMetronAccount,
                  onDisconnect: _disconnect,
                )
              : SingleChildScrollView(
                  key: const ValueKey("metron_input_form"),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _tokenController,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: "Metron API Token",
                          prefixIcon: Icon(Icons.key),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !_isConnectingMetron,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isOffline ? null : _showApiKeyHelp,
                        child: const Text("Don't have a Metron API Token?"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      buttons: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: isConnected
              ? FilledButton(
                  onPressed: widget.onContinue,
                  child: const Text("Continue"),
                )
              : FilledButton(
                  onPressed: (_isConnectingMetron || isOffline)
                      ? null
                      : _connectMetronAccount,
                  child: _isConnectingMetron
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Connect Metron"),
                ),
        ),
      ],
    );
  }
}