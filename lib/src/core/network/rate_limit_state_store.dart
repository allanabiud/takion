import "dart:async";
import "dart:convert";

import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/metron_request_scheduler.dart";
import "package:takion/src/data/common/drift/daos/sync_meta_dao.dart";

/// Persists [RateLimitState] snapshots to SQLite so rate-limit knowledge
/// survives app restarts and Workmanager isolate teardown.
///
/// Snapshots are stored as JSON under the SyncMeta key
/// `ratelimit:<accountId>`, which requires no schema migration and keeps the
/// state namespaced per account. Saves are debounced because the scheduler
/// emits a state change on every dispatch and every response.
class RateLimitStateStore {
  RateLimitStateStore(
    this._metaDao, {
    this.accountId = "local-user",
    this.debounce = const Duration(milliseconds: 500),
  });

  final SyncMetaDao _metaDao;
  final String accountId;
  final Duration debounce;

  Timer? _debounceTimer;
  RateLimitState? _pendingState;
  bool _writeInFlight = false;

  /// The SyncMeta key this store persists under.
  String get key => "ratelimit:$accountId";

  /// Schedules a debounced save of [state]. The latest state always wins.
  void scheduleSave(RateLimitState state) {
    _pendingState = state;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      final pending = _pendingState;
      _pendingState = null;
      if (pending != null) {
        unawaited(_flush(pending));
      }
    });
  }

  Future<void> _flush(RateLimitState state) async {
    // Serialize writes so a slow write is never interleaved with a newer one.
    while (_writeInFlight) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    _writeInFlight = true;
    try {
      await _metaDao.set(key, jsonEncode(state.toJson()));
    } catch (e) {
      AppLogger.warning("Failed to persist rate-limit state: $e");
    } finally {
      _writeInFlight = false;
    }
  }

  /// Immediately persists [state], bypassing the debounce. Used on dispose
  /// and in tests that must not wait for the debounce window.
  Future<void> saveNow(RateLimitState state) {
    _debounceTimer?.cancel();
    _pendingState = null;
    return _flush(state);
  }

  /// Loads the persisted snapshot, or null when none exists (or the stored
  /// value is corrupt — a corrupt snapshot must never block networking).
  Future<RateLimitState?> load() async {
    try {
      final raw = await _metaDao.get(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return RateLimitState.fromJson(decoded);
    } catch (e) {
      AppLogger.warning("Failed to restore rate-limit state: $e");
      return null;
    }
  }

  /// Deletes the persisted snapshot (e.g. on logout/account switch).
  Future<void> clear() => _metaDao.deleteByKey(key);

  /// Cancels any pending debounced write.
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
