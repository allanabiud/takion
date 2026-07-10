# Six Local-Only Features for Takion

Implementation plan for 6 features using only local storage (no new API calls).

---

## 1. Collection Value Calculator

**Effort:** 15 min | **Files:** 2

Compute `totalValue` from `pricePaid × quantityOwned` instead of hardcoded `'--'`.

- `lib/src/domain/entities/collection_stats.dart` — keep `String totalValue` type
- `lib/src/presentation/features/library/providers/collection_stats_provider.dart` — replace `totalValue: '--'` with formatted currency

---

## 2. Reading Goals

**Effort:** 1 hr | **Files:** 4

Set a monthly/yearly reading target and track progress with a progress bar.

- **New:** `lib/src/presentation/features/settings/providers/reading_goal_provider.dart` — `AsyncNotifierProvider` using Hive `settings_box`
- **New:** `lib/src/presentation/features/profile/widgets/reading_goal_card.dart` — card with progress bar, edit/clear actions
- **Modified:** `lib/src/presentation/features/profile/profile_screen.dart` — insert card into scrollable slivers

---

## 3. Series Completion Tracker

**Effort:** 45 min | **Files:** 3

Show owned vs total issues per series with a progress bar.

- **New:** `lib/src/presentation/features/series/providers/series_completion_provider.dart` — `FutureProvider.family` computing owned/total
- **Modified:** `lib/src/presentation/features/series/series_list_tile.dart` — add mini progress bar
- **Modified:** `lib/src/presentation/features/series/series_details_screen.dart` — add completion card

---

## 4. Streak Calendar

**Effort:** 1.5 hr | **Files:** 3

GitHub-style contribution heatmap showing 52 weeks of reading activity.

- **New:** `lib/src/presentation/features/profile/widgets/streak_calendar_widget.dart` — heatmap grid widget
- **Modified:** `lib/src/presentation/features/profile/providers/profile_insights_provider.dart` — expose `dailyReadActivity` list
- **Modified:** `lib/src/presentation/features/profile/profile_screen.dart` — add below reading trends chart

---

## 5. Collection Export (CSV)

**Effort:** 30 min | **Files:** 2

Export the full collection to a CSV file using `file_picker`.

- **New:** `lib/src/core/export/collection_csv_export.dart` — utility function
- **Modified:** `lib/src/presentation/features/settings/widgets/data_storage_settings.dart` — add export tile

---

## 6. Custom Tags

**Effort:** 3 hr | **Files:** 8

Create, manage, and assign tags to issues; filter library by tag.

- **New:** `lib/src/domain/entities/tag.dart` — plain `Tag` class (no code-gen)
- **New:** `lib/src/presentation/features/tags/providers/tag_provider.dart` — CRUD notifier with Hive `tags_box`
- **New:** `lib/src/presentation/features/tags/widgets/tag_manager_sheet.dart` — create/edit/delete
- **New:** `lib/src/presentation/features/tags/widgets/tag_selector_sheet.dart` — assign to issues
- **Modified:** `lib/src/presentation/features/issue/issue_details_screen.dart` — tag assignment entry point
- **Modified:** `lib/src/presentation/features/library/library_screen.dart` — tag filter chips
- **Modified:** `lib/src/presentation/features/settings/widgets/collection_settings.dart` — tag management entry

---

**Total:** ~7 hours across ~22 files
