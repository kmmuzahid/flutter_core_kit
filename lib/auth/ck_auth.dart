import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_result.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/social_auth_manager.dart';
import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/state/auth_loading_controller.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:flutter/material.dart';

Map<String, dynamic> lastSubmitAuthData = {};

/// Static developer-facing gateway for authentication operations.
/// Eliminates the need to use [CkAuthService.instance] directly.
class CkAuth {
  CkAuth._();

  /// The token manager for stored auth tokens.
  static CkAuthTokenManager get tokenManager =>
      CkAuthService.instance.tokenManager;

  /// The state controller for reactive auth status.
  static CkAuthStateController get authState =>
      CkAuthService.instance.authState;

  /// The OTP manager for OTP sending and verification countdowns.
  static CkOtpFlowManager get otpManager => CkAuthService.instance.otpManager;

  /// The logout handler.
  static CkLogoutHandler get logoutHandler =>
      CkAuthService.instance.logoutHandler;

  /// The social authentication manager.
  static CkSocialAuthManager<dynamic> get socialManager =>
      CkAuthService.instance.socialManager;

  /// The loading state controller for all auth operations.
  static CkAuthLoadingController get loadingController =>
      CkAuthService.instance.loadingController;

  static String? get username {
    return _findUsernameValue(lastSubmitAuthData);
  }

  static String? get password {
    return _findPasswordValue(lastSubmitAuthData);
  }

  /// The active configuration.
  static CkAuthConfig<dynamic> get config => CkAuthService.instance.config;

  /// Whether the session is currently authenticated.
  static bool get isAuthenticated => CkAuthService.instance.isAuthenticated;

  /// The active user profile. Returns `null` if unauthenticated.
  static dynamic get profile => CkAuthService.instance.currentProfile;

  /// Stream of user profile changes.
  static Stream<dynamic> get profileStream =>
      CkAuthService.instance.profileStream;

