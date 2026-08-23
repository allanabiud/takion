import "package:flutter/foundation.dart" show compute;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:takion/src/domain/entities.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/core/logging/app_logger.dart";
import "package:takion/src/presentation/features/library/providers/category_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart";

const _maxHydrationConcurrency = 4;
const _isolateHydrationThreshold = 500;

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
            : "",
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
    bookFormat: item.format.name,
    grade: item.conditionGrade == null
        ? null
        : double.tryParse(item.conditionGrade!.trim()),
    purchaseDate: item.purchaseDate ?? item.acquiredOn,
    isRead: item.isRead,
    readCount: item.isRead ? 1 : 0,
    rating: item.rating,
    modified: item.updatedAt,
    ownershipStatus: item.ownershipStatus,
    pricePaid: item.pricePaid,
    firstReadAt: item.firstReadAt,
    acquiredOn: item.acquiredOn,
    notes: item.notes,
  );
}

CollectionItem hydratedRowToCollectionItem(
  dynamic row, {
  Map<int, double>? priceBackfill,
}) {
  final d = row.libraryItem;
  final issue = row.issue;
  final series = row.series;

  if (priceBackfill != null &&
      d.pricePaid == null &&
      issue != null &&
      issue.price != null) {
    final coverPrice = double.tryParse(issue.price!);
    if (coverPrice != null && coverPrice > 0) {
      priceBackfill[d.metronIssueId] = coverPrice;
    }
  }

  final domainItem = LibraryItem(
    id: d.id,
    userId: d.userId,
    metronIssueId: d.metronIssueId,
    metronSeriesId: d.metronSeriesId,
    ownershipStatus: d.ownershipStatus == "owned"
        ? LibraryOwnershipStatus.owned
        : (d.ownershipStatus == "wishlist"
              ? LibraryOwnershipStatus.wishlist
              : LibraryOwnershipStatus.notOwned),
    isRead: d.isRead,
    rating: d.rating,
    purchaseDate: d.purchaseDate != null
        ? DateTime.tryParse(d.purchaseDate!)
        : null,
    pricePaid: d.pricePaid,
    quantityOwned: d.quantityOwned,
    format: d.format == "digital"
        ? LibraryItemFormat.digital
        : (d.format == "both"
              ? LibraryItemFormat.both
              : LibraryItemFormat.print),
    firstReadAt: d.firstReadAt != null
        ? DateTime.tryParse(d.firstReadAt!)
        : null,
    conditionGrade: d.conditionGrade,
    acquiredOn: d.acquiredOn != null ? DateTime.tryParse(d.acquiredOn!) : null,
    notes: d.notes,
    createdAt: DateTime.tryParse(d.createdAt) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(d.updatedAt) ?? DateTime.now(),
  );

  return toCollectionItem(
    domainItem,
    series?.id ?? (d.metronSeriesId > 0 ? d.metronSeriesId : null),
    series?.name,
    series?.volume,
    series?.yearBegan,
    issue?.number ?? "",
    issue?.imageUrl,
    issue?.coverDate != null ? DateTime.tryParse(issue!.coverDate!) : null,
    issue?.storeDate != null ? DateTime.tryParse(issue!.storeDate!) : null,
    issue?.modified != null ? DateTime.tryParse(issue!.modified!) : null,
  );
}

void schedulePriceBackfill(Ref ref, Map<int, double> priceBackfill) {
  if (priceBackfill.isEmpty) return;
  Future.microtask(() async {
    try {
      final repo = ref.read(libraryRepositoryProvider);
      await repo.batchUpdatePricePaid(priceBackfill);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(libraryBasicStatsProvider);
      ref.invalidate(libraryEntityStatsProvider);
      ref.invalidate(libraryReadingTrendsProvider);
      ref.invalidate(libraryRecentlyFinishedProvider);
      ref.invalidate(categoryInsightsProvider);
    } catch (e) {
      AppLogger.warning("Failed to batch backfill cover prices", error: e);
    }
  });
}

Future<List<CollectionItem>> hydrateLibraryItems(
  Ref ref,
  List<LibraryItem> items, {
  bool applyPriceBackfill = true,
}) async {
  if (items.isEmpty) return <CollectionItem>[];
  final localCatalog = ref.read(localCatalogRepositoryProvider);

  final issueIds = <int>{};
  final seriesIds = <int>{};
  for (final item in items) {
    if (item.metronIssueId > 0) issueIds.add(item.metronIssueId);
    if (item.metronSeriesId > 0) seriesIds.add(item.metronSeriesId);
  }

  final issues = await localCatalog.getIssuesByIds(issueIds.toList());
  for (final issue in issues.values) {
    if (issue.seriesId != null && issue.seriesId! > 0) {
      seriesIds.add(issue.seriesId!);
    }
  }
  final seriesMap = await localCatalog.getSeriesByIds(seriesIds.toList());

  final (results, priceBackfill) = items.length > _isolateHydrationThreshold
      ? await compute(
          _buildCollectionItems,
          _HydrationBatch(items, issues, seriesMap, applyPriceBackfill),
        )
      : _buildCollectionItems(
          _HydrationBatch(items, issues, seriesMap, applyPriceBackfill),
        );

  if (applyPriceBackfill && priceBackfill.isNotEmpty) {
    try {
      final repo = ref.read(libraryRepositoryProvider);
      await repo.batchUpdatePricePaid(priceBackfill);
      ref.invalidate(collectionStatsProvider);
      ref.invalidate(libraryBasicStatsProvider);
      ref.invalidate(libraryEntityStatsProvider);
      ref.invalidate(libraryReadingTrendsProvider);
      ref.invalidate(libraryRecentlyFinishedProvider);
      ref.invalidate(categoryInsightsProvider);
    } catch (e) {
      AppLogger.warning("Failed to batch backfill cover prices", error: e);
    }
  }

  return results;
}

class _HydrationBatch {
  const _HydrationBatch(
    this.items,
    this.issues,
    this.seriesMap,
    this.applyPriceBackfill,
  );

  final List<LibraryItem> items;
  final Map<int, LocalIssue> issues;
  final Map<int, SeriesList> seriesMap;
  final bool applyPriceBackfill;
}

(List<CollectionItem>, Map<int, double>) _buildCollectionItems(
  _HydrationBatch batch,
) {
  final priceBackfill = <int, double>{};
  final results = <CollectionItem>[];

  for (final item in batch.items) {
    final issue = batch.issues[item.metronIssueId];
    SeriesList? series;
    if (issue?.seriesId != null) {
      series = batch.seriesMap[issue!.seriesId];
    }
    series ??= batch.seriesMap[item.metronSeriesId];

    if (batch.applyPriceBackfill &&
        item.pricePaid == null &&
        issue != null &&
        issue.price != null) {
      final coverPrice = double.tryParse(issue.price!);
      if (coverPrice != null && coverPrice > 0) {
        priceBackfill[item.metronIssueId] = coverPrice;
      }
    }

    results.add(
      toCollectionItem(
        item,
        series?.id ?? (item.metronSeriesId > 0 ? item.metronSeriesId : null),
        series?.name,
        series?.volume,
        series?.yearBegan,
        issue?.number ?? "",
        issue?.imageUrl,
        issue?.coverDate,
        issue?.storeDate,
        issue?.modified,
      ),
    );
  }

  return (results, priceBackfill);
}
