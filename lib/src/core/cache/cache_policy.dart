class CachePolicy {
  const CachePolicy({
    required this.ttl,
    this.refreshCooldown = const Duration(seconds: 60),
  });

  final Duration ttl;
  final Duration refreshCooldown;

  bool isFresh(DateTime fetchedAt, DateTime now) {
    return now.difference(fetchedAt) < ttl;
  }
}

class MetronCachePolicies {
  const MetronCachePolicies._();

  static const weeklyReleases = CachePolicy(ttl: Duration(hours: 24));
  static const focReleases = CachePolicy(ttl: Duration(hours: 3));
  static const searchResults = CachePolicy(ttl: Duration(hours: 3));
  static const issueDetails = CachePolicy(ttl: Duration(days: 1));
  static const seriesDetails = CachePolicy(ttl: Duration(hours: 48));
  static const seriesIssueList = CachePolicy(ttl: Duration(hours: 24));
  static const characterDetails = CachePolicy(ttl: Duration(days: 7));
  static const characterIssueList = CachePolicy(ttl: Duration(hours: 24));
  static const creatorSearchResults = CachePolicy(ttl: Duration(hours: 3));
  static const creatorDetails = CachePolicy(ttl: Duration(days: 7));
  static const universeSearchResults = CachePolicy(ttl: Duration(hours: 3));
  static const universeDetails = CachePolicy(ttl: Duration(days: 7));
  static const imprintDetails = CachePolicy(ttl: Duration(days: 7));
  static const publisherDetails = CachePolicy(ttl: Duration(days: 7));
  static const teamSearchResults = CachePolicy(ttl: Duration(hours: 3));
  static const teamDetails = CachePolicy(ttl: Duration(days: 7));
  static const arcSearchResults = CachePolicy(ttl: Duration(hours: 3));
  static const arcList = CachePolicy(ttl: Duration(hours: 3));
  static const arcDetails = CachePolicy(ttl: Duration(days: 7));
  static const arcIssueList = CachePolicy(ttl: Duration(hours: 24));
  static const teamIssueList = CachePolicy(ttl: Duration(hours: 24));
  static const characterList = CachePolicy(ttl: Duration(hours: 3));
  static const creatorList = CachePolicy(ttl: Duration(hours: 3));
  static const imprintList = CachePolicy(ttl: Duration(hours: 3));
  static const publisherList = CachePolicy(ttl: Duration(hours: 3));
  static const teamList = CachePolicy(ttl: Duration(hours: 3));
  static const universeList = CachePolicy(ttl: Duration(hours: 3));
  static const readingList = CachePolicy(ttl: Duration(hours: 3));

  static DateTime _weekStart(DateTime date) {
    final offset = date.weekday % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
  }

  static CachePolicy weeklyReleasesForDate(DateTime date) {
    final now = DateTime.now();
    final diff = _weekStart(date).difference(_weekStart(now)).inDays;
    if (diff < 0) return const CachePolicy(ttl: Duration(days: 7));
    if (diff == 0) return const CachePolicy(ttl: Duration(hours: 6));
    return const CachePolicy(ttl: Duration(hours: 24));
  }
}

class LocalDataCachePolicies {
  const LocalDataCachePolicies._();

  static const collectionStats = CachePolicy(ttl: Duration(hours: 3));
  static const collectionItems = CachePolicy(ttl: Duration(hours: 3));
  static const collectionItemDetails = CachePolicy(ttl: Duration(hours: 3));
  static const subscriptions = CachePolicy(ttl: Duration(hours: 3));
}

class HomeCachePolicies {
  const HomeCachePolicies._();

  static const seriesSuggestions = CachePolicy(ttl: Duration(hours: 1));
  static const becauseYouPulled = CachePolicy(ttl: Duration(hours: 1));
  static const continueReading = CachePolicy(ttl: Duration(hours: 1));
}
