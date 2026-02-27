import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/presentation/providers/collection_items_provider.dart';

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

Future<CollectionItem> _randomCollectionItemByPredicate(
  List<CollectionItem> items,
  bool Function(CollectionItem item) predicate, {
  required String emptyError,
}) async {
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

Future<IssueList> _toSuggestionIssueList(
  CollectionItem item, {
  required String fallbackName,
}) async {
  final issue = item.issue;
  final seriesRef = issue?.series;
  final seriesName = seriesRef?.name.trim();
  final issueNumber = issue?.number.trim() ?? '';
  final issueId = issue?.id;

  String suggestionName() {
    if (seriesName != null && seriesName.isNotEmpty) {
      return '$seriesName #$issueNumber';
    }
    if (issueNumber.isNotEmpty) {
      return 'Issue #$issueNumber';
    }
    return fallbackName;
  }

  final imageUrl = issue?.image?.trim();

  return IssueList(
    id: issueId,
    name: suggestionName(),
    number: issueNumber,
    series: seriesRef == null
        ? null
        : Series(
            id: null,
            name: seriesRef.name,
            volume: seriesRef.volume,
            yearBegan: seriesRef.yearBegan,
          ),
    coverDate: issue?.coverDate,
    storeDate: issue?.storeDate,
    image: imageUrl,
    modified: issue?.modified,
  );
}

Future<SuggestionIssueTileData> _toSuggestionTileData(
  CollectionItem item, {
  required String fallbackName,
}) async {
  final issueList = await _toSuggestionIssueList(
    item,
    fallbackName: fallbackName,
  );

  return SuggestionIssueTileData(
    issue: issueList,
    collectionItemId: item.id,
    isCollected: item.quantity > 0,
    isRead: item.isRead,
    rating: item.rating,
  );
}

final readingSuggestionProvider =
    FutureProvider.autoDispose<CollectionItem?>((ref) async {
  final items = await ref.watch(allCollectionItemsProvider.future);
  try {
    return await _randomCollectionItemByPredicate(
      items,
      (item) => !item.isRead,
      emptyError: 'No unread issues found in your collection.',
    );
  } on StateError {
    return null;
  }
});

final readingSuggestionIssueProvider =
    FutureProvider.autoDispose<SuggestionIssueTileData?>((ref) async {
  final item = await ref.watch(readingSuggestionProvider.future);
  if (item == null) return null;
  return _toSuggestionTileData(item, fallbackName: 'Unread issue');
});

final rateSuggestionProvider =
    FutureProvider.autoDispose<CollectionItem?>((ref) async {
  final items = await ref.watch(allCollectionItemsProvider.future);
  try {
    return await _randomCollectionItemByPredicate(
      items,
      (item) {
        final rating = item.rating;
        return item.isRead && (rating == null || rating <= 0);
      },
      emptyError: 'No read and unrated issues found in your collection.',
    );
  } on StateError {
    return null;
  }
});

final rateSuggestionIssueProvider =
    FutureProvider.autoDispose<SuggestionIssueTileData?>((ref) async {
  final item = await ref.watch(rateSuggestionProvider.future);
  if (item == null) return null;
  return _toSuggestionTileData(item, fallbackName: 'Unrated issue');
});
