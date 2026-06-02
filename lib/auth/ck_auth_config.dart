import 'package:core_kit/auth/ck_auth_endpoints.dart';
import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/ck_auth_flow_handlers.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/social/social_login_config.dart';

/// Main auth configuration for [CkAuthService].
///
/// Set on [CoreKitConfig.authConfig]. When non-null, CoreKit initializes
/// [CkAuthService], wires [CkTransport] token refresh, and restores session on launch.
class CkAuthConfig<TProfile> {
  // ─── Endpoints ───
  final CkAuthEndpoints endpoints;

  // ─── Model Mapping ───
  /// Maps persisted profile JSON to [TProfile] (cold start / storage restore).
  final TProfile Function(Map<String, dynamic> json) profileExtractor;

  // ─── Response Extractors (flexible backend mapping) ───
  final CkAuthExtractors<TProfile> extractors;

  Map<String, dynamic> Function(LoginCallback loginCallBack) loginBodyBuilder;

  // ─── Flow Handlers ───
  final CkAuthFlowHandlers? handlers;

  // ─── OTP Configuration (optional — null means no OTP flow) ───
  final CkOtpConfig otpConfig;

  // ─── Social Login (optional — null providers are ignored) ───
  final CkSocialLoginConfig? socialLoginConfig;

  // ─── Lifecycle Hooks (optional) ───
  final Future<void> Function()? onTokenRestored;
  final Future<bool> Function()? customAuthValidator;

  CkAuthConfig({
    required this.endpoints,
    required this.loginBodyBuilder,
    required this.profileExtractor,
    CkAuthExtractors<TProfile>? extractors,
    this.handlers,
    required this.otpConfig,
    this.socialLoginConfig,
    this.onTokenRestored,
    this.customAuthValidator,
  }) : extractors = extractors ?? CkAuthExtractors<TProfile>.standard();
}

class LoginCallback {
  final String username;
  final String password;
  final CkOtpTrigger? trigger;
  LoginCallback({required this.username, required this.password, this.trigger});
}
