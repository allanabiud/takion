import 'package:takion/src/domain/entities.dart';

enum LibraryFilter { week, month, year, allTime }

class EntityStat {
  const EntityStat({required this.id, required this.name, required this.count});

  final int id;
  final String name;
  final int count;
}

class ReadingTrendPoint {
  const ReadingTrendPoint({
    required this.label,
    required this.count,
    required this.date,
  });

  final String label;
  final int count;
  final DateTime date;
}

class LibraryBasicStats {
  const LibraryBasicStats({
    required this.totalOwned,
    required this.readPercent,
    required this.wishlistCount,
    required this.subscriptionsCount,
    required this.pullsInPeriod,
    required this.readsInPeriod,
    required this.streakDays,
    required this.averageRating,
    required this.mostReadSeries,
    required this.mostReadSeriesYear,
    required this.filter,
  });

  final int totalOwned;
  final double readPercent;
  final int wishlistCount;
  final int subscriptionsCount;
  final int pullsInPeriod;
  final int readsInPeriod;
  final int streakDays;
  final double averageRating;
  final String? mostReadSeries;
  final int? mostReadSeriesYear;
  final LibraryFilter filter;

  static LibraryBasicStats zero(LibraryFilter filter) => LibraryBasicStats(
    totalOwned: 0,
    readPercent: 0,
    wishlistCount: 0,
    subscriptionsCount: 0,
    pullsInPeriod: 0,
    readsInPeriod: 0,
    streakDays: 0,
    averageRating: 0,
    mostReadSeries: null,
    mostReadSeriesYear: null,
    filter: filter,
  );
}

class LibraryEntityStats {
  const LibraryEntityStats({
    required this.topPublishers,
    required this.topCharacters,
    required this.allCharacters,
    required this.topCreators,
    required this.allCreators,
  });

  final List<MapEntry<String, int>> topPublishers;
  final List<EntityStat> topCharacters;
  final List<EntityStat> allCharacters;
  final List<EntityStat> topCreators;
  final List<EntityStat> allCreators;
}

class LibraryInsights {
  const LibraryInsights({
    required this.totalOwned,
    required this.readPercent,
    required this.wishlistCount,
    required this.subscriptionsCount,
    required this.pullsInPeriod,
    required this.readsInPeriod,
    required this.topPublishers,
    required this.topCharacters,
    required this.allCharacters,
    required this.topCreators,
    required this.allCreators,
    required this.streakDays,
    required this.averageRating,
    required this.mostReadSeries,
    required this.mostReadSeriesYear,
    required this.readingTrends,
    required this.recentlyFinished,
    required this.filter,
  });

  final int totalOwned;
  final double readPercent;
  final int wishlistCount;
  final int subscriptionsCount;
  final int pullsInPeriod;
  final int readsInPeriod;
  final List<MapEntry<String, int>> topPublishers;
  final List<EntityStat> topCharacters;
  final List<EntityStat> allCharacters;
  final List<EntityStat> topCreators;
  final List<EntityStat> allCreators;
  final int streakDays;
  final double averageRating;
  final String? mostReadSeries;
  final int? mostReadSeriesYear;
  final List<ReadingTrendPoint> readingTrends;
  final List<CollectionItem> recentlyFinished;
  final LibraryFilter filter;
}
