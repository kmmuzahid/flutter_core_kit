import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLogger {
  static bool enableLogs = kDebugMode; // Only log in debug mode
  static final DateFormat _timeFormatter = DateFormat('HH:mm:ss');

  // ANSI color codes
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _gray = '\x1B[90m';
  static const _red = '\x1B[31m';
  static const _brightRed = '\x1B[91m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _blue = '\x1B[34m';
  static const _cyan = '\x1B[36m';
  static const _magenta = '\x1B[35m';

  static void _log(String level, String message, {String? tag}) {
    if (!enableLogs) {
      return;
    }

    final now = DateTime.now();
    final time = _timeFormatter.format(now);
    final coloredTime = '$_gray[$time]$_reset';

    final coloredTag = tag != null ? '$_yellow[$tag]$_reset ' : '';

    late String levelEmoji;
    late String levelColor;

    switch (level) {
      case 'INFO':
        levelEmoji = 'ℹ️ℹ️';
        levelColor = _blue;
        break;
      case 'WARN':
        levelEmoji = '⚠️⚠️';
        levelColor = _yellow;
        break;
      case 'ERROR':
        levelEmoji = '❌❌';
        levelColor = _red;
        break;
      case 'DEBUG':
        levelEmoji = '🐞🐞';
        levelColor = _green;
        break;
      case 'API DEBUG':
        levelEmoji = '🌐📡';
        levelColor = _cyan;
        break;
      case 'API ERROR':
        levelEmoji = '🚨🛑';
        levelColor = _brightRed;
        break;
      case 'MOCK':
        levelEmoji = '🎭🧪';
        levelColor = _magenta;
        break;
      default:
        levelEmoji = '';
        levelColor = _reset;
    }

    final levelText = '$levelEmoji $_bold$levelColor$level$_reset';
    final coloredMessage = '$levelColor$message$_reset';

    final formatted = '$coloredTime [$levelText] $coloredTag$coloredMessage';

    debugPrint(formatted);
  }

  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log('WARN', message, tag: tag);
  }

  static void error(String message, {String? tag}) {
    _log('ERROR', message, tag: tag);
  }

  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  static void apiDebug(String message, {String? tag}) {
    _log('API DEBUG', message, tag: tag);
  }

  static void apiError(String message, {String? tag}) {
    _log('API ERROR', message, tag: tag);
  }

  static void screen(String message, {String? tag}) {
    _log('SCREEN', message, tag: tag);
  }
}
