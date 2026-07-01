import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/library_item.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

const _maxHydrationConcurrency = 4;

String _ownershipToStorage(LibraryOwnershipStatus status) {
  switch (status) {
    case LibraryOwnershipStatus.owned:
      return 'owned';
    case LibraryOwnershipStatus.notOwned:
      return 'not_owned';
    case LibraryOwnershipStatus.wishlist:
      return 'wishlist';
  }
}

LibraryOwnershipStatus? _ownershipFromStorage(String value) {
  switch (value) {
    case 'owned':
      return LibraryOwnershipStatus.owned;
    case 'not_owned':
      return LibraryOwnershipStatus.notOwned;
    case 'wishlist':
      return LibraryOwnershipStatus.wishlist;
  }
  return null;
}

String _formatToStorage(LibraryItemFormat format) {
  switch (format) {
    case LibraryItemFormat.print:
      return 'print';
    case LibraryItemFormat.digital:
      return 'digital';
    case LibraryItemFormat.both:
      return 'both';
  }
}

LibraryItemFormat? _formatFromStorage(String value) {
  switch (value) {
    case 'print':
      return LibraryItemFormat.print;
    case 'digital':
      return LibraryItemFormat.digital;
    case 'both':
      return LibraryItemFormat.both;
  }
  return null;
}

Map<String, dynamic> libraryItemToJson(LibraryItem item) {
  return {
    'id': item.id,
    'user_id': item.userId,
    'metron_issue_id': item.metronIssueId,
    'metron_series_id': item.metronSeriesId,
    'ownership_status': _ownershipToStorage(item.ownershipStatus),
    'is_read': item.isRead,
    'rating': item.rating,
    'purchase_date': item.purchaseDate?.toIso8601String(),
    'price_paid': item.pricePaid,
    'quantity_owned': item.quantityOwned,
    'format': _formatToStorage(item.format),
    'first_read_at': item.firstReadAt?.toIso8601String(),
    'condition_grade': item.conditionGrade,
    'acquired_on': item.acquiredOn?.toIso8601String(),
    'notes': item.notes,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };
}

LibraryItem? libraryItemFromJson(Map<String, dynamic> json) {
  final id = json['id'] as String?;
  final userId = json['user_id'] as String?;
  final metronIssueId = (json['metron_issue_id'] as num?)?.toInt();
  final metronSeriesId = (json['metron_series_id'] as num?)?.toInt();
  final ownershipStatus = _ownershipFromStorage(
    json['ownership_status'] as String? ?? '',
  );
  final format = _formatFromStorage(json['format'] as String? ?? '');
  final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '');
  final updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  if (id == null ||
      userId == null ||
      metronIssueId == null ||
      metronSeriesId == null ||
      ownershipStatus == null ||
      format == null ||
      createdAt == null ||
      updatedAt == null) {
    return null;
  }

  return LibraryItem(
    id: id,
    userId: userId,
    metronIssueId: metronIssueId,
    metronSeriesId: metronSeriesId,
    ownershipStatus: ownershipStatus,
    isRead: json['is_read'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toInt(),
    purchaseDate: DateTime.tryParse(json['purchase_date'] as String? ?? ''),
    pricePaid: (json['price_paid'] as num?)?.toDouble(),
    quantityOwned: (json['quantity_owned'] as num?)?.toInt() ?? 1,
    format: format,
    firstReadAt: DateTime.tryParse(json['first_read_at'] as String? ?? ''),
    conditionGrade: json['condition_grade'] as String?,
    acquiredOn: DateTime.tryParse(json['acquired_on'] as String? ?? ''),
    notes: json['notes'] as String?,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

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
            : 'Series ${item.metronSeriesId}',
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
    if (details == null) {
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
  } catch (_) {
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
}
