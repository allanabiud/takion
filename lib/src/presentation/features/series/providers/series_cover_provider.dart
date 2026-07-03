import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/cache/entity_image_cache.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

const _seriesCoverCacheBoxName = 'series_cover_cache_box';
const _seriesCoverCacheMetaPrefix = 'series_cover:';
const _seriesCoverEmptySentinel = '__none__';
const _seriesCoverCacheTtl = Duration(days: 14);
const seriesCoverFetchBudgetPerSession = 12;

String _seriesCoverMetaKey(int seriesId) =>
    '$_seriesCoverCacheMetaPrefix$seriesId';

DateTime? _cachedAtFromEpoch(int? epoch) {
  if (epoch == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(epoch);
}

bool _isFresh(DateTime? cachedAt) {
  if (cachedAt == null) return false;
  return DateTime.now().difference(cachedAt) <= _seriesCoverCacheTtl;
}

String? _firstIssueImage(Iterable<dynamic> issues) {
  for (final issue in issues) {
    final image = issue.image as String?;
    if (image != null && image.trim().isNotEmpty) {
      return image.trim();
    }
  }
  return null;
}

final seriesCoverImageProvider = FutureProvider.autoDispose
    .family<String?, ({int seriesId, bool allowRemoteFetch})>((
      ref,
      request,
    ) async {
      final seriesId = request.seriesId;
      final hiveService = ref.read(hiveServiceProvider);
      final coverBox = await hiveService.openBox<dynamic>(
        _seriesCoverCacheBoxName,
      );
      final metaBox = await hiveService.openBox<int>('cache_meta_box');
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;

      final cachedRaw = coverBox.get(seriesId);
      final hasCached = coverBox.containsKey(seriesId);
      final cachedAt = _cachedAtFromEpoch(
        metaBox.get(_seriesCoverMetaKey(seriesId)),
      );
      final cachedCover = switch (cachedRaw) {
        final String value when value == _seriesCoverEmptySentinel => null,
        final String value => value.trim().isEmpty ? null : value.trim(),
        _ => null,
      };

      if (hasCached && _isFresh(cachedAt)) {
        if (cachedCover != null) {
          final entityCache = ref.read(entityImageCacheProvider);
          if (entityCache.getCached('series', seriesId) == null) {
            entityCache.set('series', seriesId, cachedCover).then((_) {
              ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
            });
          }
        }
        return cachedCover;
      }

      final localDataSource = ref.read(metronLocalDataSourceProvider);
      final localIssues = await localDataSource.getSeriesIssueListResults(
        seriesId,
        page: 1,
        limit: metronDefaultPageSize,
      );
      final localCover = localIssues == null
          ? null
          : _firstIssueImage(localIssues);
      if (localCover != null) {
        await coverBox.put(seriesId, localCover);
        await metaBox.put(_seriesCoverMetaKey(seriesId), nowEpoch);
        final entityCache = ref.read(entityImageCacheProvider);
        await entityCache.set('series', seriesId, localCover);
        ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
        return localCover;
      }

      if (!request.allowRemoteFetch) {
        return cachedCover;
      }

      final metronRepository = ref.read(metronRepositoryProvider);
      final remotePage = await metronRepository.getSeriesIssueList(
        seriesId,
        page: 1,
      );
      final remoteCover = _firstIssueImage(remotePage.results);

      if (remoteCover != null) {
        await coverBox.put(seriesId, remoteCover);
        final entityCache = ref.read(entityImageCacheProvider);
        await entityCache.set('series', seriesId, remoteCover);
        ref.read(entityImageVersionProvider.notifier).update((s) => s + 1);
      } else if (!hasCached) {
        await coverBox.put(seriesId, _seriesCoverEmptySentinel);
      }
      await metaBox.put(_seriesCoverMetaKey(seriesId), nowEpoch);

      return remoteCover ?? cachedCover;
    });
