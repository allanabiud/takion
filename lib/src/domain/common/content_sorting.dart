import "package:takion/src/domain/entities.dart";

int naturalCompare(String a, String b) {
  final aLower = a.toLowerCase();
  final bLower = b.toLowerCase();
  var ai = 0;
  var bi = 0;

  while (ai < aLower.length && bi < bLower.length) {
    final aDigit = _isDigit(aLower[ai]);
    final bDigit = _isDigit(bLower[bi]);

    if (aDigit && bDigit) {
      var an = 0;
      while (ai < aLower.length && _isDigit(aLower[ai])) {
        an = an * 10 + aLower.codeUnitAt(ai) - 48;
        ai++;
      }
      var bn = 0;
      while (bi < bLower.length && _isDigit(bLower[bi])) {
        bn = bn * 10 + bLower.codeUnitAt(bi) - 48;
        bi++;
      }
      if (an != bn) return an.compareTo(bn);
    } else if (!aDigit && !bDigit) {
      final cmp = aLower[ai].compareTo(bLower[bi]);
      if (cmp != 0) return cmp;
      ai++;
      bi++;
    } else {
      return aDigit ? -1 : 1;
    }
  }

  return (aLower.length - ai).compareTo(bLower.length - bi);
}

bool _isDigit(String ch) {
  final c = ch.codeUnitAt(0);
  return c >= 48 && c <= 57;
}

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
  searchArcs,
  publisherSeries,
  arcIssues,
  teamIssues,
}

const Map<SortPreferenceContext, String> _storageKeys = {
  SortPreferenceContext.searchIssues: "search_issues",
  SortPreferenceContext.searchSeries: "search_series",
  SortPreferenceContext.searchCharacters: "search_characters",
  SortPreferenceContext.searchCreators: "search_creators",
  SortPreferenceContext.searchUniverses: "search_universes",
  SortPreferenceContext.browseIssues: "browse_issues",
  SortPreferenceContext.browseRecentlyAdded: "browse_recently_added",
  SortPreferenceContext.browseSeries: "browse_series",
  SortPreferenceContext.libraryMyComics: "library_my_comics",
  SortPreferenceContext.libraryWishlist: "library_wishlist",
  SortPreferenceContext.libraryUnrated: "library_unrated",
  SortPreferenceContext.libraryRead: "library_read",
  SortPreferenceContext.libraryUnread: "library_unread",
  SortPreferenceContext.libraryReadingHistory: "library_reading_history",
  SortPreferenceContext.seriesDetailsIssues: "series_details_issues",
  SortPreferenceContext.characterIssues: "character_issues_sort",
  SortPreferenceContext.releasesWeekly: "releases_weekly",
  SortPreferenceContext.releasesFoc: "releases_foc",
  SortPreferenceContext.releasesMyPulls: "releases_my_pulls",
  SortPreferenceContext.releasesNewFirst: "releases_new_first",
  SortPreferenceContext.continueReading: "continue_reading",
  SortPreferenceContext.subscriptions: "subscriptions",
  SortPreferenceContext.searchImprints: "search_imprints",
  SortPreferenceContext.searchTeams: "search_teams",
  SortPreferenceContext.searchPublishers: "search_publishers",
  SortPreferenceContext.searchArcs: "search_arcs",
  SortPreferenceContext.publisherSeries: "publisher_series",
  SortPreferenceContext.arcIssues: "arc_issues_sort",
  SortPreferenceContext.teamIssues: "team_issues_sort",
};

const Set<SortPreferenceContext> _dateNewestDefaults = {
  SortPreferenceContext.browseRecentlyAdded,
  SortPreferenceContext.libraryReadingHistory,
  SortPreferenceContext.seriesDetailsIssues,
  SortPreferenceContext.continueReading,
};

const Set<SortPreferenceContext> _dateOldestDefaults = {
  SortPreferenceContext.characterIssues,
  SortPreferenceContext.arcIssues,
  SortPreferenceContext.teamIssues,
};

extension SortPreferenceContextX on SortPreferenceContext {
  String get storageKey => _storageKeys[this]!;

  ContentSortOption get defaultOption {
    if (_dateNewestDefaults.contains(this)) return ContentSortOption.dateNewest;
    if (_dateOldestDefaults.contains(this)) return ContentSortOption.dateOldest;
    return ContentSortOption.nameAsc;
  }
}

String contentSortLabel(ContentSortOption option) {
  switch (option) {
    case ContentSortOption.nameAsc:
      return "Alphabetical (A-Z)";
    case ContentSortOption.nameDesc:
      return "Alphabetical (Z-A)";
    case ContentSortOption.dateNewest:
      return "Release Date (Newest)";
    case ContentSortOption.dateOldest:
      return "Release Date (Oldest)";
  }
}

