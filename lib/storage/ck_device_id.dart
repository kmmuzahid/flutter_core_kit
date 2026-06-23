import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// A stable per-device identifier that survives app uninstall/reinstall.
///
///  - Android: `Settings.Secure.ANDROID_ID`. Survives reinstall; only resets on
///    factory reset or a change of app signing key. Unique per device.
///  - iOS / other: a UUID generated once and persisted in secure storage
///    ([CkStorage]). The id is registered as a protected key, so it is NOT
///    removed by [CkStorage.deleteAll] (e.g. on logout / cache wipe).
///
/// Usage: `final id = await CkDeviceId.get();`
abstract class CkDeviceId {
  /// Storage key for the persisted device id. Protected from [CkStorage.deleteAll].
  static const String storageKey = 'ck_persistent_device_id';

  static const AndroidId _androidId = AndroidId();

  /// In-memory cache so repeat calls within a session are instant.
  static String? _cached;

  /// Returns the stable device id, generating and persisting one on first use.
  static Future<String?> get() async {
    if (_cached != null) return _cached;

    // Ensure the device-id key is never wiped by a full storage clear.
    CkStorage.protectKey(storageKey);

    try {
      if (Platform.isAndroid) {
        _cached = await _androidId.getId();
        return _cached;
      }
    } catch (e) {
      debugPrint('CkDeviceId: ANDROID_ID lookup failed: $e');
    }

    // iOS / other platforms (and Android fallback): a persisted UUID.
    var id = await CkStorage.read(storageKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await CkStorage.write(storageKey, id);
    }
    _cached = id;
    return _cached;
  }
}
