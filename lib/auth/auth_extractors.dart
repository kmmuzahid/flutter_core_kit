/// Flexible response data extraction system.
/// Supports 3 modes: standard key-based, path-based, and fully custom callbacks.
class AuthExtractors {
  // ─── Token Extractors ───
  final String? Function(dynamic responseData) accessToken;
  final String? Function(dynamic responseData)? refreshToken;
  
  // ─── Profile Extractor ───
  final Map<String, dynamic>? Function(dynamic responseData)? profileData;
  
  // ─── OTP/Verification Token Extractor ───
  final String? Function(dynamic responseData)? verificationToken;
  
  // ─── Forget Password Token Extractor ───
  final String? Function(dynamic responseData)? forgetPasswordToken;
  
  // ─── Message Extractor ───
  final String? Function(dynamic responseData)? message;
  
  // ─── Full Response Transformer (escape hatch) ───
  final dynamic Function(dynamic rawResponse)? responseTransformer;
  
  const AuthExtractors({
    required this.accessToken,
    this.refreshToken,
    this.profileData,
    this.verificationToken,
    this.forgetPasswordToken,
    this.message,
    this.responseTransformer,
  });
  
  /// Convenience: common pattern where tokens are at data root level
  /// e.g., response.data = { "accessToken": "...", "refreshToken": "...", "user": {...} }
  factory AuthExtractors.standard({
    String accessTokenKey = 'accessToken',
    String refreshTokenKey = 'refreshToken',
    String profileKey = 'user',
    String verificationTokenKey = 'createUserToken',
    String forgetPasswordTokenKey = 'forgetToken',
    String messageKey = 'message',
  }) {
    return AuthExtractors(
      accessToken: (data) => _extractByKey(data, accessTokenKey)?.toString(),
      refreshToken: (data) => _extractByKey(data, refreshTokenKey)?.toString(),
      profileData: (data) {
        final profile = _extractByKey(data, profileKey);
        if (profile is Map<String, dynamic>) {
          return profile;
        } else if (profile is Map) {
          return Map<String, dynamic>.from(profile);
        }
        return null;
      },
      verificationToken: (data) => _extractByKey(data, verificationTokenKey)?.toString(),
      forgetPasswordToken: (data) => _extractByKey(data, forgetPasswordTokenKey)?.toString(),
      message: (data) => _extractByKey(data, messageKey)?.toString(),
    );
  }
  
  /// Path-based extraction for nested structures
  /// e.g., "result.data.accessToken" → response['result']['data']['accessToken']
  factory AuthExtractors.fromPaths({
    required String accessTokenPath,
    String? refreshTokenPath,
    String? profilePath,
    String? verificationTokenPath,
    String? forgetPasswordTokenPath,
    String? messagePath,
  }) {
    return AuthExtractors(
      accessToken: (data) => _extractByPath(data, accessTokenPath)?.toString(),
      refreshToken: refreshTokenPath != null
          ? (data) => _extractByPath(data, refreshTokenPath)?.toString()
          : null,
      profileData: profilePath != null
          ? (data) {
              final profile = _extractByPath(data, profilePath);
              if (profile is Map<String, dynamic>) {
                return profile;
              } else if (profile is Map) {
                return Map<String, dynamic>.from(profile);
              }
              return null;
            }
          : null,
      verificationToken: verificationTokenPath != null
          ? (data) => _extractByPath(data, verificationTokenPath)?.toString()
          : null,
      forgetPasswordToken: forgetPasswordTokenPath != null
          ? (data) => _extractByPath(data, forgetPasswordTokenPath)?.toString()
          : null,
      message: messagePath != null
          ? (data) => _extractByPath(data, messagePath)?.toString()
          : null,
    );
  }
  
  /// Internal key helper
  static dynamic _extractByKey(dynamic data, String key) {
    if (data is Map) {
      return data[key];
    }
    return null;
  }
  
  /// Internal path resolver
  static dynamic _extractByPath(dynamic data, String path) {
    final keys = path.split('.');
    dynamic current = data;
    for (final key in keys) {
      if (current is Map) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}
