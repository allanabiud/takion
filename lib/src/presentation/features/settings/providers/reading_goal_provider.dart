import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/drift_database_provider.dart';

class ReadingGoal {
  final int target;
  final String period; // 'monthly' or 'yearly'

  const ReadingGoal({required this.target, required this.period});

  ReadingGoal copyWith({int? target, String? period}) {
    return ReadingGoal(
      target: target ?? this.target,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() => {'target': target, 'period': period};

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
    target: json['target'] as int,
    period: json['period'] as String,
  );
}

final readingGoalProvider =
    AsyncNotifierProvider<ReadingGoalNotifier, ReadingGoal?>(
      ReadingGoalNotifier.new,
    );

class ReadingGoalNotifier extends AsyncNotifier<ReadingGoal?> {
  static const _targetKey = 'reading_goal_target';
  static const _periodKey = 'reading_goal_period';

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
