import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/storage/ck_storage.dart';

/// Internal token manager — NOT exposed to developers.
/// Creates [CkTokenProvider] internally for [CkTransport]/[DioInterceptor].
class CkAuthTokenManager {
  // In-memory cache for fast synchronous access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  CkAuthTokenManager();

  /// Initialize: restore tokens from secure storage to memory cache
  Future<void> initialize() async {
    _cachedAccessToken = await CkStorage.read(CkAuthStorageKeys.accessTokenKey);
    _cachedRefreshToken = await CkStorage.read(
      CkAuthStorageKeys.refreshTokenKey,
    );
  }

  /// Save tokens (called internally after login/signup/token refresh)
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken ?? _cachedRefreshToken;
    await CkStorage.write(CkAuthStorageKeys.accessTokenKey, accessToken);
    if (refreshToken != null) {
      await CkStorage.write(CkAuthStorageKeys.refreshTokenKey, refreshToken);
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
    await CkStorage.delete(CkAuthStorageKeys.accessTokenKey);
    await CkStorage.delete(CkAuthStorageKeys.refreshTokenKey);
  }

  /// Creates [CkTokenProvider] for [CkTransport] — internal bridge only.
  /// Developer never sees or creates this.
  CkTokenProvider createTokenProvider(CkAuthExtractors extractors) =>
      CkTokenProvider(
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
