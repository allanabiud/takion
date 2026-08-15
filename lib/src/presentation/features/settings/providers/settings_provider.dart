import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:takion/src/core/network/dio_client.dart";
import "package:takion/src/presentation/features/library/providers/collection_items_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_search_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_collection_status_provider.dart";
import "package:takion/src/presentation/features/issues/providers/issue_details_provider.dart";
import "package:takion/src/presentation/features/releases/providers/weekly_releases_provider.dart";
import "package:takion/src/presentation/features/library/providers/pulls_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_details_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_issue_list_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_list_provider.dart";
import "package:takion/src/presentation/features/series/providers/series_search_provider.dart";
import "package:takion/src/presentation/features/library/providers/category_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/collection_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/collection_suggestions_provider.dart";
import "package:takion/src/presentation/features/library/providers/because_you_pulled_provider.dart";
import "package:takion/src/presentation/features/library/providers/continue_reading_provider.dart";
import "package:takion/src/presentation/features/home/providers/home_trending_provider.dart";
import "package:takion/src/presentation/features/series/providers/subscriptions_provider.dart";
import "package:takion/src/presentation/features/characters/providers/character_details_provider.dart";
import "package:takion/src/presentation/features/characters/providers/character_search_provider.dart";
import "package:takion/src/presentation/features/characters/providers/character_issue_list_provider.dart";
import "package:takion/src/presentation/features/creators/providers/creator_details_provider.dart";
import "package:takion/src/presentation/features/creators/providers/creator_search_provider.dart";
import "package:takion/src/presentation/features/universes/providers/universe_details_provider.dart";
import "package:takion/src/presentation/features/universes/providers/universe_search_provider.dart";
import "package:takion/src/presentation/features/imprints/providers/imprint_details_provider.dart";
import "package:takion/src/presentation/features/imprints/providers/imprint_search_provider.dart";
import "package:takion/src/presentation/features/teams/providers/team_details_provider.dart";
import "package:takion/src/presentation/features/teams/providers/team_search_provider.dart";
import "package:takion/src/presentation/features/teams/providers/team_issue_list_provider.dart";
import "package:takion/src/presentation/features/arcs/providers/arc_details_provider.dart";
import "package:takion/src/presentation/features/arcs/providers/arc_search_provider.dart";
import "package:takion/src/presentation/features/arcs/providers/arc_issue_list_provider.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_details_provider.dart";
import "package:takion/src/presentation/features/publishers/providers/publisher_search_provider.dart";
import "package:takion/src/presentation/providers/providers.dart";
import "package:takion/src/presentation/features/library/providers/library_basic_stats_provider.dart";
import "package:takion/src/presentation/features/library/providers/library_entity_stats_provider.dart";
import "package:takion/src/core/logging/app_logger.dart";

part "settings_provider.freezed.dart";
part "settings_provider.g.dart";

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isBusy,
    String? statusMessage,
  }) = _AppSettings;
}

void invalidateReleaseProviders(void Function(ProviderOrFamily provider) invalidate) {
  invalidate(weeklyReleasesProvider);
  invalidate(focReleasesProvider);
}

void invalidateCacheBackedProviders(
  void Function(ProviderOrFamily provider) invalidate,
) {
  _invalidateBatch(invalidate);
}

void invalidateCacheBackedProvidersForAutoSync(
  void Function(ProviderOrFamily provider) invalidate,
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
    invalidate(libraryBasicStatsProvider);
    invalidate(libraryEntityStatsProvider);
    invalidate(libraryReadingTrendsProvider);
    invalidate(libraryRecentlyFinishedProvider);
    invalidate(collectionStatsProvider);
    invalidate(categoryInsightsProvider);
    invalidate(issuePullListEntryProvider);
    invalidate(issueDetailsProvider);
    invalidate(pullListEntriesForWeekProvider);
    invalidate(pullsIssuesForWeekProvider);

Future.microtask(() {
        invalidate(seriesIssueListProvider);
        invalidate(seriesDetailsIssuesProvider);
        invalidate(seriesListProvider);
      invalidate(currentSeriesListProvider);
      invalidate(seriesSearchProvider);
      invalidate(readingSuggestionProvider);
      invalidate(readingSuggestionIssueProvider);
      invalidate(rateSuggestionProvider);
      invalidate(rateSuggestionIssueProvider);
      invalidate(activeSubscriptionsProvider);
      invalidate(subscribedSeriesListProvider);
      invalidate(subscribedSeriesPageProvider);
      invalidate(seriesSubscriptionProvider);

      Future.microtask(() {
        invalidate(issueSearchProvider);
        invalidate(characterSearchProvider);
        invalidate(characterIssueListProvider);
        invalidate(characterDetailsIssuesProvider);
        invalidate(teamIssueListProvider);
        invalidate(teamDetailsIssuesProvider);
        invalidate(arcIssueListProvider);
        invalidate(arcDetailsIssuesProvider);
        invalidate(creatorSearchProvider);
        invalidate(universeSearchProvider);
        invalidate(imprintSearchProvider);
        invalidate(teamSearchProvider);
        invalidate(publisherSearchProvider);
      });
    });
  });
}

