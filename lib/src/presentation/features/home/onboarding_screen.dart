import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/common/floating_icons_background.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/metron_account_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _connectMetronAccount() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      TakionAlerts.info(context, 'Please enter Metron username and password.');
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final connected = await ref
          .read(metronAccountServiceProvider)
          .connect(username, password);
      if (!mounted || !context.mounted) return;

      if (!connected) {
        TakionAlerts.error(context, 'Invalid Metron username or password.');
        return;
      }

      ref.invalidate(metronConnectionProvider);
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(displayName: username);
      if (!mounted) return;
      _passwordController.clear();
      _goToPage(3);
    } catch (error) {
      if (!mounted || !context.mounted) return;
      TakionAlerts.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
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

  Future<void> _finishSetup() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    await settingsBox.put(_seenOnboardingKey, true);
    if (!mounted || !context.mounted) return;
    context.router.replaceAll([const MainRoute()]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
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
                _buildMetronInfoPage(theme),
                _buildAuthorizePage(theme),
                _buildAllDonePage(theme),
              ],
            ),
          ),
        ],
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
                          height: 128,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleFade),
                        child: Text(
                          'Takion',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _descFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_descFade),
                        child: const Text(
                          'Discover, track, and organize your comic collection.',
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

  Widget _buildMetronInfoPage(ThemeData theme) {
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
                    Icon(
                      LucideIcons.atom,
                      size: 100,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Metron',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Takion uses The Metron Comic Database to keep up to date with comics.',
                      style: const TextStyle(fontSize: 18, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => _goToPage(2),
                child: const Text('Connect Metron'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizePage(ThemeData theme) {
    final metronConnectionAsync = ref.watch(metronConnectionProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;
    final isConnected = metronConnectionAsync.value != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.atom,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Metron',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Connect with The Metron Comic Database to fetch comic metadata and enhance your library.',
                    style: theme.textTheme.bodyLarge,
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
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are offline. Internet is required to verify and authorize your Metron account.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
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
                                  'No internet connection. Please reconnect and try again.',
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
                      child:
                          const Text('Don\'t have an account? Create one'),
                    ),
                  ),
                ],
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
                        scale: _pulseScale,
                        child: Icon(
                          LucideIcons.badgeCheck,
                          size: 120,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'All Done!',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You\'re all set to start organizing your comic collection.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
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
        ),
      ),
    );
  }
}

