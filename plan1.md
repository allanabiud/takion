# App Improvements Plan

Ordered from least effort to most effort.

---

## 1. Fix silent error swallowing (`catch (_) {}`)

- **Effort:** ~2–4 hours
- ~89 `try` blocks across the codebase, many with empty `catch (_) {}`.
- Pass to inspect each one and decide: log it, show a user-facing error, or add a comment explaining why swallowing is intentional.
- Focus on the most impactful patterns in:
  - Providers (`favorites_provider.dart`, `home_trending_provider.dart`)
  - Repository implementations (`metron_repository_impl_releases.dart`)

---

## 2. Add structured logging

- **Effort:** ~4–6 hours
- Pick a logging package (e.g., `logging` from dart:core, or `talker`, or `logger`).
- Replace all 24 `debugPrint()` calls with structured log statements with levels (info, warning, error).
- Add context-aware logging in key areas:
  - Sync service (already has some)
  - API calls
  - Background tasks

---

## 3. Add tests

- **Effort:** ~40–80+ hours (ongoing)
- Add `mockito` or `mocktail` for mocking.
- Start with critical paths: sync logic, storage layer, key providers.
- Add widget tests for main screens.
- Add integration tests for core flows.
- This is the highest-impact, highest-effort item.
