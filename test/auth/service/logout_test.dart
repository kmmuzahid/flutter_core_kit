// test/auth/service/logout_test.dart
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_service.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_auth_config.dart';

Future<CkAuthService<dynamic>> _buildService({
  required TestFlowHandlers handlers,
}) async {
  CkStorage.resetForTests();
  final config = buildMockConfig(
    handlers: handlers,
    autoTriggers: {},
    mockAuth: true,
  );
  return CkAuthService.initForTests(
    config: config,
    tokenManager: CkAuthTokenManager(),
  );
}

void main() {
  group('CkAuthService.logout — mock mode', () {
    late TestFlowHandlers handlers;

    setUp(() {
      handlers = TestFlowHandlers();
    });

    // LO-01
    test('logout clears tokens and sets unauthenticated', () async {
      final service = await _buildService(handlers: handlers);

      // First sign in to get tokens
      await service.signIn(
        request: CkLoginRequest(
          body: {'email': 'a@b.com', 'password': 'p'},
        ),
      );
      expect(service.isAuthenticated, isTrue);
      expect(service.tokenManager.currentAccessToken, isNotNull);

      // Now logout
      await service.logout();
      expect(service.isAuthenticated, isFalse);
      expect(service.tokenManager.currentAccessToken, isNull);
    });

    // LO-02
    test('logout calls showLogin handler', () async {
      final service = await _buildService(handlers: handlers);
      await service.signIn(
        request: CkLoginRequest(
          body: {'email': 'a@b.com', 'password': 'p'},
        ),
      );
      handlers.reset();
      await service.logout();
      expect(handlers.showLoginCalled, isTrue);
    });

    // LO-03
    test(
      'logout with mockAuth=true bypasses network logoutHandler.execute()',
      () async {
        // If mock auth, logout should still succeed without any network call
        final service = await _buildService(handlers: handlers);
        await service.signIn(
          request: CkLoginRequest(
            body: {'email': 'a@b.com', 'password': 'p'},
          ),
        );
        // No network exception expected
        expect(() => service.logout(), returnsNormally);
      },
    );

    test('logout sets auth status to unauthenticated', () async {
      final service = await _buildService(handlers: handlers);
      await service.signIn(
        request: const CkLoginRequest(
          body: {'email': 'a@b.com', 'password': 'p'},
        ),
      );
      await service.logout();
      expect(service.authState.isUnauthenticated, isTrue);
    });
  });
}
