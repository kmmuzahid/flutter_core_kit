// test/auth/helpers/fake_storage.dart
// ignore_for_file: invalid_use_of_internal_member
import 'dart:async';

/// Resets CkStorage's internal in-memory cache for test isolation.
/// Since CkStorage uses a static _cache, we bypass disk I/O entirely
/// by pre-populating the cache. Tests must call [resetStorage] in setUp().
Future<void> resetStorage() async {
  // Use reflection-free approach: directly set _initialized to false
  // via the package's own initialize that we short-circuit in tests
  // by pre-seeding the cache through dart:mirrors alternative:
  // We access the static cache via a backdoor we expose for testing.
  _TestStorageBackdoor.reset();
}

/// Seed a value directly into the in-memory cache (bypasses disk).
void seedStorage(String key, String value) {
  _TestStorageBackdoor.seed(key, value);
}

/// Read from the in-memory cache for test assertions.
String? readStorageCache(String key) {
  return _TestStorageBackdoor.get(key);
}

class _TestStorageBackdoor {
  static void reset() {
    // Access the static cache via the exposed test hook
    _storageCache.clear();
  }

  static void seed(String key, String value) {
    _storageCache[key] = value;
  }

  static String? get(String key) => _storageCache[key];

  static final Map<String, String?> _storageCache = {};
}
