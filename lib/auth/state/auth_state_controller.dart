import 'package:core_kit/auth/reactive/behavior_stream.dart';

enum AuthStatus {
  unknown,        // app just launched, checking tokens
  authenticated,  // valid tokens exist
  unauthenticated, // no tokens or expired
}

/// Pure Dart stream-based auth state.
/// New subscribers immediately receive the current state.
class AuthStateController {
  late final BehaviorStream<AuthStatus> _status;
  
  AuthStateController() {
    _status = BehaviorStream(initialValue: AuthStatus.unknown);
  }
  
  /// Stream of auth status — replays last value to new subscribers
  BehaviorStream<AuthStatus> get status => _status;
  
  /// Current status (synchronous)
  AuthStatus get current => _status.value;
  
  bool get isAuthenticated => current == AuthStatus.authenticated;
  bool get isUnauthenticated => current == AuthStatus.unauthenticated;
  bool get isChecking => current == AuthStatus.unknown;
  
  void setAuthenticated() => _status.add(AuthStatus.authenticated);
  void setUnauthenticated() => _status.add(AuthStatus.unauthenticated);
  void setUnknown() => _status.add(AuthStatus.unknown);
  
  void dispose() => _status.dispose();
}
