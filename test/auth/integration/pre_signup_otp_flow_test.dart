// test/auth/integration/pre_signup_otp_flow_test.dart
// Flow: sendOtp(signup) → verifyOtp() → signUp() — no duplicate OTP screen
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

Future<CkAuthService<dynamic>> _buildService(TestFlowHandlers handlers) async {
  CkStorage.resetForTests();
  final config = buildMockConfig(
    handlers: handlers,
    autoTriggers: {CkOtpTrigger.signup},
    mockAuth: true,
  );
  return CkAuthService.initForTests(
    config: config,
    tokenManager: CkAuthTokenManager(),
  );
}

void main() {
  group('Pre-Signup OTP Flow (PS tests)', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // PS-01
    test(
      'full pre-signup OTP flow → signUp skips OTP and completes cleanly',
      () async {
        final service = await _buildService(handlers);

        // Step 1: Manual sendOtp (pre-signup)
        final sendResult = await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'user@test.com',
        );
        expect(sendResult.requiresOtp, isTrue);
        expect(handlers.showOtpVerificationCalled, isTrue);

        // Step 2: User enters OTP — no loginCallback → sets _preSignupOtpVerified=true
        handlers.reset();
        final verifyResult = await service.verifyOtp(otp: '123456');
        expect(verifyResult.isSuccess, isTrue);

        // Step 3: User fills signup form → signUp should NOT show another OTP screen
        handlers.reset();
        final signUpResult = await service.signUp(
          body: {'email': 'user@test.com', 'password': 'pass123'},
        );
        expect(signUpResult.isSuccess, isTrue);
        expect(signUpResult.requiresOtp, isFalse);
        expect(handlers.showOtpVerificationCalled, isFalse); // NO DUPLICATE OTP
      },
    );

    // PS-02
    test(
      'verifyOtp with no pending callback sets _preSignupOtpVerified=true',
      () async {
        final service = await _buildService(handlers);
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        await service.verifyOtp(otp: '123456');

        // State: _preSignupOtpVerified=true
        // Next signUp should bypass OTP
        final signUpResult = await service.signUp(body: {'email': 'a@b.com'});
        expect(signUpResult.requiresOtp, isFalse);
      },
    );

    // PS-03
    test(
      'signUp resets _preSignupOtpVerified to false after completing',
      () async {
        final service = await _buildService(handlers);
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        await service.verifyOtp(otp: '123456');
        await service.signUp(body: {'email': 'a@b.com'});

        // Flag should be reset — next signUp re-triggers OTP
        handlers.reset();
        final secondSignUp = await service.signUp(body: {'email': 'b@c.com'});
        expect(secondSignUp.requiresOtp, isTrue);
      },
    );

    // PS-04 — CRITICAL REGRESSION TEST
    test(
      'second signUp call without re-verify does NOT bypass OTP (one-shot only)',
      () async {
        final service = await _buildService(handlers);

        // Complete pre-signup flow once
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        await service.verifyOtp(otp: '123456');
        await service.signUp(body: {'email': 'a@b.com'}); // consumes the flag

        // Second signUp — flag already consumed → OTP required again
        handlers.reset();
        final secondResult = await service.signUp(body: {'email': 'a@b.com'});
        expect(
          secondResult.requiresOtp,
          isTrue,
          reason: 'The one-shot bypass must NOT apply to subsequent signUps',
        );
        expect(handlers.showOtpVerificationCalled, isTrue);
      },
    );
  });
}
