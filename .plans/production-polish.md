# Production Polish Plan

## Background
Takion (v1.1.0) is near production. The codebase is 455 Dart files (~71k hand-written lines) and `flutter analyze` is already clean. A three-pronged audit (data/API layer, presentation layer, code-quality) surfaced four buckets of work before shipping:

- **Actual bugs** — a few logic errors and one broken cache-cleanup pattern.
- **Metron API misuse** — the API contract (see `assets/docs/Metron/`) isn't fully exploited: dropped `limit` params, duplicate query params, all-page walks on barcode scan, no in-flight dedup on searches, dead delta-sync surface.
- **Duplication** — ~9 copy-paste search providers, 4 byte-identical entity list screens, 21 identical cache-meta classes, 9 identical sort-label functions, a dozen shared widgets defined but bypassed.
- **Organization** — a 2,810-line god file, a 1,529-line god service, oversized screens, and 8 files importing Drift directly from presentation.

The goal of this branch is to land these **without changing app behavior** — a pure refactor + small correctness fixes, each verified by the existing test suite (105 tests) plus `flutter analyze`.

---

## Current architecture (what already exists)

| Concern | Location | Notes |
|---|---|---|
| Network | `lib/src/core/network/` | Dio; `RateLimitInterceptor` (burst/minute + sustained/day budgets), `ConditionalRequestInterceptor` (ETag/If-None-Match + If-Modified-Since), `MetronRequestScheduler` (priority queues), `CacheHeaderStore`. |
| Remote source | `lib/src/data/catalog/datasources/remote/metron_remote_data_source.dart` (1,090 lines) | Interface + impl in one file; ~80 endpoint methods. |
| Local cache | `lib/src/data/catalog/datasources/local/metron_local_data_source.dart` (2,810 lines) | **Worst file in the app**: 21 identical `*PageCacheMeta` classes, ~30 copy-pasted 4-method cache blocks, 15 key-builder one-liners. |
| Repositories | `lib/src/data/catalog/repositories/metron_repository_impl*.dart` | Delta sync, `_coalesce` dedup, background zones, TTL caching. |
| Drift | `lib/src/data/common/drift/` | `metron_entity_dao.dart` (586 lines, section-divider comments), `api_cache_dao.dart`, `junction_dao.dart`, `image_cache_dao.dart`. |
| Presentation | `lib/src/presentation/` (242 files) | 17 feature folders each with `providers/`; 43 shared widgets + `components.dart` barrel; mixed Riverpod idioms (`@riverpod` classes vs manual family finals). |

---

## Phase 1 — Fix actual bugs (behavior changes, smallest first)

These are correctness defects found during the audit. Each is a small, isolated change.

1. **Stale search cache never cleaned** — `lib/src/data/common/drift/daos/api_cache_dao.dart:51` deletes `search_results:%` keys, but every real search cache key is prefixed `issue_search:` / `series_search:` / `character_search:` / `creator_search:` / `universe_search:` / `imprint_search:` / `team_search:` / `arc_search:` / `publisher_search:` (verified in `metron_local_data_source.dart:1205,1347,1524,1701,1760,1819,1878,1936,2050`). `upc_prefix:` is also missed. The 3h search cache never expires and everything falls to the 7-day catch-all.
   - Fix: expand the LIKE pattern to match all real prefixes.
2. **Character detail self-comparison** — `lib/src/data/catalog/repositories/metron_repository_impl_characters.dart:336` compares `cached.modified == cached.modified` (always true), so the cached-JSON fallback never refreshes. Fix to `== dto.modified` (mirrors the correct check at `:319`).
3. **Arc search uses the wrong sort context** — `lib/src/presentation/features/search/search_results_screen.dart:717`: `_isArcSearch ? SortPreferenceContext.searchTeams`. There is no `searchArcs` context; add one and use it.
4. **Fake `series` row with `id 0`** — `lib/src/data/catalog/repositories/metron_repository_impl.dart:127` inserts `MetronSeriesCompanion(id: Value(series.id ?? 0))` when the API omits a series id, polluting the table with a bogus key. Fix: skip the series upsert when `series.id` is null.
5. **`ApiCache.etag` column never written** — `api_cache_dao.dart:17,24` accepts an `etag` but no caller passes it (etags are stored as `cache_headers:` payload rows instead). Drop the unused column or wire it.

**Exit check:** all 105 existing tests still pass; `flutter analyze` clean.

---

## Phase 2 — Better Metron API usage (respect the documented contract)

