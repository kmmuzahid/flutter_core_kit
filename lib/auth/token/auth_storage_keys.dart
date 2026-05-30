import 'package:core_kit/storage/ck_storage.dart';

abstract class AuthStorageKeys {
  static const accessTokenKey = 'core_kit_access_token';
  static const refreshTokenKey = 'core_kit_refresh_token';
  static const profileDataKey = 'core_kit_profile_data';
  static const verificationTokenPrefix = 'core_kit_vtoken_';
  static const firstTimeUserKey = 'core_kit_first_time_user';

  /// Check if this is a first-time user (for onboarding routing)
  static Future<bool> isFirstTimeUser() async {
    final value = await CkStorage.read(firstTimeUserKey);
    return value == null; // null means never logged in before
  }
  
  /// Mark user as not first-time (called after first successful login)
  static Future<void> markNotFirstTimeUser() async {
    await CkStorage.write(firstTimeUserKey, 'false');
  }
}
