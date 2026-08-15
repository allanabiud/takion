import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/core/network/request_priority.dart"
    show backgroundZoneKey;
import "package:takion/src/presentation/features/library/providers/library_items_serialization.dart";
import "package:takion/src/presentation/providers/providers.dart";

class SubscriptionCardsHydrater {
  SubscriptionCardsHydrater(this.ref);

  static const _maxHydrationConcurrency = 4;
  static const _issueFetchLimit = 200;
  static const _minBurstRemainingToHydrate = 5;
  static const _retryDelay = Duration(seconds: 60);
  static const _maxRetryAttempts = 3;

  final Ref ref;

  final Map<int, int> _retryAttempts = {};
  final Set<int> _pendingRetry = {};
  Timer? _retryTimer;

  Future<void> hydrate(List<int> seriesIds) async {
    if (seriesIds.isEmpty) return;

    final status = ref.read(connectivityStatusProvider).value;
    if (status == AppConnectivityStatus.offline) return;

    if (!_hasBudget()) {
      _scheduleRetry(seriesIds);
      return;
    }

    final localCatalog = ref.read(localCatalogRepositoryProvider);
    final repository = ref.read(metronRepositoryProvider);

    final missingIds = <int>[];
    for (final seriesId in seriesIds) {
      final series = await localCatalog.getSeries(seriesId);
      final issues = await localCatalog.getIssuesBySeries(seriesId, limit: 1);
      if (series == null || series.name.trim().isEmpty || issues.isEmpty) {
        missingIds.add(seriesId);
      } else {
        _retryAttempts.remove(seriesId);
      }
    }
    if (missingIds.isEmpty) return;

    final failedIds = <int>[];
    await _runInBackground(() => mapWithConcurrency(
          missingIds,
          (seriesId) async {
            try {
              await repository.getSeriesDetails(seriesId);
              await repository.getSeriesIssueList(
                seriesId,
                page: 1,
                limit: _issueFetchLimit,
              );
              _retryAttempts.remove(seriesId);
            } catch (e) {
              failedIds.add(seriesId);
              AppLogger.warning(
                "Failed to hydrate subscription card for series $seriesId",
                error: e,
              );
            }
          },
          maxConcurrency: _maxHydrationConcurrency,
        ));

    if (failedIds.isNotEmpty) {
      _scheduleRetry(failedIds);
    }
  }

  void _scheduleRetry(Iterable<int> seriesIds) {
    final due = <int>[];
    for (final seriesId in seriesIds) {
      final attempts = _retryAttempts[seriesId] ?? 0;
      if (attempts >= _maxRetryAttempts) continue;
      _retryAttempts[seriesId] = attempts + 1;
      due.add(seriesId);
    }
    if (due.isEmpty) return;
    _pendingRetry.addAll(due);
    _retryTimer ??= Timer(_retryDelay, () {
      _retryTimer = null;
      final batch = _pendingRetry.toList(growable: false);
      _pendingRetry.clear();
      unawaited(hydrate(batch));
    });
  }

  bool _hasBudget() {
    final interceptor = ref.read(rateLimitInterceptorProvider);
    return interceptor.state.burstRemaining >= _minBurstRemainingToHydrate;
  }

  Future<T> _runInBackground<T>(Future<T> Function() task) {
    return runZoned(() => task(), zoneValues: {backgroundZoneKey: true});
  }
}

final subscriptionCardsHydraterProvider = Provider<SubscriptionCardsHydrater>(
  SubscriptionCardsHydrater.new,
);
