import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/router/app_router.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/router/auth_guard.dart';
import 'package:takion/src/core/theme/app_theme.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';
import 'package:takion/src/presentation/providers/connectivity_provider.dart';
import 'package:takion/src/presentation/providers/theme_provider.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

class TakionApp extends ConsumerStatefulWidget {
  const TakionApp({super.key});

  @override
  ConsumerState<TakionApp> createState() => _TakionAppState();
}

class _TakionAppState extends ConsumerState<TakionApp> {
  late final AppRouter _appRouter;
  bool _metronCheckedForSession = false;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(AuthGuard(ref));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runMetronConnectionCheckIfNeeded();
    });
  }

  Future<void> _runMetronConnectionCheckIfNeeded() async {
    final authState = ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated || _metronCheckedForSession) {
      return;
    }

    _metronCheckedForSession = true;
    final service = ref.read(metronAccountServiceProvider);
    final hasStoredConnection = await service.getConnection();

    if (!mounted || hasStoredConnection == null) {
      return;
    }

    final status = await service.validateStoredConnection();

    if (!mounted) return;

    if (status == MetronConnectionStatus.invalid) {
      await service.disconnect();
      if (!mounted) return;

      TakionAlerts.error(
        context,
        'Metron connection is invalid. Please reconnect your Metron account.',
      );
      _appRouter.replaceAll([const MetronConnectRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    ref.watch(authStateProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;

    // Re-evaluate guards when auth state changes (e.g. on logout/login)
    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading && previous?.value != next.value) {
        _appRouter.reevaluateGuards();

        final current = next.value;
        if (current == AuthStatus.authenticated) {
          _metronCheckedForSession = false;
          Future<void>(() => _runMetronConnectionCheckIfNeeded());
        } else if (current == AuthStatus.unauthenticated) {
          _metronCheckedForSession = false;
        }
      }
    });

    final themeSettings =
        themeAsync.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );

    return MaterialApp.router(
      title: 'Takion',
      theme: AppThemes.light(),
      darkTheme: AppThemes.dark(darkIsTrueBlack: themeSettings.darkIsTrueBlack),
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      builder: (context, child) {
        final bannerColor = Theme.of(context).colorScheme.errorContainer;
        final bannerTextColor = Theme.of(context).colorScheme.onErrorContainer;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: FlexColorScheme.themedSystemNavigationBar(
            context,
            systemNavBarStyle: FlexSystemNavBarStyle.transparent,
          ).copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            statusBarBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.dark
                    : Brightness.light,
          ),
          child: Stack(
            children: [
              child!,
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: isOffline
                        ? IgnorePointer(
                            key: const ValueKey('offline-banner'),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: bannerColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.wifi_off_outlined,
                                    size: 16,
                                    color: bannerTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You are offline',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: bannerTextColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('offline-none')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
