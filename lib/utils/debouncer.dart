/*
 * @Author: Km Muzahid
 * @Date: 2026-01-26 11:13:05
 * @Email: km.muzahid@gmail.com
 */
//debouncer

import 'dart:async';
import 'dart:ui';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
