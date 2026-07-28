import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/core/network/dio_client.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_search_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart';
import 'package:takion/src/presentation/features/issues/providers/issue_details_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/selected_week_provider.dart';
import 'package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart';
import 'package:takion/src/presentation/features/library/providers/pulls_provider.dart';
import 'package:takion/src/presentation/features/library/providers/subscription_pull_reconciler.dart';
import 'package:takion/src/presentation/features/series/providers/series_details_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_list_provider.dart';
import 'package:takion/src/presentation/features/series/providers/series_search_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_suggestions_provider.dart';
import 'package:takion/src/presentation/features/library/providers/because_you_pulled_provider.dart';
import 'package:takion/src/presentation/features/library/providers/continue_reading_provider.dart';
import 'package:takion/src/presentation/features/home/providers/home_trending_provider.dart';
import 'package:takion/src/presentation/features/series/providers/subscriptions_provider.dart';
import 'package:takion/src/presentation/features/characters/providers/character_details_provider.dart';
import 'package:takion/src/presentation/features/characters/providers/character_search_provider.dart';
import 'package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_details_provider.dart';
import 'package:takion/src/presentation/features/creators/providers/creator_search_provider.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_details_provider.dart';
import 'package:takion/src/presentation/features/universes/providers/universe_search_provider.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart';
import 'package:takion/src/presentation/features/imprints/providers/imprint_search_provider.dart';
import 'package:takion/src/presentation/features/teams/providers/team_details_provider.dart';
import 'package:takion/src/presentation/features/teams/providers/team_search_provider.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart';
import 'package:takion/src/presentation/features/publishers/providers/publisher_search_provider.dart';
import 'package:takion/src/presentation/providers/providers.dart';
import 'package:takion/src/presentation/features/library/providers/library_insights_provider.dart';
import 'package:takion/src/core/logging/app_logger.dart';

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

enum RefreshType { full, quick }

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isBusy,
    String? statusMessage,
  }) = _AppSettings;
}

void invalidateReleaseProviders(void Function(dynamic provider) invalidate) {
  invalidate(weeklyReleasesProvider);
  invalidate(focReleasesProvider);
}

void invalidateCacheBackedProviders(
  void Function(dynamic provider) invalidate,
) {
  _invalidateBatch(invalidate);
}

void invalidateCacheBackedProvidersBatched(
  void Function(dynamic provider) invalidate,
) {
  invalidateReleaseProviders(invalidate);
  invalidate(homeTrendingProvider);
  invalidate(continueReadingSuggestionsProvider);
  invalidate(currentWeekPullsProvider);
  invalidate(currentWeekPullsCountProvider);
  invalidate(becauseYouPulledIssuesProvider);

  Future.microtask(() {
    invalidate(collectionIssueStatusMapProvider);
    invalidate(allLibraryItemsProvider);
    invalidate(libraryInsightsProvider);
    invalidate(issuePullListEntryProvider);
    invalidate(issueDetailsProvider);
    invalidate(pullListEntriesForWeekProvider);
    invalidate(pullsIssuesForWeekProvider);

    Future.microtask(() {
      invalidate(seriesDetailsProvider);
      invalidate(seriesIssueListProvider);
      invalidate(seriesListProvider);
      invalidate(currentSeriesListProvider);
      invalidate(seriesSearchResultsProvider);
      invalidate(readingSuggestionProvider);
      invalidate(readingSuggestionIssueProvider);
      invalidate(rateSuggestionProvider);
      invalidate(rateSuggestionIssueProvider);
      invalidate(activeSubscriptionsProvider);
      invalidate(subscribedSeriesListProvider);
      invalidate(subscribedSeriesPageProvider);
      invalidate(seriesSubscriptionProvider);

      Future.microtask(() {
        invalidate(issueSearchResultsProvider);
        invalidate(characterDetailsProvider);
        invalidate(characterSearchResultsProvider);
        invalidate(characterIssueListProvider);
        invalidate(characterDetailsIssuesProvider);
        invalidate(creatorDetailsProvider);
        invalidate(creatorSearchResultsProvider);
        invalidate(universeDetailsProvider);
        invalidate(universeSearchResultsProvider);
        invalidate(imprintDetailsProvider);
        invalidate(imprintSearchResultsProvider);
        invalidate(teamDetailsProvider);
        invalidate(teamSearchResultsProvider);
        invalidate(publisherDetailsProvider);
        invalidate(publisherSearchResultsProvider);
      });
    });
  });
}

