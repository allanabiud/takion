import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/metron_account_service.dart';
import 'package:takion/src/core/notifications/notification_service.dart';
import 'package:takion/src/core/notifications/notification_settings_provider.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/data/services/drive_backup_service.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/router/app_router.dart';
import 'package:takion/src/core/router/app_router.gr.dart'
    show
        AuthorizeMetronRoute,
        MyPullsRoute;
import 'package:takion/src/core/router/auth_guard.dart';
import 'package:takion/src/core/theme/app_theme.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/settings/providers/settings_provider.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/logic/shortcut_handler.dart';

class TakionApp extends ConsumerStatefulWidget {
  const TakionApp({super.key});

  @override
  ConsumerState<TakionApp> createState() => _TakionAppState();
}

class _TakionAppState extends ConsumerState<TakionApp> {
  late final AppRouter _appRouter;
  final ShortcutHandler _shortcutHandler = ShortcutHandler();
  bool _metronCheckedForSession = false;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(AuthGuard(ref));
    _shortcutHandler.init();
    final box = ref.read(hiveServiceProvider).getBoxIfOpen('settings_box');
    final hasSeen = box?.get('has_seen_onboarding', defaultValue: false) == true;
    final navigator = _appRouter;

    _shortcutHandler.navigateNamed = (route) {
      if (!hasSeen) return;
      navigator.push(route);
    };

    NotificationService.instance.onNavigateToMyPulls = () {
      if (!hasSeen) return;
      navigator.push(const MyPullsRoute());
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _runMetronConnectionCheckIfNeeded();
      _reconcileSubscriptionPullsOnSessionStart();
      _runDriveAutoSyncIfEnabled();
      _scheduleWeeklyPullNotification();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _shortcutHandler.checkPending();
        _maybeEnableShortcuts();
      });
    });
  }

  void _maybeEnableShortcuts() {
    final box = ref.read(hiveServiceProvider).getBoxIfOpen('settings_box');
    final hasSeen = box?.get('has_seen_onboarding', defaultValue: false) == true;
    if (hasSeen) {
      ShortcutHandler.enableShortcuts();
    }
  }

  Future<void> _reconcileSubscriptionPullsOnSessionStart() async {
    final authState = ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated) return;

    try {
      await ref.read(subscriptionPullReconcilerProvider).reconcile();
    } catch (error) {
      if (!mounted) return;
      TakionAlerts.error(
        context,
        'Background pull reconciliation failed: $error',
      );
    }
  }

  Future<void> _runDriveAutoSyncIfEnabled() async {
    final syncState = ref.read(driveSyncProvider);
    if (!syncState.enabled) {
      return;
    }
    final driveService = ref.read(driveBackupServiceProvider);
    final syncNotifier = ref.read(driveSyncProvider.notifier);
    final container = ProviderScope.containerOf(context, listen: false);
    final account = await driveService.signInSilently();
    if (account == null) {
      return;
    }
    syncNotifier.setSyncing(true);
    try {
      await driveService.uploadBackup(
        lastSyncTime: syncState.lastSync,
      );
      await syncNotifier.updateLastSync();
      invalidateCacheBackedProviders((p) => container.invalidate(p));
      await Future<void>.delayed(Duration.zero);
    } catch (_) {
      // sync failure is non-critical; state resets on next launch
    }
    syncNotifier.setSyncing(false);
  }

  Future<void> _scheduleWeeklyPullNotification() async {
    final enabled = ref.read(notificationsEnabledProvider).value ?? false;
    if (!enabled) {
      await NotificationService.instance.cancel();
      return;
    }
    final day = ref.read(notificationDayProvider).value ?? NotificationDay.wednesday;
    final count = ref.read(currentWeekPullsCountProvider);
    if (count > 0) {
      await NotificationService.instance.scheduleWeekly(count, day);
    } else {
      await NotificationService.instance.cancel();
    }
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
      _appRouter.replaceAll([const AuthorizeMetronRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    ref.watch(authStateProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);
    final isOffline =
        connectivityState.asData?.value == AppConnectivityStatus.offline;

    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading && previous?.value != next.value) {
        _appRouter.reevaluateGuards();

        final current = next.value;
        if (current == AuthStatus.authenticated) {
          _metronCheckedForSession = false;
          _runMetronConnectionCheckIfNeeded();
          _reconcileSubscriptionPullsOnSessionStart();
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
    final accentScheme = ref.watch(accentSchemeProvider).value ?? FlexScheme.green;
    return MaterialApp.router(
      title: 'Takion',
      theme: AppThemes.light(accentScheme: accentScheme),
      darkTheme: AppThemes.dark(
        darkIsTrueBlack: themeSettings.darkIsTrueBlack,
        accentScheme: accentScheme,
      ),
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      builder: (context, child) {
        final bannerColor = Theme.of(context).colorScheme.errorContainer;
        final bannerTextColor = Theme.of(
          context,
        ).colorScheme.onErrorContainer;

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
                              margin: const EdgeInsets.fromLTRB(
                                12,
                                8,
                                12,
                                0,
                              ),
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
                                          ?.copyWith(
                                            color: bannerTextColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('offline-none'),
                          ),
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