List<IssueList> sortIssues(
  List<IssueList> issues,
  ContentSortOption sortOption,
) {
  return sortItemsByNameAndDate<IssueList>(
    issues,
    sortOption: sortOption,
    nameOf: (i) => i.name,
    dateOf: (i) =>
        i.storeDate ??
        i.coverDate ??
        (i.series?.yearBegan != null && i.series!.yearBegan! > 0
            ? DateTime(i.series!.yearBegan!)
            : null),
  );
}

List<IssueList> selectRecentIssues(
  List<IssueList> issues, {
  int targetCount = 5,
}) {
  final sortedNewest = sortIssues(issues, ContentSortOption.dateNewest);
  return sortedNewest.take(targetCount).toList();
}

List<IssueList> selectRecentDistinctSeriesIssues(
  List<IssueList> issues, {
  int targetCount = 5,
}) {
  final sortedNewest = sortIssues(issues, ContentSortOption.dateNewest);
  final seenSeries = <int>{};
  final selected = <IssueList>[];

  for (final issue in sortedNewest) {
    final sId = issue.series?.id;
    if (sId != null && sId > 0) {
      if (seenSeries.add(sId)) {
        selected.add(issue);
        if (selected.length >= targetCount) return selected;
      }
    }
  }

  for (final issue in sortedNewest) {
    if (!selected.contains(issue)) {
      selected.add(issue);
      if (selected.length >= targetCount) break;
    }
  }

  return selected;
}

List<SeriesList> sortSeries(
  List<SeriesList> series,
  ContentSortOption sortOption,
) {
  return sortItemsByNameAndDate<SeriesList>(
    series,
    sortOption: sortOption,
    nameOf: (s) => s.name,
    dateOf: (s) => s.yearBegan != null ? DateTime(s.yearBegan!) : null,
  );
}

List<T> _sortByNameOnly<T>(
  List<T> items,
  ContentSortOption sortOption,
  String Function(T item) nameOf,
) {
  return sortItemsByNameAndDate<T>(
    items,
    sortOption: sortOption,
    nameOf: nameOf,
    dateOf: (_) => null,
  );
}

List<CharacterList> sortCharacters(
  List<CharacterList> items,
  ContentSortOption option,
) => _sortByNameOnly(items, option, (c) => c.name);

List<CreatorList> sortCreators(
  List<CreatorList> items,
  ContentSortOption option,
) => _sortByNameOnly(items, option, (c) => c.name);

List<UniverseList> sortUniverses(
  List<UniverseList> items,
  ContentSortOption option,
) => _sortByNameOnly(items, option, (u) => u.name);

List<ImprintList> sortImprints(
  List<ImprintList> items,
  ContentSortOption option,
) => _sortByNameOnly(items, option, (i) => i.name);

List<TeamList> sortTeams(List<TeamList> items, ContentSortOption option) =>
    _sortByNameOnly(items, option, (t) => t.name);

List<ArcList> sortArcs(List<ArcList> items, ContentSortOption option) =>
    _sortByNameOnly(items, option, (a) => a.name);

List<PublisherList> sortPublishers(
  List<PublisherList> items,
  ContentSortOption option,
) => _sortByNameOnly(items, option, (p) => p.name);

String _collectionItemName(CollectionItem item) {
  final seriesName = item.issue?.series?.name.trim() ?? "";
  final issueNumber = item.issue?.number.trim() ?? "";
  if (seriesName.isEmpty && issueNumber.isEmpty) return "";
  return "$seriesName #$issueNumber".trim();
}

DateTime? _collectionItemDate(CollectionItem item) {
  return item.purchaseDate ??
      item.issue?.storeDate ??
      item.issue?.coverDate ??
      item.modified ??
      item.issue?.modified;
}

List<CollectionItem> sortCollectionItems(
  List<CollectionItem> items,
  ContentSortOption sortOption,
) {
  return sortItemsByNameAndDate<CollectionItem>(
    items,
    sortOption: sortOption,
    nameOf: _collectionItemName,
    dateOf: _collectionItemDate,
  );
}

List<T> sortItemsByNameAndDate<T>(
  List<T> items, {
  required ContentSortOption sortOption,
  required String Function(T item) nameOf,
  required DateTime? Function(T item) dateOf,
}) {
  final sorted = [...items];

  int compareByName(T a, T b) {
    return naturalCompare(nameOf(a), nameOf(b));
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
