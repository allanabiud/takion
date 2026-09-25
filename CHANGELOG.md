# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-09-25

### Added

- **Metron-First Data & Sync Infrastructure**: Direct Metron API client layer with dedicated `CollectionSyncManager`, `WishlistSyncManager`, and `PullListSyncManager`.
- **Offline Write Queue**: Persistent offline queue ensuring all local mutations (collected, read, wishlist, rating) save instantly to SQLite and synchronize to Metron in the background.
- **Incremental Sync**: Optimized sync using `modified_gt` timestamps and 404-idempotent remote handling.
- **Migration Manager**: Seamless one-time data migration pipeline with rate-limit-aware batching and progress tracking.
- **Unified Series Screen**: Consolidated library series and series details into a master screen with multi-select triage, filter chips, and gap finder.
- **Reading Lists & Favorites Tracking**: Local reading list creation, arc importing, and favorites support.
- **SQL Aggregate Stats & Analytics**: Drift SQL aggregates for collection analytics, monthly/yearly spending trends, and offline fallback search.
- **Backup Hardening**: Google Drive and local backup checksum validation, pre-restore preview, and rollback safety.
- **Pull-to-Refresh on Releases**: Added pull-to-refresh to Weekly Releases, FOC Calendar, New #1s, and My Pulls.
- **Unified Takion Alerts**: Integrated flash alert notifications for clipboard copy actions (SKU, UPC/ISBN) and library updates.

### Changed

- **Compact Week Picker**: Redesigned week navigation bar with left-aligned title, grouped compact controls (`<`, `📅`, `>`), and removed the NCBD countdown badge to maximize vertical screen space.
- **Opt-in Hero Transitions**: Made Hero animations opt-in on issue covers to prevent jarring cross-route flight artifacts and disappearing covers during navigation.
- **Stream Debouncing**: Added 16ms status stream debouncing to prevent UI jitter during bulk background syncs and backup restores.
- **Atomic Ownership Transitions**: Wrapped collection/wishlist status mutations in atomic Drift database transactions to guarantee mutual exclusivity.
- Replaced discontinued `flutter_markdown` with `flutter_markdown_plus`.

### Removed

- Removed legacy SuperHero API integration and obsolete endpoints.

## [1.3.5] - 2026-08-17

### Added

- Animated app bar title that slides continuously between Home, Releases and Library tabs.

### Changed

- Made series issue list pull-to-refresh robust so a failed refresh no longer clears the list.
- Improved scroll-to-top FAB with smooth fade/scale in and out.
- Increased favorite indicator contrast on covers.

### Fixed

- Fixed type cast crash when the Metron API returns a 304 Not Modified for series issue lists.
- Added friendly fallback for unexpected type cast errors.

## [1.3.0] - 2026-08-16

### Added

- Scroll-to-top FAB on long lists.
- Unified series and category bulk action sheets with All / Issue range selection.
- Search history chips with live bulk-action counter.
- In-app changelog sheet.

### Changed

- Refined transitions, series tile skeletons and tactile haptics.
- Overhauled content layouts, grid/list density toggles and PinnedListHeader collapse behavior.
- Throttled drive auto-sync and deferred full snapshot uploads.
- Updated favorite indicators across cards and list tiles to use a rounded square container matching the detail-screen action button style.

### Fixed

- Resolved imprint publisher name from the local database.
- Fixed series pagination, cover fallbacks and subscription card hydration.

## [1.2.0] - 2026-08-15

### Added

- Local catalog repository with paged cache and drive sync delta primitives.
- Rate-limit priority queue and request scheduling.

### Changed

- Performance improvements across library catalog screens.
- Aligned Metron API usage with supporter tier rate limits.

### Fixed

- Cache cleanup and arc issue list 304 handling with subscription card cover fixes.

## [1.1.0] - 2026-08-06

### Changed

- Maintenance release with no notable user-facing changes.

## [1.0.0] - 2026-08-05

### Added

- SuperHero API character powerstats.
- Import arcs as reading lists.

### Changed

- Improved drive sync reliability with true-delta sync and sync UI polish.

## [0.9.5] - 2026-08-03

### Added

- Barcode scanner with bulk actions.
- Scrobble sheet.
- Google Drive sync, local backup/restore and weekly pull-list notifications.

### Changed

- Migrated from Hive to Drift and from the Metron REST API to the Arc API.
- Redesigned stats UI with activity log series-aware grouping.

### Fixed

- Fixed scrobble, subscribe and sync issues including subscription card hydration.

## [0.9.0] - 2026-03-06

### Added

- Metron-powered search and issue/series details.
- Local library database.
- Onboarding, home, settings and notifications.

### Fixed

- Various bug fixes including notification navigation and library performance issues.
