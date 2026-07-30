// test/auth/service/verify_otp_test.dart
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

Future<CkAuthService<dynamic>> _buildService({
  required TestFlowHandlers handlers,
  Set<CkOtpTrigger> autoTriggers = const {
    CkOtpTrigger.signup,
    CkOtpTrigger.forgetPassword,
    CkOtpTrigger.login,
  },
}) async {
  CkStorage.resetForTests();
  final config = buildMockConfig(
    handlers: handlers,
    autoTriggers: autoTriggers,
    mockAuth: true,
  );
  return CkAuthService.initForTests(
    config: config,
    tokenManager: CkAuthTokenManager(),
  );
}

void main() {
  group('CkAuthService.verifyOtp — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // VO-01
    test(
      'verifyOtp for signup trigger → calls _resolvePostSignupAuth → success',
      () async {
        final service = await _buildService(handlers: handlers);

        // Trigger signup OTP first
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        expect(service.otpManager.lastTrigger, equals(CkOtpTrigger.signup));

        // Verify OTP — should resolve post-signup auth
        final result = await service.verifyOtp(otp: '123456');
        expect(result.isSuccess, isTrue);
      },
    );

    // VO-02
    test('verifyOtp for login trigger → returns success (mock)', () async {
      final service = await _buildService(handlers: handlers);

      // After signIn with OTP required, lastTrigger=login
      await service.signIn(
        request: CkLoginRequest(
          body: {'email': 'u@test.com', 'password': 'p'},
        ),
      );
      // lastTrigger is set to login by mock signIn with autoTrigger
      final result = await service.verifyOtp(otp: '111111');
      expect(result.isSuccess, isTrue);
    });

    // VO-03
    test('verifyOtp for forgetPassword → calls showResetPassword', () async {
      final service = await _buildService(handlers: handlers);
      await service.forgotPassword(body: {'email': 'a@b.com'});
      expect(
        service.otpManager.lastTrigger,
        equals(CkOtpTrigger.forgetPassword),
      );

      await service.verifyOtp(otp: '999999');
      expect(handlers.showResetPasswordCalled, isTrue);
    });

    // VO-05
    test(
      'verifyOtp mockAuth + signup trigger → _resolvePostSignupAuth called',
      () async {
        final service = await _buildService(handlers: handlers);
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        final result = await service.verifyOtp(otp: '123456');
        expect(result.isSuccess, isTrue);
      },
    );

    // VO-06
    test(
      'verifyOtp mockAuth + FP trigger → showResetPassword called',
      () async {
        final service = await _buildService(handlers: handlers);
        await service.forgotPassword(body: {'email': 'a@b.com'});
        await service.verifyOtp(otp: '123456');
        expect(handlers.showResetPasswordCalled, isTrue);
      },
    );

    // VO-07
    test('verifyOtp mockAuth + login trigger → returns success', () async {
      final service = await _buildService(handlers: handlers);
      await service.signIn(
        request: CkLoginRequest(
          body: {'email': 'u@test.com', 'password': 'p'},
        ),
      );
      final result = await service.verifyOtp(otp: '000000');
      expect(result.isSuccess, isTrue);
    });
  });
}
