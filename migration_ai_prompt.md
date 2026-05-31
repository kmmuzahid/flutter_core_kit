# CoreKit Migration & Integration Plan

This guide outlines a seamless migration path for the `rizaldyrferrer_better_help` project to adopt the latest `flutter_core_kit` (pulled from `main`). 

Because `flutter_core_kit` has been modernized, the old `DioService` and `ResponseState` classes were replaced by `CkTransport` and `CkResponse`, and the direct `tokenProvider` configuration in `CoreKitConfig` was replaced by an internal `CkAuthService` engine. 

---

## 💾 1. Storage Migration (`CkStorage` & Pubspec Cleanup)

To adopt secure storage with guaranteed fallback out-of-the-box, we will migrate the project's internal storage engine from raw `SharedPreferences` and `GetStorage` to the modern **`CkStorage`** provided by CoreKit. 

### 1.1 Remove Redundant Dependencies from `pubspec.yaml`
Remove direct storage dependencies from your `pubspec.yaml` as they are now handled internally by `core_kit`:
* ❌ Remove `get_storage:` from line 15
* ❌ Remove `shared_preferences:` from line 35

### 1.2 Refactor `StorageService` to wrap `CkStorage`
Replace the entire content of `lib/service/storage_services/storage_services.dart` with the following implementation. This wraps CoreKit's `CkStorage` while keeping the **exact same method signatures** so that none of the 40+ call sites across your widgets and controllers break!

```dart
import 'dart:convert';
import 'package:core_kit/storage/ck_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  factory StorageService() => _instance;
  StorageService._internal();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _imageDataPrefix = 'image_';
  static const String _questionnaireResponsesKey = 'questionnaire_responses';
  static const String _questionnaireOutputKey = 'questionnaire_output';
  static const String _createUserTokenKey = 'create_user_token';
  static String get userId => '695e1c0e085dd3d8713c17f7';
  static const String _isFirstAiGeneratedKey = 'is_first_time_user';

  /// Initialize CkStorage
  Future<void> init() async {
    await CkStorage.initialize();
  }

  Future<bool?> isFirstAiTaskGenereted() async {
    final val = await CkStorage.read(_isFirstAiGeneratedKey);
    if (val == null) return null;
    return val == 'true';
  }

  Future<bool> setAiTaskGenerated(bool isFirstTimeUser) async {
    await CkStorage.write(_isFirstAiGeneratedKey, isFirstTimeUser.toString());
    return true;
  }

  // ==================== Token Management ====================

  Future<bool> saveAccessToken(String token) async {
    await CkStorage.write(_accessTokenKey, token);
    return true;
  }

  Future<String?> getAccessToken() async {
    return await CkStorage.read(_accessTokenKey);
  }

  Future<bool> saveRefreshToken(String token) async {
    await CkStorage.write(_refreshTokenKey, token);
    return true;
  }

  Future<String?> getRefreshToken() async {
    return await CkStorage.read(_refreshTokenKey);
  }

  Future<bool> removeTokens() async {
    await CkStorage.delete(_accessTokenKey);
    await CkStorage.delete(_refreshTokenKey);
    return true;
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== User Data Management ====================

  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    await CkStorage.write(_userDataKey, json.encode(userData));
    return true;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await CkStorage.read(_userDataKey);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<bool> removeUserData() async {
    await CkStorage.delete(_userDataKey);
    return true;
  }

  // ==================== Questionnaire Responses Management ====================

  Future<bool> saveQuestionnaireResponses(List<Map<String, dynamic>> responses) async {
    await CkStorage.write(_questionnaireResponsesKey, json.encode(responses));
    return true;
  }

  Future<List<Map<String, dynamic>>?> getQuestionnaireResponses() async {
    final jsonString = await CkStorage.read(_questionnaireResponsesKey);
    if (jsonString == null) return null;
    final decoded = json.decode(jsonString) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<bool> removeQuestionnaireResponses() async {
    await CkStorage.delete(_questionnaireResponsesKey);
    return true;
  }

  Future<bool> saveQuestionnaireOutput(Map<String, dynamic> output) async {
    await CkStorage.write(_questionnaireOutputKey, json.encode(output));
    return true;
  }

  Future<Map<String, dynamic>?> getQuestionnaireOutput() async {
    final jsonString = await CkStorage.read(_questionnaireOutputKey);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<bool> removeQuestionnaireOutput() async {
    await CkStorage.delete(_questionnaireOutputKey);
    return true;
  }

  // ==================== Create User Token Management ====================

  Future<bool> saveCreateUserToken(String token) async {
    await CkStorage.write(_createUserTokenKey, token);
    return true;
  }

  Future<String?> getCreateUserToken() async {
    return await CkStorage.read(_createUserTokenKey);
  }

  Future<bool> removeCreateUserToken() async {
    await CkStorage.delete(_createUserTokenKey);
    return true;
  }

  // ==================== Image Data Management ====================

  Future<bool> saveImageData(String imageKey, String imageData) async {
    await CkStorage.write('$_imageDataPrefix$imageKey', imageData);
    return true;
  }

  Future<String?> getImageData(String imageKey) async {
    return await CkStorage.read('$_imageDataPrefix$imageKey');
  }

  Future<bool> removeImageData(String imageKey) async {
    await CkStorage.delete('$_imageDataPrefix$imageKey');
    return true;
  }

  // ==================== Generic Storage Methods ====================

  Future<bool> saveString(String key, String value) async {
    await CkStorage.write(key, value);
    return true;
  }

  Future<String?> getString(String key) async {
    return await CkStorage.read(key);
  }

  Future<bool> saveInt(String key, int value) async {
    await CkStorage.write(key, value.toString());
    return true;
  }

  Future<int?> getInt(String key) async {
    final val = await CkStorage.read(key);
    if (val == null) return null;
    return int.tryParse(val);
  }

  Future<bool> saveBool(String key, bool value) async {
    await CkStorage.write(key, value.toString());
    return true;
  }

  Future<bool?> getBool(String key) async {
    final val = await CkStorage.read(key);
    if (val == null) return null;
    return val == 'true';
  }

  Future<bool> saveDouble(String key, double value) async {
    await CkStorage.write(key, value.toString());
    return true;
  }

  Future<double?> getDouble(String key) async {
    final val = await CkStorage.read(key);
    if (val == null) return null;
    return double.tryParse(val);
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    await CkStorage.write(key, json.encode(value));
    return true;
  }

  Future<List<String>?> getStringList(String key) async {
    final val = await CkStorage.read(key);
    if (val == null) return null;
    final decoded = json.decode(val) as List;
    return decoded.map((e) => e.toString()).toList();
  }

  Future<bool> saveJson(String key, Map<String, dynamic> json) async {
    await CkStorage.write(key, jsonEncode(json));
    return true;
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final val = await CkStorage.read(key);
    if (val == null) return null;
    return jsonDecode(val) as Map<String, dynamic>;
  }

  Future<bool> remove(String key) async {
    await CkStorage.delete(key);
    return true;
  }

  Future<bool> clearAll() async {
    await CkStorage.deleteAll();
    return true;
  }
}
```

