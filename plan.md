# Provider State Update Bug Audit

## Root Cause Pattern

Most stale-state bugs in the app stem from one pattern: **a provider A depends on provider B (via `ref.watch(B)` in A's `build`), but after a mutation only A is invalidated. When A rebuilds, it reads B's cached (stale) data instead of re-fetching.**

Other recurring patterns:
- **Cache-then-invalidate race**: Manual `updateIssue()` on `collectionStatusCacheProvider` is applied, then `allLibraryItemsProvider` is invalidated — which causes `collectionStatusCacheProvider.build()` to re-run on the next frame, overwriting the manual update with DB data (which may be stale if the write hasn't propagated).
- **DateTime.now() family key mismatch**: `DateTime.now()` at call sites A and B will differ by microseconds, creating different family provider instances. Invalidations with one key never reach watchers with the other key.

---

## HIGH Priority Fixes

### H1 — `_applyBulkActions` cache overwrite (#5)
**File**: `bulk_scan_actions_sheet.dart:285-299`
**Problem**: `ref.invalidate(allLibraryItemsProvider)` marks `collectionStatusCacheProvider` dirty. On next frame, `collectionStatusCacheProvider.build()` runs and overwrites the manual `updateIssue()` calls (lines 297-299). The optimistic cache state is lost and replaced by whatever `allLibraryItemsProvider` returns.
**Fix**: Remove `ref.invalidate(allLibraryItemsProvider)` and `ref.invalidate(collectionStatsProvider)`. The cache updates are the source of truth for the current screen. DB writes already persist. Other screens refetch on navigation.

### H2 — Missing pull family invalidation in `_applyBulkActions` (#2)
**File**: `bulk_scan_actions_sheet.dart:289-295`
**Problem**: After pull upserts, only `issuePullListEntryProvider(issueId)` and `currentWeekPullsProvider` are invalidated. But `currentWeekPullsProvider` reads `pullsIssuesForWeekProvider(DateTime.now())` — which was never invalidated and returns cached stale data (doesn't include the new pull entry).
**Fix**: Add `ref.invalidate(pullListEntriesForWeekProvider)` and `ref.invalidate(pullsIssuesForWeekProvider)` (without args = all family instances).

### H3 — Scrobble sheet pull invalidation uses week-specific key (#2, scrobble_sheet)
**File**: `scrobble_sheet.dart:225-229`
**Problem**: `ref.invalidate(pullsIssuesForWeekProvider(week))` only invalidates the selected week. `currentWeekPullsProvider` uses `DateTime.now()` as key — which won't match `week` if the user navigated to a different week.
**Fix**: Change to all-instance invalidation: `ref.invalidate(pullListEntriesForWeekProvider)` and `ref.invalidate(pullsIssuesForWeekProvider)`.

### H4 — Scrobble missing library/continue-reading invalidations (#11)
**File**: `scrobble_issue_provider.dart:99-164`
**Problem**: After every scrobble mutation (add/remove collection, mark read, rate), only `issueMyDetailsProvider` is invalidated. `allLibraryItemsProvider`, `continueReadingAllSuggestionsProvider`, and `continueReadingSuggestionsProvider` are never invalidated — library stats and home suggestions stay stale.
**Fix**: Add invalidations for `allLibraryItemsProvider`, `continueReadingAllSuggestionsProvider`, `continueReadingSuggestionsProvider` after each mutation path.

### H5 — Issue details missing library/continue-reading invalidations (#12)
**File**: `issue_my_details_provider.dart:38-218`
**Problem**: `saveDetails()`, `addReadLogAt()`, and `deleteReadLogById()` each mutate the DB but only invalidate `issueMyDetailsProvider`. Other providers remain stale.
**Fix**: Add invalidations for `allLibraryItemsProvider`, `continueReadingAllSuggestionsProvider`, `continueReadingSuggestionsProvider` after each mutation path.

---

## MEDIUM Priority Fixes

### M1 — `currentWeekPullsProvider` uses raw `DateTime.now()` key (#8)
**File**: `pulls_provider.dart:77-83`
**Problem**: `currentWeekPullsProvider.build()` calls `pullsIssuesForWeekProvider(DateTime.now()).future`. The `DateTime.now()` has microsecond precision. Every invalidation site uses a different `DateTime.now()` value, so they never match the watched instance.
**Fix**: Normalize the key: `dateOnly(DateTime.now())`. This ensures same-day calls produce matching keys.

### M2 — Missing invalidations in helper functions (#3, #4)
**Files**: `collection_items_provider.dart:18-24` and `collection_cache_helpers.dart:8-21`
**Problem**: `invalidateLibraryCollectionProvidersForWidget()` and `invalidateLibraryItemsLocalCache()` don't invalidate continue-reading or pull providers. Callers like `my_pulls_screen.dart:57,111` and `bulk_scrobble_provider.dart:111` get stale data.
**Fix**: Add `continueReadingAllSuggestionsProvider`, `continueReadingSuggestionsProvider`, and `readingHistoryCollectionItemsProvider` to both helpers.

### M3 — Series issues screen bulk ops skip stats & continue-reading (#13)
**File**: `series_issues_screen.dart:454-457`
**Problem**: Bulk operations only invalidate `allLibraryItemsProvider` and per-issue `issueCollectionStatusProvider`. Stats and continue-reading providers are missed.
**Fix**: Add `collectionStatsProvider`, `continueReadingAllSuggestionsProvider`, `continueReadingSuggestionsProvider` invalidations.

---

## LOW Priority (self-heals, acceptable)

### L1 — Reading list mutations miss per-list details invalidation (#15, #16)
**Files**: `reading_list_edit_screen.dart:488-490`, `add_to_reading_list_bottom_sheet.dart:89`
**Fix**: Add per-list detail provider invalidations.

### L2 — Auto-dispose ephemeral state loss (#17, #18)
**Files**: `scrobble_issue_provider.dart:12-14`, `pulls_provider.dart:30-74`
**Notes**: Providers are disposed when no watchers exist. Data self-heals on navigation back. Acceptable trade-off.

### L3 — `weeklyReleasesProvider` null vs explicit key (#10)
**File**: `weekly_releases_provider.dart:13`
**Notes**: `build([DateTime? date])` defaults to `DateTime.now()` when null. Standardize on explicit key.

---

## Implementation Order

1. **H1**: `bulk_scan_actions_sheet.dart` — Remove `allLibraryItemsProvider`/`collectionStatsProvider` invalidation
2. **H2**: `bulk_scan_actions_sheet.dart` — Add all-instance pull family invalidation
3. **H3**: `scrobble_sheet.dart` — Switch to all-instance pull family invalidation
4. **H4**: `scrobble_issue_provider.dart` — Add missing library/continue-reading invalidations
5. **H5**: `issue_my_details_provider.dart` — Add missing library/continue-reading invalidations
6. **M1**: `pulls_provider.dart` — Normalize `DateTime.now()` key
7. **M2**: `collection_items_provider.dart`, `collection_cache_helpers.dart` — Expand helper invalidations
8. **M3**: `series_issues_screen.dart` — Add stats/continue-reading invalidations
