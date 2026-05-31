import 'dart:async';

import 'package:core_kit/auth/auth_config.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/social_auth_manager.dart';
import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/state/profile_extractor.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/network/ck_response.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter/material.dart';

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

  static bool get isInitialized => _instance != null;

  // Sub-managers
  final CkAuthTokenManager tokenManager;
  final CkAuthStateController authState;
  final CkProfileExtractor<TProfile> _profileExtractor;
  final CkOtpFlowManager otpManager;
  final CkLogoutHandler logoutHandler;
  final CkSocialAuthManager<TProfile> socialManager;
  final CkAuthConfig<TProfile> config;

  CkAuthService._({
    required this.tokenManager,
    required this.authState,
    required CkProfileExtractor<TProfile> profileExtractor,
    required this.otpManager,
    required this.logoutHandler,
    required this.socialManager,
    required this.config,
  }) : _profileExtractor = profileExtractor;

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
      profileExtractor: config.profileExtractor,
      extractors: config.extractors,
    );

    final otpManager = CkOtpFlowManager(
      config: config.otpConfig ?? const CkOtpConfig(),
      extractors: config.extractors as CkAuthExtractors<dynamic>,
      sendUrl: config.endpoints.otpSendUrl,
      verifyUrl: config.endpoints.otpVerifyUrl,
      sendMethod: config.endpoints.otpSendMethod,
      verifyMethod: config.endpoints.otpVerifyMethod,
    );

    await otpManager.restoreTokens();

    final logoutHandler = CkLogoutHandler(
      config: config.logoutConfig,
      tokenManager: tokenManager,
      profileExtractor: profileExtractor,
      otpManager: otpManager,
      stateController: authState,
      routes: config.routes,
      logoutUrl: config.endpoints.logoutUrl,
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

    final service = CkAuthService<TProfile>._(
      tokenManager: tokenManager,
      authState: authState,
      profileExtractor: profileExtractor,
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

  /// Sign up — returns CkAuthResult with OTP info if needed
  Future<CkAuthResult<TProfile>> signUp({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.signupUrl,
          method: config.endpoints.signupMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (response.isSuccess) {
        // Check if OTP flow is triggered
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(CkOtpTrigger.signup) ??
            false;
        final vToken = config
            .extractors
            .verificationTokens?[CkOtpTrigger.signup]
            ?.call(response.data);

        if (autoOtp && vToken != null) {
          await otpManager.storeVerificationToken(CkOtpTrigger.signup, vToken);
          otpManager.startResendTimer();
          return CkAuthResult<TProfile>(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: CkOtpTrigger.signup,
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
          await CkAuthStorageKeys.markNotFirstTimeUser();

          await _profileExtractor.applyFromResponse(response);
          final profile = _profileExtractor.current;
          if (config.onProfileLoaded != null && profile != null) {
            await config.onProfileLoaded?.call(profile);
          }

          autoNavigate();
          return CkAuthResult<TProfile>.success(
            data: profile,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        // Signup succeeded but no direct token (needs manual login or verification)
        return CkAuthResult<TProfile>.success(
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return CkAuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return CkAuthResult<TProfile>.failure(message: e.toString());
    }
  }

  /// Sign in — auto-saves tokens, auto-fetches profile
  Future<CkAuthResult<TProfile>> signIn({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.signinUrl,
          method: config.endpoints.signinMethod,
          jsonBody: body,
          headers: headers,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (response.isSuccess) {
        // Check if OTP flow is triggered for login
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(CkOtpTrigger.login) ??
            false;
        final vToken = config.extractors.verificationTokens?[CkOtpTrigger.login]
            ?.call(response.data);

        if (autoOtp && vToken != null) {
          await otpManager.storeVerificationToken(CkOtpTrigger.login, vToken);
          otpManager.startResendTimer();
          return CkAuthResult(
            isSuccess: true,
            requiresOtp: true,
            otpTrigger: CkOtpTrigger.login,
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
          await CkAuthStorageKeys.markNotFirstTimeUser();

          await _profileExtractor.applyFromResponse(response);
          final profile = _profileExtractor.current;
          if (config.onProfileLoaded != null && profile != null) {
            await config.onProfileLoaded?.call(profile);
          }

          autoNavigate();
          return CkAuthResult<TProfile>.success(
            data: profile,
            statusCode: response.statusCode,
            rawResponse: response.data,
          );
        }

        return CkAuthResult<TProfile>.failure(
          message: 'Authentication tokens not found in sign-in response',
        );
      }

      return CkAuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return CkAuthResult<TProfile>.failure(message: e.toString());
    }
  }

  /// Forgot password — auto-stores forgetToken
  Future<CkAuthResult<void>> forgotPassword({
    required Map<String, dynamic> body,
  }) async {
    if (config.endpoints.forgetPasswordUrl == null) {
      return const CkAuthResult<void>.failure(
        message: 'Forgot password URL is not configured',
      );
    }

    try {
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.forgetPasswordUrl!,
          method: config.endpoints.forgetPasswordMethod,
          jsonBody: body,
          requiresToken: false,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (response.isSuccess) {
        final autoOtp =
            config.otpConfig?.autoTriggers.contains(
              CkOtpTrigger.forgetPassword,
            ) ??
            false;
        final fToken = config
            .extractors
            .verificationTokens?[CkOtpTrigger.forgetPassword]
            ?.call(response.data);

        if (fToken != null) {
          await otpManager.storeVerificationToken(
            CkOtpTrigger.forgetPassword,
            fToken,
          );
          if (autoOtp) {
            otpManager.startResendTimer();
          }
        }

        return CkAuthResult<void>(
          isSuccess: true,
          requiresOtp: autoOtp,
          otpTrigger: autoOtp ? CkOtpTrigger.forgetPassword : null,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return CkAuthResult<void>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return CkAuthResult<void>.failure(message: e.toString());
    }
  }

  /// Verify OTP — uses stored verification token automatically
  Future<CkAuthResult<void>> verifyOtp({
    required String otp,
    required CkOtpTrigger trigger,
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
          await CkAuthStorageKeys.markNotFirstTimeUser();

          await _profileExtractor.applyFromResponse(
            CkResponse<dynamic>(
              data: data,
              isSuccess: true,
              statusCode: verifyResult.statusCode,
            ),
          );
          final profile = _profileExtractor.current;
          if (config.onProfileLoaded != null && profile != null) {
            await config.onProfileLoaded!(profile);
          }

          autoNavigate();
        }
      }
      return const CkAuthResult<void>.success();
    }

    return verifyResult;
  }

  /// Resend OTP — auto-restarts timer
  Future<CkAuthResult<void>> resendOtp({
    required CkOtpTrigger trigger,
    String? identifier,
  }) async {
    return otpManager.sendOtp(trigger: trigger, identifier: identifier);
  }

  /// Change password
  Future<CkAuthResult<void>> changePassword({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    if (config.endpoints.changePasswordUrl == null) {
      return const CkAuthResult<void>.failure(
        message: 'Change password URL is not configured',
      );
    }

    try {
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: config.endpoints.changePasswordUrl!,
          method: config.endpoints.changePasswordMethod,
          jsonBody: body,
          headers: headers,
        ),
        responseBuilder: (data) => data,
        showMessage: true,
      );

      if (response.isSuccess) {
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
    } catch (e) {
      return CkAuthResult<void>.failure(message: e.toString());
    }
  }

  // ─── Social Login ───

  /// Authenticate with Google
  Future<CkAuthResult<TProfile>> signInWithGoogle(CkGoogleAuthData data) async {
    return socialManager.authenticateGoogle(data);
  }

  /// Authenticate with Apple
  Future<CkAuthResult<TProfile>> signInWithApple(CkAppleAuthData data) async {
    return socialManager.authenticateApple(data);
  }

  /// Authenticate with Facebook
  Future<CkAuthResult<TProfile>> signInWithFacebook(
    CkFacebookAuthData data,
  ) async {
    return socialManager.authenticateFacebook(data);
  }

  /// Authenticate with Custom Social Provider
  Future<CkAuthResult<TProfile>> signInWithCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) async {
    return socialManager.authenticateCustom(
      providerName: providerName,
      authData: authData,
    );
  }

  /// Available social providers
  List<CkSocialProvider> get availableCkSocialProviders =>
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
      await _profileExtractor.restoreProfile();

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
        _profileExtractor
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
    } else {
      authState.setUnauthenticated();
    }
  }

  // ─── Quick Access ───

  bool get isAuthenticated => authState.isAuthenticated;
  TProfile? get currentProfile => _profileExtractor.current;

  /// Stream of user profile changes.
  Stream<TProfile?> get profileStream => _profileExtractor.profile.stream;

  /// Fetches the profile from the server using the configured [profileGetUrl].
  Future<CkAuthResult<TProfile?>> fetchProfile() async {
    if (config.endpoints.profileGetUrl == null) {
      return const CkAuthResult.failure(
        message: 'Profile GET URL is not configured',
      );
    }
    return _profileExtractor.fetchProfile(
      config.endpoints.profileGetUrl!,
      config.endpoints.profileGetMethod,
    );
  }

  /// Updates the profile on the server using the configured [profileUpdateUrl].
  Future<CkAuthResult<TProfile?>> updateProfile({
    Map<String, dynamic>? formFields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? jsonBody,
  }) async {
    if (config.endpoints.profileUpdateUrl == null) {
      return const CkAuthResult.failure(
        message: 'Profile update URL is not configured',
      );
    }
    final result = await _profileExtractor.updateProfileRemote(
      url: config.endpoints.profileUpdateUrl!,
      method: config.endpoints.profileUpdateMethod,
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
  }

  void autoNavigate() async {
    if (config.routes == null) return;

    // Resolve what to navigate to first (may involve async storage reads).
    final bool authenticated = authState.isAuthenticated;
    bool? isFirstTime;
    if (!authenticated) {
      isFirstTime = await CkAuthStorageKeys.isFirstTimeUser();
    }

    // Schedule navigation with multiple fallbacks to ensure it runs
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (authenticated) {
            config.routes!.routeOnSuccess();
          } else {
            if (config.routes!.routeToOnboarding != null) {
              final showOnboarding =
                  !config.routes!.firstTimeOnly || (isFirstTime ?? true);
              if (showOnboarding) {
                config.routes!.routeToOnboarding!();
              } else {
                config.routes!.routeToLogin();
              }
            } else {
              config.routes!.routeToLogin();
            }
          }
        } catch (e) {
          // Fallback: try again after a longer delay if first attempt fails
          Future.delayed(const Duration(milliseconds: 500), () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (authenticated) {
                  config.routes!.routeOnSuccess();
                } else {
                  config.routes!.routeToLogin();
                }
              } catch (e2) {
                // Last resort: direct navigation without postFrameCallback
                if (authenticated) {
                  config.routes!.routeOnSuccess();
                } else {
                  config.routes!.routeToLogin();
                }
              }
            });
          });
        }
      });
    });
  }
}
