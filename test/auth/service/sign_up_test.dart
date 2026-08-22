// test/auth/service/sign_up_test.dart
// Tests CkAuthService.signUp() using mockAuth=true.
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

Future<CkAuthService<dynamic>> _buildService({
  required TestFlowHandlers handlers,
  Set<CkOtpTrigger> autoTriggers = const {CkOtpTrigger.signup},
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
  group('CkAuthService.signUp — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // SU-01
    test('signUp with no OTP autoTrigger resolves success immediately', () async {
      final service = await _buildService(handlers: handlers, autoTriggers: {});
      final result = await service.signUp(
        body: {'name': 'Test', 'email': 'a@b.com'},
      );
      // In mock mode with no autoTriggers, _resolvePostSignupAuth is called.
      // With no loginCallback and no token in response, _preSignupOtpVerified=true.
      // Since signUp(no autoOtp) → resolvePostSignupAuth → success.
      expect(result.isSuccess, isTrue);
    });

    // SU-02
    test('signUp with signup in autoTriggers → requiresOtp=true', () async {
      final service = await _buildService(
        handlers: handlers,
        autoTriggers: {CkOtpTrigger.signup},
      );
      final result = await service.signUp(body: {'email': 'a@b.com'});
      expect(result.requiresOtp, isTrue);
      expect(result.otpTrigger, equals(CkOtpTrigger.signup));
      expect(handlers.showOtpVerificationCalled, isTrue);
    });

    // SU-03 & SU-04: pre-signup OTP bypass
    test(
      'when _preSignupOtpVerified=true, signUp skips OTP and resets flag',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.signup},
        );

        // Simulate pre-signup OTP verification
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        await service.verifyOtp(otp: '123456');

        // Now signUp should skip OTP and complete immediately (no OTP screen)
        handlers.reset();
        final result = await service.signUp(
          body: {'email': 'a@b.com', 'password': 'pass'},
        );
        expect(result.isSuccess, isTrue);
        expect(result.requiresOtp, isFalse);
        expect(handlers.showOtpVerificationCalled, isFalse);
      },
    );

    // SU-06
    test(
      'signUp with loginCallback stores it as pendingLoginCallback',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.signup},
        );
        final result = await service.signUp(
          body: {'email': 'a@b.com'},
          loginCallback: LoginCallback(account: 'a@b.com', password: '123'),
        );
        // With OTP required and loginCallback set, it should store callback
        expect(result.requiresOtp, isTrue);
      },
    );

    // SU-08
    test(
      'signUp with mockAuth=true and _preSignupOtpVerified → resolves immediately',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.signup},
        );
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        await service.verifyOtp(otp: '123456');

        final result = await service.signUp(body: {'email': 'a@b.com'});
        expect(result.isSuccess, isTrue);
        expect(result.requiresOtp, isFalse);
      },
    );

    // SU-09
    test(
      'signUp with mockAuth + signup in autoTriggers shows OTP screen',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.signup},
        );
        await service.signUp(body: {'email': 'a@b.com'});
        expect(handlers.showOtpVerificationCalled, isTrue);
      },
    );
  });
}