  /// A simplified reactive StreamBuilder UI helper for the user profile.
  static Widget profileUi<TProfile>({
    required Widget Function(BuildContext context, TProfile? profile) builder,
    Widget? loading,
  }) {
    return StreamBuilder<dynamic>(
      stream: profileStream,
      initialData: profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        // If there's no data yet and we're waiting/loading
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }
        return builder(context, snapshot.data);
      },
    );
  }

  /// A simplified reactive StreamBuilder UI helper for the OTP resend countdown.
  ///
  /// The [builder] receives only the remaining seconds as an [int].
  static Widget otpCountdownUi({
    required Widget Function(int seconds) builder,
  }) {
    return StreamBuilder<int>(
      stream: otpManager.resendCountdown.stream,
      initialData: otpManager.resendCountdown.value,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return builder(snapshot.data ?? 0);
      },
    );
  }

  /// A simplified reactive StreamBuilder UI helper for auth operation loading states.
  ///
  /// Pass the [type] of auth operation to observe, and the [builder]
  /// receives only a [bool] indicating whether that operation is loading.
  ///
  /// Example:
  /// ```dart
  /// CkAuth.loadingUi(
  ///   type: CkAuthLoadingType.signIn,
  ///   builder: (isLoading) => ElevatedButton(
  ///     onPressed: isLoading ? null : () => CkAuth.signIn(...),
  ///     child: isLoading ? CircularProgressIndicator() : Text('Sign In'),
  ///   ),
  /// )
  /// ```
  static Widget loadingUi({
    required CkAuthLoadingType type,
    required Widget Function(bool isLoading) builder,
  }) {
    final stream = loadingController.streamOf(type);
    return StreamBuilder<bool>(
      stream: stream.stream,
      initialData: stream.value,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return builder(false);
        }
        return builder(snapshot.data ?? false);
      },
    );
  }

  /// Whether [CkAuthService] is fully initialized.
  static bool get isInitialized => CkAuthService.isInitialized;

  /// Sign up — returns [CkAuthResult] with OTP info if needed.
  static Future<CkAuthResult<dynamic>> signUp({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    lastSubmitAuthData = body;
    return CkAuthService.instance.signUp(body: body, headers: headers);
  }

  /// Sign in — auto-saves tokens, auto-fetches profile.
  static Future<CkAuthResult<dynamic>> signIn({
    required String username,
    required String password,
    Map<String, String>? headers,
  }) {
    final body = config.loginBodyBuilder(
      LoginCallback(
        username: username,
        password: password,
        trigger: otpManager.lastTrigger,
      ),
    );
    return CkAuthService.instance.signIn(body: body, headers: headers);
  }

  /// Forgot password — auto-stores forgetToken.
  static Future<CkAuthResult<void>> forgotPassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) => CkAuthService.instance.forgotPassword(body: body, headers: headers);

  /// Verify OTP — uses stored verification token automatically.
  static Future<CkAuthResult<void>> verifyOtp({required String otp}) =>
      CkAuthService.instance.verifyOtp(otp: otp);

  /// Resend OTP — auto-restarts timer.
  static Future<CkAuthResult<void>> sendOtp({String? identifier}) =>
      CkAuthService.instance.resendOtp();

  /// Reset password.
  static Future<CkAuthResult<void>> updatePassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) => CkAuthService.instance.updatePassword(body: body, headers: headers);

  /// Authenticate with Google.
  static Future<CkAuthResult<dynamic>> signInWithGoogle(
    CkGoogleAuthData data,
  ) => CkAuthService.instance.signInWithGoogle(data);

  /// Authenticate with Apple.
  static Future<CkAuthResult<dynamic>> signInWithApple(CkAppleAuthData data) =>
      CkAuthService.instance.signInWithApple(data);

  /// Authenticate with Facebook.
  static Future<CkAuthResult<dynamic>> signInWithFacebook(
    CkFacebookAuthData data,
  ) => CkAuthService.instance.signInWithFacebook(data);

  /// Authenticate with Custom Social Provider.
  static Future<CkAuthResult<dynamic>> signInWithCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) => CkAuthService.instance.signInWithCustom(
    providerName: providerName,
    authData: authData,
  );

  /// Available social providers.
  static List<CkSocialProvider> get availableCkSocialProviders =>
      CkAuthService.instance.availableCkSocialProviders;

  /// Logout — follows configured strategy, auto-navigates.
  static Future<void> logout() => CkAuthService.instance.logout();

  /// Fetches the profile from the server.
  static Future<CkAuthResult<dynamic>> fetchProfile() =>
      CkAuthService.instance.fetchProfile();

  /// Updates the profile on the server.
  static Future<CkAuthResult<dynamic>> updateProfile({
    Map<String, dynamic>? formFields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? jsonBody,
  }) async {
    return CkAuthService.instance.updateProfile(
      formFields: formFields,
      files: files,
      jsonBody: jsonBody,
    );
  }

  static String? _findUsernameValue(Map<String, dynamic> data) {
    const priorities = [
      ['username', 'user_name', 'user'],
      ['email', 'email_address', 'mail'],
      ['phone', 'phone_number', 'mobile', 'contact'],
    ];

    for (final group in priorities) {
      for (final entry in data.entries) {
        final key = entry.key.toLowerCase();

        final isMatched = group.any(
          (keyword) => key.contains(keyword.toLowerCase()),
        );

        if (isMatched) {
          final value = entry.value?.toString().trim();

          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
      }
    }

    return null;
  }

  static String? _findPasswordValue(Map<String, dynamic> data) {
    const passwordKeys = ['password', 'pass', 'pwd', 'pin'];

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();

      final isMatched = passwordKeys.any(
        (keyword) => key.contains(keyword.toLowerCase()),
      );

      if (isMatched) {
        final value = entry.value?.toString().trim();

        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }
}
