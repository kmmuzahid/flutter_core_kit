// test/auth/unit/ck_login_request_test.dart
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CkLoginRequest', () {
    // LR-01
    test('fromBody wraps map into body field', () {
      final request = CkLoginRequest.fromBody({'email': 'a@b.com'});
      expect(request.body, equals({'email': 'a@b.com'}));
      expect(request.pathParams, isNull);
      expect(request.headers, isNull);
    });

    // LR-02
    test('copyWith overrides only specified fields', () {
      const original = CkLoginRequest(
        body: {'email': 'a@b.com'},
        headers: {'X-Auth': 'token'},
      );
      final copy = original.copyWith(body: {'email': 'c@d.com'});
      expect(copy.body, equals({'email': 'c@d.com'}));
      expect(copy.headers, equals({'X-Auth': 'token'}));
    });

    // LR-03
    test('copyWith with null argument leaves original values unchanged', () {
      const original = CkLoginRequest(body: {'email': 'a@b.com'});
      final copy = original.copyWith();
      expect(copy.body, equals({'email': 'a@b.com'}));
    });

    // LR-04
    test(
      'all fields are nullable — empty constructor compiles and has nulls',
      () {
        const request = CkLoginRequest();
        expect(request.body, isNull);
        expect(request.pathParams, isNull);
        expect(request.queryParams, isNull);
        expect(request.formFields, isNull);
        expect(request.listBody, isNull);
        expect(request.files, isNull);
        expect(request.headers, isNull);
      },
    );

    test('copyWith merges headers correctly', () {
      const original = CkLoginRequest(body: {'k': 'v'}, headers: {'X-A': '1'});
      final copy = original.copyWith(headers: {'X-B': '2'});
      expect(
        copy.headers,
        equals({'X-B': '2'}),
      ); // copyWith replaces headers entirely
    });
  });
}
