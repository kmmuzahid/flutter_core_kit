import 'dart:async';

import 'package:core_kit/auth/ck_auth.dart';
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_result.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/social_auth_manager.dart';
import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/state/auth_loading_controller.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/state/profile_extractor.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/storage/ck_storage.dart';

/// Token layer prepared before [CkTransport.init] (CoreKit internal).
class CkAuthNetworkBootstrap {
  const CkAuthNetworkBootstrap({
    required this.tokenManager,
    required this.tokenProvider,
  });

  final CkAuthTokenManager tokenManager;
  final CkTokenProvider tokenProvider;
}

/// Main orchestrator — singleton, initialized automatically by CoreKit
/// when CkAuthConfig is provided.
class CkAuthService<TProfile> {
  static CkAuthService? _instance;

  static CkAuthService get instance {
    assert(
      _instance != null,
      'CkAuthService not initialized. Please check if you provided `authConfig` in CoreKitConfig.',
    );
    return _instance!;
  }

  /// Returns the singleton instance cast to a specific profile type [T].
  static CkAuthService<T> typedInstance<T>() {
    assert(
      _instance != null,
      'CkAuthService not initialized. Please check if you provided `authConfig` in CoreKitConfig.',
    );
    return _instance! as CkAuthService<T>;
  }

  static bool get isInitialized => _instance != null;

  // Sub-managers
  final CkAuthTokenManager tokenManager;
  final CkAuthStateController authState;
  final CkProfileExtractor<TProfile> _profileExtractor;
  final CkOtpFlowManager otpManager;
  final CkLogoutHandler logoutHandler;
  final CkSocialAuthManager<TProfile> socialManager;
  final CkAuthConfig<TProfile> config;
  final CkAuthLoadingController loadingController;

  CkAuthService._({
    required this.tokenManager,
    required this.authState,
    required this._profileExtractor,
    required this.otpManager,
    required this.logoutHandler,
    required this.socialManager,
    required this.config,
    required this.loadingController,
  });

  /// Prepares secure storage, token cache, and [CkTokenProvider] for Dio.
  /// CoreKit calls this, then [CkTransport.init], then [init].
  static Future<CkAuthNetworkBootstrap> prepareNetwork({
    required CkAuthConfig config,
  }) async {
    await CkStorage.initialize();

    final tokenManager = CkAuthTokenManager();
    await tokenManager.initialize();

    return CkAuthNetworkBootstrap(
      tokenManager: tokenManager,
      tokenProvider: tokenManager.createTokenProvider(config.extractors),
    );
  }

  /// Completes auth module setup. [CkTransport] must already be initialized.
  static Future<CkAuthService<TProfile>> init<TProfile>({
    required CkAuthConfig<TProfile> config,
    required CkAuthTokenManager tokenManager,
  }) async {
    final authState = CkAuthStateController();

    final profileExtractor = CkProfileExtractor<TProfile>(
      extractors: config.extractors,
    );

    final otpManager = CkOtpFlowManager(
      config: config.otpConfig,
      extractors: config.extractors,
      sendUrl: config.endpoints.sendOtp,
      verifyUrl: config.endpoints.verifyOtp,
      verifyForgetUrl: config.endpoints.verifyForgetOtp,
      sendMethod: config.endpoints.sendOtpMethod,
      verifyMethod: config.endpoints.verifyOtpMethod,
      verifyForgotMethod: config.endpoints.verifyForgotOtpMethod,
    );

    await otpManager.restoreTokens();

    final logoutHandler = CkLogoutHandler(
      tokenManager: tokenManager,
      profileExtractor: profileExtractor,
      otpManager: otpManager,
      stateController: authState,
      handlers: config.handlers,
      logoutUrl: config.endpoints.logout,
      logoutMethod: config.endpoints.logoutMethod,
    );

    final socialManager = CkSocialAuthManager<TProfile>(
      config: config.socialLoginConfig,
      tokenManager: tokenManager,
      profileExtractor: profileExtractor,
      stateController: authState,
      logoutHandler: logoutHandler,
      defaultExtractors: config.extractors,
    );

    final loadingController = CkAuthLoadingController();

    final service = CkAuthService<TProfile>._(
      tokenManager: tokenManager,
      authState: authState,
      profileExtractor: profileExtractor,
      otpManager: otpManager,
      logoutHandler: logoutHandler,
      socialManager: socialManager,
      config: config,
      loadingController: loadingController,
    );

    _instance = service;

    // Restore session on init
    await service.restoreSession();
    return service;
  }

