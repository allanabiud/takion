import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/data/common/drift/database.dart' hide LibraryItem;
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/presentation/features/library/providers/category_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart';
import 'package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart';

const _maxHydrationConcurrency = 4;

Future<List<R>> mapWithConcurrency<T, R>(
  List<T> items,
  Future<R> Function(T item) mapper, {
  int maxConcurrency = _maxHydrationConcurrency,
}) async {
  if (items.isEmpty) return <R>[];
  final results = List<R?>.filled(items.length, null);
  var cursor = 0;

  Future<void> worker() async {
    while (true) {
      final index = cursor;
      if (index >= items.length) return;
      cursor = index + 1;
      results[index] = await mapper(items[index]);
    }
  }

  final workers = List.generate(
    maxConcurrency.clamp(1, items.length),
    (_) => worker(),
  );
  await Future.wait(workers);
  return results.whereType<R>().toList(growable: false);
}

CollectionItem toCollectionItem(
  LibraryItem item,
  int? seriesId,
  String? seriesName,
  int? seriesVolume,
  int? seriesYearBegan,
  String issueNumber,
  String? issueImage,
  DateTime? coverDate,
  DateTime? storeDate,
  DateTime? modified,
) {
  return CollectionItem(
    id: item.id.hashCode,
    issue: CollectionIssueRef(
      id: item.metronIssueId,
      number: issueNumber,
      series: CollectionIssueSeriesRef(
        id: seriesId,
        name: (seriesName != null && seriesName.trim().isNotEmpty)
            ? seriesName.trim()
            : '',
        volume: seriesVolume,
        yearBegan: seriesYearBegan,
      ),
      image: issueImage,
      coverDate: coverDate,
      storeDate: storeDate,
      modified: modified,
    ),
    quantity: item.ownershipStatus == LibraryOwnershipStatus.owned
        ? item.quantityOwned
        : 0,
    grade: item.conditionGrade == null
        ? null
        : double.tryParse(item.conditionGrade!.trim()),
    purchaseDate: item.purchaseDate ?? item.acquiredOn,
    isRead: item.isRead,
    readCount: item.isRead ? 1 : 0,
    rating: item.rating,
    modified: item.updatedAt,
  );
}

Future<CollectionItem> enrichLibraryItem(Ref ref, LibraryItem item) async {
  final db = ref.read(driftDatabaseProvider);
  final repo = ref.read(libraryRepositoryProvider);

  try {
    final issue = await db.metronEntityDao.getIssue(item.metronIssueId);
    if (issue != null) {
      MetronSery? series;
      if (issue.seriesId != null) {
        series = await db.metronEntityDao.getSeries(issue.seriesId!);
      }
      if (item.pricePaid == null && issue.price != null) {
        final coverPrice = double.tryParse(issue.price!);
        if (coverPrice != null) {
          await repo.updateItemPricePaid(item.metronIssueId, coverPrice);
          try {
            ref.invalidate(collectionStatsProvider);
            ref.invalidate(libraryBasicStatsProvider);
            ref.invalidate(libraryEntityStatsProvider);
            ref.invalidate(libraryReadingTrendsProvider);
            ref.invalidate(libraryRecentlyFinishedProvider);
            ref.invalidate(categoryInsightsProvider);
          } catch (_) {}
        }
      }
      return toCollectionItem(
        item,
        series?.id ?? (item.metronSeriesId > 0 ? item.metronSeriesId : null),
        series?.name,
        series?.volume,
        series?.yearBegan,
        issue.number,
        issue.imageUrl,
        issue.coverDate != null ? DateTime.tryParse(issue.coverDate!) : null,
        issue.storeDate != null ? DateTime.tryParse(issue.storeDate!) : null,
        issue.modified != null ? DateTime.tryParse(issue.modified!) : null,
      );
    }
  } catch (e) {
    AppLogger.warning(
      'Failed to hydrate library item from issue details',
      error: e,
    );
  }

  String? seriesName;
  int? seriesVolume;
  int? seriesYearBegan;

  try {
    final seriesDetails = await db.metronEntityDao.getSeries(
      item.metronSeriesId,
    );
    if (seriesDetails != null) {
      seriesName = seriesDetails.name;
      seriesVolume = seriesDetails.volume;
      seriesYearBegan = seriesDetails.yearBegan;
    }
  } catch (e) {
    AppLogger.warning(
      'Failed to hydrate library item from local series details',
      error: e,
    );
  }

  if ((seriesName == null || seriesName.trim().isEmpty) &&
      item.metronSeriesId > 0) {
    try {
      final remoteSeries = await ref
          .read(metronRepositoryProvider)
          .getSeriesDetails(item.metronSeriesId);
      seriesName = remoteSeries.name;
      seriesVolume = remoteSeries.volume;
      seriesYearBegan = remoteSeries.yearBegan;
    } catch (e) {
      AppLogger.warning(
        'Failed to fetch remote series details for hydration',
        error: e,
      );
    }
  }

  return toCollectionItem(
    item,
    item.metronSeriesId > 0 ? item.metronSeriesId : null,
    seriesName,
    seriesVolume,
    seriesYearBegan,
    '',
    null,
    null,
    null,
    null,
  );
}
