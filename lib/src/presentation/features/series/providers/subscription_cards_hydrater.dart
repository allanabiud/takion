import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/data/common/drift/daos/metron_entity_dao.dart';
import 'package:takion/src/presentation/features/library/providers/library_items_serialization.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class SubscriptionCardsHydrater {
  SubscriptionCardsHydrater(this.ref);

  static const _maxHydrationConcurrency = 4;
  static const _issueFetchLimit = 200;

  final Ref ref;

  Future<void> hydrate(List<int> seriesIds) async {
    if (seriesIds.isEmpty) return;

    final status = ref.read(connectivityStatusProvider).value;
    if (status == AppConnectivityStatus.offline) return;

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

    await mapWithConcurrency(
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
    );
  }

  Future<void> warmCoverImages(
    BuildContext context,
    List<int> seriesIds,
  ) async {
    if (seriesIds.isEmpty) return;

    final dao = ref.read(metronEntityDaoProvider);
    for (final seriesId in seriesIds) {
      final imageUrl = await _mostRecentImageUrl(dao, seriesId);
      if (imageUrl == null || imageUrl.trim().isEmpty) continue;
      if (!context.mounted) return;
      try {
        await precacheImage(
          CachedNetworkImageProvider(imageUrl.trim()),
          context,
        );
      } catch (e) {
        AppLogger.debug(
          'Failed to pre-cache cover for series $seriesId',
          error: e,
        );
      }
    }
  }

  Future<String?> _mostRecentImageUrl(
    MetronEntityDao dao,
    int seriesId,
  ) async {
    final issues = await dao.getIssuesBySeries(seriesId, limit: _issueFetchLimit);
    for (final issue in issues) {
      final url = issue.imageUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }
}

final subscriptionCardsHydraterProvider = Provider<SubscriptionCardsHydrater>(
  (ref) => SubscriptionCardsHydrater(ref),
);
