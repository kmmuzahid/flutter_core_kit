import 'package:core_kit/auth/reactive/behavior_stream.dart';

/// Types of auth operations that can have loading states.
enum CkAuthLoadingType {
  signUp,
  signIn,
  forgotPassword,
  verifyOtp,
  sendOtp,
  updatePassword,
  socialLogin,
  logout,
  fetchProfile,
  updateProfile,
}

/// Manages per-operation loading state using [CkBehaviorStream].
///
/// Each [CkAuthLoadingType] gets its own reactive boolean stream,
/// allowing the UI to observe loading for specific operations independently.
class CkAuthLoadingController {
  final Map<CkAuthLoadingType, CkBehaviorStream<bool>> _streams = {};

  CkAuthLoadingController() {
    for (final type in CkAuthLoadingType.values) {
      _streams[type] = CkBehaviorStream(initialValue: false);
    }
  }

  /// Get the loading stream for a specific operation type.
  CkBehaviorStream<bool> streamOf(CkAuthLoadingType type) => _streams[type]!;

  /// Whether a specific operation is currently loading.
  bool isLoading(CkAuthLoadingType type) => _streams[type]!.value;

  /// Set loading state for a specific operation.
  void setLoading(CkAuthLoadingType type, bool value) {
    _streams[type]!.add(value);
  }

  /// Wraps an async operation with loading state management.
  /// Sets loading to `true` before the operation, and `false` after
  /// (regardless of success or failure).
  Future<T> wrap<T>(CkAuthLoadingType type, Future<T> Function() action) async {
    setLoading(type, true);
    try {
      return await action();
    } finally {
      setLoading(type, false);
    }
  }

  void dispose() {
    for (final stream in _streams.values) {
      stream.dispose();
    }
  }
}
