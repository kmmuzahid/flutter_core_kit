import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/auth/auth_extractors.dart';

/// Google Sign-In configuration
/// Developer provides: backend URL + what to extract from Google + what to send to backend
class CkGoogleAuthConfig {
  /// Backend endpoint to send Google token to
  /// (e.g., '/auth/google', '/auth/social-login')
  final String backendUrl;
  
  /// HTTP method for backend call (default: POST)
  final RequestMethod method;
  
  /// Google client ID (for web — Android/iOS use google-services.json/plist)
  final String? webClientId;
  
  /// Scopes to request from Google (default: email, profile)
  final List<String> scopes;
  
  /// Build the body to send to YOUR backend after Google auth succeeds
  /// Receives Google auth data (idToken, accessToken, user info)
  /// Must return the body your backend expects
  final Map<String, dynamic> Function(CkGoogleAuthData data) bodyBuilder;
  
  /// Extract response from YOUR backend (uses CkAuthExtractors by default)
  /// Override if social login response has different structure
  final CkAuthExtractors? responseExtractors;
  
  const CkGoogleAuthConfig({
    required this.backendUrl,
    this.method = RequestMethod.POST,
    this.webClientId,
    this.scopes = const ['email', 'profile'],
    required this.bodyBuilder,
    this.responseExtractors,
  });
}

/// Data received from Google after successful Google Sign-In
class CkGoogleAuthData {
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const CkGoogleAuthData({
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
