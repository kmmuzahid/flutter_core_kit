// test/auth/service/resolve_post_signup_auth_test.dart
//
// Targeted tests for the `dynamic responseData` parameter change in
// `_resolvePostSignupAuth`. Since the method is private, it is tested
// indirectly through signUp() and verifyOtp() — the two public callers.
//
// Change: `required responseData` → `required dynamic responseData`
// (lib/auth/ck_auth_service.dart:366)

import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

/// Builds a mock service with no OTP auto-triggers so signUp goes directly
/// through _resolvePostSignupAuth without any OTP detour.
Future<CkAuthService<dynamic>> _buildNoOtpService({
  TestFlowHandlers? handlers,
}) async {
  CkStorage.resetForTests();
  final config = buildMockConfig(
    handlers: handlers ?? TestFlowHandlers(),
    autoTriggers: {}, // no OTP → straight to _resolvePostSignupAuth
    mockAuth: true,
  );
  return CkAuthService.initForTests(
    config: config,
    tokenManager: CkAuthTokenManager(),
  );
}

/// Builds a service with signup OTP trigger so verifyOtp calls
/// _resolvePostSignupAuth with the mock Map responseData.
Future<CkAuthService<dynamic>> _buildWithSignupOtp({
  required TestFlowHandlers handlers,
}) async {
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
  group('_resolvePostSignupAuth — dynamic responseData (via signUp)', () {
    // RPSA-01
    // signUp in mock mode with no autoTriggers calls _resolvePostSignupAuth
    // with `const {'message': 'Mock sign up successful'}` (Map<String,dynamic>).
    // Verifies dynamic Map data is accepted and result is success.
    test('RPSA-01: Map responseData → isSuccess true', () async {
      final service = await _buildNoOtpService();
      final result = await service.signUp(
        body: {'email': 'test@x.com', 'password': 'pass'},
      );
      expect(result.isSuccess, isTrue);
    });

    // RPSA-02
    // rawResponse in the result must be the exact dynamic Map object that
    // was passed into _resolvePostSignupAuth. Verifies the value is not lost.
    test('RPSA-02: rawResponse is preserved from dynamic Map input', () async {
      final service = await _buildNoOtpService();
      final result = await service.signUp(body: {'email': 'test@x.com'});
      expect(result.rawResponse, isNotNull);
      expect(result.rawResponse, isA<Map>());
    });

    // RPSA-03
    // statusCode from the call site (200 in mock) must be forwarded correctly
    // through _resolvePostSignupAuth to the result.
    test(
      'RPSA-03: statusCode is forwarded correctly through dynamic path',
      () async {
        final service = await _buildNoOtpService();
        final result = await service.signUp(body: {'email': 'test@x.com'});
        expect(result.statusCode, equals(200));
      },
    );

    // RPSA-04
    // Calling signUp multiple times (each creates a fresh _resolvePostSignupAuth
    // invocation with a new dynamic Map) — ensures no state leak between calls.
    test('RPSA-04: repeated signUp calls each resolve correctly', () async {
      final service = await _buildNoOtpService();

      final r1 = await service.signUp(body: {'email': 'a@x.com'});
      final r2 = await service.signUp(body: {'email': 'b@x.com'});
      final r3 = await service.signUp(body: {'email': 'c@x.com'});

      expect(r1.isSuccess, isTrue);
      expect(r2.isSuccess, isTrue);
      expect(r3.isSuccess, isTrue);
    });
  });

  group('_resolvePostSignupAuth — dynamic responseData (via verifyOtp)', () {
    // RPSA-05
    // verifyOtp in mock mode for signup trigger calls _resolvePostSignupAuth
    // with `const {'message': 'Mock OTP verification successful'}` (Map).
    // Verifies dynamic Map data flows through the verifyOtp code path.
    test(
      'RPSA-05: verifyOtp signup trigger → Map responseData → isSuccess',
      () async {
        final handlers = TestFlowHandlers();
        final service = await _buildWithSignupOtp(handlers: handlers);

        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        final result = await service.verifyOtp(otp: '123456');

        expect(result.isSuccess, isTrue);
      },
    );

    // RPSA-06
    // rawResponse from the verifyOtp path must be the Map passed into
    // _resolvePostSignupAuth and not null.
    test(
      'RPSA-06: verifyOtp path preserves rawResponse from dynamic Map',
      () async {
        final handlers = TestFlowHandlers();
        final service = await _buildWithSignupOtp(handlers: handlers);

        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'a@b.com',
        );
        final result = await service.verifyOtp(otp: '123456');

        expect(result.rawResponse, isNotNull);
      },
    );

    // RPSA-07
    // calledFromVerifyOtp=true path: verifyOtp sets _preSignupOtpVerified=true
    // then calls _resolvePostSignupAuth. The subsequent signUp should bypass
    // OTP entirely, proving the full flow through the dynamic param works end-to-end.
    test(
      'RPSA-07: verifyOtp+signUp end-to-end — dynamic param does not break flow',
      () async {
        final handlers = TestFlowHandlers();
        final service = await _buildWithSignupOtp(handlers: handlers);

        // Step 1: trigger OTP
        await service.sendOtp(
          trigger: CkOtpTrigger.signup,
          recipient: 'user@test.com',
        );
        // Step 2: verify OTP → _resolvePostSignupAuth called with dynamic Map
        final verifyResult = await service.verifyOtp(otp: '999999');
        expect(verifyResult.isSuccess, isTrue);

        // Step 3: signUp bypasses OTP because _preSignupOtpVerified=true
        handlers.reset();
        final signUpResult = await service.signUp(
          body: {'email': 'user@test.com', 'password': 'abc'},
        );
        expect(signUpResult.isSuccess, isTrue);
        expect(signUpResult.requiresOtp, isFalse);
        expect(handlers.showOtpVerificationCalled, isFalse);
      },
    );
  });
}
