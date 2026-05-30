import 'dart:async';
import 'package:core_kit/auth/auth_config.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/state/profile_manager.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/auth/social/social_auth_manager.dart';
import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/network/ck_network.dart';
import 'package:core_kit/network/dio_service_config.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/network/ck_response.dart';
import 'package:core_kit/initializer.dart';

/// Main orchestrator — singleton, initialized automatically by CoreKit
/// when CoreKitAuthConfig is provided.
class AuthService<TProfile> {
  static AuthService? _instance;

  static AuthService get instance {
    assert(
      _instance != null,
      'AuthService not initialized. Please check if you provided `authConfig` in CoreKitConfig.',
    );
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  // Sub-managers
  final AuthTokenManager tokenManager;
  final AuthStateController authState;
  final ProfileManager<TProfile> profileManager;
  final OtpFlowManager otpManager;
  final LogoutHandler logoutHandler;
  final SocialAuthManager<TProfile> socialManager;
  final CoreKitAuthConfig<TProfile> config;

  AuthService._({
    required this.tokenManager,
    required this.authState,
    required this.profileManager,
    required this.otpManager,
    required this.logoutHandler,
    required this.socialManager,
    required this.config,
  });

  /// Initialize — called internally by CoreKit, NOT by developer
  static Future<AuthService<TProfile>> init<TProfile>({
    required CoreKitAuthConfig<TProfile> config,
    required DioServiceConfig dioConfig,
  }) async {
    await CkStorage.initialize();

    final tokenManager = AuthTokenManager();
    await tokenManager.initialize();

    // Create TokenProvider internally — developer never touches this
    final tokenProvider = tokenManager.createTokenProvider(config.extractors);

    // Feed to CkNetwork init
    await CkNetwork.init(config: dioConfig, tokenProvider: tokenProvider);

    final authState = AuthStateController();

    final profileManager = ProfileManager<TProfile>(
      fromJson: config.profileFromJson,
      toJson: config.profileToJson,
      extractors: config.extractors,
    );

    final otpManager = OtpFlowManager(
      config: config.otpConfig ?? const OtpConfig(),
      extractors: config.extractors,
      sendUrl: config.endpoints.otpSendUrl,
      verifyUrl: config.endpoints.otpVerifyUrl,
      sendMethod: config.endpoints.otpSendMethod,
      verifyMethod: config.endpoints.otpVerifyMethod,
    );

    await otpManager.restoreTokens();

    final logoutHandler = LogoutHandler(
      config: config.logoutConfig,
      tokenManager: tokenManager,
      profileManager: profileManager,
      otpManager: otpManager,
      stateController: authState,
      routes: config.routes,
      logoutUrl: config.endpoints.logoutUrl,
      logoutMethod: config.endpoints.logoutMethod,
    );

    final socialManager = SocialAuthManager<TProfile>(
      config: config.socialLoginConfig,
      tokenManager: tokenManager,
      profileManager: profileManager,
      stateController: authState,
      logoutHandler: logoutHandler,
      defaultExtractors: config.extractors,
    );

    final service = AuthService<TProfile>._(
      tokenManager: tokenManager,
      authState: authState,
      profileManager: profileManager,
      otpManager: otpManager,
      logoutHandler: logoutHandler,
      socialManager: socialManager,
      config: config,
    );

    _instance = service;

    // Restore session on init
    await service.restoreSession();
    return service;
  }

  // ─── Auth Actions ───

  /// Sign up — returns AuthResult with OTP info if needed
  Future<AuthResult<TProfile>> signUp({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(
          endpoint: config.endpoints.signupUrl,
          method: config.endpoints.signupMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
      );

      if (response.isSuccess) {
        // Check if OTP flow is triggered
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(OtpTrigger.signup) ?? false;
        final vToken = config.extractors.verificationToken?.call(response.data);

        if (autoOtp && vToken != null) {
          await otpManager.storeVerificationToken(OtpTrigger.signup, vToken);
          otpManager.startResendTimer();
          return AuthResult<TProfile>(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: OtpTrigger.signup,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        // Otherwise, see if tokens exist to log in directly
        final access = config.extractors.accessToken(response.data);
        final refresh = config.extractors.refreshToken?.call(response.data);

        if (access != null) {
          await tokenManager.saveTokens(
            accessToken: access,
            refreshToken: refresh,
          );
          authState.setAuthenticated();
          await AuthStorageKeys.markNotFirstTimeUser();

          final profileData = config.extractors.profileData?.call(
            response.data,
          );
          TProfile? profile;
          if (profileData != null) {
            profile = config.profileFromJson(profileData);
            await profileManager.updateProfile(profile);
            if (config.onProfileLoaded != null && profile != null) {
              await config.onProfileLoaded?.call(profile);
            }
          }

          _autoNavigate();
          return AuthResult<TProfile>.success(
            data: profile,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        // Signup succeeded but no direct token (needs manual login or verification)
        return AuthResult<TProfile>.success(
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return AuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return AuthResult<TProfile>.failure(message: e.toString());
    }
  }

  /// Sign in — auto-saves tokens, auto-fetches profile
  Future<AuthResult<TProfile>> signIn({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(
          endpoint: config.endpoints.signinUrl,
          method: config.endpoints.signinMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
      );

      if (response.isSuccess) {
        // Check if OTP flow is triggered for login
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(OtpTrigger.login) ?? false;
        final vToken = config.extractors.verificationToken?.call(response.data);

        if (autoOtp && vToken != null) {
          await otpManager.storeVerificationToken(OtpTrigger.login, vToken);
          otpManager.startResendTimer();
          return AuthResult(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: OtpTrigger.login,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        final access = config.extractors.accessToken(response.data);
        final refresh = config.extractors.refreshToken?.call(response.data);

        if (access != null) {
          await tokenManager.saveTokens(
            accessToken: access,
            refreshToken: refresh,
          );
          authState.setAuthenticated();
          await AuthStorageKeys.markNotFirstTimeUser();

          final profileData = config.extractors.profileData?.call(
            response.data,
          );
          TProfile? profile;
          if (profileData != null) {
            profile = config.profileFromJson(profileData);
            await profileManager.updateProfile(profile);
            if (config.onProfileLoaded != null && profile != null) {
              await config.onProfileLoaded?.call(profile);
            }
          }

          _autoNavigate();
          return AuthResult<TProfile>.success(
            data: profile,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        return AuthResult<TProfile>.failure(
          message: 'Authentication tokens not found in sign-in response',
        );
      }

      return AuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return AuthResult<TProfile>.failure(message: e.toString());
    }
  }

  /// Forgot password — auto-stores forgetToken
  Future<AuthResult<void>> forgotPassword({
    required Map<String, dynamic> body,
  }) async {
    if (config.endpoints.forgetPasswordUrl == null) {
      return const AuthResult<void>.failure(
        message: 'Forgot password URL is not configured',
      );
    }

    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(
          endpoint: config.endpoints.forgetPasswordUrl!,
          method: config.endpoints.forgetPasswordMethod,
          jsonBody: body,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
      );

      if (response.isSuccess) {
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(
              OtpTrigger.forgetPassword,
            ) ??
            false;
        final fToken = config.extractors.forgetPasswordToken?.call(
          response.data,
        );

        if (fToken != null) {
          await otpManager.storeVerificationToken(
            OtpTrigger.forgetPassword,
            fToken,
          );
          if (autoOtp) {
            otpManager.startResendTimer();
          }
        }

        return AuthResult<void>(
          isSuccess: true,
          requiresOtp: autoOtp,
          otpTrigger: autoOtp ? OtpTrigger.forgetPassword : null,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return AuthResult<void>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return AuthResult<void>.failure(message: e.toString());
    }
  }

  /// Verify OTP — uses stored verification token automatically
  Future<AuthResult<void>> verifyOtp({
    required String otp,
    required OtpTrigger trigger,
    Map<String, dynamic>? additionalBody,
  }) async {
    final verifyResult = await otpManager.verifyOtp(
      otp: otp,
      trigger: trigger,
      additionalBody: additionalBody,
    );

    if (verifyResult.isSuccess) {
      // In signup/login OTP verification, the response might return final access tokens
      final data = verifyResult.rawResponse;
      if (data != null) {
        final access = config.extractors.accessToken(data);
        final refresh = config.extractors.refreshToken?.call(data);

        if (access != null) {
          await tokenManager.saveTokens(
            accessToken: access,
            refreshToken: refresh,
          );
          authState.setAuthenticated();
          await AuthStorageKeys.markNotFirstTimeUser();

          final profileData = config.extractors.profileData?.call(data);
          if (profileData != null) {
            final profile = config.profileFromJson(profileData);
            await profileManager.updateProfile(profile);
            if (config.onProfileLoaded != null) {
              await config.onProfileLoaded!(profile);
            }
          }

          _autoNavigate();
        }
      }
      return const AuthResult<void>.success();
    }

    return verifyResult;
  }

  /// Resend OTP — auto-restarts timer
  Future<AuthResult<void>> resendOtp({
    required OtpTrigger trigger,
    String? identifier,
  }) async {
    return otpManager.sendOtp(trigger: trigger, identifier: identifier);
  }

  /// Change password
  Future<AuthResult<void>> changePassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    if (config.endpoints.changePasswordUrl == null) {
      return const AuthResult<void>.failure(
        message: 'Change password URL is not configured',
      );
    }

    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(
          endpoint: config.endpoints.changePasswordUrl!,
          method: config.endpoints.changePasswordMethod,
          jsonBody: body,
          headers: headers,
        ),
        responseBuilder: (data) => data,
      );

      if (response.isSuccess) {
        return AuthResult<void>.success(
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }
      return AuthResult<void>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return AuthResult<void>.failure(message: e.toString());
    }
  }

  // ─── Social Login ───

  /// Authenticate with Google
  Future<AuthResult<TProfile>> signInWithGoogle(GoogleAuthData data) async {
    return socialManager.authenticateGoogle(data);
  }

  /// Authenticate with Apple
  Future<AuthResult<TProfile>> signInWithApple(AppleAuthData data) async {
    return socialManager.authenticateApple(data);
  }

  /// Authenticate with Facebook
  Future<AuthResult<TProfile>> signInWithFacebook(FacebookAuthData data) async {
    return socialManager.authenticateFacebook(data);
  }

  /// Authenticate with Custom Social Provider
  Future<AuthResult<TProfile>> signInWithCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) async {
    return socialManager.authenticateCustom(
      providerName: providerName,
      authData: authData,
    );
  }

  /// Available social providers
  List<SocialProvider> get availableSocialProviders =>
      socialManager.availableProviders;

  // ─── Session ───

  /// Logout — follows configured strategy, auto-navigates
  Future<void> logout() async {
    await logoutHandler.execute();
  }

  /// Restore session — called on app launch (auto-called during init)
  Future<void> restoreSession() async {
    if (tokenManager.hasTokens) {
      authState.setAuthenticated();
      await config.onTokenRestored?.call();

      // Restore cached profile immediately (no blank screen)
      await profileManager.restoreProfile();

      // Run custom/optional API auth validation before completing routing
      bool valid = true;
      if (config.customAuthValidator != null) {
        valid = await config.customAuthValidator!();
      }

      if (!valid) {
        await logout();
        return;
      }

      // Then fetch fresh profile in background
      if (config.endpoints.profileGetUrl != null) {
        profileManager
            .fetchProfile(
              config.endpoints.profileGetUrl!,
              config.endpoints.profileGetMethod,
            )
            .then((result) {
              if (result.isSuccess && result.data != null) {
                config.onProfileLoaded?.call(result.data as TProfile);
              }
            });
      }

      _autoNavigate();
    } else {
      authState.setUnauthenticated();
      _autoNavigate();
    }
  }

  // ─── Quick Access ───

  bool get isAuthenticated => authState.isAuthenticated;
  TProfile? get currentProfile => profileManager.current;

  void _autoNavigate() async {
    if (authState.isAuthenticated) {
      config.routes.routeOnSuccess();
    } else {
      final isFirstTime = await AuthStorageKeys.isFirstTimeUser();
      if (isFirstTime && config.routes.routeToOnboarding != null) {
        config.routes.routeToOnboarding!();
      } else {
        config.routes.routeToLogin();
      }
    }
  }
}
