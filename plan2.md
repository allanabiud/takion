# Cleanup Plan — Remaining Items

## Item A: Replace `http` with `dio` in `drive_backup_service.dart`

### Background
- `drive_backup_service.dart` is the **only file** still using `package:http/http.dart`
- `dio` is already a dependency (`dio: ^5.9.1`) and used everywhere else
- `http: ^1.3.0` can be removed from `pubspec.yaml` after migration

### All 8 `http` calls to replace

| # | Current `http` API | Replace with `dio` | Lines |
|---|---|---|---|
| 1 | `http.get(url, headers)` — find app folder | `_dio.get(url, queryParameters: {...}, options: Options(headers: {...}))` | 63–66 |
| 2 | `http.post(url, headers, body: jsonEncode(...))` — create folder | `_dio.post(url, data: {...}, options: Options(headers: {...}))` | 83–93 |
| 3 | `http.get(url, headers)` — find backup file | `_dio.get(url, queryParameters: {...}, options: Options(headers: {...}))` | 111–114 |
| 4 | `http.get(url, headers)` — get createdTime | `_dio.get(url, queryParameters: {'fields': 'createdTime'}, options: Options(headers: {...}))` | 133–136 |
| 5 | `http.get(url, headers)` — get modifiedTime | `_dio.get(url, queryParameters: {'fields': 'modifiedTime'}, options: Options(headers: {...}))` | 154–157 |
| 6 | `http.get(url, headers)` → `response.bodyBytes` — download bytes | `_dio.get(url, queryParameters: {'alt': 'media'}, options: Options(responseType: ResponseType.bytes, headers: {...}))` → `response.data as Uint8List` | 172–175 |
| 7 | `http.Request(method, url)` + `request.send()` + `http.Response.fromStream()` — multipart upload | `_dio.post/patch(url, queryParameters: {'uploadType': 'multipart'}, data: formData, options: Options(headers: {...}))` using `FormData.fromMap({...})` with `MultipartFile` | 290–299 |
| 8 | `http.delete(url, headers)` — delete backup | `_dio.delete(url, options: Options(headers: {...}))` | 457–460 |

### Key changes needed
- **Remove `import 'package:http/http.dart' as http;`** (line 7)
- **Add `import 'package:dio/dio.dart';`** (line 6, before google_sign_in)
- **Create a local Dio instance** in the class (no base URL, since Google Drive URLs are full):
  `final _dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 10), receiveTimeout: Duration(seconds: 10)));`
- **Remove `_multipartBody()` method** (lines 310–329) — Dio's `FormData` handles multipart natively
- **Remove all `jsonDecode(response.body)`** calls (lines 71, 97, 119, 138, 159, 305) — use `response.data` directly
- **Remove all `Uri.encodeComponent()`** calls (lines 57–59, 104–106) — Dio auto-encodes `queryParameters`
- **Remove all `Uri.parse()`** calls — Dio accepts string URLs
- **Use `validateStatus`** in `Options` to preserve the null-on-404 pattern: `validateStatus: (status) => status == 200 || status == 404`
- **Remove `dart:convert` import** if `jsonEncode`/`jsonDecode` are no longer needed
- **Remove `http: ^1.3.0`** from `pubspec.yaml` (line 40)

### Steps
1. Add `dio` import + local Dio instance field
2. Replace all 8 http calls one-by-one with dio equivalents
3. Delete `_multipartBody()` method
4. Remove all `jsonDecode`, `Uri.encodeComponent`, `Uri.parse` calls
5. Remove `import 'package:http/http.dart' as http;`
6. Remove `http: ^1.3.0` from `pubspec.yaml`
7. Run `flutter pub get` + `flutter analyze`

---

## Item B: Major Package Upgrades

### B1. `fl_chart 0.70.2 → ^1.2.0`

**Usage:** 1 file (`profile_charts.dart`) — LineChart + BarChart

**Risk:** **High** — Major version jump (12 minor versions). Likely API changes in:
- `SideTitleWidget` constructor params
- `FlDotCirclePainter` constructor
- `LineTooltipItem`/`BarTooltipItem` constructors
- `BackgroundBarChartRodData` (may be renamed/removed)
- `BarTouchTooltipData.getTooltipItem` signature

**Steps:**
1. Bump constraint to `fl_chart: ^1.2.0` in `pubspec.yaml`
2. Run `flutter pub get`
3. Fix compile errors in `profile_charts.dart` iteratively:
   - Run `flutter analyze` after each fix
   - Check `SideTitleWidget`, `FlDotCirclePainter`, `LineTooltipItem`, `BarTooltipItem`, `BackgroundBarChartRodData`, `BarTouchTooltipData` for API changes
   - Update constructor params to match 1.x API
4. Verify the chart renders correctly at runtime

### B2. `flutter_local_notifications 18.0.1 → ^22.0.1`

**Usage:** **None** — package is completely unused. Zero imports anywhere in `lib/`.

**Steps:**
1. Just **remove** `flutter_local_notifications: ^18.0.1` from `pubspec.yaml`
2. Run `flutter pub get` + `flutter analyze`

### B3. `google_sign_in 6.3.0 → ^7.2.0`

**Usage:** 1 file directly (`drive_backup_service.dart`) + 2 files indirectly via `DriveBackupService`

**Risk:** **Medium** — Auth API changes in v7.

