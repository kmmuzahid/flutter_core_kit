import 'package:core_kit/auth/reactive/behavior_stream.dart';

enum CkAuthStatus {
  unknown,        // app just launched, checking tokens
  authenticated,  // valid tokens exist
  unauthenticated, // no tokens or expired
}

/// Pure Dart stream-based auth state.
/// New subscribers immediately receive the current state.
class CkAuthStateController {
  late final CkBehaviorStream<CkAuthStatus> _status;
  
  CkAuthStateController() {
    _status = CkBehaviorStream(initialValue: CkAuthStatus.unknown);
  }
  
  /// Stream of auth status — replays last value to new subscribers
  CkBehaviorStream<CkAuthStatus> get status => _status;
  
  /// Current status (synchronous)
  CkAuthStatus get current => _status.value;
  
  bool get isAuthenticated => current == CkAuthStatus.authenticated;
  bool get isUnauthenticated => current == CkAuthStatus.unauthenticated;
  bool get isChecking => current == CkAuthStatus.unknown;
  
  void setAuthenticated() => _status.add(CkAuthStatus.authenticated);
  void setUnauthenticated() => _status.add(CkAuthStatus.unauthenticated);
  void setUnknown() => _status.add(CkAuthStatus.unknown);
  
  void dispose() => _status.dispose();
}
