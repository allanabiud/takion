# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-11-07

### Added

- Tapping any date with read issues on the reading activity calendar heatmap opens a bottom sheet listing all issues read that day, complete with read counts, issue cover art, ratings, and timestamps.
- Interactive issue cover carousel with real-time finger drag tracking, adjacent cover peeking, spring physics, and fast-fling snapping when navigating between series issues.
- Subtle tactile haptic feedback when toggling favorites, switching reading history filters, changing calendar months, and navigating weeks.
- Android 14+ system predictive back gesture support.

### Changed

- Home screen search bar opening transition is now instant and fluid on first launch without frame drops or skipped animation.
- Publisher and imprint detail headers now display in styled rounded cards with background contrast matching universes, teams, and story arcs.
- In-memory image caching now dynamically adapts to your device pixel density (DPR) with a 120 MB maximum allocation limit, reducing RAM usage and preventing out-of-memory spikes during long catalog browsing.
- Soft keyboard now automatically dismisses when dragging through search results and history lists.
- Cold start time improved by deferring non-critical startup sync tasks until after the first frame renders.

## [2.1.1] - 2026-11-02

### Changed

- Detail screen headers now display larger images for universes, teams, story arcs, publishers, imprints, characters, and creators, with tighter spacing above and below so the image occupies more of the header without feeling crowded.
- Issue detail screen cover carousel now has a little more breathing room between the cover and the bottom sheet.
- Entity card and list tile images now load at higher resolution so covers and thumbnails are sharper.
- Reduced the gap after the Creators section in team and character detail screens.

## [2.1.0] - 2026-11-01

### Added

- Added a smooth cover slide transition when navigating between issues in the issue details screen.
- Reading history dates can now expand independently without collapsing others, with new expand all and collapse all controls.
- Added circular backgrounds behind header app bar buttons on detail screens for better contrast over covers and banners.
- The app now remembers Metron rate-limit cooldowns across restarts. If the server rate-limits you, background sync pauses and picks up again automatically once the window passes, instead of retrying into it.
- The Performance & Diagnostics sheet now shows live rate quota (burst and daily remaining), cache hit rate including 304 revalidations, pending changes in the sync queue with their age, and resolved sync conflicts.
- Added a "Copy Diagnostics Report" button for bug reports. The copied summary is stripped of tokens, authorization headers, and passwords before it ever leaves the device.
- Added a background sync schedule setting (Daily, Every 12 Hours, Every 6 Hours, Manual Only), with a random per-install offset so all installs don't contact the server at the same moment.
- Added cover date range filters (before/after a date) and a "not a solicitation" filter when browsing issues.
- Series lists now show publisher, series type, Comic Vine ID, and GCD ID where Metron provides them.
- Cover cards now show a badge while a change is waiting to sync, or when a local change was kept after a conflict.

### Changed

- Reading activity calendar heatmap now stays consistent with your full reading history and scrobbles.
- Refined entity card dimensions and image proportions across universes, creators, characters, teams, and story arcs.
- "Clear All Cache" in Settings is now "Rebuild Cache": it clears network metadata and cover images while keeping your library, reading lists, downloaded/pinned content, and offline changes waiting to sync. It also no longer fails midway if cover images can't be cleared.
- Background sync now runs at most 3 requests at a time with a slot kept free for foreground use, and full pagination scans run one at a time - browsing stays responsive while a sync is working.
- Screens open instantly from local data and validate against Metron in the background; browsing, reading, and edits keep working offline and sync later.
- Sync no longer restarts an interrupted scan from the first page, and a failed or partial sync never deletes local data.
- Foreground and background sync now take turns through a single scheduler instead of running over each other.
- Quick sequences like add-then-edit are combined into a single request to Metron instead of one per change.
- Retries after server errors and rate limits now wait as long as the server asks, with randomized jitter, instead of retrying in synchronized bursts.
- Background sync now uploads your offline changes before downloading new data.
- Updating from an older version carries over any changes still waiting to sync - nothing queued is lost.

### Fixed

- Fixed rating 0 being rejected by Metron with an error; setting a rating back to 0 now saves and syncs correctly.
- Fixed pull list sync deactivating series that are listed on other pages during a full sync - all pages are now collected before anything is removed.
- Fixed "Unknown Series" appearing instead of the real series title for some pull list entries.
- Fixed series and pull lists stopping after a single page when there is more data to load.
- The image cache size shown in Settings now reports the actual on-disk image cache instead of the database size.

