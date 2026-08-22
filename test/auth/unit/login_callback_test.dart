// test/auth/unit/login_callback_test.dart
// ignore_for_file: deprecated_member_use
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginCallback', () {
    // LC-01
    test('account param sets account field', () {
      final cb = LoginCallback(account: 'user@example.com', password: 'pass');
      expect(cb.account, equals('user@example.com'));
    });

    // LC-02
    test('deprecated username param silently maps to account', () {
      final cb = LoginCallback(username: 'legacyuser', password: 'pass');
      expect(cb.account, equals('legacyuser'));
    });

    // LC-03
    test('deprecated username getter returns same value as account', () {
      final cb = LoginCallback(account: 'myuser', password: 'pass');
      expect(cb.username, equals(cb.account));
    });

    // LC-04
    test('assert fires if both account and username are null', () {
      expect(() => LoginCallback(), throwsA(isA<AssertionError>()));
    });

    // LC-05
    test('password, args, trigger are all optional', () {
      final cb = LoginCallback(account: 'user@test.com');
      expect(cb.password, isNull);
      expect(cb.args, isNull);
      expect(cb.trigger, isNull);
    });

    test('args and trigger fields are preserved', () {
      final cb = LoginCallback(
        account: 'user@test.com',
        args: {'device': 'ios'},
        trigger: CkOtpTrigger.login,
      );
      expect(cb.args, equals({'device': 'ios'}));
      expect(cb.trigger, equals(CkOtpTrigger.login));
    });
  });
}
