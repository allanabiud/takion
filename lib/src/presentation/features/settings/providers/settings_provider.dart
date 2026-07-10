import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takion/src/core/constants/pagination.dart';
import 'package:takion/src/data/dto/issue_details_dto.dart';
import 'package:takion/src/core/cache/cache_policy.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/features/library/providers/collection_items_provider.dart';
import 'package:takion/src/presentation/features/library/providers/collection_stats_provider.dart';
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
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
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
import 'package:takion/src/presentation/providers/repository_providers.dart';
import 'package:takion/src/core/storage/local_profile_service.dart';
import 'package:takion/src/core/notifications/push_notification_service.dart';

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

enum SyncType { full, quick }

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
  }) = _AppSettings;
}

final pushPullNotificationsEnabledProvider =
    AsyncNotifierProvider<PushPullNotificationsEnabledNotifier, bool>(
      PushPullNotificationsEnabledNotifier.new,
    );

class PushPullNotificationsEnabledNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'push_pull_notifications_enabled';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return box.get(_key, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool value) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);

    // Request permission via the push notification service if enabling
    final service = ref.read(pushNotificationServiceProvider);
    if (value) {
      try {
        final granted = await service.requestPermission();
        if (!granted) {
          // Do not enable if permission not granted
          state = AsyncValue.data(false);
          await box.put(_key, false);
          return;
        }
      } catch (_) {
        // Permission request failed; stop enabling
        state = AsyncValue.data(false);
        await box.put(_key, false);
        return;
      }
    }

    await box.put(_key, value);
    state = AsyncValue.data(value);

    // Inform push service to (un)register as needed
    try {
      await service.syncRegistration(enabled: value);
    } catch (_) {}
  }
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
    final hive = ref.read(hiveServiceProvider);
    final selectedWeek = ref.read(selectedWeekProvider);
    final nowWeek = _weekStart(DateTime.now());
    final selectedWeekStart = _weekStart(selectedWeek);

    final weeklyBox = await hive.openBox<List>('weekly_releases_box');
    final focBox = await hive.openBox<List>('foc_releases_box');
    final cachedWeeks = {
      ...weeklyBox.keys,
      ...focBox.keys,
    }.map(_parseWeekKey).whereType<DateTime>().map(_weekStart).toSet();

    return {...cachedWeeks, nowWeek, selectedWeekStart};
  }

  void _invalidateReleaseProviders() {
    ref.invalidate(weeklyReleasesProvider);
    ref.invalidate(focReleasesProvider);
  }

  void _invalidateCacheBackedProviders() {
    _invalidateReleaseProviders();
    ref.invalidate(issueDetailsProvider);
    ref.invalidate(issueSearchResultsProvider);
    ref.invalidate(collectionIssueStatusMapProvider);
    ref.invalidate(allLibraryItemsProvider);
    ref.invalidate(allCollectionItemsProvider);
    ref.invalidate(collectionItemsByOwnershipStatusProvider);
    ref.invalidate(collectionItemsByReadStatusProvider);
    ref.invalidate(unratedCollectionItemsProvider);
    ref.invalidate(wishlistCollectionItemsProvider);
    ref.invalidate(collectionSeriesKeysProvider);
    ref.invalidate(collectionItemsProvider);
    ref.invalidate(currentCollectionItemsProvider);
    ref.invalidate(collectionStatsProvider);
    ref.invalidate(seriesDetailsProvider);
    ref.invalidate(seriesIssueListProvider);
    ref.invalidate(seriesListProvider);
    ref.invalidate(currentSeriesListProvider);
    ref.invalidate(seriesSearchResultsProvider);
    ref.invalidate(readingSuggestionProvider);
    ref.invalidate(readingSuggestionIssueProvider);
    ref.invalidate(rateSuggestionProvider);
    ref.invalidate(rateSuggestionIssueProvider);
    ref.invalidate(homeTrendingProvider);
    ref.invalidate(continueReadingSuggestionsProvider);
    ref.invalidate(becauseYouPulledIssuesProvider);
    ref.invalidate(activeSubscriptionsProvider);
    ref.invalidate(activeSubscriptionsCountProvider);
    ref.invalidate(subscribedSeriesListProvider);
    ref.invalidate(subscribedSeriesPageProvider);
    ref.invalidate(seriesSubscriptionProvider);
    ref.invalidate(issuePullListEntryProvider);
    ref.invalidate(pullListEntriesForWeekProvider);
    ref.invalidate(pullsIssuesForWeekProvider);
    ref.invalidate(currentWeekPullsProvider);
    ref.invalidate(currentWeekPullsCountProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(profileInsightsProvider);
    ref.invalidate(characterDetailsProvider);
    ref.invalidate(characterSearchResultsProvider);
    ref.invalidate(characterIssueListProvider);
    ref.invalidate(characterDetailsIssuesProvider);
    ref.invalidate(creatorDetailsProvider);
    ref.invalidate(creatorSearchResultsProvider);
    ref.invalidate(universeDetailsProvider);
    ref.invalidate(universeSearchResultsProvider);
    ref.invalidate(imprintDetailsProvider);
    ref.invalidate(imprintSearchResultsProvider);
    ref.invalidate(teamDetailsProvider);
    ref.invalidate(teamSearchResultsProvider);
    ref.invalidate(publisherDetailsProvider);
    ref.invalidate(publisherSearchResultsProvider);
  }

  static const _syncRequestDelay = Duration(milliseconds: 3500);

  Future<void> _throttle() async {
    await Future.delayed(_syncRequestDelay);
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
    final match = RegExp(r'^series_list:p(\d+):l(\d+)$').firstMatch(key);
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

  Future<int> _syncMetronCaches({required bool quick}) async {
    final hive = ref.read(hiveServiceProvider);
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

    final issueDetailsBox = await hive.openBox<IssueDetailsDto>(
      'issue_details_box',
    );
    for (final key in issueDetailsBox.keys) {
      if (key is! int || key <= 0) continue;
      if (quick) {
        final cachedAt = await localDataSource.getIssueDetailsCachedAt(key);
        if (_isStaleOrMissing(
          cachedAt: cachedAt,
          policy: MetronCachePolicies.issueDetails,
          now: now,
        )) {
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

    final seriesDetailsBox = await hive.openBox<Map>('series_details_box');
    for (final key in seriesDetailsBox.keys) {
      if (key is! int || key <= 0) continue;
      if (quick) {
        final cachedAt = await localDataSource.getSeriesDetailsCachedAt(key);
        if (_isStaleOrMissing(
          cachedAt: cachedAt,
          policy: MetronCachePolicies.seriesDetails,
          now: now,
        )) {
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

    final seriesListBox = await hive.openBox<List>('series_list_box');
    for (final key in seriesListBox.keys) {
      final page = _parseSeriesListPageKey(key);
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

    final issueSearchBox = await hive.openBox<List>('issue_search_box');
    for (final key in issueSearchBox.keys) {
      final parsed = _parseSearchKey(key);
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

    final seriesSearchBox = await hive.openBox<List>('series_search_box');
    for (final key in seriesSearchBox.keys) {
      final parsed = _parseSearchKey(key);
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

    final seriesIssueListBox = await hive.openBox<List>(
      'series_issue_list_box',
    );
    for (final key in seriesIssueListBox.keys) {
      final parsed = _parseSeriesIssueListKey(key);
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

  Future<void> _syncLocalData({required bool quick}) async {
    final pullRepo = ref.read(pullListRepositoryProvider);
    final profileService = ref.read(localProfileServiceProvider);
    final reconciler = ref.read(subscriptionPullReconcilerProvider);
    final fromDate = _weekStart(DateTime.now());
    await pullRepo.regenerateFromSubscriptions(
      fromDate: quick ? fromDate : fromDate.subtract(const Duration(days: 365)),
      toDate: quick ? null : fromDate.add(const Duration(days: 365 * 2)),
    );
    await reconciler.reconcile(force: true);
    _invalidateCacheBackedProviders();
    await Future.wait([
      ref.read(allLibraryItemsProvider.future),
      ref.read(activeSubscriptionsProvider.future),
      ref.read(currentWeekPullsProvider.future),
      profileService.getCurrentProfile(forceRefresh: !quick),
    ]);
  }

  Future<void> triggerFullSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Starting full sync...',
    );

    try {
      final synced = await _syncMetronCaches(quick: false);
      await _syncLocalData(quick: false);
      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage:
            'Full sync completed ($synced cached slice(s) refreshed)',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Full sync failed: $e',
      );
    }
  }

  Future<void> triggerQuickSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Starting quick sync...',
    );

    try {
      final synced = await _syncMetronCaches(quick: true);
      await _syncLocalData(quick: true);
      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage:
            'Quick sync completed ($synced stale/missing cache slice(s) refreshed)',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Quick sync failed: $e',
      );
    }
  }

  Future<void> clearCache() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncMessage: 'Clearing local cache and metadata...',
    );
    final hive = ref.read(hiveServiceProvider);

    try {
      await hive.clearLocalCache();
      _invalidateCacheBackedProviders();
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Cache and metadata cleared successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Failed to clear cache: $e',
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
  static const _boxName = 'settings_box';
  static const _key = 'collection_default_format';

  @override
  Future<CollectionDefaultFormat> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw =
        (box.get(_key, defaultValue: 'digital') as String?) ?? 'digital';

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
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final value = switch (format) {
      CollectionDefaultFormat.print => 'print',
      CollectionDefaultFormat.digital => 'digital',
      CollectionDefaultFormat.both => 'both',
    };
    await box.put(_key, value);
    state = AsyncValue.data(format);
  }
}

enum PullNotificationTiming { dayBefore, releaseDay, dayAfter }

final pullNotificationTimingProvider =
    AsyncNotifierProvider<
      PullNotificationTimingNotifier,
      PullNotificationTiming
    >(PullNotificationTimingNotifier.new);

class PullNotificationTimingNotifier
    extends AsyncNotifier<PullNotificationTiming> {
  static const _boxName = 'settings_box';
  static const _key = 'push_pull_notification_timing';

  @override
  Future<PullNotificationTiming> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw =
        (box.get(_key, defaultValue: 'release_day') as String?) ??
        'release_day';

    switch (raw) {
      case 'day_before':
        return PullNotificationTiming.dayBefore;
      case 'day_after':
        return PullNotificationTiming.dayAfter;
      case 'release_day':
        return PullNotificationTiming.releaseDay;
      default:
        return PullNotificationTiming.releaseDay;
    }
  }

  Future<void> setTiming(PullNotificationTiming timing) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final value = switch (timing) {
      PullNotificationTiming.dayBefore => 'day_before',
      PullNotificationTiming.releaseDay => 'release_day',
      PullNotificationTiming.dayAfter => 'day_after',
    };
    await box.put(_key, value);
    state = AsyncValue.data(timing);
  }
}

final autoCollectOnReadProvider =
    AsyncNotifierProvider<AutoCollectOnReadNotifier, bool>(
      AutoCollectOnReadNotifier.new,
    );

class AutoCollectOnReadNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'auto_collect_on_read';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return (box.get(_key, defaultValue: false) as bool?) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final autoPullToCollectionProvider =
    AsyncNotifierProvider<AutoPullToCollectionNotifier, bool>(
      AutoPullToCollectionNotifier.new,
    );

class AutoPullToCollectionNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'auto_pull_to_collection';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return (box.get(_key, defaultValue: false) as bool?) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

enum DefaultSortOrder { dateAdded, title, series }

final defaultSortOrderProvider =
    AsyncNotifierProvider<DefaultSortOrderNotifier, DefaultSortOrder>(
      DefaultSortOrderNotifier.new,
    );

class DefaultSortOrderNotifier extends AsyncNotifier<DefaultSortOrder> {
  static const _boxName = 'settings_box';
  static const _key = 'default_sort_order';

  @override
  Future<DefaultSortOrder> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw =
        (box.get(_key, defaultValue: 'date_added') as String?) ?? 'date_added';
    switch (raw) {
      case 'title':
        return DefaultSortOrder.title;
      case 'series':
        return DefaultSortOrder.series;
      default:
        return DefaultSortOrder.dateAdded;
    }
  }

  Future<void> setSortOrder(DefaultSortOrder order) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final value = switch (order) {
      DefaultSortOrder.dateAdded => 'date_added',
      DefaultSortOrder.title => 'title',
      DefaultSortOrder.series => 'series',
    };
    await box.put(_key, value);
    state = AsyncValue.data(order);
  }
}

final showReadIssueTickOverlayProvider =
    AsyncNotifierProvider<ShowReadIssueTickOverlayNotifier, bool>(
      ShowReadIssueTickOverlayNotifier.new,
    );

class ShowReadIssueTickOverlayNotifier extends AsyncNotifier<bool> {
  static const _boxName = 'settings_box';
  static const _key = 'show_read_issue_tick_overlay';

  @override
  Future<bool> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    return (box.get(_key, defaultValue: false) as bool?) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, enabled);
    state = AsyncValue.data(enabled);
  }
}

final accentSchemeProvider =
    AsyncNotifierProvider<AccentSchemeNotifier, FlexScheme>(
      AccentSchemeNotifier.new,
    );

class AccentSchemeNotifier extends AsyncNotifier<FlexScheme> {
  static const _boxName = 'settings_box';
  static const _key = 'accent_scheme';

  @override
  Future<FlexScheme> build() async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    final raw = box.get(_key, defaultValue: FlexScheme.bigStone.index) as int;
    return FlexScheme.values.length > raw ? FlexScheme.values[raw] : FlexScheme.bigStone;
  }

  Future<void> setScheme(FlexScheme scheme) async {
    final hive = ref.read(hiveServiceProvider);
    final box = await hive.openBox(_boxName);
    await box.put(_key, scheme.index);
    state = AsyncValue.data(scheme);
  }
}

final cacheSizeProvider = FutureProvider<int>((ref) async {
  final hive = ref.read(hiveServiceProvider);
  return hive.cacheSize();
});

final imageCacheSizeProvider = FutureProvider<int>((ref) async {
  final hive = ref.read(hiveServiceProvider);
  return hive.imageCacheSize();
});
