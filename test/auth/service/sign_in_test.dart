// test/auth/service/sign_in_test.dart
// Tests CkAuthService.signIn() using mockAuth=true to bypass network.
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

/// Build a fully initialised CkAuthService backed by in-memory storage
/// and mock auth (no real HTTP calls).
Future<CkAuthService<dynamic>> _buildService({
  required TestFlowHandlers handlers,
  Set<CkOtpTrigger> autoTriggers = const {},
  bool mockAuth = true,
}) async {
  CkStorage.resetForTests();

  final config = buildMockConfig(
    handlers: handlers,
    autoTriggers: autoTriggers,
    mockAuth: mockAuth,
  );

  final tokenManager = CkAuthTokenManager();
  // Don't call tokenManager.initialize() — that would touch disk.
  // We manually use saveTokens/clearTokens in tests.

  return CkAuthService.initForTests(config: config, tokenManager: tokenManager);
}

void main() {
  group('CkAuthService.signIn — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // SI-01
    test(
      'signIn success (no OTP) → saves mock tokens and sets authenticated',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {},
        );

        final result = await service.signIn(
          request: const CkLoginRequest(
            body: {'email': 'a@b.com', 'password': 'pass'},
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(service.isAuthenticated, isTrue);
        expect(
          service.tokenManager.currentAccessToken,
          equals('mock_access_token'),
        );
      },
    );

    // SI-05
    test('signIn success → calls onAuthenticated handler', () async {
      final service = await _buildService(handlers: handlers, autoTriggers: {});
      await service.signIn(
        request: const CkLoginRequest(
          body: {'email': 'a@b.com', 'password': 'pass'},
        ),
      );
      expect(handlers.onAuthenticatedCalled, isTrue);
    });

    // SI-06
    test('signIn with mockAuth=true saves mock_access_token', () async {
      final service = await _buildService(handlers: handlers);
      await service.signIn(
        request: const CkLoginRequest(
          body: {'email': 'u@test.com', 'password': '123'},
        ),
      );
      expect(
        service.tokenManager.currentAccessToken,
        equals('mock_access_token'),
      );
    });

    // SI-07
    test(
      'signIn with mockAuth + login in autoTriggers → requiresOtp=true',
      () async {
        final service = await _buildService(
          handlers: handlers,
          autoTriggers: {CkOtpTrigger.login},
        );
        final result = await service.signIn(
          request: const CkLoginRequest(
            body: {'email': 'u@test.com', 'password': '123'},
          ),
        );
        expect(result.requiresOtp, isTrue);
        expect(result.otpTrigger, equals(CkOtpTrigger.login));
        expect(handlers.showOtpVerificationCalled, isTrue);
      },
    );

    test('signIn returns raw response in rawResponse field', () async {
      final service = await _buildService(handlers: handlers, autoTriggers: {});
      final result = await service.signIn(
        request: const CkLoginRequest(
          body: {'email': 'u@test.com', 'password': '123'},
        ),
      );
      expect(result.rawResponse, isNotNull);
    });

    test('signIn result has statusCode 200 in mock mode', () async {
      final service = await _buildService(handlers: handlers, autoTriggers: {});
      final result = await service.signIn(
        request: const CkLoginRequest(
          body: {'email': 'u@test.com', 'password': '123'},
        ),
      );
      expect(result.statusCode, equals(200));
    });
  });
}
