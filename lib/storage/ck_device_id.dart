import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable per-device identifier that survives app uninstall/reinstall.
///
///  - **Android**: `Settings.Secure.ANDROID_ID`. Survives reinstall; only
///    resets on factory reset or a change of app signing key.
///  - **iOS**: A UUID generated once and persisted directly in the **Keychain**
///    via a dedicated [FlutterSecureStorage] instance with
///    [KeychainAccessibility.first_unlock]. The iOS Keychain survives app
///    uninstall/reinstall (the item persists on disk and becomes accessible
///    again when the same bundle-ID / team is reinstalled).
///
///    A backup copy is also kept in [SharedPreferences] (which does NOT survive
///    uninstall) so that if the Keychain read ever fails transiently, the id
///    can still be recovered within the same install session.
///
/// ### Why not go through [CkStorage]?
/// `CkStorage` has a 3-second timeout on its `readAll()` warm-up. If the
/// Keychain is slow (cold boot, first launch after OS update, etc.), the
/// timeout fires and `CkStorage` silently falls back to [SharedPreferences].
/// When the device id is written there instead of the Keychain, it is **lost
/// on uninstall**. By using a dedicated [FlutterSecureStorage] instance for
/// just this one key, we avoid that timeout entirely and guarantee the id is
/// always written to the Keychain.
///
/// Usage: `final id = await CkDeviceId.get();`
abstract class CkDeviceId {
  // ── Storage keys ──────────────────────────────────────────────────────────

  /// Primary key – stored in the iOS Keychain (via dedicated secure storage).
  static const String _keychainKey = 'ck_persistent_device_id';

  /// Backup key – stored in SharedPreferences (plain, non-secure).
  static const String _prefsBackupKey = 'ck_persistent_device_id_backup';

  /// Legacy key used by the old CkStorage-based implementation.
  /// Checked once for migration so existing users keep their id.
  static const String _legacyCkStorageKey = 'ck_persistent_device_id';

  // ── Internals ─────────────────────────────────────────────────────────────

  static const AndroidId _androidId = AndroidId();

  /// Dedicated [FlutterSecureStorage] instance for the device id **only**.
  ///
  ///  - [KeychainAccessibility.first_unlock]: accessible after the device has
  ///    been unlocked at least once since boot – works in background too.
  ///  - [synchronizable: false]: do NOT sync to iCloud Keychain; each physical
  ///    device must have its own unique id.
  static const FlutterSecureStorage _keychain = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

  /// In-memory cache so repeat calls within a session are instant.
  static String? _cached;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the stable device id, generating and persisting one on first use.
  static Future<String?> get() async {
    if (_cached != null) return _cached;

    // ── Android: hardware id ───────────────────────────────────────────────
    try {
      if (Platform.isAndroid) {
        _cached = await _androidId.getId();
        return _cached;
      }
    } catch (e) {
      debugPrint('CkDeviceId: ANDROID_ID lookup failed: $e');
    }

    // ── iOS / other: Keychain → SharedPreferences → legacy → generate ─────
    _cached = await _readOrCreate();

    // Also register with CkStorage.protectKey so that if anyone calls
    // CkStorage.deleteAll(), the key is preserved in CkStorage's own cache.
    CkStorage.protectKey(_legacyCkStorageKey);

    return _cached;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Reads the device id from all available sources (in priority order) or
  /// generates a new one. Writes back to ALL sources so they stay in sync.
  static Future<String> _readOrCreate() async {
    String? id;

    // 1️⃣  Keychain (survives uninstall on iOS).
    try {
      id = await _keychain.read(key: _keychainKey);
    } catch (e) {
      debugPrint('CkDeviceId: Keychain read failed: $e');
    }

    // 2️⃣  SharedPreferences backup (does NOT survive uninstall, but handles
    //     transient Keychain failures within the same install session).
    if (id == null || id.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        id = prefs.getString(_prefsBackupKey);
        if (id != null && id.isNotEmpty) {
          debugPrint('CkDeviceId: recovered from SharedPreferences backup');
        }
      } catch (e) {
        debugPrint('CkDeviceId: SharedPreferences read failed: $e');
      }
    }

    // 3️⃣  Legacy CkStorage key (migration from old implementation).
    if (id == null || id.isEmpty) {
      try {
        final legacyId = await CkStorage.read(_legacyCkStorageKey);
        if (legacyId != null && legacyId.isNotEmpty) {
          id = legacyId;
          debugPrint('CkDeviceId: migrated from legacy CkStorage');
        }
      } catch (e) {
        debugPrint('CkDeviceId: legacy CkStorage read failed: $e');
      }
    }

    // 4️⃣  Nothing found anywhere → generate a fresh UUID.
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      debugPrint('CkDeviceId: generated new device id');
    }

    // 5️⃣  Write back to ALL sources so they stay in sync.
    await _persistEverywhere(id);

    return id;
  }

  /// Best-effort write to Keychain + SharedPreferences + legacy CkStorage.
  static Future<void> _persistEverywhere(String id) async {
    // Keychain (primary – survives uninstall).
    try {
      await _keychain.write(key: _keychainKey, value: id);
    } catch (e) {
      debugPrint('CkDeviceId: Keychain write failed: $e');
    }

    // SharedPreferences backup.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsBackupKey, id);
    } catch (e) {
      debugPrint('CkDeviceId: SharedPreferences write failed: $e');
    }

    // Legacy CkStorage – keeps the protected-key mechanism working so that
    // CkStorage.deleteAll() won't accidentally wipe a future Keychain read.
    try {
      await CkStorage.write(_legacyCkStorageKey, id);
    } catch (e) {
      debugPrint('CkDeviceId: CkStorage write failed: $e');
    }
  }
}
