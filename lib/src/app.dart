import "dart:async";

import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/logging/talker_setup.dart";
import "package:talker_flutter/talker_flutter.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/core/notifications/notification_service.dart";
import "package:takion/src/core/notifications/notification_settings_provider.dart";
import "package:takion/src/core/session/session_coordinator.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/router/app_router.dart";
import "package:takion/src/core/router/app_router.gr.dart"
    show AuthorizeMetronRoute, MyPullsRoute, OnboardingRoute;
import "package:takion/src/core/router/auth_guard.dart";
import "package:takion/src/core/theme/app_theme.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/utils/shortcut_handler.dart";

class TakionApp extends ConsumerStatefulWidget {
  const TakionApp({super.key});

  @override
  ConsumerState<TakionApp> createState() => _TakionAppState();
}

class _TakionAppState extends ConsumerState<TakionApp>
    with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  final ShortcutHandler _shortcutHandler = ShortcutHandler();
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter(AuthGuard(ref));
    _shortcutHandler.init();
    final navigator = _appRouter;

    ref
        .read(driftDatabaseProvider)
        .settingsDao
        .getBool("has_seen_onboarding")
        .then((seen) {
          if (!mounted) return;
          setState(() => _hasSeenOnboarding = seen);
          if (seen) {
            NotificationService.instance.tryNavigateToMyPulls();
          }
        });

    _shortcutHandler.navigateNamed = (route) {
      if (!_hasSeenOnboarding) return;
      navigator.push(route);
    };

    NotificationService.instance.onNavigateToMyPulls = () {
      try {
        final currentRouteName = _appRouter.current.name;
        if (currentRouteName == OnboardingRoute.name) {
          return false;
        }
        if (currentRouteName == MyPullsRoute.name) {
          return true;
        }
      } catch (_) {
        return false;
      }
      navigator.push(const MyPullsRoute());
      return true;
    };
    NotificationService.instance.checkPendingNotificationLaunch();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final coordinator = ref.read(sessionCoordinatorProvider);
      final status = await coordinator.validateMetronConnectionIfNeeded();
      if (!mounted) return;

      if (status == MetronConnectionStatus.invalid) {
        TakionAlerts.error(
          context,
          "Metron connection is invalid. Please reconnect your Metron account.",
        );
        _appRouter.replaceAll([const AuthorizeMetronRoute()]);
        return;
      }

      await coordinator.reconcileSubscriptionPulls();
      if (!mounted) return;

      final container = ProviderScope.containerOf(context, listen: false);
      await coordinator.runDriveAutoSync(
        onInvalidateCache: container.invalidate,
      );
      await scheduleWeeklyPullNotification(ref);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _shortcutHandler.checkPending();
        _maybeEnableShortcuts();
        NotificationService.instance.tryNavigateToMyPulls();
      });
    });
  }

  void _maybeEnableShortcuts() {
    ref
        .read(driftDatabaseProvider)
        .settingsDao
        .getBool("has_seen_onboarding")
        .then((seen) {
          if (seen) {
            ShortcutHandler.enableShortcuts();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    ref.watch(authStateProvider);

    if (_hasSeenOnboarding) {
      ref.listen(currentWeekPullsProvider, (previous, next) {
        if (next.hasValue && mounted) {
          scheduleWeeklyPullNotification(ref);
        }
      });
    }

    ref.listen(authStateProvider, (previous, next) async {
      if (!next.isLoading && previous?.value != next.value) {
        _appRouter.reevaluateGuards();
        final coordinator = ref.read(sessionCoordinatorProvider);
        coordinator.onAuthStatusChanged(previous?.value, next.value);

        final current = next.value;
        if (current == AuthStatus.authenticated) {
          final status = await coordinator.validateMetronConnectionIfNeeded();
          if (!mounted) return;

          if (status == MetronConnectionStatus.invalid) {
            final navContext = _appRouter.navigatorKey.currentContext;
            if (navContext != null && navContext.mounted) {
              TakionAlerts.error(
                navContext,
                "Metron connection is invalid. Please reconnect your Metron account.",
              );
            }
            _appRouter.replaceAll([const AuthorizeMetronRoute()]);
            return;
          }

          await coordinator.reconcileSubscriptionPulls();
          await scheduleWeeklyPullNotification(ref);
        } else if (current == AuthStatus.unauthenticated) {
          if (previous?.value == AuthStatus.authenticated &&
              _hasSeenOnboarding &&
              mounted) {
            AppLogger.warning(
              "Session expired - redirecting to authorize screen",
            );
            Future.microtask(
              () => _appRouter.replaceAll([const AuthorizeMetronRoute()]),
            );
          }
        }
      }
    });
    final themeSettings =
        themeAsync.value ??
        const ThemeSettings(
          themeMode: ThemeMode.system,
          darkIsTrueBlack: false,
        );
    final accentScheme =
        ref.watch(accentSchemeProvider).value ?? FlexScheme.green;
    return MaterialApp.router(
      title: "Takion",
      theme: AppThemes.light(accentScheme: accentScheme),
      darkTheme: AppThemes.dark(
        darkIsTrueBlack: themeSettings.darkIsTrueBlack,
        accentScheme: accentScheme,
      ),
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [TalkerRouteObserver(talker)],
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              FlexColorScheme.themedSystemNavigationBar(
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
          child: child!,
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.debug("App lifecycle state: $state");
    if (state == AppLifecycleState.resumed && mounted) {
      final container = ProviderScope.containerOf(context, listen: false);
      ref.read(sessionCoordinatorProvider).onAppResumed(
        onInvalidateCache: container.invalidate,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
