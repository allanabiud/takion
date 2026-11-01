import "dart:async";
import "dart:math";
import "package:clock/clock.dart";
import "package:dio/dio.dart";
import "package:drift/drift.dart";
import "package:takion/src/core/commands/outbox_constants.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/sync/outbox/outbox_action_result.dart";
import "package:takion/src/core/sync/outbox/outbox_projection_applier.dart";
import "package:takion/src/core/sync/outbox/outbox_remote_dispatcher.dart";
import "package:takion/src/data/common/drift/daos/outbox_dao.dart";
import "package:takion/src/data/common/drift/daos/sync_conflict_dao.dart";
import "package:takion/src/data/common/drift/database.dart";
import "package:uuid/uuid.dart";

class OutboxDrainResult {
  const OutboxDrainResult({
    this.completedCount = 0,
    this.retryCount = 0,
    this.blockedCount = 0,
    this.conflictCount = 0,
    this.stoppedDueToRateLimit = false,
  });

  final int completedCount;
  final int retryCount;
  final int blockedCount;
  final int conflictCount;
  final bool stoppedDueToRateLimit;

  bool get hasWorkPending => retryCount > 0 || blockedCount > 0;
}

class OutboxExecutor {
  OutboxExecutor({
    required AppDatabase db,
    required OutboxDao outboxDao,
    required OutboxRemoteDispatcher dispatcher,
    required OutboxProjectionApplier projectionApplier,
    SyncConflictDao? conflictDao,
    Random? random,
    Clock? clock,
  }) : _db = db,
       _outboxDao = outboxDao,
       _dispatcher = dispatcher,
       _projectionApplier = projectionApplier,
       _conflictDao = conflictDao ?? SyncConflictDao(db),
       _random = random ?? Random(),
       _clock = clock ?? const Clock();

  final AppDatabase _db;
  final OutboxDao _outboxDao;
  final OutboxRemoteDispatcher _dispatcher;
  final OutboxProjectionApplier _projectionApplier;
  final SyncConflictDao _conflictDao;
  final Random _random;
  final Clock _clock;
  static const _uuid = Uuid();

