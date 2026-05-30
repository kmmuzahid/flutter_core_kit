import 'package:core_kit/auth/auth_endpoints.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_routes.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/logout/logout_config.dart';
import 'package:core_kit/auth/social/social_login_config.dart';

/// Main auth configuration.
/// When provided in CoreKitConfig, auth module activates automatically.
/// When null, CoreKit behaves exactly as before — zero impact.
class CoreKitAuthConfig<TProfile> {
  // ─── Endpoints ───
  final AuthEndpoints endpoints;
  
  // ─── Model Mapping ───
  final TProfile Function(Map<String, dynamic> json) profileFromJson;
  final Map<String, dynamic> Function(TProfile profile) profileToJson;
  
  // ─── Response Extractors (flexible backend mapping) ───
  final AuthExtractors extractors;
  
  // ─── Routing ───
  final AuthRoutes routes;
  
  // ─── OTP Configuration (optional — null means no OTP flow) ───
  final OtpConfig? otpConfig;
  
  // ─── Logout Strategy ───
  final LogoutConfig logoutConfig;
  
  // ─── Social Login (optional — null providers are ignored) ───
  final SocialLoginConfig? socialLoginConfig;
  
  // ─── Lifecycle Hooks (optional) ───
  final Future<void> Function(TProfile profile)? onProfileLoaded;
  final Future<void> Function()? onTokenRestored;
  final Future<bool> Function()? customAuthValidator;

  const CoreKitAuthConfig({
    required this.endpoints,
    required this.profileFromJson,
    required this.profileToJson,
    required this.extractors,
    required this.routes,
    this.otpConfig,
    this.logoutConfig = const LogoutConfig(),
    this.socialLoginConfig,
    this.onProfileLoaded,
    this.onTokenRestored,
    this.customAuthValidator,
  });
}
