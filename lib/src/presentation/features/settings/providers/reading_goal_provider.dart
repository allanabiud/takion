import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/constants/settings_keys.dart";
import "package:takion/src/domain/collection/entities/collection_analytics.dart";
import "package:takion/src/presentation/providers/repository_providers.dart";

class ReadingGoal {
  final int target;
  final String period;

  const ReadingGoal({required this.target, required this.period});

  ReadingGoal copyWith({int? target, String? period}) {
    return ReadingGoal(
      target: target ?? this.target,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() => {"target": target, "period": period};

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
    target: json["target"] as int,
    period: json["period"] as String,
  );
}

final readingGoalProvider =
    AsyncNotifierProvider<ReadingGoalNotifier, ReadingGoal?>(
      ReadingGoalNotifier.new,
    );

class ReadingGoalNotifier extends AsyncNotifier<ReadingGoal?> {
  static const _targetKey = SettingsKeys.readingGoalTarget;
  static const _periodKey = SettingsKeys.readingGoalPeriod;

  @override
  Future<ReadingGoal?> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final target = await dao.getInt(_targetKey);
    final period = await dao.getString(_periodKey);
    if (period == null) return null;
    return ReadingGoal(target: target, period: period);
  }

  Future<void> setGoal(ReadingGoal goal) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setInt(_targetKey, goal.target);
    await dao.setString(_periodKey, goal.period);
    state = AsyncValue.data(goal);
  }

  Future<void> clearGoal() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.deleteByKey(_targetKey);
    await dao.deleteByKey(_periodKey);
    state = const AsyncValue.data(null);
  }
}

/// Progress of the configured goal for its own period window (a calendar
/// year for "yearly", the current month otherwise), counted in SQL over
/// `first_read_at`. Independent of whatever period filter the stats UI is
/// showing; re-emits whenever the library changes.
final readingGoalProgressProvider =
    StreamProvider.autoDispose<ReadingGoalProgress?>((ref) {
      final goalAsync = ref.watch(readingGoalProvider);
      final engine = ref.watch(collectionAnalyticsEngineProvider);
      final goal = goalAsync.value;
      if (goal == null) return Stream<ReadingGoalProgress?>.value(null);
      return engine.watchReadingGoalProgress(
        target: goal.target,
        period: goal.period,
      );
    });
