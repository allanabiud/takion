import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takion/src/core/network/superhero_account_service.dart';
import 'package:takion/src/presentation/features/integrations/providers/superhero_providers.dart';
import 'package:takion/src/presentation/features/settings/widgets/settings_helpers.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/metron_connected_state.dart';
import 'package:takion/src/presentation/shared/widgets/takion_bottom_sheet.dart';

void showSuperHeroIntegrationSettings(BuildContext context, WidgetRef ref) {
  TakionBottomSheet.show(
    context: context,
    title: 'SuperHero API',
    child: const _SuperHeroIntegrationContent(),
  );
}

class _SuperHeroIntegrationContent extends ConsumerStatefulWidget {
  const _SuperHeroIntegrationContent();

  @override
  ConsumerState<_SuperHeroIntegrationContent> createState() =>
      _SuperHeroIntegrationContentState();
}

class _SuperHeroIntegrationContentState
    extends ConsumerState<_SuperHeroIntegrationContent> {
  final _tokenController = TextEditingController();
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  String? _maskedToken;

  @override
  void initState() {
    super.initState();
    _loadMaskedToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadMaskedToken() async {
    final token = await ref
        .read(superheroAccountServiceProvider)
        .getStoredToken();
    if (token != null && mounted) {
      setState(() => _maskedToken = maskMetronToken(token));
    }
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      TakionAlerts.info(context, 'Enter an access token');
      return;
    }

    setState(() => _isConnecting = true);
    try {
      final connected = await ref
          .read(superheroAccountServiceProvider)
          .connect(token);
      if (!mounted) return;
      if (connected) {
        _tokenController.clear();
        setState(() => _maskedToken = maskMetronToken(token));
        ref.invalidate(superheroConnectionProvider);
        ref.invalidate(superheroEnabledProvider);
        TakionAlerts.success(context, 'SuperHero connected');
      } else {
        TakionAlerts.error(context, 'Invalid token');
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isDisconnecting = true);
    try {
      await ref.read(superheroAccountServiceProvider).disconnect();
      if (!mounted) return;
      setState(() => _maskedToken = null);
      ref.invalidate(superheroConnectionProvider);
      ref.invalidate(superheroEnabledProvider);
      TakionAlerts.info(context, 'Disconnected');
    } finally {
      if (mounted) setState(() => _isDisconnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionAsync = ref.watch(superheroConnectionProvider);
    final isConnected =
        connectionAsync.value == SuperHeroConnectionStatus.valid;
    final usePowerstatsAsync = ref.watch(superheroUsePowerstatsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sign in with GitHub on the SuperHero API site to get a free '
            'access token, then paste it below. Used to enrich character '
            'details.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://superheroapi.com/index.html');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (!context.mounted) return;
                TakionAlerts.couldNotOpenInBrowser(context, 'SuperHero API');
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Text(
              'Get access token',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isConnected) ...[
            buildSettingsRow(
              'Status',
              'Connected',
              color: theme.colorScheme.primary,
            ),
            if (_maskedToken != null) ...[
              const SizedBox(height: 4),
              buildSettingsRow('Access token', _maskedToken!),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDisconnecting ? null : _disconnect,
                icon: const Icon(Icons.link_off),
                label: Text(_isDisconnecting ? 'Disconnecting…' : 'Disconnect'),
              ),
            ),
          ] else ...[
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Access token',
                hintText: 'Paste your SuperHero API token',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isConnecting ? null : _connect,
                icon: _isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(_isConnecting ? 'Connecting…' : 'Connect'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          buildSettingsGroup(
            context,
            'Data to show',
            [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                value: usePowerstatsAsync.value ?? true,
                onChanged: (value) => ref
                    .read(superheroUsePowerstatsProvider.notifier)
                    .setEnabled(value),
                title: const Text(
                  'Powerstats',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Radar chart of the character stats on details',
                ),
              ),
            ],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
