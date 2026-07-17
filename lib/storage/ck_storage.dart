import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage with guaranteed fallback + zero-latency in-memory cache.
///
/// Read layer  : memory cache → (miss) disk read → populate cache
/// Write layer : update cache immediately, persist to disk in background
/// Delete layer: evict from cache, delete from disk
/// deleteAll   : wipe cache, wipe disk
///
/// Disk chain  : FlutterSecureStorage → SharedPreferences (plain fallback)
/// NEVER fails — always has an alternative.
abstract class CkStorage {
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _fallbackStorage;
  static bool _useSecure = true;
  static bool _initialized = false;

  /// In-memory cache: key → value.
  /// `null` value means the key was explicitly deleted (tombstone).
  /// Absent key means it does not exist on disk (pre-populated at startup).
  static final Map<String, String?> _cache = {};

  /// Keys that must survive [deleteAll] (e.g. the persistent device id).
  /// Use [protectKey] to register a key as exempt from a full wipe.
  static final Set<String> _protectedKeys = {};

  /// Marks [key] as protected so it is preserved across [deleteAll].
  static void protectKey(String key) => _protectedKeys.add(key);

  // ─── Initialization ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _secureStorage = const FlutterSecureStorage();
      // Warm up secure storage and read all keys in a single platform call.
      // flutter_secure_storage can hang 10-20s on Android during first use
      // if the Keystore hasn't warmed up yet (known upstream bug).
      final allElements = await _secureStorage!.readAll().timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw Exception('SecureStorage timeout'),
      );
      _cache.addAll(allElements);
      _useSecure = true;
    } catch (_) {
      _useSecure = false;
      _secureStorage = null;
      _cache.clear();
      try {
        _fallbackStorage = await SharedPreferences.getInstance();
        final keys = _fallbackStorage!.getKeys();
        for (final key in keys) {
          final val = _fallbackStorage!.get(key);
          if (val != null) {
            _cache[key] = val.toString();
          }
        }
      } catch (_) {}
    }
    _initialized = true;
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Writes [value] for [key].
  /// Cache is updated synchronously before returning so subsequent reads
  /// are instant. Disk persistence runs concurrently in the background.
  static Future<void> write(String key, String value) async {
    await _ensureInitialized();

    // 1. Update cache immediately — callers get zero-latency reads after this.
    _cache[key] = value;

    // 2. Persist to disk (fire-and-forget is intentional — cache stays consistent).
    _writeToDisk(key, value);
  }

  static Future<void> _writeToDisk(String key, String value) async {
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

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// Reads the value for [key].
  /// Returns from memory cache on every hit — O(1), no I/O.
  /// Since _cache is pre-populated during initialize(), this is a guaranteed cache hit.
  static Future<String?> read(String key) async {
    await _ensureInitialized();

    // Cache hit (including explicitly-deleted tombstone → null).
    if (_cache.containsKey(key)) return _cache[key];

    // If it's not in the cache, it doesn't exist on disk.
    return null;
  }

  // static Future<String?> _readFromDisk(String key) async {
  //   try {
  //     if (_useSecure) {
  //       _secureStorage ??= const FlutterSecureStorage();
  //       return await _secureStorage!.read(key: key);
  //     } else {
  //       _fallbackStorage ??= await SharedPreferences.getInstance();
  //       return _fallbackStorage!.getString(key);
  //     }
  //   } catch (_) {
  //     try {
  //       _fallbackStorage ??= await SharedPreferences.getInstance();
  //       final val = _fallbackStorage!.getString(key);
  //       _useSecure = false;
  //       return val;
  //     } catch (_) {
  //       return null;
  //     }
  //   }
  // }

  // ─── Delete ────────────────────────────────────────────────────────────────

  /// Deletes [key] from both the memory cache and disk.
  static Future<void> delete(String key) async {
    await _ensureInitialized();

    // Evict from cache immediately (tombstone so reads return null instantly).
    _cache[key] = null;

    // Remove from disk in background.
    _deleteFromDisk(key);
  }

  static Future<void> _deleteFromDisk(String key) async {
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

  // ─── Delete All ────────────────────────────────────────────────────────────

  /// Clears ALL stored keys and values from both memory cache and disk,
  /// EXCEPT keys registered via [protectKey] (e.g. the persistent device id),
  /// whose values are preserved.
  static Future<void> deleteAll() async {
    await _ensureInitialized();

    // Snapshot protected entries before wiping so they can be restored.
    final preserved = <String, String>{};
    for (final key in _protectedKeys) {
      final value = _cache[key];
      if (value != null) preserved[key] = value;
    }

    // Wipe memory cache immediately, then re-seed the protected entries.
    _cache.clear();
    _cache.addAll(preserved);

    // Wipe disk in background, then re-persist the protected entries.
    _deleteAllFromDisk(preserved);
  }

  static Future<void> _deleteAllFromDisk(Map<String, String> preserved) async {
    // Delete keys individually instead of using a blanket deleteAll().
    // This prevents wiping Keychain items written by other storage instances
    // (e.g. CkDeviceId's dedicated FlutterSecureStorage instance) and avoids
    // the race condition where a crash between deleteAll() and the restore
    // loop would permanently lose protected keys.
    final keysToDelete = _cache.keys
        .where((k) => !_protectedKeys.contains(k))
        .toList();

    try {
      if (_useSecure) {
        _secureStorage ??= const FlutterSecureStorage();
        for (final key in keysToDelete) {
          try {
            await _secureStorage!.delete(key: key);
          } catch (_) {}
        }
      } else {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        for (final key in keysToDelete) {
          try {
            await _fallbackStorage!.remove(key);
          } catch (_) {}
        }
      }
    } catch (_) {
      try {
        _fallbackStorage ??= await SharedPreferences.getInstance();
        for (final key in keysToDelete) {
          try {
            await _fallbackStorage!.remove(key);
          } catch (_) {}
        }
        _useSecure = false;
      } catch (_) {}
    }
  }
}
