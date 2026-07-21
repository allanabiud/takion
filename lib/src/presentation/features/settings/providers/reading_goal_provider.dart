import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';

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
  static const _boxName = 'settings_box';
  static const _targetKey = 'reading_goal_target';
  static const _periodKey = 'reading_goal_period';

  @override
  Future<ReadingGoal?> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final target = box.get(_targetKey) as int?;
    final period = box.get(_periodKey) as String?;
    if (target == null || period == null) return null;
    return ReadingGoal(target: target, period: period);
  }

  Future<void> setGoal(ReadingGoal goal) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_targetKey, goal.target);
    await box.put(_periodKey, goal.period);
    state = AsyncValue.data(goal);
  }

  Future<void> clearGoal() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.delete(_targetKey);
    await box.delete(_periodKey);
    state = const AsyncValue.data(null);
  }
}
