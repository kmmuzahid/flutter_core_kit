import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CkLogger {
  CkLogger._();

  static bool enableLogs = kDebugMode; // Only log in debug mode
  static final DateFormat _timeFormatter = DateFormat('HH:mm:ss');

  // Auto-detect ANSI color support (only enabled on desktop platforms where it is native)
  static bool enableColors = () {
    try {
      if (kIsWeb) return false;
      return (Platform.isMacOS || Platform.isWindows || Platform.isLinux) && stdout.supportsAnsiEscapes;
    } catch (_) {
      return false;
    }
  }();

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

    final reset = enableColors ? _reset : '';
    final bold = enableColors ? _bold : '';
    final gray = enableColors ? _gray : '';
    final red = enableColors ? _red : '';
    final brightRed = enableColors ? _brightRed : '';
    final yellow = enableColors ? _yellow : '';
    final green = enableColors ? _green : '';
    final blue = enableColors ? _blue : '';
    final cyan = enableColors ? _cyan : '';
    final magenta = enableColors ? _magenta : '';

    final coloredTime = '$gray[$time]$reset';

    final coloredTag = tag != null ? '$yellow[$tag]$reset ' : '';

    late String levelEmoji;
    late String levelColor;

    switch (level) {
      case 'INFO':
        levelEmoji = 'ℹ️ℹ️';
        levelColor = blue;
        break;
      case 'WARN':
        levelEmoji = '⚠️⚠️';
        levelColor = yellow;
        break;
      case 'ERROR':
        levelEmoji = '❌❌';
        levelColor = red;
        break;
      case 'DEBUG':
        levelEmoji = '🐞🐞';
        levelColor = green;
        break;
      case 'API DEBUG':
        levelEmoji = '🌐📡';
        levelColor = cyan;
        break;
      case 'API ERROR':
        levelEmoji = '🚨🛑';
        levelColor = brightRed;
        break;
      case 'MOCK':
        levelEmoji = '🎭🧪';
        levelColor = magenta;
        break;
      default:
        levelEmoji = '';
        levelColor = reset;
    }

    final levelText = '$levelEmoji $bold$levelColor$level$reset';
    final coloredMessage = '$levelColor$message$reset';

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

/// Global shortcut for [CkLogger.info]
void ckInfo(String message, {String? tag}) {
  CkLogger.info(message, tag: tag);
}

/// Global shortcut for [CkLogger.warning]
void ckWarning(String message, {String? tag}) {
  CkLogger.warning(message, tag: tag);
}

/// Global shortcut for [CkLogger.error]
void ckError(String message, {String? tag}) {
  CkLogger.error(message, tag: tag);
}

/// Global shortcut for [CkLogger.debug]
void ckDebug(String message, {String? tag}) {
  CkLogger.debug(message, tag: tag);
}

/// Global shortcut for [CkLogger.apiDebug]
void ckApiDebug(String message, {String? tag}) {
  CkLogger.apiDebug(message, tag: tag);
}

/// Global shortcut for [CkLogger.apiError]
void ckApiError(String message, {String? tag}) {
  CkLogger.apiError(message, tag: tag);
}

/// Global shortcut for [CkLogger.screen]
void ckScreen(String message, {String? tag}) {
  CkLogger.screen(message, tag: tag);
}
