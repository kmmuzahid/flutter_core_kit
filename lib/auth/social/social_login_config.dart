import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/social/custom_social_auth_config.dart';

/// Social login configuration — entirely optional.
/// Only providers with non-null configs are available.
class SocialLoginConfig {
  /// Google Sign-In config (null = Google login not available)
  final GoogleAuthConfig? google;
  
  /// Apple Sign-In config (null = Apple login not available)
  final AppleAuthConfig? apple;
  
  /// Facebook Sign-In config (null = Facebook login not available)
  final FacebookAuthConfig? facebook;
  
  /// Custom social providers (for any other OAuth/social provider)
  final List<CustomSocialAuthConfig>? customProviders;
  
  const SocialLoginConfig({
    this.google,
    this.apple,
    this.facebook,
    this.customProviders,
  });
  
  /// Which providers are enabled
  List<SocialProvider> get availableProviders => [
    if (google != null) SocialProvider.google,
    if (apple != null) SocialProvider.apple,
    if (facebook != null) SocialProvider.facebook,
    ...?customProviders?.map((c) => SocialProvider.custom),
  ];
}

enum SocialProvider { google, apple, facebook, custom }
