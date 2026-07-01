# App-Wide Refactoring Plan

**Goal:** Rename, reorganize, merge single-use files, and extract reusable components — without changing app behavior.

---

## Phase A: Renaming & File Moves

| # | Current Path | → Proposed Path | Rationale |
|---|---|---|---|
| A1 | `issues/issue_details/issue_library_sheets.dart` | `issues/issue_details/issue_my_details_sheets.dart` | "library" is misleading — sheets manage my-details, not library |
| A2 | `issues/issue_cover_gallery_screen.dart` | `issues/issue_details/issue_cover_gallery_screen.dart` | Sub-screen of issue details; belongs in `issue_details/` |
| A3 | `releases/weekly_issue_list_scaffold.dart` | `components/paged_issue_list_scaffold.dart` | Reusable generic widget (used by weekly, FOC, and pulls screens) |
| A4 | `releases/week_picker_bar.dart` | `components/week_picker_bar.dart` | Reusable generic widget |

**Risk:** Low. Pure file moves — update all imports. Verified via `dart analyze`.

---

## Phase B: Split Oversized / Mixed-Concern Files

### B1. Split `issues_provider.dart`
**Path:** `issues/providers/issues_provider.dart` (92 lines)

Currently mixes 4 unrelated providers:
- `WeeklyReleasesNotifier` → move to `releases/providers/weekly_releases_provider.dart`
- `focReleasesProvider` → move to above file (same concern)
- `SelectedWeek` → move to `releases/providers/selected_week_provider.dart`
- `IssueDetailsNotifier` → keep in `issue_details_provider.dart` (rename file)

**Update:** Replace all `import 'issues_provider.dart'` with specific imports.
**Regenerate:** `dart run build_runner build` for the moved `@riverpod` classes.

### B2. Split `collection_items_provider.dart`
**Path:** `library/providers/collection_items_provider.dart` (~537 lines)

Split into:
- `collection_items_provider.dart` — main collection item providers only
- `library_items_serialization.dart` — JSON serialization helpers
- `collection_cache_helpers.dart` — cache invalidation functions
- `reading_history_provider.dart` — `ReadingHistoryEntry` + `readingHistoryCollectionItemsProvider`

### B3. Extract `SubscriptionPullReconciler` from `pulls_provider.dart`
**Path:** `library/providers/pulls_provider.dart` (~250 lines)

Extract `SubscriptionPullReconciler` class (119 lines) into `library/providers/subscription_pull_reconciler.dart`.

**Risk:** Medium. Requires moving imports and regenerating `.g.dart` files. Verify with analyze.

---

## Phase C: Extract Inline Private Widgets from Massive Screen Files

### C1. `issue_details_screen.dart` (1426 lines)
Extract into `issue_details/`:
- `_issueSeriesNavigationProvider` + args/result classes → `issue_details/providers/issue_series_navigation_provider.dart`
- `_IssueDetailsSheet` (292 lines) → `issue_details/issue_details_sheet.dart`
- `_IssueDetailsSkeleton` (64 lines) → `issue_details/issue_details_skeleton.dart`
- `_showIssueMoreOptionsSheet` (48 lines) → `issue_details/issue_more_options_sheet.dart`

### C2. `profile_screen.dart` (1015 lines)
Extract into `profile/widgets/`:
- `_StatCard` → `profile/widgets/stat_card.dart`
- `_InsightRow` → `profile/widgets/insight_row.dart`
- `_EditProfileSheet` → `profile/widgets/edit_profile_sheet.dart`
- `_ProfileHeader` → `profile/widgets/profile_header.dart`
- `_ProfileLoadingView` → `profile/widgets/profile_loading_view.dart`
- `_DottedRoundedBorderPainter` → `profile/widgets/dotted_rounded_border_painter.dart`

### C3. `settings_screen.dart` (1323 lines)
Extract into `settings/widgets/`:
- Each settings section as its own file (Metron, Notifications, Appearance, Collection, Data & Storage, About, Performance)
- `_SettingsNavTile` → `settings/widgets/settings_nav_tile.dart`
- `_buildSettingsGroup`, `_buildSettingsRow`, `_buildSectionHeader` — extract as helpers

**Risk:** Low-Medium. Pure extraction of private classes into public ones. No behavioral change.
**Verification:** `dart analyze` must remain clean after each phase.

---

## Phase D: Extract Duplicated Patterns Into Reusable Components

### D1. Generic `PagedSearchSection<T>` widget
**Pattern:** 6 near-identical paged result section blocks in `search_results_screen.dart` (~900 duplicated lines).
**New file:** `components/paged_search_section.dart`
**Parameters:** `entityType`, `pageAsync`, `emptyMessage`, `emptyIcon`, `itemBuilder`, `sortLabel`, `onSortTap`, `pageEstimator`
**Saves:** ~700 lines from `search_results_screen.dart`.

### D2. `DetailScreenSkeleton` shared component
**Pattern:** 5 private skeleton classes across detail screens (issue, series, character, creator, reading-list).
**New file:** `components/detail_screen_skeleton.dart`
**Parameters:** `imageUrl`, `title`
**Saves:** ~300 lines across 5 files.

### D3. Entity detail action buttons widget
**Pattern:** Share/browser/favorites toggle repeated across 6 detail screens.
**New file:** `components/entity_detail_actions.dart`
**Parameters:** `onShare`, `onOpenInBrowser`, `isFavorite`, `onToggleFavorite`
**Saves:** ~60 lines per screen.

### D4. Extract `_initials()` to shared utility
**Pattern:** Identical function in 6 component files (`person_card`, `person_list_tile`, `universe_card`, `universe_list_tile`, `imprint_card`, `imprint_list_tile`).
**New location:** `presentation/logic/string_extensions.dart` or similar.
**Saves:** ~8 lines per file.

**Risk:** Low. Pure extraction — test via analyze.

---

## Phase E: Merge Tiny Single-Use Files Into Parent

| # | File (lines) | Currently Used By | Action |
|---|---|---|---|
| E1 | `reading_list_timeline_tile.dart` (~49 lines) | Only `reading_list_details_screen.dart` | Merge inline into `reading_list_details_screen.dart` |
| E2 | `reading_list_cover.dart` (~170 lines) | Only `reading_list_card.dart` | Merge inline into `reading_list_card.dart` |
| E3 | `reading_list_grid_item.dart` (~110 lines) | `reading_list_details_screen.dart` + `reading_list_edit_screen.dart` | Keep separate (shared) |

**Rationale:** Files used by only one parent add indirection without benefit. Merging reduces file count and makes navigation more direct.
**Risk:** Low. Inline the class definition and delete the file. Update imports.

---

## Estimated Impact Summary

| Phase | Files Changed | Files Deleted | Lines Removed | Risk |
|---|---|---|---|---|
| A | 4 moved + 8 import updates | 0 | 0 | Low |
| B | 3 split → ~10 new | 2-3 removed | 0 | Medium |
| C | 3 massive screens → ~18 new | 0 | 0 | Low-Med |
| D | `search_results_screen.dart` + 5 others | 0 | ~1,000 (duplication) | Low |
| E | 2 parents | 2 | ~220 (file overhead) | Low |

**Verification:** `dart analyze lib/` after each phase must return "No issues found".
