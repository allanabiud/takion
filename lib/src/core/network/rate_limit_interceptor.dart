import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'dart:async';

class RateLimitInterceptor extends Interceptor {
  final int maxRequestsPerMinute;
  final int maxRequestsPerDay;
  final _lock = Lock();

  static const String _statsBoxName = 'api_stats';
  static const String _dailyCountKey = 'daily_count';
  static const String _lastResetKey = 'last_reset_date';
  static const String _recentRequestsKey = 'recent_requests';

  RateLimitInterceptor({
    this.maxRequestsPerMinute = 18,
    this.maxRequestsPerDay = 4800,
  });

  Future<Box> _getStatsBox() async {
    return await Hive.openBox(_statsBoxName);
  }

  Future<void> _checkDailyLimit() async {
    final box = await _getStatsBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    final lastReset = box.get(_lastResetKey);
    if (lastReset != today) {
      await box.put(_lastResetKey, today);
      await box.put(_dailyCountKey, 0);
    }

    final count = box.get(_dailyCountKey, defaultValue: 0) as int;
    if (count >= maxRequestsPerDay) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Daily API limit reached. Please try again tomorrow.',
        type: DioExceptionType.cancel,
      );
    }
  }

  Future<void> _incrementDailyCount() async {
    final box = await _getStatsBox();
    final count = box.get(_dailyCountKey, defaultValue: 0) as int;
    await box.put(_dailyCountKey, count + 1);
  }

  // Returns null if budget was consumed and the request may proceed,
  // or a Duration to wait before retrying (caller waits outside the lock).
  Future<Duration?> _tryConsumeBudget() {
    return _lock.synchronized<Duration?>(() async {
      await _checkDailyLimit();

      final box = await _getStatsBox();
      final stored = box.get(_recentRequestsKey);
      final List<int> storedList =
          stored != null ? List<int>.from(stored as Iterable) : [];

      final now = DateTime.now();

      // Filter out requests older than 1 minute
      final recent = storedList
          .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
          .where((time) => now.difference(time) <= const Duration(minutes: 1))
          .toList();

      if (recent.length < maxRequestsPerMinute) {
        recent.add(now);
        await box.put(
          _recentRequestsKey,
          recent.map((time) => time.millisecondsSinceEpoch).toList(),
        );
        await _incrementDailyCount();
        return null;
      }

      final sleepTime =
          const Duration(minutes: 1) - now.difference(recent.first);
      return sleepTime > Duration.zero
          ? sleepTime + const Duration(milliseconds: 100)
          : const Duration(milliseconds: 100);
    });
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      while (true) {
        final wait = await _tryConsumeBudget();
        if (wait == null) break;
        // Wait outside the lock so other requests aren't blocked
        await Future.delayed(wait);
      }

      handler.next(options);
    } catch (e) {
      if (e is DioException) {
        handler.reject(e);
      } else {
        handler.reject(
          DioException(requestOptions: options, error: e.toString()),
        );
      }
    }
  }
}