---

## 🧭 2. Authentication Integration (Option A vs Option B)

Choose **one** of the two paths below to integrate CoreKit's authentication system:

### Option A: Zero-Risk Compatibility Bridge (Keep Custom Auth)

This keeps your current `StorageService()` and custom GetX controller logic fully active under the hood.

1. **Create Compatibility File** at `lib/core/compatibility/corekit_compat.dart`:
```dart
library corekit_compat;

export 'package:core_kit/core_kit.dart';
export 'package:core_kit/network/ck_response.dart';
export 'package:core_kit/network/request_input.dart';
export 'package:core_kit/utils/ck_screen_utils.dart';

import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/ck_response.dart';
import 'package:core_kit/network/request_input.dart';

typedef ResponseState<T> = CkResponse<T>;

class DioService {
  DioService._();
  static final DioService instance = DioService._();

  Future<CkResponse<T?>> request<T>({
    required RequestInput input,
    required T? Function(dynamic data) responseBuilder,
    int retryCount = 0,
    int maxRetry = 2,
    bool showMessage = false,
    bool debug = false,
    bool isRetry = false,
  }) {
    return CkTransport.request<T>(
      input: input,
      responseBuilder: responseBuilder,
      retryCount: retryCount,
      maxRetry: maxRetry,
      showMessage: showMessage,
      debug: debug,
      isRetry: isRetry,
    );
  }
}
```

