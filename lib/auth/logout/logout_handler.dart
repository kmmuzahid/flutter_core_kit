import 'package:core_kit/auth/logout/logout_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/auth/state/profile_extractor.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/auth_routes.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/initializer.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:flutter/widgets.dart';

class CkLogoutHandler {
  final CkLogoutConfig _config;
  final CkAuthTokenManager _tokenManager;
  final CkProfileExtractor _profileExtractor;
  final CkOtpFlowManager _otpManager;
  final CkAuthStateController _stateController;
  final CkAuthRoutes? _routes;
  final String? _logoutUrl;
  final RequestMethod _logoutMethod;

  CkLogoutHandler({
    required CkLogoutConfig config,
    required CkAuthTokenManager tokenManager,
    required CkProfileExtractor profileExtractor,
    required CkOtpFlowManager otpManager,
    required CkAuthStateController stateController,
    CkAuthRoutes? routes,
    String? logoutUrl,
    RequestMethod logoutMethod = RequestMethod.POST,
  })  : _config = config,
        _tokenManager = tokenManager,
        _profileExtractor = profileExtractor,
        _otpManager = otpManager,
        _stateController = stateController,
        _routes = routes,
        _logoutUrl = logoutUrl,
        _logoutMethod = logoutMethod;

  /// Execute full logout sequence:
  /// 1. Call API (if configured)
  /// 2. Call custom onLogout callback (if configured in authConfig)
  /// 3. Clear tokens
  /// 4. Clear profile
  /// 5. Clear OTP state
  /// 6. Set auth status to unauthenticated
  /// 7. Navigate to login or onboarding (auto-detected)
  Future<void> execute() async {
    if (_logoutUrl != null) {
      try {
        final body = _config.logoutBodyBuilder?.call();
        final headers = _config.logoutHeadersBuilder?.call();
        await CkTransport.request(
          input: RequestInput(
            endpoint: _logoutUrl!,
            method: _logoutMethod,
            jsonBody: body,
            headers: headers,
          ),
          responseBuilder: (data) => data,
          showMessage: true,
        );
      } catch (e) {
        // Ignore API failures to ensure local session is always cleared
      }
    }

    // Call custom onLogout callback for app-specific cleanup
    // This allows clearing custom storage without requiring logoutConfig
    await _config.onLogout?.call();

    // Clear local states
    await _tokenManager.clearTokens();
    await _profileExtractor.clearProfile();
    await _otpManager.clearOtpState();
    
    // Set to unauthenticated
    _stateController.setUnauthenticated();

    // Auto navigate
    await autoNavigate();
  }

  /// Perform automatic navigation based on route configuration
  Future<void> autoNavigate() async {
    if (_routes == null) return;
    final isFirstTime = await CkAuthStorageKeys.isFirstTimeUser();
    if (_routes!.routeToOnboarding != null) {
      final showOnboarding = !_routes!.firstTimeOnly || isFirstTime;
      if (showOnboarding) {
        _routes!.routeToOnboarding!();
      } else {
        _routes!.routeToLogin();
      }
    } else {
      _routes!.routeToLogin();
    }
  }
}
