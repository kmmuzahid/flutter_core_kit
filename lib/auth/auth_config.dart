import 'package:core_kit/auth/auth_endpoints.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_routes.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/logout/logout_config.dart';
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
  
  // ─── Routing ───
  final CkAuthRoutes? routes;
  
  // ─── OTP Configuration (optional — null means no OTP flow) ───
  final CkOtpConfig? otpConfig;
  
  // ─── Logout Strategy ───
  final CkLogoutConfig logoutConfig;
  
  // ─── Social Login (optional — null providers are ignored) ───
  final CkSocialLoginConfig? socialLoginConfig;
  
  // ─── Lifecycle Hooks (optional) ───
  final Future<void> Function(TProfile profile)? onProfileLoaded;
  final Future<void> Function()? onTokenRestored;
  final Future<bool> Function()? customAuthValidator;

  CkAuthConfig({
    required this.endpoints,
    required this.profileExtractor,
    CkAuthExtractors<TProfile>? extractors,
    this.routes,
    this.otpConfig,
    this.logoutConfig = const CkLogoutConfig(),
    this.socialLoginConfig,
    this.onProfileLoaded,
    this.onTokenRestored,
    this.customAuthValidator,
  }) : extractors = extractors ?? CkAuthExtractors<TProfile>.standard();
}
