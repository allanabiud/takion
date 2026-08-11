import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/network/request_priority.dart'
    show backgroundZoneKey;
import 'package:takion/src/presentation/features/library/providers/library_items_serialization.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class SubscriptionCardsHydrater {
  SubscriptionCardsHydrater(this.ref);

  static const _maxHydrationConcurrency = 4;
  static const _issueFetchLimit = 200;
  static const _minBurstRemainingToHydrate = 5;

  final Ref ref;

  Future<void> hydrate(List<int> seriesIds) async {
    if (seriesIds.isEmpty) return;

    final status = ref.read(connectivityStatusProvider).value;
    if (status == AppConnectivityStatus.offline) return;

    if (!_hasBudget()) return;

    final dao = ref.read(metronEntityDaoProvider);
    final repository = ref.read(metronRepositoryProvider);

    final missingIds = <int>[];
    for (final seriesId in seriesIds) {
      final series = await dao.getSeries(seriesId);
      final issues = await dao.getIssuesBySeries(seriesId, limit: 1);
      if (series == null || series.name.trim().isEmpty || issues.isEmpty) {
        missingIds.add(seriesId);
      }
    }
    if (missingIds.isEmpty) return;

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
            } catch (e) {
              AppLogger.warning(
                'Failed to hydrate subscription card for series $seriesId',
                error: e,
              );
            }
          },
          maxConcurrency: _maxHydrationConcurrency,
        ));
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
  (ref) => SubscriptionCardsHydrater(ref),
);
