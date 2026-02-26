import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _settingsBoxName = 'settings_box';
  static const _seenOnboardingKey = 'has_seen_onboarding';
  static const _logoHeroTag = 'takion-app-logo';

  bool _isCheckingFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    final hasSeen =
        settingsBox.get(_seenOnboardingKey, defaultValue: false) == true;

    if (!mounted) return;

    if (hasSeen) {
      final authStatus = await ref.read(authStateProvider.future);
      if (!mounted) return;

      if (authStatus == AuthStatus.authenticated) {
        final metronService = ref.read(metronAccountServiceProvider);
        final connection = await metronService.getConnection();
        if (!mounted) return;

        if (connection != null) {
          context.router.replaceAll([const MainRoute()]);
        } else {
          context.router.replace(const MetronConnectRoute());
        }
      } else {
        context.router.replace(LoginRoute());
      }
      return;
    }

    setState(() {
      _isCheckingFirstLaunch = false;
    });
  }

  Future<void> _handleGetStarted() async {
    context.router.push(LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstLaunch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
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
                      Hero(
                        tag: _logoHeroTag,
                        child: SvgPicture.asset(
                          'assets/images/takion_logo.svg',
                          height: 128,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Takion',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Discover, track, and organize your comic collection.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleGetStarted,
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
