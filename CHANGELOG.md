
## 1.0.7+3

* **pub.dev Discoverability Improvements**:
  * Added `topics` to `pubspec.yaml` (`ui`, `widgets`, `networking`, `authentication`, `responsive`) — enables category-based search filtering on pub.dev.
  * Added `screenshots` to `pubspec.yaml` — four preview images now display as a carousel on the pub.dev package page.
  * Updated `description` to include the `CoreKit` alias, `screen_utils`-inspired responsive scaling, and additional search keywords (`JWT`, `OTP`, `Dio`, `paginated lists`, `forms`, `dialogs`) for improved discoverability.

## 1.0.7+2


* **Static Analysis Fixes**: Resolved all `lints_core` issues reported by pub.dev static analysis.
  * Fixed `INFO: Angle brackets will be interpreted as HTML` in `behavior_stream.dart` by wrapping the usage example in a `dart` fenced code block.
  * Fixed `INFO: Missing type annotation` in `profile_extractor.dart` by adding explicit `dynamic` type to `parseProfile(data)`.
  * Fixed `directives_ordering` lint in `ck_auth_service.dart` by sorting import sections correctly (`dart:` → `package:flutter` → other packages).
  * Fixed `avoid_annotating_with_dynamic` lint in `ck_auth_service.dart` by removing the redundant `dynamic` annotation on `_resolvePostSignupAuth`.
* **pub.dev SEO**: Added `topics` and `screenshots` to `pubspec.yaml` for improved discoverability and pub.dev page presentation.

## 1.0.7+1

* **Documentation Update**: Added the latest demo screenshots and a new preview video to the `README.md`.

## 1.0.7

* **Comprehensive Auth System Test Suite**: Created a robust, VM-friendly test plan and suite containing 164 unit, service, integration, edge-case, and backward-compatibility tests to validate the full authentication and OTP flow logic.
* **OTP & Mock Auth Bugfixes**:
  * Fixed a mock `sendOtp()` bug where active triggers and recipients were not stored, preventing subsequent verification checks.
  * Resolved an issue where the `_preSignupOtpVerified` flag was infinitely re-asserted in unified post-signup auth checks, ensuring it behaves correctly as a one-shot bypass.
  * Added test-only helpers and factories (`resetForTests()`, `seedForTests()`, and `initForTests()`) to fully isolate auth tests from disk and network dependencies.
* **Smart Text Field Capitalization**:
  * Added a validation-type check (`InputHelper.shouldCapitalize`) to disable text capitalization on input fields where it is undesirable (e.g., email address, passwords, URLs, usernames).

## 1.0.6+4

* **Deprecated `CoreKitConfigDefaults`**: Deprecated the `CoreKitConfigDefaults` mixin and updated all code implementations, comments, and documentation examples. Developers should inherit directly from `CoreKitConfig` instead, as it now provides concrete default implementations for all optional properties. 


## 1.0.6+3

* **Global Input Configuration (`CkInputConfig`)**: Added support for configuring app-wide text field style defaults (borders, background colors, sizing, text styles, alignments, and capitalization defaults) from one place.
* **Global SnackBar Configuration (`CkSnackBarConfig`)**: Added support for configuring global `CkSnackBar` overrides (including top/bottom positions, margins, padding, border radii, shadows, semantic colors, and custom icons).
* **URL Auto-Lowercase**: URLs typed or pasted inside text fields are automatically converted to lowercase while preserving the surrounding text.
* **Capitalization Toggle (`enableCapitalization`)**: Added a parameter to disable automatic sentence capitalization on specific text fields.

## 1.0.6+2

* **CkAppBar Title Alignment Fix**: Fixed an issue where global app bar title alignment configured via `CoreKitConfig` was not being applied.

## 1.0.6+1

* **New Validation Type (`usernameAndEmailValidation`)**: Added `CkValidationType.usernameAndEmailValidation` to `CkTextField`, allowing a single field to accept either a valid username or a valid email address.
* **Documentation — Mock Auth**: Corrected the auth mock docs to use `mockAuth: true` (replacing the stale `authEnable: false` references).
* **Documentation — Template Setup**: Expanded the template quick-start steps to include `fvm dart run build_runner build` (required for AutoRoute code generation) and `fvm flutter run`, with a clear explanation of when to re-run `build_runner`.

## 1.0.6

* **CkAppBar Initialization Fix**: Resolved a `LateInitializationError: Field 'appbarConfig' has not been initialized` crash that occurred when rendering `CkAppBar` on initial routes (such as a Splash Screen) before `CoreKitRouterGate` completed its asynchronous initialization. `appbarConfig` now defaults to a safe instance of `CkAppBarConfig()`.
* **Auth Mock Mode Enhancements (`mockAuth`)**:
  * Renamed the `authEnable` configuration parameter to `mockAuth` (inverting logic for improved semantic clarity).
  * Updated `signIn` and `signUp` mocks to seamlessly bypass OTP dialog triggers when `showOtpVerification` is not implemented in the application handlers.
  * Added a `mockAuth` check in `restoreSession` to prevent profile fetch failures to blank URLs upon hot restarts.

## 1.0.5

* **State Abbreviation Support & Data Class**: Updated `CkStateDropDown` callbacks (`onChanged`, `selectedItemBuilder`, `nameBuilder`) to pass `CkStateDropDownItemProperty` containing both `stateName` and `abbreviation`.
* **Flexible Initial Selection**: Added `initialState` parameter to `CkStateDropDown` accepting either full state name (e.g. `'California'`) or state abbreviation (e.g. `'CA'`).
* **Smart City Dropdown**: Updated `CkCityDropDown`'s `selectedState` parameter to seamlessly handle state abbreviations as well as state names.
* **Built-in Abbreviation Dataset**: Added `StateAbbreviations` dataset supporting automatic abbreviation lookups for US States, Canadian Provinces, and Australian States.

## 1.0.4

* **Warning fixed**: Fixed linting warnings in `ck_auth_service.dart` and `request_builder.dart`.

## 1.0.3

* **License Update**: Changed package license to MIT.

## 1.0.2

* **Web & Multi-Platform Support**: Replaced native `dart:io` imports with `universal_io` to ensure seamless compatibility across all platforms, including Flutter Web.
* **Resolved Dependency Conflicts**: Downgraded to stable releases of `file_picker` (`^11.0.2`) and `share_plus` (`^12.0.2`) to resolve win32 compatibility issues for web and desktop platforms.
* **Example App**: Added a full Flutter example application demonstrating core layout helpers, `CkTransport`, `CkStorage`, `CkListView` pagination, `CkAppBar`, and form validations.
* **Dartdoc Documentation**: Added comprehensive documentation comments to public APIs including `CoreKit`, `CoreKitConfig`, `CkResponse`, `CkTransportConfig`, and others.
* **Design Guidelines**: Documented best practices in `README.md` for using native-like `Ck` widgets and correctly applying responsive extensions (`.w`, `.h`, `.sp`, `.r`).
