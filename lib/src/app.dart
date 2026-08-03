import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/logging/talker_setup.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/notifications/notification_settings_provider.dart';
import 'package:takion/src/data/common/services/drive_backup_service.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/router/app_router.dart';
import 'package:takion/src/core/router/app_router.gr.dart'
    show AuthorizeMetronRoute, MyPullsRoute;
import 'package:takion/src/core/router/auth_guard.dart';
import 'package:takion/src/core/theme/app_theme.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/utils/shortcut_handler.dart';

class TakionApp extends ConsumerStatefulWidget {
  const TakionApp({super.key});

  @override
  ConsumerState<TakionApp> createState() => _TakionAppState();
}

class _TakionAppState extends ConsumerState<TakionApp>
    with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  final ShortcutHandler _shortcutHandler = ShortcutHandler();
  bool _metronCheckedForSession = false;
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
        .getBool('has_seen_onboarding')
        .then((seen) {
          if (!mounted) return;
          setState(() => _hasSeenOnboarding = seen);
        });

    _shortcutHandler.navigateNamed = (route) {
      if (!_hasSeenOnboarding) return;
      navigator.push(route);
    };

    NotificationService.instance.onNavigateToMyPulls = () {
      if (!_hasSeenOnboarding) return;
      navigator.push(const MyPullsRoute());
    };
    NotificationService.instance.checkPendingNotificationLaunch();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _runMetronConnectionCheckIfNeeded();
      await _reconcileSubscriptionPullsOnSessionStart();
      _runDriveAutoSyncIfEnabled();
      await _scheduleWeeklyPullNotification();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _shortcutHandler.checkPending();
        _maybeEnableShortcuts();
      });
    });
  }

  void _maybeEnableShortcuts() {
    ref
        .read(driftDatabaseProvider)
        .settingsDao
        .getBool('has_seen_onboarding')
        .then((seen) {
          if (seen) {
            ShortcutHandler.enableShortcuts();
          }
        });
  }

  Future<void> _reconcileSubscriptionPullsOnSessionStart() async {
    final authState = ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated) return;

    final service = ref.read(metronAccountServiceProvider);
    if (!await service.getConnection()) return;

    try {
      await ref.read(subscriptionPullReconcilerProvider).reconcile();
    } catch (error) {
      if (!mounted) return;
      TakionAlerts.safeError(
        context,
        error,
        userMessage: 'Background pull reconciliation failed',
      );
    }
  }

  Future<void> _runDriveAutoSyncIfEnabled() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final syncNotifier = ref.read(driveSyncProvider.notifier);
    await syncNotifier.ensureInitialized();
    final syncState = ref.read(driveSyncProvider);
    if (!syncState.enabled) {
      AppLogger.info('Drive auto sync skipped: disabled');
      return;
    }
    final driveService = ref.read(driveSyncServiceProvider);
    final account = await driveService.signInSilently();
    if (account == null) {
      AppLogger.info('Drive auto sync skipped: no account');
      return;
    }
    AppLogger.info('Drive auto sync triggered');
    syncNotifier.setSyncing(true);
    try {
      await driveService.triggerSync();
      await syncNotifier.updateLastSync();
      syncNotifier.clearError();
      invalidateCacheBackedProvidersForAutoSync((p) => container.invalidate(p));
      AppLogger.info('Drive auto sync completed');
    } catch (e) {
      AppLogger.warning('Background sync failed', error: e);
      syncNotifier.setError(e.toString());
    }
    syncNotifier.setSyncing(false);
  }

  Future<void> _scheduleWeeklyPullNotification() async {
    await scheduleWeeklyPullNotification(ref);
  }

  Future<void> _runMetronConnectionCheckIfNeeded() async {
    final authState = ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated || _metronCheckedForSession) {
      return;
    }

    _metronCheckedForSession = true;
    final service = ref.read(metronAccountServiceProvider);
    final hasStoredConnection = await service.getConnection();

    if (!mounted || !hasStoredConnection) {
      return;
    }

    AppLogger.info('Metron session check: stored connection found');
    final status = await service.validateStoredConnection();

    if (!mounted) return;

    if (status == MetronConnectionStatus.invalid) {
      AppLogger.warning(
        'Metron session check: invalid credentials, disconnecting',
      );
      await service.disconnect();
      ref.invalidate(authStateProvider);
      if (!mounted) return;

      TakionAlerts.error(
        context,
        'Metron connection is invalid. Please reconnect your Metron account.',
      );
      _appRouter.replaceAll([const AuthorizeMetronRoute()]);
    } else {
      AppLogger.info('Metron session check: status=$status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    ref.watch(authStateProvider);

    if (_hasSeenOnboarding) {
      ref.listen(currentWeekPullsProvider, (previous, next) {
        if (next.hasValue && mounted) {
          _scheduleWeeklyPullNotification();
        }
      });
    }

    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading && previous?.value != next.value) {
        _appRouter.reevaluateGuards();

        final current = next.value;
        if (current == AuthStatus.authenticated) {
          _metronCheckedForSession = false;
          _runMetronConnectionCheckIfNeeded();
          _reconcileSubscriptionPullsOnSessionStart().then(
            (_) => _scheduleWeeklyPullNotification(),
          );
        } else if (current == AuthStatus.unauthenticated) {
          _metronCheckedForSession = false;
          if (previous?.value == AuthStatus.authenticated &&
              _hasSeenOnboarding &&
              mounted) {
            AppLogger.warning(
              'Session expired - redirecting to authorize screen',
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
      title: 'Takion',
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
    AppLogger.debug('App lifecycle state: $state');
    if (state == AppLifecycleState.resumed && mounted) {
      _scheduleWeeklyPullNotification();
      ref.read(driftDatabaseProvider).apiCacheDao.deleteStaleEntries();
      _runDriveAutoSyncIfEnabled();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
