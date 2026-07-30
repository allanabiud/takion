import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/shared/widgets/metron_connected_state.dart';
import 'package:takion/src/presentation/utils/shortcut_handler.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/presentation/features/settings/providers/metron_account_provider.dart';
import 'package:takion/src/data/common/services/drive_backup_service.dart';
import 'package:takion/src/data/common/services/local_backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:takion/src/presentation/features/settings/widgets/appearance_settings.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _DelayCurve extends Curve {
  final double delayFraction;
  const _DelayCurve(this.delayFraction);

  @override
  double transformInternal(double t) {
    if (t <= delayFraction) return 0;
    final adjusted = (t - delayFraction) / (1 - delayFraction);
    return Curves.easeOutCubic.transform(adjusted);
  }
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _seenOnboardingKey = 'has_seen_onboarding';

  bool _isCheckingFirstLaunch = true;

  int _currentPage = 0;

  final _tokenController = TextEditingController();
  bool _restoreCompleted = false;
  bool _isDriveRestoring = false;
  bool _isLocalRestoring = false;
  bool _isConnectingMetron = false;
  String? _maskedToken;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final settingsDao = ref.read(driftDatabaseProvider).settingsDao;
    final hasSeen = await settingsDao.getBool(_seenOnboardingKey);

    if (!mounted) return;

    if (hasSeen) {
      final metronService = ref.read(metronAccountServiceProvider);
      final hasConnection = await metronService.getConnection();
      if (!mounted) return;

      if (hasConnection) {
        context.router.replaceAll([const MainRoute()]);
      } else {
        context.router.replace(const AuthorizeMetronRoute());
      }
      return;
    }

    setState(() {
      _isCheckingFirstLaunch = false;
    });
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    if (page == 4) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<bool> _connectMetronAccount() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      TakionAlerts.info(context, 'Enter your API token');
      return false;
    }

    setState(() => _isConnectingMetron = true);

    try {
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(token);
      if (!mounted || !context.mounted) return false;

      if (!connected) {
        TakionAlerts.error(context, 'Invalid token');
        return false;
      }

      setState(() => _maskedToken = maskMetronToken(token));
      ref.invalidate(metronConnectionProvider);
      ref.invalidate(authStateProvider);
      if (!mounted) return false;
      _tokenController.clear();
      return true;
    } catch (error) {
      if (!mounted || !context.mounted) return false;
      TakionAlerts.safeError(context, error, userMessage: 'Connection failed');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isConnectingMetron = false);
      }
    }
  }

  Future<void> _showApiKeyHelp() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Get a Metron API Key'),
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

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentPage
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _animateIn({required double delayFraction, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: _DelayCurve(delayFraction),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildPage({
    required Widget icon,
    required Widget title,
    String? subtitle,
    required Widget content,
    required List<Widget> buttons,
  }) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: icon,
          ),
          const SizedBox(height: 12),
          _animateIn(delayFraction: 0.12, child: title),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            _animateIn(
              delayFraction: 0.22,
              child: Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 24),
          Expanded(child: _animateIn(delayFraction: 0.35, child: content)),
          const SizedBox(height: 16),
          _animateIn(
            delayFraction: 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSetup() async {
    final settingsDao = ref.read(driftDatabaseProvider).settingsDao;
    await settingsDao.setBool(_seenOnboardingKey, true);
    ShortcutHandler.enableShortcuts();
    if (!mounted || !context.mounted) return;
    context.router.replaceAll([const MainRoute()]);
  }

  Future<void> _restoreFromDrive() async {
    AppLogger.info('Drive restore started during onboarding');
    setState(() => _isDriveRestoring = true);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final driveService = ref.read(driveSyncServiceProvider);
      if (driveService.currentUser == null) {
        final account = await driveService.signIn();
        if (account == null) {
          if (mounted) {
            setState(() => _isDriveRestoring = false);
            TakionAlerts.info(
              context,
              'Sign in to Google Drive to restore your backup.',
            );
          }
          return;
        }
      }

      final email = driveService.currentUser!.email;
      bool hadBackup = true;

      try {
        await driveService.restoreFromDrive();
      } on StateError catch (e) {
        if (e.message == 'No sync data found on Google Drive') {
          hadBackup = false;
        } else {
          rethrow;
        }
      }

      await ref.read(driveSyncProvider.notifier).enable(email: email);

      if (hadBackup) {
        invalidateCacheBackedProvidersBatched((p) => container.invalidate(p));
        AppLogger.info('Drive restore completed');
        AppLogger.info('Onboarding completed');
        if (mounted) {
          setState(() {
            _restoreCompleted = true;
            _isDriveRestoring = false;
          });
        }
      } else {
        try {
          ref.read(driveSyncProvider.notifier).setSyncing(true);
          await driveService.triggerSync();
          await ref.read(driveSyncProvider.notifier).updateLastSync();
          AppLogger.info('Initial backup uploaded to Drive');
        } catch (e) {
          AppLogger.warning('Onboarding backup upload failed', error: e);
        } finally {
          ref.read(driveSyncProvider.notifier).setSyncing(false);
        }
        AppLogger.info('Onboarding completed');
        if (mounted) {
          setState(() {
            _restoreCompleted = true;
            _isDriveRestoring = false;
          });
          TakionAlerts.info(
            context,
            'No backup file found. Sync has been enabled — your data will be backed up to Drive.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDriveRestoring = false);
        final msg = e.toString().contains('No sync data')
            ? 'No backup file found'
            : 'Drive restore failed';
        TakionAlerts.safeError(
          context,
          msg == 'Drive restore failed' ? e : null,
          userMessage: msg,
        );
      }
    }
  }

  Future<void> _restoreFromLocalFile() async {
    AppLogger.info('Local restore started during onboarding');
    setState(() => _isLocalRestoring = true);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isLocalRestoring = false);
        return;
      }

      final file = result.files.single;
      final bytes = await file.readAsBytes();

      final service = ref.read(localBackupServiceProvider);
      await service.importBackupData(bytes);

      invalidateCacheBackedProvidersBatched((p) => container.invalidate(p));
      await Future<void>.delayed(Duration.zero);

      AppLogger.info('Local restore completed');
      if (mounted) {
        setState(() {
          _restoreCompleted = true;
          _isLocalRestoring = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocalRestoring = false);
        TakionAlerts.safeError(
          context,
          e,
          userMessage: 'Failed to restore backup',
        );
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstLaunch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    final pages = [
      _buildWelcomePage(theme),
      _buildAppearancePage(theme),
      _buildMetronInfoPage(theme),
      _buildRestoreBackupPage(theme),
      _buildAllDonePage(theme),
    ];

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPage > 0) {
          _goToPage(_currentPage - 1);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildProgressBar(),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeIn,
                    ),
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentPage),
                  child: pages[_currentPage],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return _buildPage(
      icon: SvgPicture.asset(
        'assets/branding/takion_logo.svg',
        height: 48,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      title: Text.rich(
        TextSpan(
          text: 'Welcome to ',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: 'Takion',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      subtitle:
          'Track your pulls, manage your collection and never miss a release.',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Track Pulls',
            description:
                'Add comics to your pull list and never miss an issue.',
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.inventory_2_outlined,
            title: 'Manage Collection',
            description: 'Keep track of every comic you own with ease.',
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.notifications_outlined,
            title: 'Release Alerts',
            description: 'Get notified when new issues are released.',
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.explore_outlined,
            title: 'Discover Comics',
            description: 'Browse new releases and explore the catalogue.',
          ),
        ],
      ),
      buttons: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => _goToPage(1),
            child: const Text('Get Started'),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearancePage(ThemeData theme) {
    final themeAsync = ref.watch(themeProvider);
    final themeSettings =
        themeAsync.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );
    final currentScheme =
        ref.watch(accentSchemeProvider).value ?? FlexScheme.green;

    return _buildPage(
      icon: Icon(
        Icons.palette_outlined,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        'Appearance',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: 'Customize your theme and accent color.',
      content: ListView(
        children: [
          Text(
            'THEME MODE',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('AUTO'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('LIGHT'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('DARK'),
                ),
              ],
              selected: {themeSettings.themeMode},
              onSelectionChanged: (selected) {
                if (selected.isEmpty) return;
                ref.read(themeProvider.notifier).setThemeMode(selected.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ACCENT COLOR',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: accentSchemes.map((scheme) {
                final schemeData = FlexColor.schemes[scheme];
                final primary = schemeData?.light.primary ?? Colors.blue;
                final selected = currentScheme == scheme;
                final luminance = primary.computeLuminance();
                final tickColor = luminance > 0.5
                    ? Colors.black87
                    : Colors.white;
                return GestureDetector(
                  onTap: () =>
                      ref.read(accentSchemeProvider.notifier).setScheme(scheme),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.39),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? Icon(Icons.check, color: tickColor, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DARK MODE',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Pure Black',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Use a true black background in dark mode',
                ),
                value: themeSettings.darkIsTrueBlack,
                onChanged: (bool value) {
                  ref.read(themeProvider.notifier).setDarkIsTrueBlack(value);
                },
              ),
            ),
          ),
        ],
      ),
      buttons: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => _goToPage(2),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetronInfoPage(ThemeData theme) {
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

    return _buildPage(
      icon: Icon(LucideIcons.atom, size: 48, color: theme.colorScheme.primary),
      title: Text(
        'Metron',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: isConnected
          ? 'Your Metron account is linked.'
          : 'Enter your Metron API token to fetch comic data.',
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
                  key: const ValueKey('metron_connected_card'),
                  context: context,
                  isConnected: isConnected,
                  maskedToken: _maskedToken ?? '',
                  onConnect: _connectMetronAccount,
                  onDisconnect: () async {
                    await ref.read(metronAccountServiceProvider).disconnect();
                    setState(() => _maskedToken = null);
                    ref.invalidate(metronConnectionProvider);
                    ref.invalidate(authStateProvider);
                    _tokenController.clear();
                  },
                )
              : SingleChildScrollView(
                  key: const ValueKey('metron_input_form'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _tokenController,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: 'Metron API Token',
                          prefixIcon: Icon(Icons.key),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !_isConnectingMetron,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isOffline ? null : _showApiKeyHelp,
                        child: const Text('Don\'t have a Metron API Key?'),
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
                  onPressed: () => _goToPage(3),
                  child: const Text('Continue'),
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
                      : const Text('Connect Metron'),
                ),
        ),
      ],
    );
  }

  Widget _buildRestoreBackupPage(ThemeData theme) {
    return _buildPage(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          _restoreCompleted ? LucideIcons.badgeCheck : LucideIcons.rotateCcw,
          key: ValueKey(_restoreCompleted),
          size: 48,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        _restoreCompleted ? 'Backup Restored' : 'Restore from Backup',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: _restoreCompleted
          ? null
          : 'If you have a previous Takion backup, you can restore your data now.',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_restoreCompleted && !_isDriveRestoring && !_isLocalRestoring)
            Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.tonalIcon(
                    onPressed: _restoreFromLocalFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Restore from Local File'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.tonalIcon(
                    onPressed: _restoreFromDrive,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Restore from Google Drive'),
                  ),
                ),
              ],
            ),
          if (_isDriveRestoring)
            const Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text('Restoring from Google Drive...'),
              ],
            ),
          if (_isLocalRestoring)
            const Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(height: 16),
                Text('Restoring from local file...'),
              ],
            ),
          if (_restoreCompleted)
            Text(
              'Your data has been restored successfully.',
              style: theme.textTheme.bodyLarge,
            ),
        ],
      ),
      buttons: [
        if (_restoreCompleted)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => _goToPage(4),
              child: const Text('Continue'),
            ),
          )
        else if (!_isDriveRestoring && !_isLocalRestoring)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => _goToPage(4),
              child: const Text('Skip'),
            ),
          ),
      ],
    );
  }

  Widget _buildAllDonePage(ThemeData theme) {
    return PopScope(
      canPop: false,
      child: _buildPage(
         icon: TweenAnimationBuilder<double>(
           tween: Tween(begin: 0.0, end: 1.0),
           duration: const Duration(milliseconds: 900),
           curve: Curves.elasticOut,
           builder: (context, value, child) => Transform.scale(
             scale: value,
             child: Transform.rotate(
               angle: (1 - value) * -0.26,
               child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
             ),
           ),
            child: Icon(Icons.verified, size: 56, color: theme.colorScheme.primary),
         ),
        title: Text(
          'All Done!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle:
            'All set to start discovering, tracking and collecting new comics.',
        content: const SizedBox.shrink(),
        buttons: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _finishSetup,
              child: const Text('Finish Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
