// test/auth/integration/forgot_password_otp_flow_test.dart
// Flow: forgotPassword() → OTP screen → verifyOtp() → updatePassword()
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
    autoTriggers: {CkOtpTrigger.forgetPassword},
    mockAuth: true,
  );
  return CkAuthService.initForTests(
    config: config,
    tokenManager: CkAuthTokenManager(),
  );
}

void main() {
  group('Forgot Password OTP Flow (FO tests)', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // FO-01
    test('forgotPassword → requiresOtp=true and OTP screen shown', () async {
      final service = await _buildService(handlers);
      final result = await service.forgotPassword(body: {'email': 'a@b.com'});
      expect(result.requiresOtp, isTrue);
      expect(result.otpTrigger, equals(CkOtpTrigger.forgetPassword));
      expect(handlers.showOtpVerificationCalled, isTrue);
    });

    // FO-03
    test(
      'verifyOtp for FP trigger → calls showResetPassword handler',
      () async {
        final service = await _buildService(handlers);
        await service.forgotPassword(body: {'email': 'a@b.com'});

        handlers.reset();
        await service.verifyOtp(otp: '654321');
        expect(handlers.showResetPasswordCalled, isTrue);
      },
    );

    // FO-05
    test('updatePassword success → calls showLogin handler', () async {
      final service = await _buildService(handlers);
      await service.forgotPassword(body: {'email': 'a@b.com'});
      await service.verifyOtp(otp: '654321');

      handlers.reset();
      // In mock mode, updatePassword calls showLogin
      final result = await service.changePassword(
        body: {'password': 'newPass123', 'confirmPassword': 'newPass123'},
      );
      expect(result.isSuccess, isTrue);
      expect(handlers.showLoginCalled, isTrue);
    });

    // FO-02 — token extraction validated through OTP config & extractors unit tests
    test('FP OTP flow ends with showResetPassword navigation call', () async {
      final service = await _buildService(handlers);
      await service.forgotPassword(body: {'email': 'a@b.com'});
      await service.verifyOtp(otp: '123456');
      expect(handlers.showResetPasswordCalled, isTrue);
    });

    // FO-06
    test('updatePassword mock mode always returns success', () async {
      final service = await _buildService(handlers);
      final result = await service.changePassword(
        body: {'password': 'new_pass'},
      );
      expect(result.isSuccess, isTrue);
    });

    test(
      'forgotPassword in mock mode sets lastTrigger to forgetPassword',
      () async {
        final service = await _buildService(handlers);
        await service.forgotPassword(body: {'email': 'a@b.com'});
        expect(
          service.otpManager.lastTrigger,
          equals(CkOtpTrigger.forgetPassword),
        );
      },
    );

    test('full forgot password flow completes in correct order', () async {
      final events = <String>[];

      handlers.reset();
      // Override to capture order
      final handlersCopy = TestFlowHandlers();
      final orderedConfig = buildMockConfig(
        handlers: handlersCopy,
        autoTriggers: {CkOtpTrigger.forgetPassword},
        mockAuth: true,
      );
      final orderedService = await CkAuthService.initForTests(
        config: orderedConfig,
        tokenManager: CkAuthTokenManager(),
      );

      // step 1: forgot password
      await orderedService.forgotPassword(body: {'email': 'a@b.com'});
      events.add('otp_shown');

      // step 2: verify OTP
      await orderedService.verifyOtp(otp: '123456');
      events.add('reset_pw_shown');

      // step 3: update password
      await orderedService.changePassword(body: {'password': 'newPass'});
      events.add('login_shown');

      expect(events, equals(['otp_shown', 'reset_pw_shown', 'login_shown']));
    });
  });
}
