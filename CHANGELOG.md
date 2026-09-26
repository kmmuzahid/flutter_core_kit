## 1.1.4+2

* **Configurable Decimal Formatting (`CkText`)**:
  * Added `decimalPlaces` parameter (`int?`) with a default value of `2` to maintain full backward compatibility.
  * Formats floating-point numbers in text dynamically using `toStringAsFixed(decimalPlaces!)`.
  * Passing `decimalPlaces: null` skips regex number formatting completely, preserving semantic versions (e.g., `v1.0.4`), GPS coordinates, and raw numeric codes as-is.
  * Supports precision metrics (`1` for ratings like `4.9`) and nearest integer rounding (`0`).
  * Works seamlessly across all rendering modes (HTML content via `flutter_widget_from_html`, single-line auto-scale, adaptive multiline scaling, and description mode).
* **Comprehensive IDE Hover DartDoc (`CkText`)**:
  * Added detailed `///` documentation for both constructor parameters and field declarations across all `CkText` properties that differ from standard Flutter `Text` (including responsive insets, direct typography shortcuts, border container styling, leading/trailing widgets, auto-scaling thresholds, and gradients).
* **Test Coverage**:
  * Added dedicated widget and unit tests in `test/ck_text_test.dart` validating decimal precision, formatting bypass, HTML number parsing, and responsive layout behavior.

## 1.1.4+1

* **Search Input Configuration Sync (`CkSearch`)**:
  * Synchronized `CkSearch` hint styling with global `CkInputConfig.hintStyle` before falling back to `InputDecorationTheme.hintStyle`.
  * Updated `hintColor()` resolution to respect widget-level `hintStyle`, global `CkInputConfig.hintStyle`, and theme decoration before defaulting to outline color.
  * Removed hardcoded italic font style and forced font size overrides, allowing custom input configuration and theme styling to cascade seamlessly.


## 1.1.4

* **Documentation & Starter Template Improvements**:
  * Added comprehensive `README.md` with GitHub-style Markdown (badges, TOC, full feature list, detailed API docs).
  

## 1.1.3

* **Documentation & Badge Cleanup**:
  * Removed broken `Pub Popularity` badge from `README.md` which was returning a 404 error on pub.dev.

## 1.1.2

* **Swift Package Manager (SPM) Ready**:
  * All native plugin dependencies (`permission_handler`, `flutter_secure_storage`, `share_plus`, `file_picker`, `cached_network_image`) are upgraded to their latest major SPM-ready releases, providing seamless integration with Flutter's Swift Package Manager on iOS and macOS.
* **Documentation & Link Fixes**:
  * Fixed relative `LICENSE` badge and footer links causing 404 errors on pub.dev.
  * Fixed repository and issue tracker URLs in `pubspec.yaml` to eliminate 404 errors on pub.dev's "View/report issues" link.
  * Updated Docsify sidebar links to use anchor query navigation `/?id=...` to avoid 404 errors when navigating sections.

## 1.1.1

* **HTML Rendering Engine Migration (`CkText`)**:
  * Replaced `flutter_html ^3.0.0` with `flutter_widget_from_html ^0.17.3` for HTML content rendering inside `CkText`.
  * Migrated the internal HTML rendering widget from `Html` (flutter_html) to `HtmlWidget` (flutter_widget_from_html), eliminating the dependency on `flutter_html`'s `Style`, `Margins`, `HtmlPaddings`, `FontSize`, and `Display` APIs.
  * Equivalent per-element styling (body, p, h1–h6) is now applied via `HtmlWidget.customStylesBuilder` using CSS property maps.
  * Font family, size, weight, and color are forwarded through `HtmlWidget.textStyle`, maintaining visual parity with the previous implementation.

## 1.1.0