## [2.0.0] - 2026-09-25

### Added

- Syncs your collection, wishlist, and pull lists directly with Metron.
- Collected, read, wishlist, and rating changes now save instantly and sync in the background - even when you're offline.
- Sync now transfers only what changed since the last sync instead of re-downloading everything, and handles items deleted on the server without errors.
- Existing data is migrated automatically on first launch after updating, with progress shown and safe pacing against Metron's rate limits.
- Library and series details are now one unified screen with multi-select, filter chips, and a gap finder for missing issues.
- Local reading lists, importing story arcs as reading lists, and favorites tracking.
- Collection statistics with monthly and yearly spending trends, plus search that works offline.
- Backups now verify their integrity, show a preview before restoring, and roll back automatically if a restore fails.
- Pull-to-refresh on Weekly Releases, FOC Calendar, New #1s, and My Pulls.
- Flash confirmation alerts when copying a SKU or UPC/ISBN and when updating your library.

### Changed

- Redesigned the week navigation bar with a compact layout and grouped controls.
- Hero animations on issue covers are now off by default to prevent covers disappearing during navigation.
- Reduced UI flicker during large background syncs and backup restores.
- Collection and wishlist status changes now apply together atomically, so an issue can never end up both collected and wishlisted.
- Updated the markdown renderer used in-app after the previous one was discontinued.

### Removed

- Removed the legacy SuperHero API integration and its obsolete endpoints.

## [1.3.5] - 2026-08-17

### Added

- Animated app bar title that slides continuously between Home, Releases and Library tabs.

### Changed

- Made series issue list pull-to-refresh robust so a failed refresh no longer clears the list.
- Improved scroll-to-top FAB with smooth fade/scale in and out.
- Increased favorite indicator contrast on covers.

### Fixed

- Fixed type cast crash when the Metron API returns a 304 Not Modified for series issue lists.
- Unexpected type errors now show a friendly message instead of crashing.

## [1.3.0] - 2026-08-16

### Added

- Scroll-to-top FAB on long lists.
- Unified series and category bulk action sheets with All / Issue range selection.
- Search history chips with live bulk-action counter.
- In-app changelog sheet.

### Changed

- Refined transitions, series tile skeletons and tactile haptics.
- Overhauled content layouts with grid/list density toggles and collapsing pinned section headers.
- Google Drive auto-sync now runs less often and waits for a quiet moment before uploading full snapshots.
- Favorite indicators on cards and list tiles now match the style used on the detail screen.

### Fixed

- Fixed imprint and publisher names not showing on series.
- Fixed series pagination, cover fallbacks, and subscription cards not loading their data.

## [1.2.0] - 2026-08-15

### Added

- Local caching for the catalog so screens load instantly, with smarter Google Drive sync.
- Requests to Metron are now prioritized, so the screen you're looking at loads first.

### Changed

- Performance improvements across library catalog screens.
- Adjusted Metron API usage to stay within supporter-tier rate limits.

### Fixed

- Fixed cache cleanup, arc issue lists not refreshing, and missing covers on subscription cards.

## [1.1.0] - 2026-08-06

### Changed

- Maintenance release with no notable user-facing changes.

## [1.0.0] - 2026-08-05

### Added

- Character power stats from the SuperHero API.
- Import arcs as reading lists.

### Changed

- Google Drive sync is more reliable, now sends only what changed, and the sync screen was polished.

## [0.9.5] - 2026-08-03

### Added

- Barcode scanner with bulk actions.
- Scrobble sheet for logging reads.
- Google Drive sync, local backup/restore and weekly pull-list notifications.

### Changed

- Switched to a new database and API backend for reliability and speed.
- Redesigned stats screen, with the activity log now grouped by series.

### Fixed

- Fixed scrobbling, subscribing, and sync issues, including subscription cards failing to load their data.

## [0.9.0] - 2026-03-06

### Added

- Metron-powered search and issue/series details.
- Local library database.
- Onboarding, home, settings and notifications.

### Fixed

- Various bug fixes including notification navigation and library performance issues.