**Current APIs used:**
| API | Where |
|---|---|
| `GoogleSignIn(scopes: [...])` | Constructor in `drive_backup_service.dart` |
| `.signIn()` → `Future<GoogleSignInAccount?>` | `onboarding_screen.dart` via wrapper |
| `.signInSilently()` → `Future<GoogleSignInAccount?>` | `app.dart` via wrapper |
| `.signOut()` → `Future<void>` | `drive_backup_service.dart` |
| `.currentUser` → `GoogleSignInAccount?` | `drive_backup_service.dart` + `onboarding_screen.dart` |
| `user.authentication` → `GoogleSignInAuthentication` | `drive_backup_service.dart` |
| `auth.accessToken` → `String?` | `drive_backup_service.dart` |

**Potential breaking changes:**
- `GoogleSignIn` constructor — `signInOption` removed/renamed
- `signInSilently()` — may throw instead of returning null when not authenticated
- `authentication` → may be renamed to `getAuth()` or similar

**Steps:**
1. Review `google_sign_in` v7 changelog at https://pub.dev/packages/google_sign_in/changelog
2. Bump constraint to `google_sign_in: ^7.2.0` in `pubspec.yaml`
3. Run `flutter pub get`
4. Fix any compile errors (likely around `authentication` property and `signInSilently` error handling)
5. Run `flutter analyze`

### B4. `package_info_plus 8.3.1 → ^10.2.1`

**Usage:** 2 files — `backup_service.dart` and `about_settings.dart`

**Risk:** **Low** — Minor API changes.

**Current APIs:**
| API | Usage |
|---|---|
| `PackageInfo.fromPlatform()` | Static factory — both files |
| `.version` → `String?` | Both files |
| `.buildNumber` → `String?` | Both files |

**Potential breaking:**
- `PackageInfo.fromPlatform()` may have changed return type or become synchronous

**Steps:**
1. Bump constraint to `package_info_plus: ^10.2.1` in `pubspec.yaml`
2. Run `flutter pub get`
3. Fix any property access changes
4. Run `flutter analyze`

### B5. `share_plus 11.1.0 → ^13.2.1`

**Usage:** 11 files — all using `SharePlus.instance.share(ShareParams(...))`

**Risk:** **Low-Medium** — Already on modern API (v11+).

**Current API pattern (used in all 11 files):**
```dart
await SharePlus.instance.share(
  ShareParams(text: uri.toString(), subject: details.name),
);
```
Plus file sharing (1 file):
```dart
SharePlus.instance.share(
  ShareParams(files: [XFile(file.path)], subject: ..., text: ...),
);
```

**Potential breaking:**
- `SharePlus.instance` singleton pattern may change
- `ShareParams` constructor params may have changed
- `XFile` may be replaced by `ShareXFile`

**Steps:**
1. Review changelog: https://pub.dev/packages/share_plus/changelog
2. Bump constraint to `share_plus: ^13.2.1`
3. Run `flutter pub get`
4. Fix `SharePlus.instance` / `ShareParams` constructor if needed
5. Update `XFile` if API changed
6. Run `flutter analyze`

### Upgrade Order (recommended)
1. `package_info_plus` (lowest risk) → verify
2. `share_plus` → verify
3. `google_sign_in` → verify
4. `fl_chart` (highest risk, do last) → verify
5. Remove `flutter_local_notifications` (zero usage) → verify

---

## Item C: Barrel Exports

### Motivation
- **Zero barrel files exist** — all 220+ imports are deep-path individual file imports
- `domain/entities/` alone has **324 import lines** across **155 files**
- `data/dto/` has **~85 import lines** from 2 datasource files
- Barrel files reduce import lines, simplify refactoring, and define module boundaries

### Priority Order

#### P0: `domain/entities/entities.dart`
- 46 entity files, **324 import lines** across 155 consumer files
- Single barrel eliminates hundreds of individual imports
- Example: `metron_repository.dart` goes from 26 imports → `import 'package:takion/src/domain/entities/entities.dart'`
- **Steps:**
  1. Create `lib/src/domain/entities/entities.dart` with `export` for all 46 entity files
  2. Update all 155 consumer files to use the barrel
  3. Keep individual imports only where a single entity is needed and no other entities are consumed

#### P0: `data/dto/dto.dart`
- 36 DTO files, ~85 import lines from 2 main consumers
- `metron_remote_data_source.dart` (24 DTO imports) → 1 barrel import
- `metron_local_data_source.dart` (18 DTO imports) → 1 barrel import
- **Steps:**
  1. Create `lib/src/data/dto/dto.dart` with `export` for all 36 DTO files
  2. Update consumers

#### P1: `domain/repositories/repositories.dart`
- 7 repository interface files, consumed together in groups
- `repository_providers.dart` imports 4 at once
- **Steps:**
  1. Create `lib/src/domain/repositories/repositories.dart`
  2. Update consumers

#### P1: `presentation/providers/providers.dart`
- 8 app-wide providers, screens import 2–4 at a time
- **Steps:**
  1. Create `lib/src/presentation/providers/providers.dart`
  2. Update consumers

#### P1: `presentation/components/components.dart`
- 31 reusable widgets — larger scope, consider sub-barrels
- **Consider splitting into:** `cards.dart`, `sheets.dart`, `layout.dart`, `misc.dart`
- **Steps:**
  1. Assess grouping based on actual import patterns
  2. Create barrel(s)
  3. Update consumers

#### P2+: Remaining directories
- `presentation/common/`, `presentation/logic/`, `data/repositories/`, `data/datasources/`
- Lower ROI — do after P0/P1

### Barrel file naming convention
Use plural descriptive names matching the directory:
- `domain/entities/entities.dart`
- `data/dto/dto.dart`
- `domain/repositories/repositories.dart`
- `presentation/providers/providers.dart`
- `presentation/components/components.dart`

### Verification
- After each barrel addition: `flutter analyze` must pass
- Generated files (`.freezed.dart`, `.g.dart`, `.gr.dart`) should NOT be exported from barrels — they are implementation details
