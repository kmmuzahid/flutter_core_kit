import 'dart:async';

/// A stream that caches the latest value and replays it to new listeners.
/// Pure Dart — no Flutter dependency, no state management lock-in.
/// 
/// When a listener subscribes for the first time, it immediately receives
/// the last emitted value (if any), so the screen never starts blank.
///
/// Usage:
///   final stream = CkBehaviorStream<int>(initialValue: 0);
///   stream.listen((value) => print(value)); // prints 0 immediately
///   stream.add(1); // prints 1
///   
///   // New subscriber gets last value (1) immediately
///   stream.listen((value) => print(value)); // prints 1 immediately
class CkBehaviorStream<T> {
  T _value;
  final StreamController<T> _controller = StreamController<T>.broadcast();
  
  CkBehaviorStream({required T initialValue}) : _value = initialValue;
  
  /// Current value (synchronous access)
  T get value => _value;
  
  /// Add new value to the stream
  void add(T value) {
    _value = value;
    _controller.add(value);
  }
  
  /// Listen to the stream — immediately receives last value, then future updates
  StreamSubscription<T> listen(
    void Function(T value) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Emit current value synchronously to new subscriber
    onData(_value);
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
  
  /// Get the raw stream (without replay — for advanced use)
  Stream<T> get stream => _controller.stream;
  
  /// Dispose the stream controller
  void dispose() => _controller.close();
}
