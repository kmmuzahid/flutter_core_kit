import 'dart:async';

class CkDebouncer {
  CkDebouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// @deprecated Use [CkDebouncer] instead.
@Deprecated('Use CkDebouncer instead')
typedef Debouncer = CkDebouncer;
