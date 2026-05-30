import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage with guaranteed fallback.
/// Chain: FlutterSecureStorage → SharedPreferences (plain)
/// NEVER fails — always has an alternative.
abstract class CkStorage {
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _fallbackStorage;
  static bool _useSecure = true;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _secureStorage = const FlutterSecureStorage();
      await _secureStorage!.write(key: '_core_kit_test', value: 'ok');
      await _secureStorage!.delete(key: '_core_kit_test');
      _useSecure = true;
    } catch (_) {
      _useSecure = false;
      try {
        _fallbackStorage = await SharedPreferences.getInstance();
      } catch (_) {}
    }
    _initialized = true;
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  static Future<void> write(String key, String value) async {
    await _ensureInitialized();
    try {
      if (_useSecure) {
        _secureStorage ??= const FlutterSecureStorage();
        await _secureStorage!.write(key: key, value: value);
      } else {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.setString(key, value);
      }
    } catch (_) {
      try {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.setString(key, value);
        _useSecure = false;
      } catch (_) {}
    }
  }

  static Future<String?> read(String key) async {
    await _ensureInitialized();
    try {
      if (_useSecure) {
        _secureStorage ??= const FlutterSecureStorage();
        return await _secureStorage!.read(key: key);
      } else {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        return _fallbackStorage!.getString(key);
      }
    } catch (_) {
      try {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        final val = _fallbackStorage!.getString(key);
        _useSecure = false;
        return val;
      } catch (_) {
        return null;
      }
    }
  }

  static Future<void> delete(String key) async {
    await _ensureInitialized();
    try {
      if (_useSecure) {
        _secureStorage ??= const FlutterSecureStorage();
        await _secureStorage!.delete(key: key);
      } else {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.remove(key);
      }
    } catch (_) {
      try {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.remove(key);
        _useSecure = false;
      } catch (_) {}
    }
  }

  /// Clears ALL stored keys and values.
  static Future<void> deleteAll() async {
    await _ensureInitialized();
    try {
      if (_useSecure) {
        _secureStorage ??= const FlutterSecureStorage();
        await _secureStorage!.deleteAll();
      } else {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.clear();
      }
    } catch (_) {
      try {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        await _fallbackStorage!.clear();
        _useSecure = false;
      } catch (_) {}
    }
  }
}

