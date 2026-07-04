# Arc Entity — Full Implementation Plan

## Overview

Implement the Arc entity end-to-end: API models → data layer → providers → UI → search integration → entry point from Issue About tab.

## API Endpoints

- `GET /api/arc/` — list/search arcs (`?name=`, `?page=`, `?cv_id=`, `?gcd_id=`, `?modified_gt=`)
- `GET /api/arc/{id}/` — arc details
- `GET /api/arc/{id}/issue_list/` — issues in this arc

### API Response Shapes

**List item:** `{ id, name, modified }`
**Detail:** `{ id, name, desc, image, cv_id, gcd_id, resource_url, modified }`
**Issue list item:** standard issue list shape (same as character/series issue lists)

---

## Files to Create (10)

| # | File | Pattern |
|---|------|---------|
| 1 | `lib/src/domain/entities/arc_details.dart` | `TeamDetails` |
| 2 | `lib/src/domain/entities/arc_list.dart` | `TeamList` |
| 3 | `lib/src/domain/entities/arc_list_page.dart` | `TeamListPage` |
| 4 | `lib/src/domain/entities/arc_issue_list_page.dart` | `CharacterIssueListPage` |
| 5 | `lib/src/data/dto/arc_details_dto.dart` | `TeamDetailsDto` |
| 6 | `lib/src/data/dto/arc_list_dto.dart` | `TeamListDto` |
| 7 | `lib/src/data/dto/arc_list_response_dto.dart` | `TeamListResponseDto` |
| 8 | `lib/src/presentation/components/arc_list_tile.dart` | `TeamListTile` |
| 9 | `lib/src/presentation/components/arc_card.dart` | `TeamCard` |
| 10 | `lib/src/presentation/features/arcs/arc_details_screen.dart` | `TeamDetailsScreen` (skip DETAILS section) |
| 11 | `lib/src/presentation/features/arcs/arc_issues_screen.dart` | `CharacterIssuesScreen` |
| 12 | `lib/src/presentation/features/arcs/providers/arc_details_provider.dart` | `teamDetailsProvider` |
| 13 | `lib/src/presentation/features/arcs/providers/arc_search_provider.dart` | `teamSearchResultsProvider` |
| 14 | `lib/src/presentation/features/arcs/providers/arc_issue_list_provider.dart` | `characterIssueListProvider` |

## Files to Modify (18)

| # | File | Change |
|---|------|--------|
| 15 | `lib/src/data/datasources/metron_remote_data_source.dart` | Add `searchArcs`, `getArcDetails`, `getArcIssueList` |
| 16 | `lib/src/data/datasources/metron_local_data_source.dart` | Add arc box constants, cache meta class, cache/get/invalidate methods |
| 17 | `lib/src/core/storage/hive_service.dart` | Add arc boxes to `_recoverableCacheBoxes` |
| 18 | `lib/src/core/cache/cache_policy.dart` | Add `arcSearchResults`, `arcDetails`, `arcIssueList` policies |
| 19 | `lib/src/domain/repositories/catalog_repository.dart` | Add `searchArcs`, `getArcDetails`, `getArcIssueList` |
| 20 | `lib/src/domain/repositories/metron_repository.dart` | Same 3 methods |
| 21 | `lib/src/data/repositories/metron_repository_impl.dart` | Implement with caching, background refresh, concurrency gate |
| 22 | `lib/src/core/router/app_router.dart` | Add `ArcDetailsRoute` and `ArcIssuesRoute` |
| 23 | `lib/src/presentation/features/search/providers/search_state_provider.dart` | Add `arcs` to `SearchTarget` enum |
| 24 | `lib/src/presentation/features/home/main_screen.dart` | Add arcs choice chip |
| 25 | `lib/src/presentation/features/search/search_results_screen.dart` | Add `_isArcSearch`, `_buildArcBody`, wire into pagination |
| 26 | `lib/src/presentation/logic/content_sorting.dart` | Add `SortPreferenceContext.searchArcs`, `sortArcs()`, `arcSortLabel()` |
| 27 | `lib/src/presentation/features/issues/issue_details/issue_about_content.dart` | Add arcs section + teams section + universes section + altNumber + volume to DETAILS |

## Implementation Order

### Phase 1: Data Layer (files 1–7, 15–21)
Domain entities → DTOs → Remote datasource → Local datasource → Hive → Cache policies → Repository interface → Repository impl

### Phase 2: Providers (files 12–14)
Details provider → Search provider → Issue list provider

### Phase 3: UI Components (files 8–11, 22)
List tile → Card → Detail screen → Issue list screen → Router registration → `build_runner`

### Phase 4: Search Integration (files 23–25, 26)
SearchTarget enum → Main screen chip → Search results body → Content sorting

### Phase 5: Issue About Tab (file 27)
Arc section + Teams section + Universes section + altNumber + volume

### Phase 6: Build + Verify
Run analyzer, fix issues

---

## Arc Detail Screen Layout

```
─────────────────────────
   [blurred bg + image]
   [AppBar with share/browser actions]
─────────────────────────
   [DraggableScrollableSheet]
   ┌─────────────────────┐
   │  Arc Name            │
   │  ─────────────────── │
   │                      │
   │  [ISSUES Section]    │
   │  ISSUES ─────────── >│
   │  [IssueCard x 5]     │
   │                      │
   │  [DATABASE IDS]      │
   │  Metron CV GCD       │
   │                      │
   │  Last modified: ...  │
   └─────────────────────┘
```

No DETAILS InfoGrid section (skip per user request). Just name, issues preview, database IDs, and last modified.

## Issue About Tab — New Sections Order

```
SUMMARY → CREATORS → CHARACTERS → TEAMS (new) → STORIES → ARCS (new)
→ DETAILS (altNumber + volume added) → REPRINTS → IMPRINT
→ UNIVERSES (new) → GENRES → DATABASE IDS → Last modified
```
