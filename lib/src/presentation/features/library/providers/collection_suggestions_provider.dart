import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';

class SuggestionIssueTileData {
  const SuggestionIssueTileData({
    required this.issue,
    required this.collectionItemId,
    required this.isCollected,
    required this.isRead,
    this.rating,
  });

  final IssueList issue;
  final int collectionItemId;
  final bool isCollected;
  final bool isRead;
  final int? rating;
}

LibraryItem _randomLibraryItemByPredicate(
  List<LibraryItem> items,
  bool Function(LibraryItem item) predicate, {
  required String emptyError,
}) {
  final random = Random();

  if (items.isEmpty) {
    throw StateError('No collection items found.');
  }

  final matches = items.where(predicate).toList();
  if (matches.isNotEmpty) {
    return matches[random.nextInt(matches.length)];
  }

  throw StateError(emptyError);
}

LibraryItem _pickStableUnreadSuggestion(List<LibraryItem> items) {
  final unread = items.where((item) {
    final isCollected = item.ownershipStatus == LibraryOwnershipStatus.owned;
    final isWishlisted =
        item.ownershipStatus == LibraryOwnershipStatus.wishlist;
    return isCollected && !item.isRead && !isWishlisted;
  }).toList();
  if (unread.isEmpty) {
    throw StateError(
      'No collected and unread issues found in your collection.',
    );
  }

  // Keep only the first unread issue per series (by lowest metronIssueId)
  final earliestBySeries = <int, LibraryItem>{};
  for (final item in unread) {
    final existing = earliestBySeries[item.metronSeriesId];
    if (existing == null || item.metronIssueId < existing.metronIssueId) {
      earliestBySeries[item.metronSeriesId] = item;
    }
  }

  final candidates = earliestBySeries.values.toList();
  candidates.sort((a, b) {
    final byUpdated = b.updatedAt.compareTo(a.updatedAt);
    if (byUpdated != 0) return byUpdated;
    return a.metronIssueId.compareTo(b.metronIssueId);
  });
  return candidates.first;
}

Future<IssueList> _toSuggestionIssueList(Ref ref, LibraryItem item) async {
  final catalogRepository = ref.read(catalogRepositoryProvider);
  try {
    final details = await catalogRepository.getIssueDetails(item.metronIssueId);
    final seriesName = details.series?.name.trim();
    final issueNumber = details.number.trim();
    final title = seriesName != null && seriesName.isNotEmpty
        ? '$seriesName #$issueNumber'
        : (issueNumber.isNotEmpty
              ? 'Issue #$issueNumber'
              : 'Issue #${item.metronIssueId}');

    return IssueList(
      id: details.id,
      name: title,
      number: details.number,
      series: details.series == null
          ? null
          : Series(
              id: details.series!.id,
              name: details.series!.name,
              volume: details.series!.volume,
              yearBegan: details.series!.yearBegan,
              publisherName: details.publisher?.name,
              description: details.description,
            ),
      coverDate: details.coverDate,
      storeDate: details.storeDate,
      image: details.image,
      modified: details.modified,
    );
  } catch (_) {
    return IssueList(
      id: item.metronIssueId,
      name: 'Issue #${item.metronIssueId}',
      number: '',
      series: Series(
        id: item.metronSeriesId,
        name: 'Series ${item.metronSeriesId}',
        volume: null,
        yearBegan: null,
      ),
      coverDate: null,
      storeDate: null,
      image: null,
      modified: item.updatedAt,
    );
  }
}

Future<SuggestionIssueTileData> _toSuggestionTileData(
  Ref ref,
  LibraryItem item,
) async {
  return SuggestionIssueTileData(
    issue: await _toSuggestionIssueList(ref, item),
    collectionItemId: item.id.hashCode,
    isCollected:
        item.ownershipStatus == LibraryOwnershipStatus.owned &&
        item.quantityOwned > 0,
    isRead: item.isRead,
    rating: item.rating,
  );
}

final readingSuggestionProvider = FutureProvider<LibraryItem?>((ref) async {
  final items = await ref.watch(allLibraryItemsProvider.future);
  try {
    return _pickStableUnreadSuggestion(items);
  } on StateError {
    return null;
  }
});

final readingSuggestionIssueProvider = FutureProvider<SuggestionIssueTileData?>(
  (ref) async {
    final item = await ref.watch(readingSuggestionProvider.future);
    if (item == null) return null;
    return _toSuggestionTileData(ref, item);
  },
);

final rateSuggestionProvider = FutureProvider<LibraryItem?>((ref) async {
  final items = await ref.watch(allLibraryItemsProvider.future);
  try {
    return _randomLibraryItemByPredicate(items, (item) {
      final rating = item.rating;
      return item.isRead && (rating == null || rating <= 0);
    }, emptyError: 'No read and unrated issues found in your collection.');
  } on StateError {
    return null;
  }
});

final rateSuggestionIssueProvider = FutureProvider<SuggestionIssueTileData?>((
  ref,
) async {
  final item = await ref.watch(rateSuggestionProvider.future);
  if (item == null) return null;
  return _toSuggestionTileData(ref, item);
});
