import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:file_picker/file_picker.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/core/notifications/notification_service.dart";
import "package:takion/src/core/router/app_router.gr.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/data/common/services/local_backup_service.dart";
import "package:takion/src/presentation/features/onboarding/widgets/all_done_page.dart";
import "package:takion/src/presentation/features/onboarding/widgets/appearance_page.dart";
import "package:takion/src/presentation/features/onboarding/widgets/metron_info_page.dart";
import "package:takion/src/presentation/features/onboarding/widgets/onboarding_page_scaffold.dart";
import "package:takion/src/presentation/features/onboarding/widgets/restore_backup_page.dart";
import "package:takion/src/presentation/features/onboarding/widgets/welcome_page.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:takion/src/presentation/utils/shortcut_handler.dart";

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _seenOnboardingKey = SettingsKeys.hasSeenOnboarding;

  bool _isCheckingFirstLaunch = true;

  int _currentPage = 0;

  bool _restoreCompleted = false;
  bool _isDriveRestoring = false;
  bool _isLocalRestoring = false;

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
        await context.router.replaceAll([const MainRoute()]);
        NotificationService.instance.tryNavigateToMyPulls();
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

  Future<void> _finishSetup() async {
    final settingsDao = ref.read(driftDatabaseProvider).settingsDao;
    await settingsDao.setBool(_seenOnboardingKey, true);
    ShortcutHandler.enableShortcuts();
    if (!mounted || !context.mounted) return;
    await context.router.replaceAll([const MainRoute()]);
    NotificationService.instance.tryNavigateToMyPulls();
  }

  Future<void> _restoreFromDrive() async {
    AppLogger.info("Drive restore started during onboarding");
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
              "Sign in to Google Drive to restore your backup.",
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
        if (e.message == "No sync data found on Google Drive") {
          hadBackup = false;
        } else {
          rethrow;
        }
      }

      await ref.read(driveSyncProvider.notifier).enable(email: email);

      if (hadBackup) {
        invalidateCacheBackedProvidersBatched(container.invalidate);
        AppLogger.info("Drive restore completed");
        AppLogger.info("Onboarding completed");
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
          AppLogger.info("Initial backup uploaded to Drive");
        } catch (e) {
          AppLogger.warning("Onboarding backup upload failed", error: e);
        } finally {
          ref.read(driveSyncProvider.notifier).setSyncing(false);
        }
        AppLogger.info("Onboarding completed");
        if (mounted) {
          setState(() {
            _restoreCompleted = true;
            _isDriveRestoring = false;
          });
          TakionAlerts.info(
            context,
            "No backup file found. Sync has been enabled — your data will be backed up to Drive.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDriveRestoring = false);
        final msg = e.toString().contains("No sync data")
            ? "No backup file found"
            : "Drive restore failed";
        TakionAlerts.safeError(
          context,
          msg == "Drive restore failed" ? e : null,
          userMessage: msg,
        );
      }
    }
  }

  Future<void> _restoreFromLocalFile() async {
    AppLogger.info("Local restore started during onboarding");
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

      invalidateCacheBackedProvidersBatched(container.invalidate);
      await Future<void>.delayed(Duration.zero);

      AppLogger.info("Local restore completed");
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
          userMessage: "Failed to restore backup",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstLaunch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    final pages = <Widget>[
      WelcomePage(onNext: () => _goToPage(1)),
      AppearancePage(onContinue: () => _goToPage(2)),
      MetronInfoPage(onContinue: () => _goToPage(3)),
      RestoreBackupPage(
        restoreCompleted: _restoreCompleted,
        isDriveRestoring: _isDriveRestoring,
        isLocalRestoring: _isLocalRestoring,
        onLocalRestore: _restoreFromLocalFile,
        onDriveRestore: _restoreFromDrive,
        onContinue: () => _goToPage(4),
      ),
      AllDonePage(onFinish: _finishSetup),
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
                child: OnboardingProgressBar(currentPage: _currentPage),
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
}