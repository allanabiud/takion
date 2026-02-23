class CachePolicy {
  const CachePolicy({required this.ttl});

  final Duration ttl;

  bool isFresh(DateTime fetchedAt, DateTime now) {
    return now.difference(fetchedAt) < ttl;
  }
}

class MetronCachePolicies {
  const MetronCachePolicies._();

  static const weeklyReleases = CachePolicy(ttl: Duration(hours: 3));
  static const issueDetails = CachePolicy(ttl: Duration(days: 1));
  static const searchResults = CachePolicy(ttl: Duration(hours: 3));
  static const seriesDetails = CachePolicy(ttl: Duration(days: 7));
}
