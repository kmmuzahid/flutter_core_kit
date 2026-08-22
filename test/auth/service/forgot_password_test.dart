// test/auth/service/forgot_password_test.dart
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

Future<CkAuthService<dynamic>> _buildService({
  required TestFlowHandlers handlers,
  Set<CkOtpTrigger> autoTriggers = const {CkOtpTrigger.forgetPassword},
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
  group('CkAuthService.forgotPassword — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // FP-01
    test('forgotPassword with FP in autoTriggers → requiresOtp=true', () async {
      final service = await _buildService(
        handlers: handlers,
        autoTriggers: {CkOtpTrigger.forgetPassword},
      );
      final result = await service.forgotPassword(body: {'email': 'a@b.com'});
      expect(result.requiresOtp, isTrue);
      expect(result.otpTrigger, equals(CkOtpTrigger.forgetPassword));
    });

    // FP-02
    test(
      'forgotPassword without FP in autoTriggers → success without OTP',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {},
        );
        final result = await service.forgotPassword(body: {'email': 'a@b.com'});
        expect(result.isSuccess, isTrue);
        expect(result.requiresOtp, isFalse);
      },
    );

    // FP-04
    test(
      'forgotPassword mockAuth + FP in triggers → shows OTP screen',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.forgetPassword},
        );
        await service.forgotPassword(body: {'email': 'a@b.com'});
        expect(handlers.showOtpVerificationCalled, isTrue);
      },
    );

    // FP-05
    test(
      'forgotPassword mockAuth without FP trigger → calls showResetPassword',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {},
        );
        await service.forgotPassword(body: {'email': 'a@b.com'});
        expect(handlers.showResetPasswordCalled, isTrue);
      },
    );
  });
}
