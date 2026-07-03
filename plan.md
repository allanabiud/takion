# Plan: Eliminate Redundant Metron API Calls from Card Sub-widgets

## Goal
Card widgets (PersonCard, TeamCard, UniverseCard, ImprintCard, PublisherCard) currently fetch full entity details via Metron API just to get the image URL, even when the parent detail screen already has that data. Remove these background fetches and use a local image-URL cache so cards can show cached images after a detail screen visit.

## Approach

### Step 1: Add `imageUrl` prop to cards missing it
- `TeamCard` / `TeamListTile`
- `UniverseCard` / `UniverseListTile`
- `ImprintCard` / `ImprintListTile`
- `PublisherCard`
- `PersonCard` / `PersonListTile` — already have `imageUrl`, no change

### Step 2: Remove internal provider fetches from all card widgets
When `imageUrl` is null → show initials only, no API call.

### Step 3: Create Hive-backed `EntityImageCache`
- New file: `lib/src/core/cache/entity_image_cache.dart`
- Maps `"$entityType:$id" → imageUrl`
- Detail screen providers write to it after fetching
- Card widgets read from it as a local-only fallback

### Step 4: Wire image URL cache into detail screen providers
- `characterDetailsProvider`, `teamDetailsProvider`, `universeDetailsProvider`, `imprintDetailsProvider`, `publisherDetailsProvider`, `creatorDetailsProvider` — after successful fetch, write each related entity's imageUrl
- `issueDetailsProvider` — write image URLs for creators, characters, imprint

### Step 5: Remove ImageWidget from PersonCard fallback
Currently PersonCard/PersonListTile have a `_ImageWidget` that fetches. Replace with simple initials-only when no imageUrl.

### Step 6: Detail screens pass `imageUrl` to sub-widgets
- `IssueAboutContent` → PersonCard(imageUrl: credit.image), ImprintCard(imageUrl: issue.imprint?.image)
- `CharacterDetailsScreen` → TeamCard(imageUrl: ...), UniverseCard(imageUrl: ...), PersonCard(imageUrl: ...)
- `TeamDetailsScreen` → PersonCard(imageUrl: ...), UniverseCard(imageUrl: ...)

### Step 7: Clean up unused providers/code
Remove any providers that are no longer called from the cards (e.g., per-card details providers if they're only used by the cards).

## Files to modify
- `lib/src/core/cache/entity_image_cache.dart` (NEW)
- `lib/src/presentation/components/person_card.dart`
- `lib/src/presentation/components/person_list_tile.dart`
- `lib/src/presentation/components/team_card.dart`
- `lib/src/presentation/components/team_list_tile.dart`
- `lib/src/presentation/components/universe_card.dart`
- `lib/src/presentation/components/universe_list_tile.dart`
- `lib/src/presentation/components/imprint_card.dart`
- `lib/src/presentation/components/imprint_list_tile.dart`
- `lib/src/presentation/components/publisher_card.dart`
- `lib/src/presentation/components/publisher_list_tile.dart`
- `lib/src/presentation/features/issues/issue_details/issue_about_content.dart`
- `lib/src/presentation/features/characters/character_details_screen.dart`
- `lib/src/presentation/features/teams/team_details_screen.dart`
- `lib/src/presentation/providers/repository_providers.dart`

## Non-goals
- Reading list widgets (TimelineIssueTile, ReadingListGridItem, ReadingListCover, ReadingListTimelineTile) — these deliberately hydrate from minimal data, unchanged
- IssueCard collection/pull/favorite — local Hive reads, not Metron API, unchanged
