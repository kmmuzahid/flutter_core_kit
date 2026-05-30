import 'package:core_kit/auth/logout/logout_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/auth/state/profile_manager.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/auth_routes.dart';
import 'package:core_kit/storage/core_kit_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/initializer.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:flutter/widgets.dart';

class LogoutHandler {
  final LogoutConfig _config;
  final AuthTokenManager _tokenManager;
  final ProfileManager _profileManager;
  final OtpFlowManager _otpManager;
  final AuthStateController _stateController;
  final AuthRoutes _routes;
  final String? _logoutUrl;
  final RequestMethod _logoutMethod;

  LogoutHandler({
    required LogoutConfig config,
    required AuthTokenManager tokenManager,
    required ProfileManager profileManager,
    required OtpFlowManager otpManager,
    required AuthStateController stateController,
    required AuthRoutes routes,
    String? logoutUrl,
    RequestMethod logoutMethod = RequestMethod.POST,
  })  : _config = config,
        _tokenManager = tokenManager,
        _profileManager = profileManager,
        _otpManager = otpManager,
        _stateController = stateController,
        _routes = routes,
        _logoutUrl = logoutUrl,
        _logoutMethod = logoutMethod;

  /// Execute full logout sequence:
  /// 1. Call API (if configured)
  /// 2. Clear tokens
  /// 3. Clear profile
  /// 4. Clear OTP state
  /// 5. Set auth status to unauthenticated
  /// 6. Navigate to login or onboarding (auto-detected)
  Future<void> execute() async {
    bool callApi = _config.strategy == LogoutStrategy.apiThenLocal ||
        _config.strategy == LogoutStrategy.apiWithForcedLocalClear;

    if (callApi && _logoutUrl != null) {
      try {
        final body = _config.logoutBodyBuilder?.call();
        final headers = _config.logoutHeadersBuilder?.call();
        final response = await DioService.instance.request(
          input: RequestInput(
            endpoint: _logoutUrl!,
            method: _logoutMethod,
            jsonBody: body,
            headers: headers,
          ),
          responseBuilder: (data) => data,
        );

        if (!response.isSuccess && _config.strategy == LogoutStrategy.apiThenLocal && !_config.forceLocalClearOnApiFailure) {
          // If strategy is apiThenLocal and it fails, and we DO NOT force local clear on failure, we stop here.
          return;
        }
      } catch (e) {
        if (_config.strategy == LogoutStrategy.apiThenLocal && !_config.forceLocalClearOnApiFailure) {
          rethrow;
        }
      }
    }

    // Clear local states
    await _tokenManager.clearTokens();
    await _profileManager.clearProfile();
    await _otpManager.clearOtpState();
    
    // Set to unauthenticated
    _stateController.setUnauthenticated();

    // Auto navigate
    await autoNavigate();
  }

  /// Perform automatic navigation based on route configuration
  Future<void> autoNavigate() async {
    final isFirstTime = await AuthStorageKeys.isFirstTimeUser();
    if (isFirstTime && _routes.routeToOnboarding != null) {
      _routes.routeToOnboarding!();
    } else {
      _routes.routeToLogin();
    }
  }
}
