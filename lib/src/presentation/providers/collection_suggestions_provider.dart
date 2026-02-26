import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/repositories/metron_repository.dart';
import 'package:takion/src/presentation/providers/repository_providers.dart';

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
  MetronRepository repository,
  bool Function(CollectionItem item) predicate, {
  required String emptyError,
}) async {
  final random = Random();

  final firstPage = await repository.getCollectionItems(page: 1);
  final firstMatches = firstPage.results.where(predicate).toList();

  if (firstPage.results.isEmpty) {
    throw StateError('No collection items found.');
  }

  final pageSize = firstPage.results.length;
  final totalPages =
      pageSize > 0 ? ((firstPage.count / pageSize).ceil()).clamp(1, 9999) : 1;

  if (totalPages == 1 && firstMatches.isNotEmpty) {
    return firstMatches[random.nextInt(firstMatches.length)];
  }

  final attemptedPages = <int>{1};
  const maxAttempts = 6;
  final attempts = totalPages < maxAttempts ? totalPages : maxAttempts;

  for (var attempt = 0; attempt < attempts; attempt++) {
    int page;
    if (attempt == 0) {
      page = 1;
    } else {
      do {
        page = random.nextInt(totalPages) + 1;
      } while (attemptedPages.contains(page) &&
          attemptedPages.length < totalPages);
    }

    attemptedPages.add(page);
    final pageData = page == 1
        ? firstPage
        : await repository.getCollectionItems(page: page);
    final matches = pageData.results.where(predicate).toList();

    if (matches.isNotEmpty) {
      return matches[random.nextInt(matches.length)];
    }
  }

  if (firstMatches.isNotEmpty) {
    return firstMatches[random.nextInt(firstMatches.length)];
  }

  throw StateError(emptyError);
}

Future<IssueList> _toSuggestionIssueList(
  MetronRepository repository,
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

  String? imageUrl;
  final directImage = issue?.image?.trim();
  if (directImage != null && directImage.isNotEmpty) {
    imageUrl = directImage;
  } else if (issueId != null && issueId > 0) {
    try {
      final details = await repository.getIssueDetails(issueId);
      imageUrl = details.image;
    } catch (_) {
      imageUrl = null;
    }
  }

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
  MetronRepository repository,
  CollectionItem item, {
  required String fallbackName,
}) async {
  final issueList = await _toSuggestionIssueList(
    repository,
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
  final repository = ref.watch(metronRepositoryProvider);
  try {
    return await _randomCollectionItemByPredicate(
      repository,
      (item) => !item.isRead,
      emptyError: 'No unread issues found in your collection.',
    );
  } on StateError {
    return null;
  }
});

final readingSuggestionIssueProvider =
    FutureProvider.autoDispose<SuggestionIssueTileData?>((ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  final item = await ref.watch(readingSuggestionProvider.future);
  if (item == null) return null;
  return _toSuggestionTileData(
    repository,
    item,
    fallbackName: 'Unread issue',
  );
});

final rateSuggestionProvider =
    FutureProvider.autoDispose<CollectionItem?>((ref) async {
  final repository = ref.watch(metronRepositoryProvider);
  try {
    return await _randomCollectionItemByPredicate(
      repository,
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
  final repository = ref.watch(metronRepositoryProvider);
  final item = await ref.watch(rateSuggestionProvider.future);
  if (item == null) return null;
  return _toSuggestionTileData(
    repository,
    item,
    fallbackName: 'Unrated issue',
  );
});
