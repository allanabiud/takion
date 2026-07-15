# Deferred Items (blocked / future)

## B1. `fl_chart 0.70.2 → ^1.2.0`

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

## B4/B5. `package_info_plus ^10.x` / `share_plus ^13.x`

**Blocked by:** `file_picker ^11.0.2` requires `win32 ^5.9.0`, but both upgrades need `win32 ^6.0.1`. Resolve `file_picker` first or wait for upstream dependency alignment.

### `package_info_plus 8.3.1 → ^10.2.1`
- 2 files affected (`backup_service.dart`, `about_settings.dart`)
- Low risk — minor API changes expected
- Bump constraint → `flutter pub get` → fix compile errors → `flutter analyze`

### `share_plus 11.1.0 → ^13.2.1`
- 11 files affected
- Low-medium risk — already on v11+ modern API
- Review changelog → bump → fix `ShareParams`/`XFile` if needed → `flutter analyze`

## Item C: Barrel Exports

**Motivation:** Zero barrel files exist. ~324 import lines from `domain/entities/` alone. Reduce import noise and define module boundaries.

### Priority order
1. `domain/entities/entities.dart` (P0) — 46 entity files, 155 consumers
2. `data/dto/dto.dart` (P0) — 36 DTO files, 2 main consumers
3. `domain/repositories/repositories.dart` (P1) — 7 repository interfaces
4. `presentation/providers/providers.dart` (P1) — 8 app-wide providers
5. `presentation/components/components.dart` (P1) — 31 widgets, consider sub-barrels
6. P2+ remaining directories (lower ROI)

**Steps per barrel:** Create barrel with `export` for all files → update consumer imports → `flutter analyze` must pass.

**Naming convention:** Plural descriptive name matching directory (e.g. `entities.dart`, `dto.dart`). Do NOT export generated files (`.freezed.dart`, `.g.dart`, `.gr.dart`).
