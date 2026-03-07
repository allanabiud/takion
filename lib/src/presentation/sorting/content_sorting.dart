import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series_list.dart';

enum ContentSortOption { nameAsc, nameDesc, dateAsc, dateDesc }

enum SortPreferenceContext {
  searchIssues,
  searchSeries,
  browseIssues,
  browseRecentlyAdded,
  browseSeries,
  libraryMyComics,
  libraryWishlist,
  libraryUnrated,
  libraryRead,
  libraryUnread,
  libraryReadingHistory,
  seriesDetailsIssues,
  releasesWeekly,
  releasesFoc,
  releasesMyPulls,
  releasesNewFirst,
  continueReading,
  subscriptions,
}

extension SortPreferenceContextX on SortPreferenceContext {
  String get storageKey {
    switch (this) {
      case SortPreferenceContext.searchIssues:
        return 'search_issues';
      case SortPreferenceContext.searchSeries:
        return 'search_series';
      case SortPreferenceContext.browseIssues:
        return 'browse_issues';
      case SortPreferenceContext.browseRecentlyAdded:
        return 'browse_recently_added';
      case SortPreferenceContext.browseSeries:
        return 'browse_series';
      case SortPreferenceContext.libraryMyComics:
        return 'library_my_comics';
      case SortPreferenceContext.libraryWishlist:
        return 'library_wishlist';
      case SortPreferenceContext.libraryUnrated:
        return 'library_unrated';
      case SortPreferenceContext.libraryRead:
        return 'library_read';
      case SortPreferenceContext.libraryUnread:
        return 'library_unread';
      case SortPreferenceContext.libraryReadingHistory:
        return 'library_reading_history';
      case SortPreferenceContext.seriesDetailsIssues:
        return 'series_details_issues';
      case SortPreferenceContext.releasesWeekly:
        return 'releases_weekly';
      case SortPreferenceContext.releasesFoc:
        return 'releases_foc';
      case SortPreferenceContext.releasesMyPulls:
        return 'releases_my_pulls';
      case SortPreferenceContext.releasesNewFirst:
        return 'releases_new_first';
      case SortPreferenceContext.continueReading:
        return 'continue_reading';
      case SortPreferenceContext.subscriptions:
        return 'subscriptions';
    }
  }

  ContentSortOption get defaultOption {
    switch (this) {
      case SortPreferenceContext.searchIssues:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchSeries:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.browseIssues:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.browseRecentlyAdded:
        return ContentSortOption.dateDesc;
      case SortPreferenceContext.browseSeries:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryMyComics:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryWishlist:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryUnrated:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryRead:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryUnread:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.libraryReadingHistory:
        return ContentSortOption.dateDesc;
      case SortPreferenceContext.seriesDetailsIssues:
        return ContentSortOption.dateAsc;
      case SortPreferenceContext.releasesWeekly:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesFoc:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesMyPulls:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesNewFirst:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.continueReading:
        return ContentSortOption.dateDesc;
      case SortPreferenceContext.subscriptions:
        return ContentSortOption.nameAsc;
    }
  }
}

String issueSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Name (A–Z)';
    case ContentSortOption.nameDesc:
      return 'Name (Z–A)';
    case ContentSortOption.dateAsc:
      return 'Date (Oldest first)';
    case ContentSortOption.dateDesc:
      return 'Date (Newest first)';
  }
}

String seriesSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Name (A–Z)';
    case ContentSortOption.nameDesc:
      return 'Name (Z–A)';
    case ContentSortOption.dateAsc:
      return 'Year Began (Oldest first)';
    case ContentSortOption.dateDesc:
      return 'Year Began (Newest first)';
  }
}

List<IssueList> sortIssues(
  List<IssueList> issues,
  ContentSortOption sortOption,
) {
  final sorted = [...issues];

  int compareByName(IssueList a, IssueList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  DateTime? issueDate(IssueList issue) {
    return issue.storeDate ?? issue.coverDate ?? issue.modified;
  }

  int compareByDate(IssueList a, IssueList b) {
    final aDate = issueDate(a);
    final bDate = issueDate(b);
    if (aDate == null && bDate == null) return compareByName(a, b);
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    final dateCompare = aDate.compareTo(bDate);
    if (dateCompare != 0) return dateCompare;
    return compareByName(a, b);
  }

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateAsc:
      sorted.sort(compareByDate);
      break;
    case ContentSortOption.dateDesc:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
  }

  return sorted;
}

List<SeriesList> sortSeries(
  List<SeriesList> series,
  ContentSortOption sortOption,
) {
  final sorted = [...series];

  int compareByName(SeriesList a, SeriesList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  int compareByYear(SeriesList a, SeriesList b) {
    final aYear = a.yearBegan;
    final bYear = b.yearBegan;
    if (aYear == null && bYear == null) return compareByName(a, b);
    if (aYear == null) return 1;
    if (bYear == null) return -1;
    final yearCompare = aYear.compareTo(bYear);
    if (yearCompare != 0) return yearCompare;
    return compareByName(a, b);
  }

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateAsc:
      sorted.sort(compareByYear);
      break;
    case ContentSortOption.dateDesc:
      sorted.sort((a, b) => compareByYear(b, a));
      break;
  }

  return sorted;
}

String _collectionItemName(CollectionItem item) {
  final seriesName = item.issue?.series?.name.trim() ?? '';
  final issueNumber = item.issue?.number.trim() ?? '';
  if (seriesName.isEmpty && issueNumber.isEmpty) return '';
  return '$seriesName #$issueNumber'.trim();
}

DateTime? _collectionItemDate(CollectionItem item) {
  return item.modified ??
      item.purchaseDate ??
      item.issue?.storeDate ??
      item.issue?.coverDate ??
      item.issue?.modified;
}

List<CollectionItem> sortCollectionItems(
  List<CollectionItem> items,
  ContentSortOption sortOption,
) {
  final sorted = [...items];

  int compareByName(CollectionItem a, CollectionItem b) {
    return _collectionItemName(
      a,
    ).toLowerCase().compareTo(_collectionItemName(b).toLowerCase());
  }

  int compareByDate(CollectionItem a, CollectionItem b) {
    final aDate = _collectionItemDate(a);
    final bDate = _collectionItemDate(b);
    if (aDate == null && bDate == null) return compareByName(a, b);
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    final dateCompare = aDate.compareTo(bDate);
    if (dateCompare != 0) return dateCompare;
    return compareByName(a, b);
  }

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateAsc:
      sorted.sort(compareByDate);
      break;
    case ContentSortOption.dateDesc:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
  }

  return sorted;
}

List<T> sortItemsByNameAndDate<T>(
  List<T> items, {
  required ContentSortOption sortOption,
  required String Function(T item) nameOf,
  required DateTime? Function(T item) dateOf,
}) {
  final sorted = [...items];

  int compareByName(T a, T b) {
    return nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase());
  }

  int compareByDate(T a, T b) {
    final aDate = dateOf(a);
    final bDate = dateOf(b);
    if (aDate == null && bDate == null) return compareByName(a, b);
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    final dateCompare = aDate.compareTo(bDate);
    if (dateCompare != 0) return dateCompare;
    return compareByName(a, b);
  }

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateAsc:
      sorted.sort(compareByDate);
      break;
    case ContentSortOption.dateDesc:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
  }

  return sorted;
}