2. **Update `lib/corekit_config_impl.dart`**:
```dart
import 'dart:ui';
import 'package:better_help/core/app_apiurl/api_end_points.dart';
import 'package:better_help/service/storage_services/storage_services.dart';
import 'package:core_kit/initializer.dart';
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'core/app_route/app_route.dart';

class CorekitConfigImpl extends CoreKitConfig with CoreKitConfigDefaults {
  @override
  Size get designSize => const Size(428, 926);

  @override
  String get imageBaseUrl => ApiEndPoints.imageUrl;

  @override
  CkTransportConfig get ckTransportConfig => CkTransportConfig(
        baseUrl: ApiEndPoints.baseUrl,
        refreshTokenEndpoint: ApiEndPoints.refreshToken,
        onLogout: () {
          StorageService().removeTokens();
          Get.offAllNamed(AppRoute.splashscreen);
        },
        enableDebugLogs: kDebugMode,
      );
}
```

3. **Bind to `StorageService` Early in `lib/main.dart`**:
```dart
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:better_help/core/app_apiurl/api_end_points.dart';
import 'package:flutter/foundation.dart';

static Future<void> initializeTokens() async {
  await CkTransport.init(
    config: CkTransportConfig(
      baseUrl: ApiEndPoints.baseUrl,
      refreshTokenEndpoint: ApiEndPoints.refreshToken,
      onLogout: () {
        StorageService().removeTokens();
        Get.offAllNamed(AppRoute.splashscreen);
      },
      enableDebugLogs: kDebugMode,
    ),
    tokenProvider: CkTokenProvider(
      accessToken: () => StorageService().getAccessToken().then((v) => v ?? ''),
      refreshToken: () => StorageService().getRefreshToken().then((v) => v ?? ''),
      updateTokens: (data) async {
        if (data is Map && data.containsKey('accessToken')) {
          await StorageService().saveAccessToken(data['accessToken']);
        } else if (data is String) {
          await StorageService().saveAccessToken(data);
        }
      },
    ),
  );
}
```

---

### Option B: Complete CoreKit Auth Migration (Remove Custom Auth)

Adopt CoreKit's reactive token manager, UI builders, and delete manual caching codes.

1. **Configure `authConfig` in `lib/corekit_config_impl.dart`**:
```dart
import 'dart:ui';
import 'package:better_help/core/app_apiurl/api_end_points.dart';
import 'package:better_help/screen/menu_drawer/my_profile/model/my_profile_model.dart';
import 'package:core_kit/initializer.dart';
import 'package:core_kit/auth/auth_config.dart';
import 'package:core_kit/auth/auth_endpoints.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_routes.dart';
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'core/app_route/app_route.dart';

class CorekitConfigImpl extends CoreKitConfig with CoreKitConfigDefaults {
  @override
  Size get designSize => const Size(428, 926);

  @override
  String get imageBaseUrl => ApiEndPoints.imageUrl;

  @override
  CkTransportConfig get ckTransportConfig => CkTransportConfig(
        baseUrl: ApiEndPoints.baseUrl,
        refreshTokenEndpoint: ApiEndPoints.refreshToken,
        enableDebugLogs: kDebugMode,
      );

  @override
  CkAuthConfig<ProfileData> get authConfig => CkAuthConfig(
        endpoints: const CkAuthEndpoints(
          signupUrl: '/users/create',
          signinUrl: '/auth/login',
          forgetPasswordUrl: '/auth/forgot-password-otp',
          otpSendUrl: '/otp/resend-otp',
          otpVerifyUrl: '/users/create-user-verify-otp',
          profileGetUrl: '/users/my-profile',
          profileUpdateUrl: '/users/update-my-profile',
          logoutUrl: '/auth/logout',
        ),
        profileExtractor: (data) => ProfileData.fromJson(data),
        extractors: CkAuthExtractors<ProfileData>.standard(
          accessTokenKey: 'accessToken',
          refreshTokenKey: 'refreshToken',
          profileKey: 'user',
        ),
        routes: CkAuthRoutes(
          routeOnSuccess: () {
            final profile = CkAuth.profile;
            if (profile?.subscriptionPackageId == null) {
              Get.offAllNamed(AppRoute.subscriptionscreen);
            } else {
              Get.offAllNamed(AppRoute.bottomNav);
            }
          },
          routeToLogin: () {
            Get.offAllNamed(AppRoute.loginScreen);
          },
        ),
      );
}
```

