import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/auth/state/profile_extractor.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';

/// Manages social login flows on the backend.
/// Designed to be 100% compile-safe with zero plugin-side SDK dependencies.
/// Developer obtains social auth credentials on project-side and passes them here.
class CkSocialAuthManager<TProfile> {
  final CkSocialLoginConfig? _config;
  final CkAuthTokenManager _tokenManager;
  final CkProfileExtractor<TProfile> _profileExtractor;
  final CkAuthStateController _stateController;
  final CkLogoutHandler _logoutHandler;
  final CkAuthExtractors<TProfile> _defaultExtractors;

  CkSocialAuthManager({
    CkSocialLoginConfig? config,
    required CkAuthTokenManager tokenManager,
    required CkProfileExtractor<TProfile> profileExtractor,
    required CkAuthStateController stateController,
    required CkLogoutHandler logoutHandler,
    required CkAuthExtractors<TProfile> defaultExtractors,
  }) : _config = config,
       _tokenManager = tokenManager,
       _profileExtractor = profileExtractor,
       _stateController = stateController,
       _logoutHandler = logoutHandler,
       _defaultExtractors = defaultExtractors;

  /// Check if a specific provider is configured
  bool isProviderAvailable(CkSocialProvider provider) {
    if (_config == null) return false;
    switch (provider) {
      case CkSocialProvider.google:
        return _config.google != null;
      case CkSocialProvider.apple:
        return _config.apple != null;
      case CkSocialProvider.facebook:
        return _config.facebook != null;
      case CkSocialProvider.custom:
        return _config.customProviders?.isNotEmpty == true;
    }
  }

  /// Get list of configured social providers
  List<CkSocialProvider> get availableProviders =>
      _config?.availableProviders ?? [];

  /// Authenticate Google credentials on backend
  Future<CkAuthResult<TProfile>> authenticateGoogle(CkGoogleAuthData data) async {
    if (_config?.google == null) {
      return CkAuthResult<TProfile>.failure(
        message: 'Google auth is not configured',
      );
    }

    final gConfig = _config!.google!;
    final body = gConfig.bodyBuilder(data);
    final extractors =
        (gConfig.responseExtractors ?? _defaultExtractors)
            as CkAuthExtractors<TProfile>;

    return _executeSocialRequest(
      url: gConfig.backendUrl,
      method: gConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate Apple credentials on backend
  Future<CkAuthResult<TProfile>> authenticateApple(CkAppleAuthData data) async {
    if (_config?.apple == null) {
      return CkAuthResult<TProfile>.failure(
        message: 'Apple auth is not configured',
      );
    }

    final aConfig = _config!.apple!;
    final body = aConfig.bodyBuilder(data);
    final extractors =
        (aConfig.responseExtractors ?? _defaultExtractors)
            as CkAuthExtractors<TProfile>;

    return _executeSocialRequest(
      url: aConfig.backendUrl,
      method: aConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate Facebook credentials on backend
  Future<CkAuthResult<TProfile>> authenticateFacebook(
    CkFacebookAuthData data,
  ) async {
    if (_config?.facebook == null) {
      return CkAuthResult<TProfile>.failure(
        message: 'Facebook auth is not configured',
      );
    }

    final fConfig = _config!.facebook!;
    final body = fConfig.bodyBuilder(data);
    final extractors =
        (fConfig.responseExtractors ?? _defaultExtractors)
            as CkAuthExtractors<TProfile>;

    return _executeSocialRequest(
      url: fConfig.backendUrl,
      method: fConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate custom OAuth credentials on backend
  Future<CkAuthResult<TProfile>> authenticateCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) async {
    if (_config?.customProviders == null) {
      return CkAuthResult<TProfile>.failure(
        message: 'No custom social providers configured',
      );
    }

    final cConfig = _config!.customProviders!.firstWhere(
      (p) => p.providerName == providerName,
      orElse: () =>
          throw ArgumentError('Provider $providerName not configured'),
    );

    final body = cConfig.bodyBuilder(authData);
    final extractors =
        (cConfig.responseExtractors ?? _defaultExtractors)
            as CkAuthExtractors<TProfile>;

    return _executeSocialRequest(
      url: cConfig.backendUrl,
      method: cConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Helper to execute the HTTP social request, save tokens, load profile, and redirect
  Future<CkAuthResult<TProfile>> _executeSocialRequest({
    required String url,
    required RequestMethod method,
    required Map<String, dynamic> body,
    required CkAuthExtractors<TProfile> extractors,
  }) async {
    try {
      final response = await CkTransport.request(
        input: RequestInput(
          endpoint: url,
          method: method,
          jsonBody: body,
          requiresToken:
              false, // social sign-in usually doesn't require an access token yet
        ),
        responseBuilder: (data) => data,
      );

      if (response.isSuccess) {
        final access = extractors.accessToken(response.data);
        final refresh = extractors.refreshToken?.call(response.data);

        if (access == null) {
          return CkAuthResult<TProfile>.failure(
            message: 'Access token not found in social login response',
          );
        }

        await _tokenManager.saveTokens(
          accessToken: access,
          refreshToken: refresh,
        );

        await _profileExtractor.applyFromResponse(response);
        final profile = _profileExtractor.current;

        _stateController.setAuthenticated();
        await CkAuthStorageKeys.markNotFirstTimeUser();

        // Auto navigate to authenticated screen
        await _logoutHandler.autoNavigate();

        return CkAuthResult.success(
          data: profile,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return CkAuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return CkAuthResult<TProfile>.failure(message: e.toString());
    }
  }
}
