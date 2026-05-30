import 'package:core_kit/storage/core_kit_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/network/dio_service.dart';

/// Internal token manager — NOT exposed to developers.
/// Creates TokenProvider internally for DioService/DioInterceptor.
class AuthTokenManager {
  // In-memory cache for fast synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  
  AuthTokenManager();

  /// Initialize: restore tokens from secure storage to memory cache
  Future<void> initialize() async {
    _cachedAccessToken = await CoreKitStorage.read(AuthStorageKeys.accessTokenKey);
    _cachedRefreshToken = await CoreKitStorage.read(AuthStorageKeys.refreshTokenKey);
  }
  
  /// Save tokens (called internally after login/signup/token refresh)
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken ?? _cachedRefreshToken;
    await CoreKitStorage.write(AuthStorageKeys.accessTokenKey, accessToken);
    if (refreshToken != null) {
      await CoreKitStorage.write(AuthStorageKeys.refreshTokenKey, refreshToken);
    }
  }
  
  /// Check if tokens exist
  bool get hasTokens => _cachedAccessToken?.isNotEmpty == true;

  /// Get the current access token
  String? get currentAccessToken => _cachedAccessToken;

  /// Get the current refresh token
  String? get currentRefreshToken => _cachedRefreshToken;
  
  /// Clear all tokens (called internally during logout)
  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await CoreKitStorage.delete(AuthStorageKeys.accessTokenKey);
    await CoreKitStorage.delete(AuthStorageKeys.refreshTokenKey);
  }
  
  /// Create TokenProvider for DioService — purely internal bridge
  /// Developer never sees or creates this.
  TokenProvider createTokenProvider(AuthExtractors extractors) => TokenProvider(
    accessToken: () async => _cachedAccessToken ?? '',
    refreshToken: () async => _cachedRefreshToken ?? '',
    updateTokens: (data) async {
      final newAccess = extractors.accessToken(data);
      final newRefresh = extractors.refreshToken?.call(data);
      if (newAccess != null) {
        await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      }
    },
  );
}
