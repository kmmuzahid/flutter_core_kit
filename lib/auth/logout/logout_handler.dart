import 'package:core_kit/auth/ck_auth_flow_handlers.dart';
import 'package:core_kit/auth/otp/otp_flow_manager.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/state/profile_extractor.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';

class CkLogoutHandler {
  final CkAuthTokenManager _tokenManager;
  final CkProfileExtractor _profileExtractor;
  final CkOtpFlowManager _otpManager;
  final CkAuthStateController _stateController;
  final CkAuthFlowHandlers? _handlers;
  final String? _logoutUrl;
  final RequestMethod _logoutMethod;

  CkLogoutHandler({
    required this._tokenManager,
    required this._profileExtractor,
    required this._otpManager,
    required this._stateController,
    this._handlers,
    this._logoutUrl,
    this._logoutMethod = RequestMethod.POST,
  });

  Future<void> execute() async {
    if (_logoutUrl != null && _logoutUrl.isNotEmpty) {
      await CkTransport.request(
        input: RequestInput(endpoint: _logoutUrl, method: _logoutMethod),
        responseBuilder: (data) => data,
        showMessage: true,
      );
    }

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
    if (_handlers == null) return;
    final isFirstTime = await CkAuthStorageKeys.isFirstTimeUser();
    if (_handlers.showOnboarding != null) {
      final showOnboarding = !_handlers.firstTimeOnly || isFirstTime;
      if (showOnboarding) {
        _handlers.showOnboarding!();
      } else {
        _handlers.showLogin();
      }
    } else {
      _handlers.showLogin();
    }
  }
}