2. **Rewrite `login()` in `LoginScreenController`**:
```dart
  Future<void> login() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final result = await CkAuth.signIn(
      body: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      },
    );

    isLoading.value = false;

    if (result.isSuccess) {
      final profile = CkAuth.profile;
      Get.find<MyProfileScreenController>().profileData.value = profile;
      
      AppSnackBar.showSuccess(result.message ?? "Login successful");
      
      if (profile?.subscriptionPackageId == null) {
        Get.offAllNamed(AppRoute.subscriptionscreen);
      } else {
        Get.offAllNamed(AppRoute.bottomNav);
      }
    } else {
      AppSnackBar.showError(result.message ?? "Authentication failed");
    }
  }
```

3. **Rewrite Logout Calls**:
```dart
await CkAuth.logout();
```

---

## 🎨 3. Adopting CoreKit UI Helpers & Profile Updates

If using **Option B**, you can completely replace your manual Stream/Timer boilerplate and manual PATCH update calls with CoreKit's pre-wired reactive widgets and automatic update synchronization!

### 3.1 Profile UI Updates (`CkAuth.profileUi`)
To automatically rebuild profile cards, headers, or settings pages when a profile changes (e.g. on profile update, avatar change), use **`CkAuth.profileUi`** in your screens. It reactively listens to CoreKit's stream under the hood:

```dart
// Wrapping headers or widgets requiring user profile details
CkAuth.profileUi(
  builder: (context, profile) {
    final user = profile as ProfileData?;
    if (user == null) {
      return const Text("Welcome, Guest!");
    }
    return Text("Hello, ${user.fullName}!");
  },
  // Optional custom loader while fetching profile
  loading: const Center(child: CircularProgressIndicator()), 
)
```

### 3.2 OTP Resend Countdown (`CkAuth.otpCountdownUi`)
In [otp_verification_screen.dart](file:///c:/Users/kmmuz/Documents/flutter_project/rizaldyrferrer_better_help/lib/screen/auth_screen/otp_verification_screen/otp_verification_screen.dart#L143-L171), replace your manual `Obx` timer rendering with CoreKit's auto-managed **`CkAuth.otpCountdownUi`**. It automatically hooks into `CkAuth.otpManager` and handles resends automatically:

```dart
Center(
  child: CkAuth.otpCountdownUi(
    builder: (context, seconds) {
      if (seconds > 0) {
        return AppText(
          text: "${AppString.resendin} ${seconds}s",
          fontFamilyIndex: 2,
          fontSize: AppSize.width(value: 16),
          color: AppColors.grey400,
          maxLines: 3,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
        );
      } else {
        return GestureDetector(
          onTap: () {
            controller.resetTimer();
          },
          child: AppText(
            text: "Resend Code",
            fontFamilyIndex: 2,
            fontSize: AppSize.width(value: 16),
            color: AppColors.blue900,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        );
      }
    },
  ),
)
```

### 3.3 Profile Updates (`CkAuth.updateProfile`)
Instead of manually making `Dio` PATCH requests and writing token save codes to update profile pictures or user details, use **`CkAuth.updateProfile`**. 

CoreKit will hit the endpoint, save the responses, and **instantly push the new profile data reactively to all `CkAuth.profileUi` widgets** across the app in real time!

Inside `ProfileRepository` in [profile_repository.dart](file:///c:/Users/kmmuz/Documents/flutter_project/rizaldyrferrer_better_help/lib/service/repository/profile_repositroy/profile_repository.dart#L24-L39), refactor `updateMyProfile` to use `CkAuth.updateProfile`:

```dart
  /// Update user profile using CkAuth
  Future<CkAuthResult<dynamic>> updateMyProfile({
    String? fullName,
    String? phone,
    String? address,
    XFile? profile,
  }) async {
    return await CkAuth.updateProfile(
      formFields: {
        'fullName': fullName,
        'phone': phone,
        'address': address,
      },
      files: {
        'profile': profile,
      },
    );
  }
```

---

## 🛠️ 4. Global Search & Replaces (Run in IDE)

Run the following search and replaces globally to resolve imports instantly:

1. **Replace CoreKit Base Imports**
   * **Search:** `import 'package:core_kit/core_kit.dart';`
   * **Replace with:** `import 'package:better_help/core/compatibility/corekit_compat.dart';`

2. **Clean up redundant/broken imports**
   * **Search:** `import 'package:core_kit/network/dio_service.dart';`
   * **Replace with:** (leave blank to delete)

3. **Update Screen Utility imports**
   * **Search:** `import 'package:core_kit/utils/core_screen_utils.dart';`
   * **Replace with:** `import 'package:core_kit/utils/ck_screen_utils.dart';`
