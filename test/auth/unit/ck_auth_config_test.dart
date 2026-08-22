// test/auth/unit/ck_auth_config_test.dart
// ignore_for_file: deprecated_member_use
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_endpoints.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:flutter_test/flutter_test.dart';

CkOtpConfig _otpConfig() => CkOtpConfig(
  verifyBodyBuilder: (cb) => {'otp': cb.otp},
  resendBodyBuilder: (cb) => {'email': cb.recipient},
);

const _endpoints = CkAuthEndpoints(
  signup: '/signup',
  signin: '/signin',
  forgotPassword: '/forgot',
  sendOtp: '/otp/send',
  verifyOtp: '/otp/verify',
  getProfile: '/profile',
  updateProfile: '/profile',
  logout: '/logout',
  resetPassword: '/reset',
);

void main() {
  group('CkAuthConfig.resolveLoginRequest', () {
    // AC-01
    test('uses loginRequestBuilder when present', () {
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: _otpConfig(),
        loginRequestBuilder: (cb) => CkLoginRequest(
          body: {'email': cb.account, 'password': cb.password},
        ),
      );

      final req = config.resolveLoginRequest(
        LoginCallback(account: 'a@b.com', password: 'secret'),
      );
      expect(req.body?['email'], equals('a@b.com'));
      expect(req.body?['password'], equals('secret'));
    });

    // AC-02
    test('falls back to deprecated loginBodyBuilder', () {
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: _otpConfig(),
        loginBodyBuilder: (cb) => {
          'username': cb.account,
          'pass': cb.password ?? '',
        },
      );

      final req = config.resolveLoginRequest(
        LoginCallback(account: 'u@test.com', password: '123'),
      );
      expect(req.body?['username'], equals('u@test.com'));
    });

    // AC-03
    test('merges extra headers into request headers', () {
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: _otpConfig(),
        loginRequestBuilder: (cb) =>
            const CkLoginRequest(body: {}, headers: {'X-Existing': 'yes'}),
      );

      final req = config.resolveLoginRequest(
        LoginCallback(account: 'a@b.com'),
        headers: {'X-Extra': 'new'},
      );
      expect(req.headers?['X-Existing'], equals('yes'));
      expect(req.headers?['X-Extra'], equals('new'));
    });

    // AC-04
    test('preserves original headers when no extra headers are passed', () {
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: _otpConfig(),
        loginRequestBuilder: (cb) =>
            const CkLoginRequest(body: {}, headers: {'X-Token': 'abc'}),
      );

      final req = config.resolveLoginRequest(LoginCallback(account: 'a@b.com'));
      expect(req.headers, equals({'X-Token': 'abc'}));
    });

    // AC-05
    test('StateError thrown if neither builder is configured (via assert)', () {
      // The CkAuthConfig assert prevents this at construction time
      expect(
        () => CkAuthConfig(
          endpoints: _endpoints,
          otpConfig: _otpConfig(),
          // neither loginRequestBuilder nor loginBodyBuilder provided
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    // AC-06
    test('mockAuth defaults to false', () {
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: _otpConfig(),
        loginRequestBuilder: (cb) => const CkLoginRequest(body: {}),
      );
      expect(config.mockAuth, isFalse);
    });

    // AC-07
    test(
      'extractors defaults to CkAuthExtractors.standard() when not provided',
      () {
        final config = CkAuthConfig(
          endpoints: _endpoints,
          otpConfig: _otpConfig(),
          loginRequestBuilder: (cb) => const CkLoginRequest(body: {}),
        );
        // Standard extractors should extract 'accessToken' key
        final token = config.extractors.accessToken({'accessToken': 'tok123'});
        expect(token, equals('tok123'));
      },
    );

    test(
      'resolveLoginRequest with empty extra headers does not modify request',
      () {
        final config = CkAuthConfig(
          endpoints: _endpoints,
          otpConfig: _otpConfig(),
          loginRequestBuilder: (cb) =>
              const CkLoginRequest(body: {}, headers: {'X-Keep': 'me'}),
        );
        final req = config.resolveLoginRequest(
          LoginCallback(account: 'a@b.com'),
          headers: {}, // empty — should not change anything
        );
        expect(req.headers, equals({'X-Keep': 'me'}));
      },
    );
  });
}
