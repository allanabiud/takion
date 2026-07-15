import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

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
  final localDataSource = ref.read(metronLocalDataSourceProvider);

  try {
    final details = await localDataSource.getIssueDetails(item.metronIssueId);
    if (details != null) {
      return toCollectionItem(
        item,
        details.series?.name,
        details.series?.volume,
        details.series?.yearBegan,
        details.number,
        details.image,
        details.coverDate != null ? DateTime.tryParse(details.coverDate!) : null,
        details.storeDate != null ? DateTime.tryParse(details.storeDate!) : null,
        details.modified != null ? DateTime.tryParse(details.modified!) : null,
      );
    }
  } catch (_) {
    // Fall through to series details lookup
  }

  try {
    final seriesDetails =
        await localDataSource.getSeriesDetails(item.metronSeriesId);
    if (seriesDetails != null) {
      return toCollectionItem(
        item,
        seriesDetails.name,
        seriesDetails.volume,
        seriesDetails.yearBegan,
        '',
        null,
        null,
        null,
        null,
      );
    }
  } catch (_) {
    // Fall through to fallback
  }

  return toCollectionItem(
    item,
    null,
    null,
    null,
    '',
    null,
    null,
    null,
    null,
  );
}
