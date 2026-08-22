// test/auth/unit/otp/otp_config_test.dart
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkOtpConfig defaults', () {
    late CkOtpConfig config;

    setUp(() {
      config = CkOtpConfig(
        verifyBodyBuilder: (cb) => {'otp': cb.otp},
        resendBodyBuilder: (cb) => {'email': cb.recipient},
      );
    });

    // OC-01
    test('default resendCooldown is 120 seconds', () {
      expect(config.resendCooldown.inSeconds, equals(120));
    });

    // OC-02
    test('default otpNotVerifiedStatusCode is 403', () {
      expect(config.otpNotVerifiedStatusCode, equals(403));
    });

    // OC-03
    test('autoTriggers defaults to empty set', () {
      expect(config.autoTriggers, isEmpty);
    });

    test('default otpLength is 6', () {
      expect(config.otpLength, equals(6));
    });

    test('default verificationTokenHeaderKey is "token"', () {
      expect(config.verificationTokenHeaderKey, equals('token'));
    });

    test('default sendVerificationTokenInHeader is true', () {
      expect(config.sendVerificationTokenInHeader, isTrue);
    });
  });

  group('CkOtpConfig custom values', () {
    test('can override resendCooldown', () {
      final config = CkOtpConfig(
        resendCooldown: const Duration(seconds: 30),
        verifyBodyBuilder: (cb) => {},
        resendBodyBuilder: (cb) => {},
      );
      expect(config.resendCooldown.inSeconds, equals(30));
    });

    test('can override otpNotVerifiedStatusCode', () {
      final config = CkOtpConfig(
        otpNotVerifiedStatusCode: 302,
        verifyBodyBuilder: (cb) => {},
        resendBodyBuilder: (cb) => {},
      );
      expect(config.otpNotVerifiedStatusCode, equals(302));
    });

    test('otpNotVerifiedStatusCode can be null (OTP disabled for login)', () {
      final config = CkOtpConfig(
        otpNotVerifiedStatusCode: null,
        verifyBodyBuilder: (cb) => {},
        resendBodyBuilder: (cb) => {},
      );
      expect(config.otpNotVerifiedStatusCode, isNull);
    });
  });

  // OC-04
  group('VerifyOtpCallBack', () {
    test('stores otp, token, trigger correctly', () {
      final cb = VerifyOtpCallBack(
        otp: '123456',
        token: 'my_token',
        trigger: CkOtpTrigger.signup,
      );
      expect(cb.otp, equals('123456'));
      expect(cb.token, equals('my_token'));
      expect(cb.trigger, equals(CkOtpTrigger.signup));
    });
  });

  // OC-05
  group('ResendOtpCallBack', () {
    test('stores recipient, token, trigger correctly', () {
      final cb = ResendOtpCallBack(
        recipient: 'user@example.com',
        token: 'vt_abc',
        trigger: CkOtpTrigger.forgetPassword,
      );
      expect(cb.recipient, equals('user@example.com'));
      expect(cb.token, equals('vt_abc'));
      expect(cb.trigger, equals(CkOtpTrigger.forgetPassword));
    });
  });

  group('CkOtpTrigger enum', () {
    test('contains signup, login, forgetPassword', () {
      expect(
        CkOtpTrigger.values,
        containsAll([
          CkOtpTrigger.signup,
          CkOtpTrigger.login,
          CkOtpTrigger.forgetPassword,
        ]),
      );
    });
  });

  group('CkOtpVerificationStrategy', () {
    test('contains tokenBased, sessionBased, identifierBased', () {
      expect(
        CkOtpVerificationStrategy.values,
        containsAll([
          CkOtpVerificationStrategy.tokenBased,
          CkOtpVerificationStrategy.sessionBased,
          CkOtpVerificationStrategy.identifierBased,
        ]),
      );
    });
  });
}