Reference: `assets/docs/Metron/Metron_API_Best_Practices.md` and `Metron_API_Endpoints.md`. Goals: fewer requests, smaller responses, stay inside the 20 req/min burst + 5,000/day sustained windows.

1. **`limit` param is silently dropped** — `metron_remote_data_source.dart` (`getIssueList:421`, `getSeriesList:449`, `getCharacterList:560`, and search methods) accepts `limit` but never adds it to `queryParameters`; only `getSeriesIssueList:533,547` sends it. Cache keys already distinguish limit (`_normalizeLimit`, `metron_local_data_source.dart:1042`). Fix: send `limit` (or remove the parameter entirely where unused).
2. **Duplicate query params on filtered issue list** — `getSeriesIssueList:530-531` sends **both** `series_id` and `series` when date filters are present, and falls back to the generic `/api/issue/` endpoint instead of the optimized `/api/series/{id}/issue_list/`. Use `store_date_range_after/before` on the series endpoint per docs, or drop the redundant param.
3. **Align rate-limit constants with the published contract** — `rate_limit_interceptor.dart:21-22` uses `maxRequestsPerMinute: 18` / `fallbackDailyLimit: 4800`; docs say 20/min and 5,000/day. Set 20/5000 (or document the intentional slack).
4. **Barcode scan walks every page** — `metron_repository_impl_issues.dart:525-545` loops `next` until exhausted on `searchIssuesByUpcPrefix`, bypassing the scheduler budget. Cap pages (e.g. 3) or walk within the burst budget; the scan only needs the top hit.
5. **All-page walks on detail screens** — `getArcIssueListAll` (`arcs:476-500`, `bypassConditional: true`) and `getReadingListItems` (`reading_lists:301-345`) walk all `next` pages unguarded. Cap or add a budget check; honor conditional headers where possible.
6. **Add `_coalesce` to all `searchX` methods** — only arc search coalesces today (`arcs:212`); `searchIssues`/`searchSeries`/`searchCharacters` etc. can fire duplicate concurrent HTTP requests for identical queries. Route them through the same in-flight dedup used by list/detail fetches (`metron_repository_impl.dart:76`).
7. **Cache every page, not just the terminus** — `getIssueList` caches only when `nextUrl == null` (`issues:306`); `getSeriesIssueList` only when `!hasFilters` (`series:474`). Cache each fetched page so paging backwards/forwards hits local storage.
8. **Fix cache-policy mislabeling** — `searchImprints` (`imprints:168`), `searchPublishers` (`publishers:168`), and `getPublisherSeriesList` (`publishers:375`) use `MetronCachePolicies.universeSearchResults`. Add dedicated `imprintSearchResults` / `publisherSearchResults` / `publisherSeriesList` policies. Remove the unused static `weeklyReleases`/`focReleases` policies (`cache_policy.dart:18-19`).
9. **Remove the `bypass_conditional` flag on `getArcIssueListAll`** after Phase 1/2 caps the walk — conditional requests are the documented way to avoid redundant work on detail data.

**Exit check:** grep confirms no endpoint call sends both `series_id` and `series`; barcode scan caps pages; search methods dedup; `limit` reaches the query string.

---

## Phase 3 — Dead code removal (cleanup)

Everything below has **zero callers** (verified). Removing it shrinks the public surface and kills confusion.

1. `createSearchProvider` — `lib/src/presentation/providers/search_utils.dart:10-70` (the 9 `@riverpod` search providers replaced it). Also drop its now-orphaned `SearchApiCall` typedef dependency and the re-export in `presentation/providers/providers.dart`.
2. `SeriesDto` — `lib/src/data/catalog/dto/series_dto.dart` (freezed) is referenced only by its generated files; the active type is `SeriesListDto`.
3. `rawGet` — declared `metron_remote_data_source.dart:8`, implemented `:254`, zero callers.
4. Nine unreachable delta methods — `refreshIssueListDelta`, `refreshCharacterListDelta`, `refreshCreatorListDelta`, `refreshUniverseListDelta`, `refreshImprintListDelta`, `refreshTeamListDelta`, `refreshPublisherListDelta`, `refreshArcListDelta`, `refreshReadingListDelta` (`metron_repository_impl_{issues,characters,creators,universes,imprints,teams,publishers,arcs,reading_lists}.dart`). Only `refreshSeriesListDelta` has a caller (`series_list_provider.dart:50`). Either wire the rest into a sync path or delete; at minimum delete the 8 with no path to a caller.
5. Four dead junction DAOs — `junction_dao.dart:70-82`: `insertIgnoreIssueImprint`, `insertIgnoreSeriesArc`, `insertIgnoreSeriesTeam`, `insertIgnoreSeriesUniverse`.
6. `HomeContentCache.deleteCachedAt` — `home_content_cache.dart:36-38`; plus the duplicated `*CacheKey`/`*MetaKey` pairs (`:8-11`) that share one value each.
7. `_asMap` — duplicated verbatim in `metron_repository_impl.dart:36` and `metron_remote_data_source.dart:266`; hoist to one shared helper.
8. Unused generated `_$IssueListDtoFromJson` — `issue_list_dto.dart` defines a custom `fromJson` that the generated path never hits; remove the generated dead mapper (regenerate cleanly).

