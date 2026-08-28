# Contributing to Takion

Thank you for contributing to Takion! This document outlines our development workflows, code generation standards, testing guidelines and quality assurance processes.

---

## 🛠️ Development Setup & Prerequisites

- **Flutter SDK**: Use the version defined in `pubspec.yaml` (environment SDK `^3.11.0`).
- **Dependencies**: Install dependencies using:
  ```bash
  flutter pub get
  ```

---

## ⚙️ Code Generation (`build_runner`) Workflow

Takion uses code generation for **Drift** (database), **Riverpod** (state providers), **Freezed** (immutable models) and **AutoRoute** (navigation).

### Generating Code

- **One-off generation (standard)**:
  Run whenever schema files, `@riverpod` annotations, `@freezed` models or `@RoutePage()` annotations change:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- **Watch mode (active development)**:
  Continuously regenerates files as you edit code:
  ```bash
  dart run build_runner watch --delete-conflicting-outputs
  ```

### Rules for Generated Files

1. **Never edit generated files manually** (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`). Any manual edits will be overwritten during CI code generation checks.
2. Ensure all generated files are committed with the corresponding source file changes.
3. CI automatically verifies that generated files match source declarations by running `dart run build_runner build --delete-conflicting-outputs` and failing if git working tree is dirty.

---

## 🧪 Testing & Verification

Before submitting code, ensure all quality gates pass locally:

1. **Format verification**:

   ```bash
   dart format --output=none --set-exit-if-changed .
   ```

2. **Static analysis**:

   ```bash
   flutter analyze
   ```

3. **Automated test suite**:

   ```bash
   flutter test
   ```

4. **Android debug build verification**:
   ```bash
   flutter build apk --debug
   ```
