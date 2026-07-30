// test/auth/service/resend_otp_test.dart
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
  group('CkAuthService.resendOtp + sendOtp — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // RO-01
    test('resendOtp returns success in mock mode', () async {
      final service = await _buildService(handlers: handlers);
      // First send to initialise state
      await service.sendOtp(trigger: CkOtpTrigger.signup, recipient: 'a@b.com');
      // Now resend — mock mode: restart timer and return success
      final result = await service.resendOtp();
      expect(result.isSuccess, isTrue);
    });

    // RO-02
    test('resendOtp mock mode → restarts timer (countdown > 0)', () async {
      final service = await _buildService(handlers: handlers);
      await service.sendOtp(trigger: CkOtpTrigger.signup, recipient: 'a@b.com');
      await service.resendOtp();
      // After resend, timer restarted → countdown should be non-zero
      expect(service.otpManager.resendCountdown.value, greaterThan(0));
    });

    // RO-04
    test('sendOtp with trigger+recipient sets lastTrigger and lastRecipient', () async {
      final service = await _buildService(handlers: handlers);
      await service.sendOtp(trigger: CkOtpTrigger.signup, recipient: 'user@test.com');
      expect(service.otpManager.lastTrigger, equals(CkOtpTrigger.signup));
      expect(service.otpManager.lastRecipient, equals('user@test.com'));
    });

    // RO-05
    test('sendOtp shows OTP verification screen on success', () async {
      final service = await _buildService(handlers: handlers);
      await service.sendOtp(trigger: CkOtpTrigger.signup, recipient: 'a@b.com');
      expect(handlers.showOtpVerificationCalled, isTrue);
    });

    // RO-06
    test('sendOtp result has requiresOtp=true', () async {
      final service = await _buildService(handlers: handlers);
      final result = await service.sendOtp(
        trigger: CkOtpTrigger.signup,
        recipient: 'a@b.com',
      );
      expect(result.requiresOtp, isTrue);
    });

    test('sendOtp returns correct otpTrigger in result', () async {
      final service = await _buildService(handlers: handlers);
      final result = await service.sendOtp(
        trigger: CkOtpTrigger.forgetPassword,
        recipient: 'a@b.com',
      );
      expect(result.otpTrigger, equals(CkOtpTrigger.forgetPassword));
    });
  });
}
