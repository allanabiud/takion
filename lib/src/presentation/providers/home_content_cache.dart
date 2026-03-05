import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/domain/entities/issue_list.dart';
import 'package:takion/src/domain/entities/series.dart';
import 'package:takion/src/domain/entities/series_list.dart';

const String homeTrendingCacheKey = 'home:series_suggestions';
const String homeTrendingMetaKey = 'home:series_suggestions';
const String homeBecauseYouPulledCacheKey = 'home:because_you_pulled';
const String homeBecauseYouPulledMetaKey = 'home:because_you_pulled';
const String homeContinueReadingCacheKey = 'home:continue_reading';
const String homeContinueReadingMetaKey = 'home:continue_reading';

final homeContentCacheProvider = Provider<HomeContentCache>((ref) {
  return HomeContentCache(ref.read(hiveServiceProvider));
});

class HomeContentCache {
  HomeContentCache(this._hiveService);

  static const _homeContentBox = 'home_content_box';
  static const _cacheMetaBox = 'cache_meta_box';
  final HiveService _hiveService;

  Future<DateTime?> getCachedAt(String metaKey) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    final epoch = metaBox.get(metaKey);
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  Future<void> writeCachedAtNow(String metaKey) async {
    final metaBox = await _hiveService.openBox<int>(_cacheMetaBox);
    await metaBox.put(metaKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>?> readJsonList(String key) async {
    final box = await _hiveService.openBox<dynamic>(_homeContentBox);
    final value = box.get(key);
    if (value is! List) return null;
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }

  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final box = await _hiveService.openBox<dynamic>(_homeContentBox);
    await box.put(key, value);
  }
}

Map<String, dynamic> seriesListToJson(SeriesList series) {
  return {
    'id': series.id,
    'name': series.name,
    'year_began': series.yearBegan,
    'volume': series.volume,
    'issue_count': series.issueCount,
    'modified': series.modified?.toIso8601String(),
  };
}

SeriesList? seriesListFromJson(Map<String, dynamic> json) {
  final id = (json['id'] as num?)?.toInt();
  final name = json['name'] as String?;
  if (id == null || name == null || name.trim().isEmpty) return null;
  return SeriesList(
    id: id,
    name: name,
    yearBegan: (json['year_began'] as num?)?.toInt(),
    volume: (json['volume'] as num?)?.toInt(),
    issueCount: (json['issue_count'] as num?)?.toInt(),
    modified: DateTime.tryParse(json['modified'] as String? ?? ''),
  );
}

Map<String, dynamic> issueListToJson(IssueList issue) {
  final series = issue.series;
  return {
    'id': issue.id,
    'name': issue.name,
    'number': issue.number,
    'series': series == null
        ? null
        : {
            'id': series.id,
            'name': series.name,
            'volume': series.volume,
            'year_began': series.yearBegan,
            'publisher_name': series.publisherName,
            'description': series.description,
          },
    'cover_date': issue.coverDate?.toIso8601String(),
    'store_date': issue.storeDate?.toIso8601String(),
    'image': issue.image,
    'modified': issue.modified?.toIso8601String(),
  };
}

IssueList? issueListFromJson(Map<String, dynamic> json) {
  final name = json['name'] as String?;
  final number = json['number'] as String?;
  if (name == null || name.trim().isEmpty || number == null) return null;
  final seriesMap = json['series'] as Map?;
  final series = seriesMap == null
      ? null
      : Series(
          id: (seriesMap['id'] as num?)?.toInt(),
          name: (seriesMap['name'] as String?) ?? 'Unknown Series',
          volume: (seriesMap['volume'] as num?)?.toInt(),
          yearBegan: (seriesMap['year_began'] as num?)?.toInt(),
          publisherName: seriesMap['publisher_name'] as String?,
          description: seriesMap['description'] as String?,
        );
  return IssueList(
    id: (json['id'] as num?)?.toInt(),
    name: name,
    number: number,
    series: series,
    coverDate: DateTime.tryParse(json['cover_date'] as String? ?? ''),
    storeDate: DateTime.tryParse(json['store_date'] as String? ?? ''),
    image: json['image'] as String?,
    modified: DateTime.tryParse(json['modified'] as String? ?? ''),
  );
}