  // ─── Auth Actions ───

  /// Handles OTP flow check and returns OTP result if triggered
  CkAuthResult<TProfile>? _handleOtpFlow(
    CkOtpTrigger trigger,
    dynamic responseData,
    int? statusCode,
  ) {
    final autoOtp = config.otpConfig.autoTriggers.contains(trigger);
    final vToken = config.extractors.verificationTokens?[trigger]?.call(
      responseData,
    );

    if (autoOtp && vToken != null) {
      otpManager.storeVerificationToken(trigger, vToken);
      otpManager.startResendTimer();

      if (config.handlers?.showOtpVerification != null) {
        config.handlers!.showOtpVerification!();
      }

      return CkAuthResult<TProfile>(
        isSuccess: true,
        requiresOtp: true,
        otpTrigger: trigger,
        statusCode: statusCode,
        rawResponse: responseData,
      );
    }
    return null;
  }

  /// Completes authentication after successful token extraction
  Future<CkAuthResult<TProfile>> _completeAuthentication(
    dynamic responseData,
    int? statusCode,
  ) async {
    final access = config.extractors.accessToken(responseData);
    final refresh = config.extractors.refreshToken?.call(responseData);

    if (access == null) {
      return CkAuthResult<TProfile>.failure(
        message: 'Authentication tokens not found in response',
      );
    }

    await tokenManager.saveTokens(accessToken: access, refreshToken: refresh);
    authState.setAuthenticated();
    await CkAuthStorageKeys.markNotFirstTimeUser();

    await fetchProfile();

    final profile = _profileExtractor.current;

    autoNavigate();
    return CkAuthResult<TProfile>.success(
      data: profile,
      statusCode: statusCode,
      rawResponse: responseData,
    );
  }

