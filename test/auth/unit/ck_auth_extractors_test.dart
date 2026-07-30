// test/auth/unit/ck_auth_extractors_test.dart
import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkAuthExtractors.standard()', () {
    late CkAuthExtractors extractors;

    setUp(() {
      extractors = CkAuthExtractors.standard();
    });

    // AE-01
    test('extracts accessToken from flat map', () {
      final data = {'accessToken': 'access_xyz'};
      expect(extractors.accessToken(data), equals('access_xyz'));
    });

    // AE-02
    test('extracts refreshToken from flat map', () {
      final data = {'refreshToken': 'refresh_abc'};
      expect(extractors.refreshToken?.call(data), equals('refresh_abc'));
    });

    // AE-03
    test('returns null for missing keys', () {
      final data = <String, dynamic>{};
      expect(extractors.accessToken(data), isNull);
      expect(extractors.refreshToken?.call(data), isNull);
    });

    // AE-04
    test('extracts verificationToken for signup trigger (createUserToken)', () {
      final data = {'createUserToken': 'vt_signup_123'};
      final token = extractors.verificationTokens?[CkOtpTrigger.signup]?.call(data);
      expect(token, equals('vt_signup_123'));
    });

    // AE-05
    test('extracts verificationToken for forgetPassword trigger (forgetToken)', () {
      final data = {'forgetToken': 'vt_forget_456'};
      final token = extractors.verificationTokens?[CkOtpTrigger.forgetPassword]?.call(data);
      expect(token, equals('vt_forget_456'));
    });

    test('extracts verificationToken for login trigger (loginUserToken)', () {
      final data = {'loginUserToken': 'vt_login_789'};
      final token = extractors.verificationTokens?[CkOtpTrigger.login]?.call(data);
      expect(token, equals('vt_login_789'));
    });

    // AE-03 (null from non-map)
    test('returns null when data is not a map', () {
      expect(extractors.accessToken('not a map'), isNull);
      expect(extractors.accessToken(42), isNull);
      expect(extractors.accessToken(null), isNull);
    });

    // AE-09
    test('custom key overrides work in standard factory', () {
      final customExtractors = CkAuthExtractors.standard(
        accessTokenKey: 'token',
        refreshTokenKey: 'rt',
      );
      final data = {'token': 'my_access', 'rt': 'my_refresh'};
      expect(customExtractors.accessToken(data), equals('my_access'));
      expect(customExtractors.refreshToken?.call(data), equals('my_refresh'));
    });
  });

  group('CkAuthExtractors.fromPaths()', () {
    // AE-06
    test('extracts accessToken via dot-notation path', () {
      final extractors = CkAuthExtractors.fromPaths(
        accessTokenPath: 'data.token',
      );
      final data = {'data': {'token': 'nested_token'}};
      expect(extractors.accessToken(data), equals('nested_token'));
    });

    // AE-07
    test('returns null for invalid path', () {
      final extractors = CkAuthExtractors.fromPaths(
        accessTokenPath: 'data.missing.key',
      );
      final data = {'data': {'token': 'nested_token'}};
      expect(extractors.accessToken(data), isNull);
    });

    // AE-08
    test('handles non-map intermediate nodes gracefully', () {
      final extractors = CkAuthExtractors.fromPaths(
        accessTokenPath: 'data.token.value',
      );
      // data.token is a string, not a map — should not throw
      final data = {'data': {'token': 'just_a_string'}};
      expect(() => extractors.accessToken(data), returnsNormally);
      expect(extractors.accessToken(data), isNull);
    });

    test('extracts nested refreshToken via path', () {
      final extractors = CkAuthExtractors.fromPaths(
        accessTokenPath: 'access',
        refreshTokenPath: 'nested.refresh',
      );
      final data = {'access': 'tok', 'nested': {'refresh': 'rtok'}};
      expect(extractors.accessToken(data), equals('tok'));
      expect(extractors.refreshToken?.call(data), equals('rtok'));
    });

    test('returns null when root is not a map', () {
      final extractors = CkAuthExtractors.fromPaths(accessTokenPath: 'token');
      expect(extractors.accessToken(null), isNull);
      expect(extractors.accessToken('string'), isNull);
    });
  });

  group('CkAuthExtractors.resetPasswordToken', () {
    test('standard extractor uses "token" key', () {
      final extractors = CkAuthExtractors.standard();
      final data = {'token': 'reset_token_abc'};
      expect(extractors.resetPasswordToken?.call(data), equals('reset_token_abc'));
    });

    test('returns null when token key is absent', () {
      final extractors = CkAuthExtractors.standard();
      expect(extractors.resetPasswordToken?.call({}), isNull);
    });
  });
}