void invalidateCacheBackedProvidersBatched(
  void Function(ProviderOrFamily provider) invalidate,
) {
  _invalidateBatch(invalidate);
}

void _invalidateBatch(void Function(ProviderOrFamily provider) invalidate) {
  invalidateReleaseProviders(invalidate);
  invalidate(issueDetailsProvider);
  invalidate(issueSearchProvider);
  invalidate(collectionIssueStatusMapProvider);
  invalidate(allLibraryItemsProvider);
  invalidate(seriesDetailsProvider);
  invalidate(seriesIssueListProvider);
  invalidate(seriesDetailsIssuesProvider);
  invalidate(seriesListProvider);
  invalidate(currentSeriesListProvider);
  invalidate(seriesSearchProvider);
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
  invalidate(libraryBasicStatsProvider);
  invalidate(libraryEntityStatsProvider);
  invalidate(libraryReadingTrendsProvider);
  invalidate(libraryRecentlyFinishedProvider);
  invalidate(collectionStatsProvider);
  invalidate(categoryInsightsProvider);
  invalidate(characterDetailsProvider);
  invalidate(characterSearchProvider);
  invalidate(characterIssueListProvider);
  invalidate(characterDetailsIssuesProvider);
  invalidate(teamDetailsProvider);
  invalidate(teamSearchProvider);
  invalidate(teamIssueListProvider);
  invalidate(teamDetailsIssuesProvider);
  invalidate(arcDetailsProvider);
  invalidate(arcSearchProvider);
  invalidate(arcIssueListProvider);
  invalidate(arcDetailsIssuesProvider);
  invalidate(creatorDetailsProvider);
  invalidate(creatorSearchProvider);
  invalidate(universeDetailsProvider);
  invalidate(universeSearchProvider);
  invalidate(imprintDetailsProvider);
  invalidate(imprintSearchProvider);
  invalidate(teamDetailsProvider);
  invalidate(teamSearchProvider);
  invalidate(publisherDetailsProvider);
  invalidate(publisherSearchProvider);
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  Future<DateTime?> getListSyncTimestamp(String key) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = await dao.getString("list_sync:$key");
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setListSyncTimestamp(String key, DateTime timestamp) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    await dao.setString(
      "list_sync:$key",
      timestamp.toUtc().toIso8601String(),
    );
  }

  void _invalidateCacheBackedProviders() {
    invalidateCacheBackedProviders((p) => ref.invalidate(p));
  }

  Future<void> clearCache() async {
    if (state.isBusy) return;

    state = state.copyWith(
      isBusy: true,
      statusMessage: "Clearing local cache and metadata...",
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
        statusMessage: "Cache and metadata cleared successfully",
      );
    } catch (e) {
      AppLogger.error("Failed to clear cache", error: e);
      state = state.copyWith(
        isBusy: false,
        statusMessage: "Failed to clear cache",
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
  static const _key = "collection_default_format";

  @override
  Future<CollectionDefaultFormat> build() async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final raw = await dao.getString(_key) ?? "digital";

    switch (raw) {
      case "print":
        return CollectionDefaultFormat.print;
      case "both":
        return CollectionDefaultFormat.both;
      case "digital":
      default:
        return CollectionDefaultFormat.digital;
    }
  }

  Future<void> setDefaultFormat(CollectionDefaultFormat format) async {
    final dao = ref.read(driftDatabaseProvider).settingsDao;
    final value = switch (format) {
      CollectionDefaultFormat.print => "print",
      CollectionDefaultFormat.digital => "digital",
      CollectionDefaultFormat.both => "both",
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
  static const _key = "auto_collect_on_read";

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
  static const _key = "auto_pull_to_collection";

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
  static const _key = "show_read_issue_tick_overlay";

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
  static const _key = "accent_scheme";

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
  final file = File("${dir.path}/takion.sqlite");
  if (!await file.exists()) return 0;
  return await file.length();
}

final cacheSizeProvider = FutureProvider<int>((ref) async {
  return _dbFileSize();
});

final imageCacheSizeProvider = FutureProvider<int>((ref) async {
  return _dbFileSize();
});
