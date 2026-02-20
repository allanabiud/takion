import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'dart:async';

class RateLimitInterceptor extends Interceptor {
  final int maxRequestsPerMinute;
  final int maxRequestsPerDay;
  final List<DateTime> _recentRequests = [];
  final _lock = Lock();
  
  static const String _statsBoxName = 'api_stats';
  static const String _dailyCountKey = 'daily_count';
  static const String _lastResetKey = 'last_reset_date';

  RateLimitInterceptor({
    this.maxRequestsPerMinute = 25, // Safer margin than 30
    this.maxRequestsPerDay = 9500,  // Safer margin than 10,000
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

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await _lock.synchronized(() async {
        await _checkDailyLimit();

        while (true) {
          final now = DateTime.now();
          // Clear requests older than 1 minute
          _recentRequests.removeWhere((time) => now.difference(time) > const Duration(minutes: 1));

          if (_recentRequests.length < maxRequestsPerMinute) {
            _recentRequests.add(now);
            await _incrementDailyCount();
            break;
          }

          // Wait until the oldest request in the window is older than 1 minute
          final sleepTime = const Duration(minutes: 1) - now.difference(_recentRequests.first);
          if (sleepTime > Duration.zero) {
            await Future.delayed(sleepTime + const Duration(milliseconds: 100));
          }
        }
      });
      handler.next(options);
    } catch (e) {
      if (e is DioException) {
        handler.reject(e);
      } else {
        handler.reject(DioException(requestOptions: options, error: e.toString()));
      }
    }
  }
}
