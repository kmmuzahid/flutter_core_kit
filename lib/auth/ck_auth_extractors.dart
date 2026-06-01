// ignore_for_file: avoid_annotating_with_dynamic
import 'package:core_kit/auth/otp/otp_config.dart';

/// Maps [CkResponse.data] (dynamic) to tokens, profile JSON, and messages.
///
/// Use [CkAuthExtractors.standard] for typical `{ accessToken, user, ... }` payloads.
/// Provide [profile] for a custom parse; otherwise [CkProfileExtractor] uses
/// [CkAuthConfig.profileExtractor] directly on [CkResponse.data].
class CkAuthExtractors<TProfile> {
  const CkAuthExtractors({
    required this.accessToken,
    this.refreshToken,
    this.profile,
    this.verificationTokens,
    this.resetPasswordToken,
    this.message,
  });

  final String? Function(dynamic data) accessToken;
  final String? Function(dynamic data)? refreshToken;

  /// Optional full parse override. When null, [CkProfileExtractor] uses [CkAuthConfig.profileExtractor].
  final TProfile? Function(dynamic data)? profile;

  /// Trigger-specific verification token extractors.
  final Map<CkOtpTrigger, String? Function(dynamic data)>? verificationTokens;

  /// Extractor for password reset token returned upon successful OTP verification.
  final String? Function(dynamic data)? resetPasswordToken;

  final String? Function(dynamic data)? message;

  /// Standard keys on [CkResponse.data] (post-envelope `data` payload).
  factory CkAuthExtractors.standard({
    String accessTokenKey = 'accessToken',
    String refreshTokenKey = 'refreshToken',
    String profileKey = 'user',
    String messageKey = 'message',
    String resetPasswordTokenKey = 'token',
    Map<CkOtpTrigger, String>? verificationTokenKeys = const {
      CkOtpTrigger.signup: 'createUserToken',
      CkOtpTrigger.login: 'loginUserToken',
      CkOtpTrigger.forgetPassword: 'forgetToken',
    },
  }) {
    return CkAuthExtractors<TProfile>(
      accessToken: (data) => _extractByKey(data, accessTokenKey)?.toString(),
      refreshToken: (data) => _extractByKey(data, refreshTokenKey)?.toString(),
      resetPasswordToken: (data) => _extractByKey(data, resetPasswordTokenKey)?.toString(),
      verificationTokens: _buildVerificationTokenExtractors(
        verificationTokenKeys,
        _extractByKey,
      ),
      message: (data) => _extractByKey(data, messageKey)?.toString(),
    );
  }

  factory CkAuthExtractors.fromPaths({
    required String accessTokenPath,
    String? refreshTokenPath,
    String? profilePath,
    String? messagePath,
    String? resetPasswordTokenPath,
    Map<CkOtpTrigger, String>? verificationTokenPaths = const {
      CkOtpTrigger.signup: 'createUserToken',
      CkOtpTrigger.login: 'loginUserToken',
      CkOtpTrigger.forgetPassword: 'forgetToken',
    },
  }) {
    return CkAuthExtractors<TProfile>(
      accessToken: (data) => _extractByPath(data, accessTokenPath)?.toString(),
      refreshToken: refreshTokenPath != null
          ? (data) => _extractByPath(data, refreshTokenPath)?.toString()
          : null,
      resetPasswordToken: resetPasswordTokenPath != null
          ? (data) => _extractByPath(data, resetPasswordTokenPath)?.toString()
          : null,
      verificationTokens: _buildVerificationTokenExtractors(
        verificationTokenPaths,
        _extractByPath,
      ),
      message: messagePath != null
          ? (data) => _extractByPath(data, messagePath)?.toString()
          : null,
    );
  }

  static Map<CkOtpTrigger, String? Function(dynamic data)>? 
      _buildVerificationTokenExtractors(
    Map<CkOtpTrigger, String>? tokenKeys,
    dynamic Function(dynamic data, String key) extractor,
  ) {
    if (tokenKeys == null) return null;
    return tokenKeys.map(
      (trigger, key) => MapEntry(
        trigger,
        (data) => extractor(data, key)?.toString(),
      ),
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
