import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/common/floating_icons_background.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/components.dart';
import 'package:takion/src/presentation/logic/shortcut_handler.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/data/services/drive_backup_service.dart';
import 'package:takion/src/presentation/features/settings/widgets/restore_sheet.dart';
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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _settingsBoxName = 'settings_box';
  static const _seenOnboardingKey = 'has_seen_onboarding';

  bool _isCheckingFirstLaunch = true;

  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<double> _descFade;
  late Animation<double> _buttonFade;

  late AnimationController _rotationController;

  late AnimationController _pageAnimController;
  late AnimationController _allDoneAnimController;
  late AnimationController _pulseController;

  late Animation<double> _heroAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _bodyAnim;
  late Animation<double> _buttonAnim;
  late Animation<double> _allDoneBadgeAnim;
  late Animation<double> _allDoneTitleAnim;
  late Animation<double> _allDoneBodyAnim;
  late Animation<double> _allDoneButtonAnim;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _restoreCompleted = false;
  bool _isDriveRestoring = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFirstLaunch();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _descFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _allDoneAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroAnim = CurvedAnimation(
      parent: _pageAnimController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _titleAnim = CurvedAnimation(
      parent: _pageAnimController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _bodyAnim = CurvedAnimation(
      parent: _pageAnimController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _buttonAnim = CurvedAnimation(
      parent: _pageAnimController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _allDoneBadgeAnim = CurvedAnimation(
      parent: _allDoneAnimController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    _allDoneTitleAnim = CurvedAnimation(
      parent: _allDoneAnimController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _allDoneBodyAnim = CurvedAnimation(
      parent: _allDoneAnimController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _allDoneButtonAnim = CurvedAnimation(
      parent: _allDoneAnimController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
  }

  Future<void> _checkFirstLaunch() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    final hasSeen =
        settingsBox.get(_seenOnboardingKey, defaultValue: false) == true;

    if (!mounted) return;

    if (hasSeen) {
      final metronService = ref.read(metronAccountServiceProvider);
      final connection = await metronService.getConnection();
      if (!mounted) return;

      if (connection != null) {
        context.router.replaceAll([const MainRoute()]);
      } else {
        context.router.replace(const AuthorizeMetronRoute());
      }
      return;
    }

    setState(() {
      _isCheckingFirstLaunch = false;
    });
    _fadeController.forward();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _pageAnimController.forward(from: 0.0);
    if (page == 4) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_currentPage != 4) return;
        _allDoneAnimController.forward(from: 0.0);
        _pulseController.repeat(reverse: true);
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_currentPage == 4) _rotationController.repeat();
      });
    } else {
      _allDoneAnimController.reset();
      _rotationController.reset();
      _pulseController.reset();
    }
  }

  Future<bool> _connectMetronAccount() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      TakionAlerts.info(context, 'Enter credentials');
      return false;
    }

    try {
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(username, password);
      if (!mounted || !context.mounted) return false;

      if (!connected) {
        TakionAlerts.error(context, 'Invalid credentials');
        return false;
      }

      ref.invalidate(metronConnectionProvider);
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(displayName: username);
      if (!mounted) return false;
      _passwordController.clear();
      return true;
    } catch (error) {
      if (!mounted || !context.mounted) return false;
      TakionAlerts.error(context, error.toString());
      return false;
    }
  }

  Future<void> _launchMetronSignup() async {
    final url = Uri.parse('https://metron.cloud/accounts/signup/');
    final launched = await launchUrl(url);
    if (!launched && mounted) {
      TakionAlerts.signupLaunchFailed(context);
    }
  }

  Future<void> _finishSetup() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    await settingsBox.put(_seenOnboardingKey, true);
    ShortcutHandler.enableShortcuts();
    if (!mounted || !context.mounted) return;
    context.router.replaceAll([const MainRoute()]);
  }

  void _showRestoreChoiceSheet() {
    TakionBottomSheet.show(
      context: context,
      title: 'Restore from Backup',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('From Local File'),
            subtitle: const Text('Restore from a .tkbk backup file'),
            onTap: () async {
              Navigator.of(context).pop();
              final restored = await showRestoreBackupSheet(context, ref);
              if (restored == true && mounted) {
                setState(() => _restoreCompleted = true);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('From Google Drive'),
            subtitle: const Text('Restore from your Drive backup'),
            onTap: () {
              Navigator.of(context).pop();
              _restoreFromDrive();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _restoreFromDrive() async {
    setState(() => _isDriveRestoring = true);
    try {
      final driveService = ref.read(driveBackupServiceProvider);
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
        if (e.message == 'No backup found on Drive') {
          hadBackup = false;
        } else {
          rethrow;
        }
      }

      await ref.read(driveSyncProvider.notifier).enable(email: email);

      if (hadBackup) {
        if (mounted) {
          setState(() {
            _restoreCompleted = true;
            _isDriveRestoring = false;
          });
        }
      } else {
        try {
          await driveService.uploadBackup();
        } catch (_) {}
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
        final msg = e.toString().contains('No backup found on Drive')
            ? 'No backup file found'
            : 'Drive restore failed: $e';
        TakionAlerts.error(context, msg);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _rotationController.dispose();
    _pageAnimController.dispose();
    _allDoneAnimController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstLaunch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPage > 0) {
          _goToPage(_currentPage - 1);
        }
      },
      child: Container(
        color: theme.colorScheme.surface,
        child: Stack(
          children: [
            const FloatingIconsBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(theme),
                  _buildAppearancePage(theme),
                  _buildMetronInfoPage(theme),
                  _buildRestoreBackupPage(theme),
                  _buildAllDonePage(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoFade,
                        child: SvgPicture.asset(
                          'assets/images/takion_logo.svg',
                          height: 96,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleFade),
                        child: Text(
                          'Takion',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _descFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_descFade),
                        child: const Text(
                          'Track your pulls, manage your collection and never miss a release.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _buttonFade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_buttonFade),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => _goToPage(1),
                    child: const Text('Get Started'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  FadeTransition(
                    opacity: _titleAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_titleAnim),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Appearance',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _bodyAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_bodyAnim),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: RadioGroup<ThemeMode>(
                              groupValue: themeSettings.themeMode,
                              onChanged: (value) {
                                if (value == null) return;
                                ref.read(themeProvider.notifier).setThemeMode(value);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<ThemeMode>(
                                    value: ThemeMode.system,
                                    title: const Text('System'),
                                    secondary: const Icon(
                                      Icons.brightness_auto_outlined,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    value: ThemeMode.light,
                                    title: const Text('Light'),
                                    secondary: const Icon(Icons.light_mode_outlined),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    value: ThemeMode.dark,
                                    title: const Text('Dark'),
                                    secondary: const Icon(Icons.dark_mode_outlined),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
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
                                final primary =
                                    schemeData?.light.primary ?? Colors.blue;
                                final selected = currentScheme == scheme;
                                final luminance = primary.computeLuminance();
                                final tickColor = luminance > 0.5
                                    ? Colors.black87
                                    : Colors.white;
                                return GestureDetector(
                                  onTap: () => ref
                                      .read(accentSchemeProvider.notifier)
                                      .setScheme(scheme),
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
                                                color: primary.withValues(
                                                  alpha: 0.39,
                                                ),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: selected
                                        ? Icon(
                                            Icons.check,
                                            color: tickColor,
                                            size: 22,
                                          )
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                ref
                                    .read(themeProvider.notifier)
                                    .setDarkIsTrueBlack(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _buttonAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_buttonAnim),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => _goToPage(2),
                    child: const Text('Continue'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectSheet() {
    final connectivityState = ref.read(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;
    var connecting = false;

    TakionBottomSheet.show(
      context: context,
      title: 'Connect to Metron',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final sheetTheme = Theme.of(context);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOffline)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_outlined,
                        size: 18,
                        color: sheetTheme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are offline. Internet is required to verify and authorize your Metron account.',
                          style: sheetTheme.textTheme.bodySmall?.copyWith(
                            color: sheetTheme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  onPressed: connecting || isOffline
                      ? null
                      : () async {
                          setSheetState(() => connecting = true);
                          if (isOffline) {
                            TakionAlerts.info(
                              context,
                              'No internet connection',
                            );
                            setSheetState(() => connecting = false);
                            return;
                          }
                          final success = await _connectMetronAccount();
                          if (context.mounted) {
                            if (success) {
                              Navigator.of(context).pop();
                            } else {
                              setSheetState(() => connecting = false);
                            }
                          }
                        },
                  child: connecting
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
                  child: const Text(
                    'Don\'t have an account? Create one',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetronInfoPage(ThemeData theme) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final isConnected = metronConnectionAsync.value != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _heroAnim,
                      child: ScaleTransition(
                        scale: _heroAnim,
                        child: Icon(
                          LucideIcons.atom,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _titleAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleAnim),
                        child: Text(
                          'Metron',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _bodyAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_bodyAnim),
                        child: isConnected
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 28,
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.badgeCheck,
                                      size: 56,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Connected as ${_usernameController.text}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your Metron account is linked.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                'Takion uses The Metron Comic Database to keep up to date with comics.',
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _buttonAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_buttonAnim),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isConnected
                      ? FilledButton(
                          onPressed: () => _goToPage(3),
                          child: const Text('Continue'),
                        )
                      : FilledButton(
                          onPressed: _showConnectSheet,
                          child: const Text('Connect Metron'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreBackupPage(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _heroAnim,
                      child: ScaleTransition(
                        scale: _heroAnim,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            _restoreCompleted
                                ? LucideIcons.badgeCheck
                                : LucideIcons.rotateCcw,
                            key: ValueKey(_restoreCompleted),
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _titleAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleAnim),
                        child: Text(
                          _restoreCompleted
                              ? 'Backup Restored'
                              : 'Restore from Backup',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _bodyAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_bodyAnim),
                        child: Column(
                          children: [
                            Text(
                              _restoreCompleted
                                  ? 'Your data has been restored successfully.'
                                  : 'If you have a previous Takion backup, you can restore your data now.',
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            if (!_restoreCompleted) ...[
                              const SizedBox(height: 8),
                              Text(
                                'You can also do this later from Settings.',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _buttonAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_buttonAnim),
                child: Column(
                  children: [
                    if (_restoreCompleted)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () => _goToPage(4),
                          child: const Text('Continue'),
                        ),
                      )
                    else if (_isDriveRestoring)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Column(
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
                      )
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _showRestoreChoiceSheet,
                          icon: const Icon(LucideIcons.rotateCcw),
                          label: const Text('Restore'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _goToPage(4),
                          child: const Text('Skip'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDonePage(ThemeData theme) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.3,
                          end: 1.0,
                        ).animate(_allDoneBadgeAnim),
                        child: FadeTransition(
                          opacity: _allDoneBadgeAnim,
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RotationTransition(
                                  turns: _rotationController,
                                  child: CustomPaint(
                                    size: const Size(150, 150),
                                    painter: _CheckShapePainter(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 1.0,
                                    end: 1.05,
                                  ).animate(_pulseController),
                                  child: const Icon(
                                    Icons.check,
                                    size: 75,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _allDoneTitleAnim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_allDoneTitleAnim),
                          child: Text(
                            'All Done!',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _allDoneBodyAnim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_allDoneBodyAnim),
                          child: Text(
                            'All set to start discovering, tracking and collecting new comics.',
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _allDoneButtonAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_allDoneButtonAnim),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _finishSetup,
                      child: const Text('Finish Setup'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckShapePainter extends CustomPainter {
  final Color color;

  _CheckShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final s = size.width;
    final cx = s / 2;
    final cy = s / 2;
    const lobes = 8;
    final distance = s * 0.34;
    final lobeRadius = s * 0.18;

    final path = Path();
    for (int i = 0; i < lobes; i++) {
      final angle = (2 * pi * i) / lobes - pi / 2;
      path.addOval(
        Rect.fromCircle(
          center: Offset(
            cx + distance * cos(angle),
            cy + distance * sin(angle),
          ),
          radius: lobeRadius,
        ),
      );
    }

    path.addOval(
      Rect.fromCircle(
        center: Offset(cx, cy),
        radius: distance,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckShapePainter oldDelegate) =>
      oldDelegate.color != color;
}