  /// Sign up — returns CkAuthResult with OTP info if needed
  Future<CkAuthResult<TProfile>> signUp({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return loadingController.wrap(CkAuthLoadingType.signUp, () async {
      if (!config.authEnable) {
        final activeTrigger = CkOtpTrigger.signup;
        final autoOtp = config.otpConfig.autoTriggers.contains(activeTrigger);
        if (autoOtp) {
          otpManager.storeVerificationToken(activeTrigger, 'mock_otp_token');
          otpManager.startResendTimer();
          config.handlers?.showOtpVerification?.call();
          return CkAuthResult<TProfile>(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: activeTrigger,
            statusCode: 200,
            rawResponse: const {'message': 'Mock sign up successful, requires OTP'},
          );
        } else {
          await tokenManager.saveTokens(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
          );
          authState.setAuthenticated();
          await CkAuthStorageKeys.markNotFirstTimeUser();
          autoNavigate();
          return CkAuthResult<TProfile>.success(
            statusCode: 200,
            rawResponse: const {'message': 'Mock sign up successful'},
          );
        }
      }
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.signup,
          method: config.endpoints.signupMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (!response.isSuccess) {
        return CkAuthResult<TProfile>.failure(
          message: response.message,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      final otpResult = _handleOtpFlow(
        CkOtpTrigger.signup,
        response.data,
        response.statusCode,
      );
      if (otpResult != null) return otpResult;

      final authResult = await _completeAuthentication(
        response.data,
        response.statusCode,
      );

      if (authResult.isSuccess) return authResult;

      return CkAuthResult<TProfile>.success(
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    });
  }

  /// Sign in — auto-saves tokens, auto-fetches profile
  Future<CkAuthResult<TProfile>> signIn({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return loadingController.wrap(CkAuthLoadingType.signIn, () async {
      if (!config.authEnable) {
        final activeTrigger = CkOtpTrigger.login;
        final autoOtp = config.otpConfig.autoTriggers.contains(activeTrigger);
        if (autoOtp) {
          otpManager.storeVerificationToken(activeTrigger, 'mock_otp_token');
          otpManager.startResendTimer();
          config.handlers?.showOtpVerification?.call();
          return CkAuthResult<TProfile>(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: activeTrigger,
            statusCode: 200,
            rawResponse: const {'message': 'Mock sign in successful, requires OTP'},
          );
        } else {
          await tokenManager.saveTokens(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
          );
          authState.setAuthenticated();
          await CkAuthStorageKeys.markNotFirstTimeUser();
          autoNavigate();
          return CkAuthResult<TProfile>.success(
            statusCode: 200,
            rawResponse: const {'message': 'Mock sign in successful'},
          );
        }
      }
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.signin,
          method: config.endpoints.signinMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (!response.isSuccess) {
        return CkAuthResult<TProfile>.failure(
          message: response.message,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      final otpResult = _handleOtpFlow(
        CkOtpTrigger.login,
        response.data,
        response.statusCode,
      );
      if (otpResult != null) return otpResult;

      return await _completeAuthentication(response.data, response.statusCode);
    });
  }

  /// Forgot password — auto-stores forgetToken
  Future<CkAuthResult<void>> forgotPassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return loadingController.wrap(CkAuthLoadingType.forgotPassword, () async {
      if (!config.authEnable) {
        final activeTrigger = CkOtpTrigger.forgetPassword;
        final autoOtp = config.otpConfig.autoTriggers.contains(activeTrigger);
        if (autoOtp) {
          otpManager.storeVerificationToken(activeTrigger, 'mock_otp_token');
          otpManager.startResendTimer();
          config.handlers?.showOtpVerification?.call();
          return const CkAuthResult<void>(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: CkOtpTrigger.forgetPassword,
            statusCode: 200,
            rawResponse: {'message': 'Mock forgot password success, requires OTP'},
          );
        } else {
          config.handlers?.showResetPassword?.call();
          return const CkAuthResult<void>.success(
            statusCode: 200,
            rawResponse: {'message': 'Mock forgot password success'},
          );
        }
      }
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.forgotPassword,
          method: config.endpoints.forgotPasswordMethod,
          jsonBody: body,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (!response.isSuccess) {
        return CkAuthResult<void>.failure(
          message: response.message,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      final otpResult = _handleOtpFlow(
        CkOtpTrigger.forgetPassword,
        response.data,
        response.statusCode,
      );

      if (otpResult != null) {
        return CkAuthResult<void>(
          isSuccess: true,
          requiresOtp: otpResult.requiresOtp,
          otpTrigger: otpResult.otpTrigger,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return CkAuthResult<void>.success(
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    });
  }

  /// Verify OTP — uses stored verification token automatically
  Future<CkAuthResult<void>> verifyOtp({required String otp}) {
    return loadingController.wrap(CkAuthLoadingType.verifyOtp, () async {
      if (!config.authEnable) {
        final activeTrigger = otpManager.lastTrigger;
        if (activeTrigger == CkOtpTrigger.signup) {
          await tokenManager.saveTokens(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
          );
          authState.setAuthenticated();
          await CkAuthStorageKeys.markNotFirstTimeUser();
          autoNavigate();
        } else if (activeTrigger == CkOtpTrigger.forgetPassword) {
          config.handlers?.showResetPassword?.call();
        }
        return const CkAuthResult<void>.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock OTP verification successful'},
        );
      }
      final activeTrigger = otpManager.lastTrigger;
      final verifyResult = await otpManager.verifyOtp(otp: otp);

      if (verifyResult.isSuccess) {
        if (activeTrigger == CkOtpTrigger.signup) {
          return signIn(
            body: config.loginBodyBuilder(
              LoginCallback(
                username: CkAuth.username ?? '',
                password: CkAuth.password ?? '',
                trigger: activeTrigger,
              ),
            ),
          );
        } else if (activeTrigger == CkOtpTrigger.forgetPassword) {
          if (config.handlers?.showResetPassword != null) {
            config.handlers!.showResetPassword!();
          }
        }
        return const CkAuthResult<void>.success();
      }

      return verifyResult;
    });
  }

  /// Resend OTP — auto-restarts timer
  Future<CkAuthResult<void>> resendOtp() {
    return loadingController.wrap(CkAuthLoadingType.sendOtp, () async {
      if (!config.authEnable) {
        otpManager.startResendTimer();
        return const CkAuthResult<void>.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock OTP resend successful'},
        );
      }
      return otpManager.sendOtp();
    });
  }

  /// Send OTP manually — also updates lastTrigger for verify/resend
  Future<CkAuthResult<void>> sendOtp({required CkOtpTrigger trigger}) {
    return loadingController.wrap(CkAuthLoadingType.sendOtp, () async {
      if (!config.authEnable) {
        otpManager.startResendTimer();
        return const CkAuthResult<void>.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock OTP send successful'},
        );
      }
      return otpManager.sendOtp(trigger: trigger);
    });
  }

  /// Reset password
  Future<CkAuthResult<void>> updatePassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return loadingController.wrap(CkAuthLoadingType.updatePassword, () async {
      if (!config.authEnable) {
        config.handlers?.showLogin();
        return const CkAuthResult<void>.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock password update successful'},
        );
      }
      final finalHeaders = <String, String>{};
      if (headers != null) {
        finalHeaders.addAll(headers);
      }

      final resetToken = otpManager.resetPasswordToken;
      if (resetToken != null) {
        finalHeaders[config.otpConfig.verificationTokenHeaderKey] = resetToken;
      }

      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.resetPassword,
          method: config.endpoints.resetPasswordMethod,
          jsonBody: body,
          headers: finalHeaders,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (response.isSuccess) {
        if (config.handlers != null) {
          config.handlers!.showLogin();
        }
        return CkAuthResult<void>.success(
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }
      return CkAuthResult<void>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    });
  }

  // ─── Social Login ───

  /// Authenticate with Google
  Future<CkAuthResult<TProfile>> signInWithGoogle(CkGoogleAuthData data) {
    return loadingController.wrap(CkAuthLoadingType.socialLogin, () async {
      if (!config.authEnable) {
        await tokenManager.saveTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
        authState.setAuthenticated();
        await CkAuthStorageKeys.markNotFirstTimeUser();
        autoNavigate();
        return const CkAuthResult.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock Google sign in successful'},
        );
      }
      return socialManager.authenticateGoogle(data);
    });
  }

  /// Authenticate with Apple
  Future<CkAuthResult<TProfile>> signInWithApple(CkAppleAuthData data) {
    return loadingController.wrap(CkAuthLoadingType.socialLogin, () async {
      if (!config.authEnable) {
        await tokenManager.saveTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
        authState.setAuthenticated();
        await CkAuthStorageKeys.markNotFirstTimeUser();
        autoNavigate();
        return const CkAuthResult.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock Apple sign in successful'},
        );
      }
      return socialManager.authenticateApple(data);
    });
  }

  /// Authenticate with Facebook
  Future<CkAuthResult<TProfile>> signInWithFacebook(
    CkFacebookAuthData data,
  ) {
    return loadingController.wrap(CkAuthLoadingType.socialLogin, () async {
      if (!config.authEnable) {
        await tokenManager.saveTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
        authState.setAuthenticated();
        await CkAuthStorageKeys.markNotFirstTimeUser();
        autoNavigate();
        return const CkAuthResult.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock Facebook sign in successful'},
        );
      }
      return socialManager.authenticateFacebook(data);
    });
  }

  /// Authenticate with Custom Social Provider
  Future<CkAuthResult<TProfile>> signInWithCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) {
    return loadingController.wrap(CkAuthLoadingType.socialLogin, () async {
      if (!config.authEnable) {
        await tokenManager.saveTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
        authState.setAuthenticated();
        await CkAuthStorageKeys.markNotFirstTimeUser();
        autoNavigate();
        return const CkAuthResult.success(
          statusCode: 200,
          rawResponse: {'message': 'Mock Custom sign in successful'},
        );
      }
      return socialManager.authenticateCustom(
        providerName: providerName,
        authData: authData,
      );
    });
  }

  /// Available social providers
  List<CkSocialProvider> get availableCkSocialProviders =>
      socialManager.availableProviders;

  // ─── Session ───

  /// Logout — follows configured strategy, auto-navigates
  Future<void> logout() {
    return loadingController.wrap(CkAuthLoadingType.logout, () async {
      if (!config.authEnable) {
        await tokenManager.clearTokens();
        await _profileExtractor.clearProfile();
        authState.setUnauthenticated();
        config.handlers?.showLogin();
        return;
      }
      await logoutHandler.execute();
    });
  }

  /// Restore session — called on app launch (auto-called during init)
  Future<void> restoreSession() async {
    if (tokenManager.hasTokens) {
      authState.setAuthenticated();
      await config.onTokenRestored?.call();

      // Restore cached profile immediately (no blank screen)
      await _profileExtractor.restoreProfile();

      // Run custom/optional API auth validation before completing routing
      var valid = true;
      if (config.customAuthValidator != null) {
        valid = await config.customAuthValidator!();
      }

      if (!valid) {
        await logout();
        return;
      }

      // Then fetch fresh profile in background
      _profileExtractor
          .fetchProfile(
            config.endpoints.getProfile,
            config.endpoints.getProfileMethod,
          )
          .then((result) {
            if (result.isSuccess && result.data != null) {
              final dynamic onProfileLoaded =
                  (config as dynamic).onProfileLoaded;
              if (onProfileLoaded != null) {
                onProfileLoaded(result.data as TProfile);
              }
            }
          });
    } else {
      authState.setUnauthenticated();
    }
  }

  // ─── Quick Access ───

  bool get isAuthenticated => authState.isAuthenticated;
  TProfile? get currentProfile => _profileExtractor.current;

  /// Stream of user profile changes.
  Stream<TProfile?> get profileStream => _profileExtractor.profile.stream;

  /// Fetches the profile from the server using the configured [getProfile] endpoint.
  Future<CkAuthResult<TProfile?>> fetchProfile() {
    return loadingController.wrap(CkAuthLoadingType.fetchProfile, () async {
      if (!config.authEnable) {
        return const CkAuthResult.success(
          data: null,
          statusCode: 200,
        );
      }
      return _profileExtractor.fetchProfile(
        config.endpoints.getProfile,
        config.endpoints.getProfileMethod,
      );
    });
  }

  /// Updates the profile on the server using the configured [profileUpdateUrl].
  Future<CkAuthResult<TProfile?>> updateProfile({
    Map<String, dynamic>? formFields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? jsonBody,
  }) {
    return loadingController.wrap(CkAuthLoadingType.updateProfile, () async {
      if (!config.authEnable) {
        return const CkAuthResult.success(
          data: null,
          statusCode: 200,
        );
      }
      final result = await _profileExtractor.updateProfileRemote(
        url: config.endpoints.updateProfile,
        method: config.endpoints.updateProfileMethod,
        formFields: formFields,
        files: files,
        jsonBody: jsonBody,
      );

      if (result.isSuccess) {
        final fetchResult = await fetchProfile();
        if (fetchResult.isSuccess && fetchResult.data != null) {
          return CkAuthResult.success(
            data: fetchResult.data,
            statusCode: result.statusCode,
            rawResponse: result.rawResponse,
          );
        }
      }

      return result;
    });
  }

  Future<void> autoNavigate() async {
    if (config.handlers == null) return;

    final authenticated = authState.isAuthenticated;
    bool? isFirstTime;
    if (!authenticated) {
      isFirstTime = await CkAuthStorageKeys.isFirstTimeUser();
    }

    void navigate() {
      if (authenticated) {
        config.handlers!.onAuthenticated();
      } else {
        if (config.handlers!.showOnboarding != null) {
          final showOnboarding =
              !config.handlers!.firstTimeOnly || (isFirstTime ?? true);
          if (showOnboarding) {
            config.handlers!.showOnboarding!();
          } else {
            config.handlers!.showLogin();
          }
        } else {
          config.handlers!.showLogin();
        }
      }
    }

    try {
      navigate();
    } catch (_) {
      Future.delayed(const Duration(milliseconds: 100), navigate);
    }
  }
}