* **Dual Password Management (`changePassword` & `resetPassword`)**:
  * Added dedicated `resetPassword` endpoint, method override (`resetPasswordMethod`), and facade method `auth.resetPassword()` / `CkAuthService.instance.resetPassword()` for unauthenticated forgot-password completion. Automatically routes to `showLogin` upon success.
  * Dedicated `changePassword` endpoint, method override (`changePasswordMethod`), and facade method `auth.changePassword()` / `CkAuthService.instance.changePassword()` for authenticated users to update their credentials. Automatically logs the user out upon success.
  * Added `CkAuthLoadingType.resetPassword` and `CkAuthLoadingType.updatePassword` to track each loading state independently.
* **Profile Synchronization**:
  * Refined `updateProfile()` in `CkAuthService` to re-fetch canonical user profile data from the server automatically via `fetchProfile()`.
* **Input Styling & Error Border Enhancements (`CkInputConfig`)**:
  * Added global `errorColor` configuration to `CkInputConfig` (defaults to `Colors.red`).
  * Added custom styling and automatic derivation for `errorBorder` and `focusedErrorBorder` across `CkTextField`, `CkMultilineTextField`, and `CkSearch` matching border style (`outline` vs `underline`) and radius.
* **Component Improvements**:
  * Added `preserveComposeText` in `CkCommentSheet` to retain drafted comment text during minimize/restore actions.

## 1.0.1

* **`material_ui` Integration & Type Fixes**:
  * Added `material_ui` support across core UI components.
  * Resolved `InputDecoration` type collision between `material_ui` and Flutter's native `material.dart` inside `CkPhoneNumberTextField`.
* **Static Analysis & Code Health (50/50 Pana Score)**:
  * Resolved all static analysis warnings, lints, and formatting issues across library and test suite.
  * Deprecated `CkPermission.calendar` with migration guidance towards `CkPermission.calendarFullAccess` and `CkPermission.calendarWriteOnly` matching `permission_handler` deprecation.
  * Optimized file existence checks in `CkPath` with synchronous `existsSync()` for better performance (`avoid_slow_async_io`).
  * Fixed multi-slash path normalization in `CkPath.join()`.
  * Cleaned up unused imports and standardized directive ordering with `dart fix`.
  * `CkListLoaderConfig` now supports a global empty-state widget for `CkListView`, `CkTabListView` and `CkGridView`.

## 1.0.7+7

* **CkPermission Manager**:
  * Introduced modern, unified permission manager `CkPermission` (`await CkPermission.camera.ensure()`, `await CkPermission.photos.ensure()`, etc.) with pre-defined typed constants and convenience getters (`status`, `isGranted`, `isDenied`, `isPermanentlyDenied`).
  * Added `.ensure()` extension on standard `Permission` (`await Permission.camera.ensure()`).
  * Marked legacy `CkPermissionHelper` and `CkPermissionHandler` as `@Deprecated`.
* **CkPath Directory & Path Manager**:
  * Added `CkPath` utility for easy access to device directories (`getTemporaryDirectory()`, `getApplicationDocumentsDirectory()`, cache, downloads, support) and direct string paths (`tempPath`, `documentsPath`, `cachePath`).
  * Added helpers to create temporary and document files (`createTempFile()`, `getTempFilePath()`, `createDocumentFile()`, `join()`, `clearTemp()`).
  * Re-exported `path_provider` directly in `core_kit.dart`.
* **CkCommentSheet Text Preservation**:
  * Added `preserveComposeText` parameter to `CkCommentSheet` to preserve written comment text across show/hide composer states until send is clicked.
  * Fixed `CkMultilineTextField` to avoid overwriting existing controller text upon mounting when `onInitalize` is null.

## 1.0.7+6

* **Static Analysis**: static analysis issues fixed and Dependencies updated.

## 1.0.7+5

* **Static Analysis**: reduce static analysis issues.

## 1.0.7+4

* **Dependencies**: Updated dependencies to address potential compatibility issues.

## 1.0.7+3

* **Documentation**: Improved pub.dev page with topics, screenshots, and an updated description.

## 1.0.7+2

* **Documentation**: Internal code comments and doc organization.


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