void _invalidateBatch(void Function(dynamic provider) invalidate) {
  invalidateReleaseProviders(invalidate);
  invalidate(issueDetailsProvider);
  invalidate(issueSearchResultsProvider);
  invalidate(collectionIssueStatusMapProvider);
  invalidate(allLibraryItemsProvider);
  invalidate(seriesDetailsProvider);
  invalidate(seriesIssueListProvider);
  invalidate(seriesListProvider);
  invalidate(currentSeriesListProvider);
  invalidate(seriesSearchResultsProvider);
  invalidate(readingSuggestionProvider);
  invalidate(readingSuggestionIssueProvider);
  invalidate(rateSuggestionProvider);
  invalidate(rateSuggestionIssueProvider);
  invalidate(homeTrendingProvider);
  invalidate(continueReadingSuggestionsProvider);
  invalidate(becauseYouPulledIssuesProvider);
  invalidate(activeSubscriptionsProvider);
  invalidate(subscribedSeriesListProvider);
  invalidate(subscribedSeriesPageProvider);
  invalidate(seriesSubscriptionProvider);
  invalidate(issuePullListEntryProvider);
  invalidate(pullListEntriesForWeekProvider);
  invalidate(pullsIssuesForWeekProvider);
  invalidate(currentWeekPullsProvider);
  invalidate(currentWeekPullsCountProvider);
  invalidate(libraryInsightsProvider);
  invalidate(characterDetailsProvider);
  invalidate(characterSearchResultsProvider);
  invalidate(characterIssueListProvider);
  invalidate(characterDetailsIssuesProvider);
  invalidate(creatorDetailsProvider);
  invalidate(creatorSearchResultsProvider);
  invalidate(universeDetailsProvider);
  invalidate(universeSearchResultsProvider);
  invalidate(imprintDetailsProvider);
  invalidate(imprintSearchResultsProvider);
  invalidate(teamDetailsProvider);
  invalidate(teamSearchResultsProvider);
  invalidate(publisherDetailsProvider);
  invalidate(publisherSearchResultsProvider);
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  DateTime _weekStart(DateTime date) {
    final offset = date.weekday % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
  }

  DateTime? _parseWeekKey(Object? key) {
    if (key is! String) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  Future<Set<DateTime>> _syncTargetWeeks() async {
    final dao = ref.read(driftDatabaseProvider).apiCacheDao;
    final selectedWeek = ref.read(selectedWeekProvider);
    final nowWeek = _weekStart(DateTime.now());
    final selectedWeekStart = _weekStart(selectedWeek);

    final weeklyEntries = await dao.getByPrefix('weekly_releases:');
    final focEntries = await dao.getByPrefix('foc_releases:');

    final cachedWeeks = {
      for (final entry in weeklyEntries)
        _parseWeekKey(entry.cacheKey.substring('weekly_releases:'.length)),
      for (final entry in focEntries)
        _parseWeekKey(entry.cacheKey.substring('foc_releases:'.length)),
    }.whereType<DateTime>().map(_weekStart).toSet();

    return {...cachedWeeks, nowWeek, selectedWeekStart};
  }

  void _invalidateCacheBackedProviders() {
    invalidateCacheBackedProviders((p) => ref.invalidate(p));
  }

  static const _refreshRequestDelay = Duration(milliseconds: 3500);

  Future<void> _throttle() async {
    await Future.delayed(_refreshRequestDelay);
  }

  ({String query, int page})? _parseSearchKey(Object? key) {
    if (key is! String) return null;
    final match = RegExp(r'^(.*)::p(\d+):l(\d+)$').firstMatch(key);
    if (match == null) return null;
    final query = match.group(1)?.trim() ?? '';
    final page = int.tryParse(match.group(2) ?? '');
    if (query.isEmpty || page == null || page <= 0) return null;
    return (query: query, page: page);
  }

  int? _parseSeriesListPageKey(Object? key) {
    if (key is! String) return null;
    final match = RegExp(r'^series_list:p(\d+):l(\d+)').firstMatch(key);
    final page = int.tryParse(match?.group(1) ?? '');
    if (page == null || page <= 0) return null;
    return page;
  }

  ({int seriesId, int page})? _parseSeriesIssueListKey(Object? key) {
    if (key is! String) return null;
    final match = RegExp(
      r'^series_issue_list:(\d+):p(\d+):l(\d+)$',
    ).firstMatch(key);
    if (match == null) return null;
    final seriesId = int.tryParse(match.group(1) ?? '');
    final page = int.tryParse(match.group(2) ?? '');
    if (seriesId == null || seriesId <= 0 || page == null || page <= 0) {
      return null;
    }
    return (seriesId: seriesId, page: page);
  }

  bool _isStaleOrMissing({
    required DateTime? cachedAt,
    required CachePolicy policy,
    required DateTime now,
  }) {
    if (cachedAt == null) return true;
    return !policy.isFresh(cachedAt, now);
  }

  Future<int> _refreshCatalogCaches({
    required bool quick,
    DateTime? lastSyncTimestamp,
  }) async {
    final db = ref.read(driftDatabaseProvider);
    final dao = db.apiCacheDao;
    final repository = ref.read(catalogRepositoryProvider);
    final localDataSource = ref.read(metronLocalDataSourceProvider);
    final now = DateTime.now();
    var synced = 0;

    final weeks = await _syncTargetWeeks();
    for (final week in weeks) {
      if (quick) {
        final weeklyCachedAt = await localDataSource.getWeeklyReleasesCachedAt(
          week,
        );
        if (_isStaleOrMissing(
          cachedAt: weeklyCachedAt,
          policy: MetronCachePolicies.weeklyReleases,
          now: now,
        )) {
          await repository.getWeeklyReleasesForDate(week, forceRefresh: true);
          synced++;
          await _throttle();
        }
        final focCachedAt = await localDataSource.getFocReleasesCachedAt(week);
        if (_isStaleOrMissing(
          cachedAt: focCachedAt,
          policy: MetronCachePolicies.focReleases,
          now: now,
        )) {
          await repository.getFocReleasesForDate(week, forceRefresh: true);
          synced++;
          await _throttle();
        }
      } else {
        await repository.getWeeklyReleasesForDate(week, forceRefresh: true);
        await _throttle();
        await repository.getFocReleasesForDate(week, forceRefresh: true);
        await _throttle();
        synced += 2;
      }
    }

    final issueDetailsEntries = await dao.getByPrefix('issue_details:');
    for (final entry in issueDetailsEntries) {
      final keyStr = entry.cacheKey.substring('issue_details:'.length);
      final key = int.tryParse(keyStr);
      if (key == null || key <= 0) continue;
      if (quick) {
        final issue = await db.metronEntityDao.getIssue(key);
        if (issue == null || !issue.isFullyHydrated) {
          await repository.getIssueDetails(key, forceRefresh: true);
          synced++;
          await _throttle();
        }
      } else {
        await repository.getIssueDetails(key, forceRefresh: true);
        synced++;
        await _throttle();
      }
    }

    final seriesDetailsEntries = await dao.getByPrefix('series_details:');
    for (final entry in seriesDetailsEntries) {
      final keyStr = entry.cacheKey.substring('series_details:'.length);
      final key = int.tryParse(keyStr);
      if (key == null || key <= 0) continue;
      if (quick) {
        final series = await db.metronEntityDao.getSeries(key);
        if (series == null || !series.isFullyHydrated) {
          await repository.getSeriesDetails(key, forceRefresh: true);
          synced++;
          await _throttle();
        }
      } else {
        await repository.getSeriesDetails(key, forceRefresh: true);
        synced++;
        await _throttle();
      }
    }

    final useIncremental = quick && lastSyncTimestamp != null;

    if (useIncremental) {
      {
        var page = 1;
        while (true) {
          final result = await repository.getSeriesList(
            page: page,
            limit: metronDefaultPageSize,
            modifiedGt: lastSyncTimestamp,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
          if (!result.hasNext) break;
          page++;
        }
      }
      {
        var page = 1;
        while (true) {
          final result = await repository.getIssueList(
            page: page,
            limit: metronDefaultPageSize,
            modifiedGt: lastSyncTimestamp,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
          if (result.next == null) break;
          page++;
        }
      }
    } else {
      final seriesListEntries = await dao.getByPrefix('series_list:');
      for (final entry in seriesListEntries) {
        final page = _parseSeriesListPageKey(entry.cacheKey);
        if (page == null) continue;
        if (quick) {
          final cachedAt = await localDataSource.getSeriesListResultsCachedAt(
            page: page,
            limit: metronDefaultPageSize,
          );
          if (_isStaleOrMissing(
            cachedAt: cachedAt,
            policy: MetronCachePolicies.searchResults,
            now: now,
          )) {
            await repository.getSeriesList(
              page: page,
              limit: metronDefaultPageSize,
              forceRefresh: true,
            );
            synced++;
            await _throttle();
          }
        } else {
          await repository.getSeriesList(
            page: page,
            limit: metronDefaultPageSize,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
        }
      }

      final issueSearchEntries = await dao.getByPrefix('issue_search:');
      for (final entry in issueSearchEntries) {
        final parsed = _parseSearchKey(entry.cacheKey);
        if (parsed == null) continue;
        if (quick) {
          final cachedAt = await localDataSource.getIssueSearchResultsCachedAt(
            parsed.query,
            page: parsed.page,
            limit: metronDefaultPageSize,
          );
          if (_isStaleOrMissing(
            cachedAt: cachedAt,
            policy: MetronCachePolicies.searchResults,
            now: now,
          )) {
            await repository.searchIssues(
              parsed.query,
              page: parsed.page,
              limit: metronDefaultPageSize,
              forceRefresh: true,
            );
            synced++;
            await _throttle();
          }
        } else {
          await repository.searchIssues(
            parsed.query,
            page: parsed.page,
            limit: metronDefaultPageSize,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
        }
      }

      final seriesSearchEntries = await dao.getByPrefix('series_search:');
      for (final entry in seriesSearchEntries) {
        final parsed = _parseSearchKey(entry.cacheKey);
        if (parsed == null) continue;
        if (quick) {
          final cachedAt = await localDataSource.getSeriesSearchResultsCachedAt(
            parsed.query,
            page: parsed.page,
            limit: metronDefaultPageSize,
          );
          if (_isStaleOrMissing(
            cachedAt: cachedAt,
            policy: MetronCachePolicies.searchResults,
            now: now,
          )) {
            await repository.searchSeries(
              parsed.query,
              page: parsed.page,
              limit: metronDefaultPageSize,
              forceRefresh: true,
            );
            synced++;
            await _throttle();
          }
        } else {
          await repository.searchSeries(
            parsed.query,
            page: parsed.page,
            limit: metronDefaultPageSize,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
        }
      }
    }

    final seriesIssueListEntries = await dao.getByPrefix('series_issue_list:');
    for (final entry in seriesIssueListEntries) {
      final parsed = _parseSeriesIssueListKey(entry.cacheKey);
      if (parsed == null) continue;
      if (quick) {
        final cachedAt = await localDataSource
            .getSeriesIssueListResultsCachedAt(
              parsed.seriesId,
              page: parsed.page,
              limit: metronDefaultPageSize,
            );
        if (_isStaleOrMissing(
          cachedAt: cachedAt,
          policy: MetronCachePolicies.seriesIssueList,
          now: now,
        )) {
          await repository.getSeriesIssueList(
            parsed.seriesId,
            page: parsed.page,
            limit: metronDefaultPageSize,
            forceRefresh: true,
          );
          synced++;
          await _throttle();
        }
      } else {
        await repository.getSeriesIssueList(
          parsed.seriesId,
          page: parsed.page,
          limit: metronDefaultPageSize,
          forceRefresh: true,
        );
        synced++;
        await _throttle();
      }
    }

    return synced;
  }

  Future<void> _refreshLocalData({required bool quick}) async {
    final reconciler = ref.read(subscriptionPullReconcilerProvider);
    await reconciler.reconcile(force: true);
    _invalidateCacheBackedProviders();
    for (final provider in <dynamic>[
      allLibraryItemsProvider,
      activeSubscriptionsProvider,
      currentWeekPullsProvider,
    ]) {
      ref
          .read(provider.future)
          .timeout(const Duration(seconds: 10))
          .catchError((_) {});
    }
  }

  Future<void> refreshAllCatalogData() async {
    if (state.isBusy) return;

    AppLogger.info('Refreshing all catalog data');

    state = state.copyWith(
      isBusy: true,
      statusMessage: 'Refreshing all catalog data...',
    );

    try {
      final synced = await _refreshCatalogCaches(quick: false);
      await _refreshLocalData(quick: false);
      _invalidateCacheBackedProviders();
      AppLogger.info(
        'Full catalog refresh completed ($synced cached slice(s) refreshed)',
      );
      state = state.copyWith(
        isBusy: false,
        statusMessage:
            'Full catalog refresh completed ($synced cached slice(s) refreshed)',
      );
    } catch (e) {
      AppLogger.error('Full catalog refresh failed', error: e);
      state = state.copyWith(
        isBusy: false,
        statusMessage: 'Full catalog refresh failed',
      );
    }
  }

  Future<void> refreshStaleCatalogData() async {
    if (state.isBusy) return;

    AppLogger.info('Refreshing stale catalog data');

    state = state.copyWith(
      isBusy: true,
      statusMessage: 'Refreshing stale catalog data...',
    );

    try {
      final settingsDao = ref.read(driftDatabaseProvider).settingsDao;
      final lastSyncStr = await settingsDao.getString(
        'stale_refresh_last_sync',
      );
      final lastSyncTimestamp = lastSyncStr != null
          ? DateTime.tryParse(lastSyncStr)
          : null;

      final synced = await _refreshCatalogCaches(
        quick: true,
        lastSyncTimestamp: lastSyncTimestamp,
      );
      await _refreshLocalData(quick: true);

      await settingsDao.setString(
        'stale_refresh_last_sync',
        DateTime.now().toUtc().toIso8601String(),
      );

      _invalidateCacheBackedProviders();
      AppLogger.info(
        'Stale catalog refresh completed ($synced stale/missing cache slice(s) refreshed)',
      );
      state = state.copyWith(
        isBusy: false,
        statusMessage:
            'Stale catalog refresh completed ($synced stale/missing cache slice(s) refreshed)',
      );
    } catch (e) {
      AppLogger.error('Stale catalog refresh failed', error: e);
      state = state.copyWith(
        isBusy: false,
        statusMessage: 'Stale catalog refresh failed',
      );
    }
  }

  Future<void> clearCache() async {
    if (state.isBusy) return;

    state = state.copyWith(
      isBusy: true,
      statusMessage: 'Clearing local cache and metadata...',
    );

    try {
      final db = ref.read(driftDatabaseProvider);
      await db.apiCacheDao.clearAll();
      await db.imageCacheDao.clearAll();
      final cacheHeaderStore = ref.read(cacheHeaderStoreProvider);
      await cacheHeaderStore.clear(db);
      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isBusy: false,
        statusMessage: 'Cache and metadata cleared successfully',
      );
    } catch (e) {
      AppLogger.error('Failed to clear cache', error: e);
      state = state.copyWith(
        isBusy: false,
        statusMessage: 'Failed to clear cache',
      );
    }
  }
}

enum CollectionDefaultFormat { print, digital, both }

final collectionDefaultFormatProvider =
    AsyncNotifierProvider<
      CollectionDefaultFormatNotifier,
      CollectionDefaultFormat
    >(CollectionDefaultFormatNotifier.new);

class CollectionDefaultFormatNotifier
    extends AsyncNotifier<CollectionDefaultFormat> {
  static const _key = 'collection_default_format';

  @override
  Future<CollectionDefaultFormat> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = await dao.getString(_key) ?? 'digital';

    switch (raw) {
      case 'print':
        return CollectionDefaultFormat.print;
      case 'both':
        return CollectionDefaultFormat.both;
      case 'digital':
      default:
        return CollectionDefaultFormat.digital;
    }
  }

  Future<void> setDefaultFormat(CollectionDefaultFormat format) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final value = switch (format) {
      CollectionDefaultFormat.print => 'print',
      CollectionDefaultFormat.digital => 'digital',
      CollectionDefaultFormat.both => 'both',
    };
    await dao.setString(_key, value);
    state = AsyncValue.data(format);
  }
}

final autoCollectOnReadProvider =
    AsyncNotifierProvider<AutoCollectOnReadNotifier, bool>(
      AutoCollectOnReadNotifier.new,
    );

class AutoCollectOnReadNotifier extends AsyncNotifier<bool> {
  static const _key = 'auto_collect_on_read';

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return dao.getBool(_key);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final autoPullToCollectionProvider =
    AsyncNotifierProvider<AutoPullToCollectionNotifier, bool>(
      AutoPullToCollectionNotifier.new,
    );

class AutoPullToCollectionNotifier extends AsyncNotifier<bool> {
  static const _key = 'auto_pull_to_collection';

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return dao.getBool(_key);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final showReadIssueTickOverlayProvider =
    AsyncNotifierProvider<ShowReadIssueTickOverlayNotifier, bool>(
      ShowReadIssueTickOverlayNotifier.new,
    );

class ShowReadIssueTickOverlayNotifier extends AsyncNotifier<bool> {
  static const _key = 'show_read_issue_tick_overlay';

  @override
  Future<bool> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    return dao.getBool(_key);
  }

  Future<void> setEnabled(bool enabled) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setBool(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final accentSchemeProvider =
    AsyncNotifierProvider<AccentSchemeNotifier, FlexScheme>(
      AccentSchemeNotifier.new,
    );

class AccentSchemeNotifier extends AsyncNotifier<FlexScheme> {
  static const _key = 'accent_scheme';

  @override
  Future<FlexScheme> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = await dao.getInt(_key, defaultValue: FlexScheme.green.index);
    return FlexScheme.values.length > raw
        ? FlexScheme.values[raw]
        : FlexScheme.green;
  }

  Future<void> setScheme(FlexScheme scheme) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setInt(_key, scheme.index);
    state = AsyncValue.data(scheme);
  }
}

Future<int> _dbFileSize() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/takion.sqlite');
  if (!await file.exists()) return 0;
  return await file.length();
}

final cacheSizeProvider = FutureProvider<int>((ref) async {
  return _dbFileSize();
});

final imageCacheSizeProvider = FutureProvider<int>((ref) async {
  return _dbFileSize();
});
