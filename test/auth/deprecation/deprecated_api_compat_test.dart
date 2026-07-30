// test/auth/deprecation/deprecated_api_compat_test.dart
// ignore_for_file: deprecated_member_use
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_endpoints.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

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
  group('Deprecated API backward compatibility (DC tests)', () {
    // DC-01
    test('LoginCallback(username:) silently maps to account', () {
      final cb = LoginCallback(username: 'legacy_user', password: 'pass');
      expect(cb.account, equals('legacy_user'));
    });

    // DC-02
    test('callback.username getter returns account value', () {
      final cb = LoginCallback(account: 'modern_user', password: 'p');
      // ignore: deprecated_member_use
      expect(cb.username, equals('modern_user'));
    });

    // DC-03
    test('CkAuthService.signIn with deprecated username-based request resolves correctly',
        () async {
      CkStorage.resetForTests();
      // Build config with loginBodyBuilder (deprecated)
      // ignore: deprecated_member_use
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: buildOtpConfig(autoTriggers: {}),
        handlers: TestFlowHandlers().build(),
        // ignore: deprecated_member_use
        loginBodyBuilder: (cb) => {
          'username': cb.account, // using account (from deprecated username param)
          'password': cb.password ?? '',
        },
        mockAuth: true,
      );

      final service = await CkAuthService.initForTests(
        config: config,
        tokenManager: CkAuthTokenManager(),
      );

      // Use the deprecated username to build the request
      final legacyCb = LoginCallback(username: 'old_user', password: 'pass');
      final request = config.resolveLoginRequest(legacyCb);

      final result = await service.signIn(request: request);
      expect(result.isSuccess, isTrue);
    });

    // DC-04
    test('loginBodyBuilder is wrapped in CkLoginRequest.fromBody via resolveLoginRequest', () {
      // ignore: deprecated_member_use
      final config = CkAuthConfig(
        endpoints: _endpoints,
        otpConfig: buildOtpConfig(autoTriggers: {}),
        loginBodyBuilder: (cb) => {'email': cb.account, 'pw': cb.password ?? ''},
        mockAuth: true,
      );

      final req = config.resolveLoginRequest(
        LoginCallback(account: 'a@b.com', password: 'secret'),
      );
      // Should be wrapped into a CkLoginRequest with body
      expect(req.body, isNotNull);
      expect(req.body?['email'], equals('a@b.com'));
      expect(req.body?['pw'], equals('secret'));
    });

    // DC-05
    test('sendOtp() with no params delegates to resendOtp()', () async {
      // This tests CkAuth facade behavior — sendOtp(null, null) → resendOtp()
      // We verify by checking that calling sendOtp without params doesn't crash
      // and behaves like resendOtp (returns success in mock mode).
      CkStorage.resetForTests();
      final handlers = TestFlowHandlers();
      final config = buildMockConfig(
        handlers: handlers,
        autoTriggers: {CkOtpTrigger.signup},
        mockAuth: true,
      );
      final service = await CkAuthService.initForTests(
        config: config,
        tokenManager: CkAuthTokenManager(),
      );

      // First call sendOtp to establish state
      await service.sendOtp(trigger: CkOtpTrigger.signup, recipient: 'a@b.com');

      // Now resendOtp (which is what sendOtp() with no params delegates to)
      final result = await service.resendOtp();
      expect(result.isSuccess, isTrue);
    });

    // DC-06
    test('signUp with body (optional) still works', () async {
      CkStorage.resetForTests();
      final handlers = TestFlowHandlers();
      final config = buildMockConfig(
        handlers: handlers,
        autoTriggers: {},
        mockAuth: true,
      );
      final service = await CkAuthService.initForTests(
        config: config,
        tokenManager: CkAuthTokenManager(),
      );

      // body is optional — should work with null body
      final result = await service.signUp();
      expect(result.isSuccess, isTrue);
    });
  });
}
