import 'package:takion/src/domain/entities/series_subscription.dart';

abstract class SubscriptionRepository {
  Future<List<SeriesSubscription>> listSubscriptions({
    bool activeOnly = true,
    int limit = 100,
    int offset = 0,
  });

  Future<SeriesSubscription?> getSubscriptionBySeriesId(int metronSeriesId);

  Future<SeriesSubscription> subscribe({
    required int metronSeriesId,
    bool autoAddToPullList = true,
  });

  Future<void> unsubscribe(int metronSeriesId);

  Future<SeriesSubscription> setAutoAddToPullList({
    required int metronSeriesId,
    required bool enabled,
  });
}
