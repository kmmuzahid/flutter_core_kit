// test/auth/unit/ck_auth_result_test.dart
import 'package:core_kit/auth/ck_auth_result.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkAuthResult', () {
    // AR-01
    test('success() sets isSuccess=true and requiresOtp=false by default', () {
      const result = CkAuthResult<String>.success();
      expect(result.isSuccess, isTrue);
      expect(result.requiresOtp, isFalse);
      expect(result.otpTrigger, isNull);
    });

    // AR-02
    test('failure() sets isSuccess=false and data=null', () {
      const result = CkAuthResult<String>.failure(message: 'bad');
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.message, equals('bad'));
    });

    // AR-03
    test('full constructor with requiresOtp=true and otpTrigger=signup', () {
      const result = CkAuthResult<void>(
        isSuccess: true,
        requiresOtp: true,
        otpTrigger: CkOtpTrigger.signup,
        statusCode: 200,
      );
      expect(result.requiresOtp, isTrue);
      expect(result.otpTrigger, equals(CkOtpTrigger.signup));
      expect(result.statusCode, equals(200));
    });

    // AR-04
    test('rawResponse is preserved on success', () {
      const result = CkAuthResult<void>.success(rawResponse: {'key': 'value'});
      expect(result.rawResponse, equals({'key': 'value'}));
    });

    // AR-04b
    test('rawResponse is preserved on failure', () {
      const result = CkAuthResult<void>.failure(
        rawResponse: {'error': 'unauthorized'},
      );
      expect(result.rawResponse, equals({'error': 'unauthorized'}));
    });

    // AR-05
    test('statusCode is nullable and preserved correctly', () {
      const noCode = CkAuthResult<void>.success();
      expect(noCode.statusCode, isNull);

      const withCode = CkAuthResult<void>.success(statusCode: 201);
      expect(withCode.statusCode, equals(201));
    });

    test('data field is preserved in success constructor', () {
      const result = CkAuthResult<int>.success(data: 42);
      expect(result.data, equals(42));
    });
  });
}
