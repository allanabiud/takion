import "package:flutter/foundation.dart";

/// The active lifecycle phase of a sync operation.
enum SyncPhase {
  idle,
  checking,
  downloading,
  parsing,
  applying,
  extracting,
  uploading,
  pruning,
  completed,
  failed,
}

/// Represents the observable progress and status of synchronization.
class SyncProgressState {
  final SyncPhase phase;
  final String? message;
  final double? progress;
  final DateTime updatedAt;

  const SyncProgressState({
    this.phase = SyncPhase.idle,
    this.message,
    this.progress,
    required this.updatedAt,
  });

  factory SyncProgressState.initial() => SyncProgressState(
    phase: SyncPhase.idle,
    updatedAt: DateTime.now(),
  );

  SyncProgressState copyWith({
    SyncPhase? phase,
    String? message,
    double? progress,
  }) {
    return SyncProgressState(
      phase: phase ?? this.phase,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      updatedAt: DateTime.now(),
    );
  }
}

/// Dispatches observable updates during sync execution.
class SyncProgressNotifier extends ValueNotifier<SyncProgressState> {
  SyncProgressNotifier([SyncProgressState? initial])
    : super(initial ?? SyncProgressState.initial());

  void setPhase(SyncPhase phase, {String? message, double? progress}) {
    value = SyncProgressState(
      phase: phase,
      message: message,
      progress: progress,
      updatedAt: DateTime.now(),
    );
  }

  void reset() {
    value = SyncProgressState.initial();
  }
}
