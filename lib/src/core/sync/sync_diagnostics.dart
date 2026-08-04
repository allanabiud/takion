import 'dart:convert';

import 'package:takion/src/data/common/drift/daos/sync_meta_dao.dart';

const int syncLogRingSize = 20;

class SyncLogEntry {
  final DateTime time;
  final String phase;
  final bool success;
  final String? error;
  final String? detail;
  final int? elapsedMs;

  const SyncLogEntry({
    required this.time,
    required this.phase,
    required this.success,
    this.error,
    this.detail,
    this.elapsedMs,
  });

  Map<String, dynamic> toJson() => {
    't': time.toUtc().toIso8601String(),
    'phase': phase,
    'ok': success,
    if (error != null) 'error': error,
    if (detail != null) 'detail': detail,
    if (elapsedMs != null) 'ms': elapsedMs,
  };

  static SyncLogEntry? tryParse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final time = DateTime.tryParse(json['t'] as String? ?? '');
      if (time == null) return null;
      return SyncLogEntry(
        time: time,
        phase: json['phase'] as String? ?? 'unknown',
        success: json['ok'] as bool? ?? false,
        error: json['error'] as String?,
        detail: json['detail'] as String?,
        elapsedMs: (json['ms'] as num?)?.toInt(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => jsonEncode(toJson());
}

class SyncDiagnostics {
  final String? lastError;
  final String? lastErrorDetail;
  final DateTime? lastErrorTime;
  final String? lastPhase;
  final DateTime? lastSuccessTime;
  final List<SyncLogEntry> recentAttempts;

  const SyncDiagnostics({
    this.lastError,
    this.lastErrorDetail,
    this.lastErrorTime,
    this.lastPhase,
    this.lastSuccessTime,
    this.recentAttempts = const [],
  });
}

Future<void> recordSyncAttempt(
  SyncMetaDao dao, {
  required String phase,
  required bool success,
  String? error,
  String? detail,
  int? elapsedMs,
}) async {
  final entry = SyncLogEntry(
    time: DateTime.now(),
    phase: phase,
    success: success,
    error: error,
    detail: detail,
    elapsedMs: elapsedMs,
  );

  final seqRaw = await dao.get('sync_log_seq');
  final seq = (int.tryParse(seqRaw ?? '') ?? 0) + 1;
  await dao.set('sync_log_seq', '$seq');
  await dao.set('sync_log:${seq % syncLogRingSize}', entry.toString());

  final nowIso = DateTime.now().toUtc().toIso8601String();
  if (success) {
    await dao.set('last_sync_success_time', nowIso);
  } else {
    await dao.set('last_sync_error', error ?? '');
    await dao.set('last_sync_error_detail', detail ?? '');
    await dao.set('last_sync_error_time', nowIso);
    await dao.set('last_sync_phase', phase);
  }
}

Future<SyncDiagnostics> loadSyncDiagnostics(SyncMetaDao dao) async {
  final all = await dao.getAll();

  DateTime? parse(String? key) {
    final raw = all[key];
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  final seqRaw = all['sync_log_seq'];
  final seq = int.tryParse(seqRaw ?? '') ?? 0;

  final attempts = <SyncLogEntry>[];
  for (var i = seq; i > seq - syncLogRingSize && i > 0; i--) {
    final raw = all['sync_log:${i % syncLogRingSize}'];
    if (raw == null) continue;
    final entry = SyncLogEntry.tryParse(raw);
    if (entry != null) attempts.add(entry);
  }

  return SyncDiagnostics(
    lastError: all['last_sync_error'],
    lastErrorDetail: all['last_sync_error_detail'],
    lastErrorTime: parse('last_sync_error_time'),
    lastPhase: all['last_sync_phase'],
    lastSuccessTime: parse('last_sync_success_time'),
    recentAttempts: attempts,
  );
}