**Exit check:** `flutter analyze` still clean (unused *public* symbols won't be flagged — verify by grep), 105 tests pass.

---

## Phase 4 — Reduce / simplify comments

Comments are already restrained (~0.4% of lines) and `print()`/`debugPrint` are nonexistent (all logging via `AppLogger`). Focus on the structural dividers that restate the code:

1. `lib/src/data/common/drift/daos/metron_entity_dao.dart` — strip all 11 `// ── Issues ─...` section dividers (`:7,89,187,215,243,269,295,323,351,379,412`). Method names already say which table they target. Replace with at most one file-level doc comment.
2. `lib/src/data/common/drift/database.dart` — strip the 4 table-group dividers (`:28,209,413,557`).
3. `lib/src/data/catalog/datasources/local/metron_local_data_source.dart` — remove the ~24 `// Issue Search Results`-style headers (`:1192,1334,...`) once Phase 6 collapses the copy-pasted blocks into a generic abstraction; the block names become self-evident.
4. `superhero_character_repository_impl.dart:51-91` — the numbered 7-step name-matching chain can collapse to a compact comment + code.
5. Keep: `drive_backup_service.dart`, `series_search_provider.dart`, `scrobble_sheet.dart` comments — they explain genuinely non-obvious logic.

**Exit check:** grep confirms only substantive comments remain; `flutter analyze` clean.

---

## Phase 5 — Reusable components (stop re-implementing shared widgets)

1. **Use `DatabaseIdsSection`** (`shared/widgets/database_ids_section.dart`) — defined, **never used**. Nine re-implementations exist: private `_buildDatabaseIdsSection` in `team_details_screen.dart:307`, `publisher_details_screen.dart:263`, `imprint_details_screen.dart:176`, `universe_details_screen.dart:176`, `arc_details_screen.dart:367` (`_ArcDatabaseIdsSection`), and inline blocks in `character_details_screen.dart:764`, `series_details_screen.dart:447`, `creator_details_screen.dart:249`, `issue_about_content.dart:651`.
2. **Standardize cover loading on `EntityCover`** — only 5 files use it (`issue_card.dart:105`, `activity_log_group_tile.dart:128`, `series_list_tile.dart:118`, `series_card.dart:61`, and one more); 22 files call `CachedNetworkImage(` directly with inline placeholder/error builders (e.g. `series_subscription_card.dart:106`, `home_screen.dart:340`, `issue_details_screen.dart:371,430`, `reading_list_cover.dart:201`). Add optional params to `EntityCover` (title placement, gradient, badge overlay) so these can migrate without layout risk.
3. **Shared resource-URL action trio** — `_resourceUri` + `_shareResourceUrl` + `_openResourceUrlInBrowser` are copy-pasted into 10 screens (team, character, universe, imprint, series, creator, publisher, arc, `issue_details_screen.dart:184`, `metron_reading_list_detail_screen.dart:154`). Extract one `ResourceUrlActions` mixin/helper.
4. **Collapse duplicate list screens onto `PagedListScaffold`/`PagedIssueListScaffold`** — `character_issues_screen.dart`, `team_issues_screen.dart`, `arc_issues_screen.dart` (~215 lines each) and `publisher_series_screen.dart` are byte-identical except entity name, hand-rolling `SliverOverlapAbsorber` + pinned header + sort + `BottomAppBar` page nav that `PagedIssueListScaffold` already provides (used by `weekly_releases_screen.dart:22`, `my_pulls_screen.dart:195`, `subscriptions_screen.dart:145`). Replace with one generic `EntityIssueListScreen<T>` + thin wrappers. `series_issues_screen.dart` (1,007 lines) is the same scaffold plus bulk-select — extract the bulk-select into a mixin/widget and reuse the scaffold. **[DONE]** — landed `shared/widgets/entity_paged_list_screen.dart` (`EntityPagedListScreen<T, TItem>`); the 4 entity screens are thin wrappers; the bulk-select lives in `series/series_issue_bulk_actions.dart` and `series_issues_screen.dart` is a thin wrapper over the same scaffold.
5. **Replace the 9 copy-paste search providers with one generic** — `arc/character/creator/imprint/issue/publisher/series/team/universe` `*_search_provider.dart` each repeat ~72 lines of `Future.delayed(500ms)` + `ref.keepAlive()` + 5-min `Timer` + `CancelToken` + neighbor prefetch. A shared `SearchProviderBase<T>` (or resurrect a fixed `createSearchProvider`) removes ~600 lines. Note `series_search_provider.dart` diverges (300ms + local-DB merge) — keep its custom parts. **[DONE]** — extracted generic `performPaginatedSearch` and `performSearchRefresh` helpers in `search_utils.dart`; updated all 9 search providers to use the shared implementation.
6. **Centralize duplicated constants** — `Duration(milliseconds: 500)` debounce (9 files), 5-min keepAlive timer (9+ files), and raw settings keys (`'metron_api_token'`, `'has_seen_onboarding'`, `'drive_sync_enabled'`, `'superhero_api_token'`, `'superhero_integration_enabled'`, `'superhero_use_image'`, …) into `core/constants/`.
7. **De-duplicate library screens** — `library_screen.dart:135-312` ("Reading Suggestion" vs "Rate Suggestion" are the same loading/error/data Column). One parameterized section widget.

**Exit check:** grep shows `DatabaseIdsSection(` used 9x, direct `CachedNetworkImage(` in list/cover contexts trending to 0, and the shared scaffold used by all entity list screens.

---

## Phase 6 — File & code organization

1. **Refactor `metron_local_data_source.dart` (2,810 lines)** — the single highest-value item. The 21 identical `*PageCacheMeta` classes (`:10-214`) and ~30 near-identical 4-method cache blocks are table-driven; introduce one generic `PagedLocalCache<T>` keyed by prefix + DTO mapper. Target: cut the file ~70%. Highest risk; do last, test heavily.
2. **Split `DriveSyncService` (1,529 lines)** into cohesive pieces: Drive REST client (`_driveGet/_drivePost/_driveDelete`, `:208-323`), upload/download, delta extraction (`extractDelta :958`), full/delta apply (`applyDelta :1189`), and row-mapping (`_rowToCompanion :1326`).
3. **Split `metron_remote_data_source.dart` (1,090 lines)** — interface in one file, impl in another, per-resource extensions if it still overflows.
4. **Collapse `content_sorting.dart` (672 lines)** — the 9 byte-identical `*SortLabel` functions (`:200-304`), the repeated 4-case comparators, and the 30-case `defaultOption` switch into data-driven maps + one comparator.
5. **Split oversized screens** — `onboarding_screen.dart` (1,061, 8 page-builders), `series_issues_screen.dart` (1,007), `series_details_screen.dart` (948), `search_results_screen.dart` (892), `my_comics_screen.dart` (889, 13 classes), `issue_about_content.dart` (816), `home_screen.dart` (811). Extract page/section widgets into feature `widgets/` subfolders (pattern already used by `characters/`, `search/`, `settings/`).
6. **Fix layering leaks:**
   - *Presentation → Drift direct:* 8+ files import `data/common/drift/database.dart` (e.g. `pulls_provider.dart:2`, `collection_items_provider.dart:4`, `favorites_provider.dart:2`, `category_stats_provider.dart:4`, `collection_stats_provider.dart:5`, `library_entity_stats_provider.dart:4`, `library_items_serialization.dart:3`, `home_content_cache.dart:5`, `subscriptions_provider.dart:6`). Route through the existing `LibraryRepository`/`FavoritesRepository`/`SettingsRepository` interfaces.
   - *Core → Presentation:* `dio_client.dart:11` imports `presentation/providers/auth_provider.dart` (calls `ref.invalidate(authStateProvider)` at `:102`). Inject the invalidation callback or move the auth state notifier into core.
   - *Core → Feature:* `core/export/collection_csv_export.dart:7` imports a feature provider. Move the export into the library feature.
7. **Consistent feature folder shape** — standardize on `screens/` + `providers/` + `widgets/` per feature; move `browse`'s 8 screens out of one file; relocate `integrations/`'s SuperHero UI from `settings/widgets/` into the feature.

**Exit check:** no non-generated import of `data/common/drift/database.dart` from presentation; `dio_client.dart` has no presentation import; god files split; `flutter analyze` clean.

---

## Phase 7 — Polish & risk reduction

1. **Log silent catches** — `issue_my_details_provider.dart:76-142` (6 swallowed activity-event failures, nested try/catch) and `:241-255`; `bulk_scan_actions_sheet.dart:234-305`; `scrobble_issue_provider.dart:308-329`; `category_stats_provider.dart:117`. Add `AppLogger.debug` with context.
2. **Deduplicate the `ignore: invalid_use_of_internal_member` workaround** — `weekly_releases_provider.dart:37,75`; extract a shared `refreshAsync` helper.
3. **`AuthGuard` is a no-op** (`core/router/auth_guard.dart`) — always `resolver.next(true)`; real gating is in `onboarding_screen.dart:_checkFirstLaunch`. Wire it to `authStateProvider` or delete it.
4. **Register the raw `Navigator.push` routes** — `my_comics_screen.dart:633-639,714-721` pushes `TopCharactersScreen`/`TopCreatorsScreen` via `MaterialPageRoute` (unregistered routes). Add them to the router.
5. **`LibrarySeriesRoute` `rawPathParams` quirk** — `app_router.dart` declares `@pathParam category` + `seriesName` but the path is only `/library/series/:seriesId`. Reconcile.
6. **Remove the one relative import** — `appearance_settings.dart:1`.
7. **Enforce with analyzer** — enable `prefer_single_quotes` and a small set of custom lints in `analysis_options.yaml` (stock `flutter_lints` today) to lock in conventions.
8. **Settings-keys constants** — centralize all raw `settingsDao` string keys (Phase 5.6).

**Exit check:** grep shows no silent `catch (e) {}` without a log, no `MaterialPageRoute` navigation in feature screens, no relative imports, and analyzer enforces single quotes.

---

## Risks & mitigations

| Risk | Mitigation |
|---|---|
| **Refactor regressions in the 2,810-line local cache** | Phase 6.1 last; add cache round-trip tests for each prefix before and after; keep the change purely mechanical. |
| **Behavior changes in Phase 1/2** (cache TTLs, pagination caps) | Each is tiny and test-covered; default-safe (shorter walks, correct cache expiry). |
| **Cover-component migration changes visuals** | Migrate cover usages incrementally with golden-free widget tests; keep `EntityCover` params backward-compatible. |
| **Removing "dead" code that's actually reachable via codegen** | Verify each removal by grep in `lib/` *and* `test/` before deleting. |
| **Riverpod `@riverpod` regen drift** | After removing dead providers, run `build_runner build --delete-conflicting-outputs` and re-analyze. |
| **Bulk screen refactors touch too much at once** | Land per-screen, per-feature; each commit keeps `flutter analyze` + tests green. |

---

## Testing

- Run `flutter analyze lib test` after **every** commit (fast, catches unused imports after deletions).
- Run `flutter test` (105 tests) after every phase; note the suite uses `flutter test` because `dart test` crashes on an FFI transformer bug.
- Add targeted tests where behavior changes:
  - `api_cache_dao` stale-entry cleanup matching all search prefixes (Phase 1.1).
  - Character detail fallback refresh when `modified` changes (Phase 1.2).
  - `getArcIssueListAll` / UPC walk page caps (Phase 2.4/2.5).
  - Search provider `_coalesce` dedup (Phase 2.6).
  - Local-cache round-trips for every prefix after the Phase 6.1 refactor.
- Widget smoke tests for the entity-list screens after collapsing onto `PagedIssueListScaffold` (Phase 5.4).

---

## Execution order

1. **Phase 1** (bug fixes) — commit as `fix: ...` per repo style.
2. **Phase 2** (API usage) — commit as `perf:`/`feat:` per change.
3. **Phase 3** (dead code) + **Phase 4** (comments) — commit as `cleanup:`.
4. **Phase 5** (reusable components) — one commit per shared-widget migration.
5. **Phase 7** (polish) — small commits, verify each.
6. **Phase 6** (organization / god files) — largest risk, do last; 6.1 (local cache) absolutely last.
7. Final: full `flutter analyze` + `flutter test` sweep, bump version to 1.1.1.
