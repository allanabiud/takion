import 'package:takion/src/domain/entities/character_list.dart';
import 'package:takion/src/domain/entities/creator_list.dart';
import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series_list.dart';
import 'package:takion/src/domain/entities/universe_list.dart';
import 'package:takion/src/domain/entities/imprint_list.dart';
import 'package:takion/src/domain/entities/team_list.dart';
import 'package:takion/src/domain/entities/publisher_list.dart';

enum ContentSortOption { nameAsc, nameDesc, dateNewest, dateOldest }

enum SortPreferenceContext {
  searchIssues,
  searchSeries,
  searchCharacters,
  searchCreators,
  searchUniverses,
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
  characterIssues,
  releasesWeekly,
  releasesFoc,
  releasesMyPulls,
  releasesNewFirst,
  continueReading,
  subscriptions,
  searchImprints,
  searchTeams,
  searchPublishers,
  publisherSeries,
}

extension SortPreferenceContextX on SortPreferenceContext {
  String get storageKey {
    switch (this) {
      case SortPreferenceContext.searchIssues:
        return 'search_issues';
      case SortPreferenceContext.searchSeries:
        return 'search_series';
      case SortPreferenceContext.searchCharacters:
        return 'search_characters';
      case SortPreferenceContext.searchCreators:
        return 'search_creators';
      case SortPreferenceContext.searchUniverses:
        return 'search_universes';
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
      case SortPreferenceContext.characterIssues:
        return 'character_issues_sort';
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
      case SortPreferenceContext.searchImprints:
        return 'search_imprints';
      case SortPreferenceContext.searchTeams:
        return 'search_teams';
      case SortPreferenceContext.searchPublishers:
        return 'search_publishers';
      case SortPreferenceContext.publisherSeries:
        return 'publisher_series';
    }
  }

  ContentSortOption get defaultOption {
    switch (this) {
      case SortPreferenceContext.searchIssues:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchSeries:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchCharacters:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchCreators:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchUniverses:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.browseIssues:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.browseRecentlyAdded:
        return ContentSortOption.dateNewest;
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
        return ContentSortOption.dateNewest;
      case SortPreferenceContext.seriesDetailsIssues:
        return ContentSortOption.dateNewest;
      case SortPreferenceContext.characterIssues:
        return ContentSortOption.dateOldest;
      case SortPreferenceContext.releasesWeekly:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesFoc:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesMyPulls:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.releasesNewFirst:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.continueReading:
        return ContentSortOption.dateNewest;
      case SortPreferenceContext.subscriptions:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchImprints:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchTeams:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.searchPublishers:
        return ContentSortOption.nameAsc;
      case SortPreferenceContext.publisherSeries:
        return ContentSortOption.nameAsc;
    }
  }
}

String issueSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String seriesSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String characterSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String creatorSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String universeSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String imprintSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String teamSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
  }
}

String publisherSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return 'Alphabetical (A-Z)';
    case ContentSortOption.nameDesc:
      return 'Alphabetical (Z-A)';
    case ContentSortOption.dateNewest:
      return 'Release Date (Newest)';
    case ContentSortOption.dateOldest:
      return 'Release Date (Oldest)';
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
    case ContentSortOption.dateNewest:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByDate);
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
    case ContentSortOption.dateNewest:
      sorted.sort((a, b) => compareByYear(b, a));
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByYear);
      break;
  }

  return sorted;
}

List<CharacterList> sortCharacters(
  List<CharacterList> characters,
  ContentSortOption sortOption,
) {
  final sorted = [...characters];

  int compareByName(CharacterList a, CharacterList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
      break;
  }

  return sorted;
}

List<CreatorList> sortCreators(
  List<CreatorList> creators,
  ContentSortOption sortOption,
) {
  final sorted = [...creators];

  int compareByName(CreatorList a, CreatorList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
      break;
  }

  return sorted;
}

List<UniverseList> sortUniverses(
  List<UniverseList> universes,
  ContentSortOption sortOption,
) {
  final sorted = [...universes];

  int compareByName(UniverseList a, UniverseList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
      break;
  }

  return sorted;
}

List<ImprintList> sortImprints(
  List<ImprintList> imprints,
  ContentSortOption sortOption,
) {
  final sorted = [...imprints];

  int compareByName(ImprintList a, ImprintList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
      break;
  }

  return sorted;
}

List<TeamList> sortTeams(
  List<TeamList> teams,
  ContentSortOption sortOption,
) {
  final sorted = [...teams];

  int compareByName(TeamList a, TeamList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
      break;
  }

  return sorted;
}

List<PublisherList> sortPublishers(
  List<PublisherList> publishers,
  ContentSortOption sortOption,
) {
  final sorted = [...publishers];

  int compareByName(PublisherList a, PublisherList b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  switch (sortOption) {
    case ContentSortOption.nameAsc:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.nameDesc:
      sorted.sort((a, b) => compareByName(b, a));
      break;
    case ContentSortOption.dateNewest:
      sorted.sort(compareByName);
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByName);
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
    case ContentSortOption.dateNewest:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByDate);
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
    case ContentSortOption.dateNewest:
      sorted.sort((a, b) => compareByDate(b, a));
      break;
    case ContentSortOption.dateOldest:
      sorted.sort(compareByDate);
      break;
  }

  return sorted;
}