  /// Drains ready operations for [accountId] within [budget].
  Future<OutboxDrainResult> drain({
    required String accountId,
    Duration budget = const Duration(minutes: 4),
    DateTime? now,
  }) async {
    final start = now ?? _clock.now().toUtc();
    final deadline = start.add(budget);

    var completed = 0;
    var retries = 0;
    var blocked = 0;
    var conflicts = 0;
    var stoppedRateLimit = false;

    while (DateTime.now().toUtc().isBefore(deadline)) {
      final op = await _outboxDao.claimNextReady(
        accountId: accountId,
        now: DateTime.now().toUtc(),
      );

      if (op == null) break;

      try {
        final result = await _dispatcher.execute(op);

        await _db.transaction(() async {
          await _projectionApplier.applyCanonicalWriteResult(op, result);
          await _outboxDao.markDone(op.id);
          if (result.remoteId != null) {
            await _outboxDao.releaseDependents(op.id, result.remoteId!);
          }
        });

        completed++;
      } catch (e, st) {
        if (e is DioException) {
          final statusCode = e.response?.statusCode;

          // 404 on delete is idempotent success: already deleted remotely
          if (statusCode == 404 && op.operation == OutboxOperationType.delete) {
            await _db.transaction(() async {
              await _projectionApplier.applyCanonicalWriteResult(
                op,
                const OutboxActionResult(),
              );
              await _outboxDao.markDone(op.id);
            });
            completed++;
            continue;
          }

          if (statusCode == 429) {
            stoppedRateLimit = true;
            retries++;
            final delay =
                _parseRetryAfter(e) ?? _calculateBackoff(op.attemptCount);
            final notBefore = DateTime.now().toUtc().add(delay);

            AppLogger.warning(
              "OutboxExecutor rate limited on op ${op.id}. Pausing until $notBefore",
            );
            await _outboxDao.finishAttempt(
              op.id,
              state: OutboxState.retry,
              notBefore: notBefore,
              errorCode: "429",
              errorMessage: "Rate limit exceeded (Retry-After)",
            );
            break; // Stop draining further requests to honor quota
          }

          if (statusCode != null && statusCode >= 500) {
            retries++;
            final delay = _calculateBackoff(op.attemptCount);
            final notBefore = DateTime.now().toUtc().add(delay);
            await _outboxDao.finishAttempt(
              op.id,
              state: OutboxState.retry,
              notBefore: notBefore,
              errorCode: statusCode.toString(),
              errorMessage: _cleanErrorMessage(e),
            );
            continue;
          }

          if (_isNetworkConnectivityError(e)) {
            retries++;
            final delay = _calculateBackoff(op.attemptCount);
            final notBefore = DateTime.now().toUtc().add(delay);
            await _outboxDao.finishAttempt(
              op.id,
              state: OutboxState.retry,
              notBefore: notBefore,
              errorCode: "NETWORK_ERROR",
              errorMessage: e.message ?? "Network connectivity error",
            );
            continue;
          }

          if (statusCode == 409) {
            conflicts++;
            await _outboxDao.finishAttempt(
              op.id,
              state: OutboxState.conflict,
              errorCode: "409",
              errorMessage: "Resource conflict on remote",
            );

            await _conflictDao.upsert(
              SyncConflictsCompanion.insert(
                id: _uuid.v4(),
                accountId: accountId,
                entityType: op.entityType,
                entityLocalId: op.entityLocalId,
                entityRemoteId: Value(op.entityRemoteId),
                localPayloadJson: op.payloadJson,
                remotePayloadJson: Value(
                  e.response?.data != null ? e.response!.data.toString() : null,
                ),
                state: const Value("open"),
                createdAt: DateTime.now().toUtc(),
              ),
            );
            continue;
          }

          // Permanent client / validation / authorization errors (400, 401, 403, 422)
          blocked++;
          final errorMsg = _cleanErrorMessage(e);
          AppLogger.error(
            "Outbox op ${op.id} permanently blocked ($statusCode): $errorMsg",
            error: e,
            stackTrace: st,
          );
          await _outboxDao.finishAttempt(
            op.id,
            state: OutboxState.blocked,
            errorCode: statusCode?.toString() ?? "CLIENT_ERROR",
            errorMessage: errorMsg,
          );
        } else {
          // Unexpected non-Dio exception
          blocked++;
          await _outboxDao.finishAttempt(
            op.id,
            state: OutboxState.blocked,
            errorCode: "UNEXPECTED_ERROR",
            errorMessage: e.toString(),
          );
        }
      }
    }

    return OutboxDrainResult(
      completedCount: completed,
      retryCount: retries,
      blockedCount: blocked,
      conflictCount: conflicts,
      stoppedDueToRateLimit: stoppedRateLimit,
    );
  }

  Duration _calculateBackoff(int attemptCount) {
    // Exponential backoff: base 2s * 2^attempt, capped at 15m, with full jitter
    final expSeconds = min(900, 2 * pow(2, attemptCount)).toInt();
    final jitterSeconds = expSeconds > 1 ? _random.nextInt(expSeconds ~/ 2) : 1;
    return Duration(seconds: expSeconds + jitterSeconds);
  }

  Duration? _parseRetryAfter(DioException e) {
    final raw =
        e.response?.headers.value("retry-after") ??
        e.response?.headers.value("Retry-After");
    if (raw == null) return null;

    final seconds = int.tryParse(raw);
    if (seconds != null && seconds > 0) {
      // Add a slight jitter (1-3 seconds) to prevent synchronized burst retry
      return Duration(seconds: seconds + 1 + _random.nextInt(3));
    }

    try {
      final date = HttpDate.parse(raw);
      final diff = date.difference(DateTime.now().toUtc());
      if (!diff.isNegative) {
        return diff + Duration(seconds: 1 + _random.nextInt(3));
      }
    } catch (_) {}
    return null;
  }

  bool _isNetworkConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  String _cleanErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data["detail"] != null) return data["detail"].toString();
      if (data["error"] != null) return data["error"].toString();
      final firstKey = data.keys.firstOrNull;
      if (firstKey != null) {
        final val = data[firstKey];
        if (val is List && val.isNotEmpty) {
          return "$firstKey: ${val.first}";
        }
        return "$firstKey: $val";
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return e.message ?? e.toString();
  }
}

class HttpDate {
  static DateTime parse(String dateStr) => DateTime.parse(dateStr);
}
