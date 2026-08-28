import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:takion/src/core/auth/auth_provider.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/metron_account_service.dart";
import "package:takion/src/core/notifications/notification_settings_provider.dart";
import "package:takion/src/core/storage/drift_database_provider.dart";
import "package:takion/src/data/common/services/drive_backup_service.dart";
import "package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart";
import "package:takion/src/presentation/features/settings/providers/settings_provider.dart";
import "package:takion/src/presentation/providers/drive_sync_provider.dart";

/// Explicit lifecycle and session states for the Takion application.
enum SessionState {
  booting,
  onboarding,
  unauthenticated,
  validating,
  ready,
  recovering,
}

/// Orchestrates session lifecycle, background sync, pull reconciliation,
/// and authentication state transitions.
class SessionCoordinator {
  SessionCoordinator(this._ref);

  final Ref _ref;
  SessionState _currentState = SessionState.booting;
  bool _metronCheckedForSession = false;

  SessionState get state => _currentState;

  void setState(SessionState newState) {
    if (_currentState != newState) {
      AppLogger.info("Session state transition: $_currentState -> $newState");
      _currentState = newState;
    }
  }

  /// Validates the stored Metron credentials if authenticated and not already checked.
  Future<MetronConnectionStatus?> validateMetronConnectionIfNeeded() async {
    final authState = _ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated || _metronCheckedForSession) {
      return null;
    }

    _metronCheckedForSession = true;
    setState(SessionState.validating);

    final service = _ref.read(metronAccountServiceProvider);
    final hasStoredConnection = await service.getConnection();

    if (!hasStoredConnection) {
      setState(SessionState.unauthenticated);
      return null;
    }

    AppLogger.info("Metron session check: stored connection found");
    final status = await service.validateStoredConnection();

    if (status == MetronConnectionStatus.invalid) {
      AppLogger.warning("Metron session check: invalid credentials, disconnecting");
      await service.disconnect();
      _ref.invalidate(authStateProvider);
      setState(SessionState.recovering);
      return status;
    }

    setState(SessionState.ready);
    AppLogger.info("Metron session check: status=$status");
    return status;
  }

  /// Safely executes subscription pull reconciliation when authenticated.
  Future<bool> reconcileSubscriptionPulls() async {
    final authState = _ref.read(authStateProvider).value;
    if (authState != AuthStatus.authenticated) return false;

    final service = _ref.read(metronAccountServiceProvider);
    if (!await service.getConnection()) return false;

    try {
      await _ref.read(subscriptionPullReconcilerProvider).reconcile();
      return true;
    } catch (error) {
      AppLogger.warning("Background pull reconciliation failed", error: error);
      return false;
    }
  }

  /// Runs Drive auto-sync if enabled and not throttled.
  Future<bool> runDriveAutoSync({
    bool ignoreThrottle = false,
    void Function(ProviderOrFamily)? onInvalidateCache,
  }) async {
    final syncNotifier = _ref.read(driveSyncProvider.notifier);
    await syncNotifier.ensureInitialized();
    final syncState = _ref.read(driveSyncProvider);

    if (!syncState.enabled) {
      AppLogger.info("Drive auto sync skipped: disabled");
      return false;
    }

    final driveService = _ref.read(driveSyncServiceProvider);
    final account = await driveService.signInSilently();
    if (account == null) {
      AppLogger.info("Drive auto sync skipped: no account");
      return false;
    }

    if (!ignoreThrottle && await driveService.isThrottled()) {
      AppLogger.info("Drive auto sync skipped: throttled (< 5m since last sync attempt)");
      return false;
    }

    AppLogger.info("Drive auto sync triggered");
    syncNotifier.setSyncing(true);
    try {
      final ran = await driveService.triggerSync(ignoreThrottle: ignoreThrottle);
      if (ran) {
        await syncNotifier.updateLastSync();
        syncNotifier.clearError();
        if (onInvalidateCache != null) {
          invalidateCacheBackedProvidersForAutoSync(onInvalidateCache);
        }
        AppLogger.info("Drive auto sync completed successfully");
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.warning("Background sync failed", error: e);
      syncNotifier.setError(e.toString());
      return false;
    } finally {
      syncNotifier.setSyncing(false);
    }
  }

  /// Triggers recurring notifications and maintenance on application resume.
  Future<void> onAppResumed({
    void Function(ProviderOrFamily)? onInvalidateCache,
  }) async {
    AppLogger.debug("SessionCoordinator onAppResumed triggered");
    await scheduleWeeklyPullNotification(_ref);
    await _ref.read(driftDatabaseProvider).apiCacheDao.deleteStaleEntries();
    await runDriveAutoSync(onInvalidateCache: onInvalidateCache);
  }

  /// Resets session validation flag on auth status changes.
  void onAuthStatusChanged(AuthStatus? previous, AuthStatus? current) {
    if (current == AuthStatus.authenticated) {
      _metronCheckedForSession = false;
      setState(SessionState.validating);
    } else if (current == AuthStatus.unauthenticated) {
      _metronCheckedForSession = false;
      setState(SessionState.unauthenticated);
    }
  }
}

final sessionCoordinatorProvider = Provider<SessionCoordinator>((ref) {
  return SessionCoordinator(ref);
});
