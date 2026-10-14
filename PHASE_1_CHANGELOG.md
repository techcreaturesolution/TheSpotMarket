# Phase 1 Changelog — Core Architecture & Foundation Hardening

## Summary of Changes

### 1. Secure PAN Local Storage Integration
- **File**: `lib/services/storage_service.dart`
- **Change**: Replaced plain `SharedPreferences` storage for PAN profiles with encrypted local storage (`FlutterSecureStorage`).
- **Rationale**: Phase 0 audit identified that sensitive PAN profiles were stored in plaintext JSON within standard `SharedPreferences`. `FlutterSecureStorage` uses KeyStore on Android and Keychain on iOS/macOS to encrypt sensitive user data.
- **Risk Level**: Low.
- **Behavior Change**: None for end-user UI. Storage mechanism for PAN profile lists is now encrypted.

### 2. Automatic Legacy PAN Migration Strategy
- **File**: `lib/services/storage_service.dart`
- **Change**: Added `_migrateAndLoadProfiles()` inside `StorageService.create()`.
- **Rationale**: Existing users with PAN profiles stored in unencrypted `SharedPreferences` under key `pan_profiles` automatically have their data migrated to `FlutterSecureStorage` key `secure_pan_profiles` on app startup. Plaintext `pan_profiles` keys are erased immediately after successful migration to prevent data leaks.
- **Risk Level**: Low.
- **Behavior Change**: Seamless migration without data loss or duplicate profiles.

### 3. Dependency Declaration
- **File**: `pubspec.yaml`
- **Change**: Added `flutter_secure_storage` dependency (`^11.1.1`).
- **Rationale**: Required for hardware-backed encrypted storage of PAN profiles.
- **Risk Level**: Low.
- **Behavior Change**: None.

### 4. Analyzer Diagnostics Cleanup
- **Files**:
  - `lib/screens/ipo_screens.dart`
  - `lib/widgets/curved_nav_bar.dart`
  - `test/core_test.dart`
- **Changes**:
  - Removed unused private `_Pill` widget class from `ipo_screens.dart`.
  - Removed redundant `import 'dart:ui';` and unused state field `_currentIndex` from `curved_nav_bar.dart`.
  - Fixed `prefer_const_declarations` lints in `core_test.dart`.
  - Removed unused `dart:convert` import from `core_test.dart`.
- **Rationale**: Eliminates all static analyzer warnings and infos to ensure a clean codebase.
- **Risk Level**: Zero.
- **Behavior Change**: None. `flutter analyze` now reports **No issues found!** (0 errors, 0 warnings, 0 infos).

### 5. Automated Unit Test Additions
- **File**: `test/core_test.dart`
- **Change**: Added two new test cases:
  - `saves and loads PAN profiles in secure storage`
  - `migrates legacy unencrypted SharedPreferences PAN profiles to secure storage`
- **Rationale**: Ensures code-level verification and prevents regression in PAN storage security and migration logic.
- **Risk Level**: Zero.
- **Behavior Change**: Total passing tests increased from 8 to 10.

---

## Detailed File Modification Log

| File Path | Component | Description of Change | Risk Level |
| --- | --- | --- | --- |
| [pubspec.yaml](file:///c:/TCS-P/TheSpotMarket/pubspec.yaml) | Dependencies | Added `flutter_secure_storage` dependency | Low |
| [storage_service.dart](file:///c:/TCS-P/TheSpotMarket/lib/services/storage_service.dart) | Services | Implemented `FlutterSecureStorage` for PAN profiles & automatic migration from `SharedPreferences` | Low |
| [ipo_screens.dart](file:///c:/TCS-P/TheSpotMarket/lib/screens/ipo_screens.dart) | Screens | Removed unused `_Pill` class | Low |
| [curved_nav_bar.dart](file:///c:/TCS-P/TheSpotMarket/lib/widgets/curved_nav_bar.dart) | Widgets | Removed redundant `dart:ui` import and unused `_currentIndex` field | Low |
| [core_test.dart](file:///c:/TCS-P/TheSpotMarket/test/core_test.dart) | Tests | Added PAN secure storage & migration unit tests; fixed const declaration lints | Low |
