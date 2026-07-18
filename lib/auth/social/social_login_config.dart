import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/custom_social_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';

/// Social login configuration — entirely optional.
/// Only providers with non-null configs are available.
class CkSocialLoginConfig {
  /// Google Sign-In config (null = Google login not available)
  final CkGoogleAuthConfig? google;
  
  /// Apple Sign-In config (null = Apple login not available)
  final CkAppleAuthConfig? apple;
  
  /// Facebook Sign-In config (null = Facebook login not available)
  final CkFacebookAuthConfig? facebook;
  
  /// Custom social providers (for any other OAuth/social provider)
  final List<CkCustomSocialAuthConfig>? customProviders;
  
  const CkSocialLoginConfig({
    this.google,
    this.apple,
    this.facebook,
    this.customProviders,
  });
  
  /// Which providers are enabled
  List<CkSocialProvider> get availableProviders => [
    if (google != null) CkSocialProvider.google,
    if (apple != null) CkSocialProvider.apple,
    if (facebook != null) CkSocialProvider.facebook,
    ...?customProviders?.map((c) => CkSocialProvider.custom),
  ];
}

enum CkSocialProvider { google, apple, facebook, custom }
