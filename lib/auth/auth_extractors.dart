// ignore_for_file: avoid_annotating_with_dynamic
import 'package:core_kit/auth/otp/otp_config.dart';

/// Maps [CkResponse.data] (dynamic) to tokens, profile JSON, and messages.
///
/// Use [CkAuthExtractors.standard] for typical `{ accessToken, user, ... }` payloads.
/// Provide [profile] for a custom parse; otherwise [CkProfileExtractor] uses
/// [profileData] with [CkAuthConfig.profileExtractor].
class CkAuthExtractors<TProfile> {
  const CkAuthExtractors({
    required this.accessToken,
    this.refreshToken,
    this.profileData,
    this.profile,
    this.verificationTokens,
    this.message,
  });

  final String? Function(dynamic data) accessToken;
  final String? Function(dynamic data)? refreshToken;

  /// Profile JSON fragment from [CkResponse.data] (persisted via jsonEncode).
  final dynamic Function(dynamic data)? profileData;

  /// Optional full parse override. When null, [CkProfileExtractor] uses [profileData] + profileExtractor.
  final TProfile? Function(dynamic data)? profile;

  /// Trigger-specific verification token extractors.
  final Map<CkOtpTrigger, String? Function(dynamic data)>? verificationTokens;
  
  final String? Function(dynamic data)? message;

  /// Standard keys on [CkResponse.data] (post-envelope `data` payload).
  factory CkAuthExtractors.standard({
    String accessTokenKey = 'accessToken',
    String refreshTokenKey = 'refreshToken',
    String profileKey = 'user',
    String messageKey = 'message',
  }) {
    return CkAuthExtractors<TProfile>(
      accessToken: (data) => _extractByKey(data, accessTokenKey)?.toString(),
      refreshToken: (data) => _extractByKey(data, refreshTokenKey)?.toString(),
      profileData: (data) => _extractByKey(data, profileKey),
      verificationTokens: {
        CkOtpTrigger.signup: (data) => _extractByKey(data, 'createUserToken')?.toString(),
        CkOtpTrigger.login: (data) => _extractByKey(data, 'loginUserToken')?.toString(),
        CkOtpTrigger.forgetPassword: (data) => _extractByKey(data, 'forgetToken')?.toString(),
      },
      message: (data) => _extractByKey(data, messageKey)?.toString(),
    );
  }

  factory CkAuthExtractors.fromPaths({
    required String accessTokenPath,
    String? refreshTokenPath,
    String? profilePath,
    String? messagePath,
  }) {
    return CkAuthExtractors<TProfile>(
      accessToken: (data) => _extractByPath(data, accessTokenPath)?.toString(),
      refreshToken: refreshTokenPath != null
          ? (data) => _extractByPath(data, refreshTokenPath)?.toString()
          : null,
      profileData: profilePath != null
          ? (data) => _extractByPath(data, profilePath)
          : null,
      verificationTokens: {
        CkOtpTrigger.signup: (data) => _extractByPath(data, 'createUserToken')?.toString(),
        CkOtpTrigger.login: (data) => _extractByPath(data, 'loginUserToken')?.toString(),
        CkOtpTrigger.forgetPassword: (data) => _extractByPath(data, 'forgetToken')?.toString(),
      },
      message: messagePath != null
          ? (data) => _extractByPath(data, messagePath)?.toString()
          : null,
    );
  }

  static dynamic _extractByKey(dynamic data, String key) {
    if (data is Map) {
      return data[key];
    }
    return null;
  }

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
