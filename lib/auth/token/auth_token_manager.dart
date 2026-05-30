import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/network/ck_network.dart';

/// Internal token manager — NOT exposed to developers.
/// Creates TokenProvider internally for DioService/DioInterceptor.
class AuthTokenManager {
  // In-memory cache for fast synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  
  AuthTokenManager();

  /// Initialize: restore tokens from secure storage to memory cache
  Future<void> initialize() async {
    _cachedAccessToken = await CkStorage.read(AuthStorageKeys.accessTokenKey);
    _cachedRefreshToken = await CkStorage.read(AuthStorageKeys.refreshTokenKey);
  }
  
  /// Save tokens (called internally after login/signup/token refresh)
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken ?? _cachedRefreshToken;
    await CkStorage.write(AuthStorageKeys.accessTokenKey, accessToken);
    if (refreshToken != null) {
      await CkStorage.write(AuthStorageKeys.refreshTokenKey, refreshToken);
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
    await CkStorage.delete(AuthStorageKeys.accessTokenKey);
    await CkStorage.delete(AuthStorageKeys.refreshTokenKey);
  }
  
  /// Create TokenProvider for DioService — purely internal bridge
  /// Developer never sees or creates this.
  CkTokenProvider createTokenProvider(AuthExtractors extractors) => CkTokenProvider(
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
