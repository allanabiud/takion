# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
