import 'package:core_kit/auth/social/social_login_config.dart';
import 'package:core_kit/auth/social/google_auth_config.dart';
import 'package:core_kit/auth/social/apple_auth_config.dart';
import 'package:core_kit/auth/social/facebook_auth_config.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/token/auth_token_manager.dart';
import 'package:core_kit/auth/state/profile_manager.dart';
import 'package:core_kit/auth/state/auth_state_controller.dart';
import 'package:core_kit/auth/logout/logout_handler.dart';
import 'package:core_kit/storage/core_kit_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/network/request_input.dart';

/// Manages social login flows on the backend.
/// Designed to be 100% compile-safe with zero plugin-side SDK dependencies.
/// Developer obtains social auth credentials on project-side and passes them here.
class SocialAuthManager<TProfile> {
  final SocialLoginConfig? _config;
  final AuthTokenManager _tokenManager;
  final ProfileManager<TProfile> _profileManager;
  final AuthStateController _stateController;
  final LogoutHandler _logoutHandler;
  final AuthExtractors _defaultExtractors;

  SocialAuthManager({
    SocialLoginConfig? config,
    required AuthTokenManager tokenManager,
    required ProfileManager<TProfile> profileManager,
    required AuthStateController stateController,
    required LogoutHandler logoutHandler,
    required AuthExtractors defaultExtractors,
  }) : _config = config,
       _tokenManager = tokenManager,
       _profileManager = profileManager,
       _stateController = stateController,
       _logoutHandler = logoutHandler,
       _defaultExtractors = defaultExtractors;

  /// Check if a specific provider is configured
  bool isProviderAvailable(SocialProvider provider) {
    if (_config == null) return false;
    switch (provider) {
      case SocialProvider.google:
        return _config.google != null;
      case SocialProvider.apple:
        return _config.apple != null;
      case SocialProvider.facebook:
        return _config.facebook != null;
      case SocialProvider.custom:
        return _config.customProviders?.isNotEmpty == true;
    }
  }

  /// Get list of configured social providers
  List<SocialProvider> get availableProviders =>
      _config?.availableProviders ?? [];

  /// Authenticate Google credentials on backend
  Future<AuthResult<TProfile>> authenticateGoogle(GoogleAuthData data) async {
    if (_config?.google == null) {
      return AuthResult<TProfile>.failure(
        message: 'Google auth is not configured',
      );
    }

    final gConfig = _config!.google!;
    final body = gConfig.bodyBuilder(data);
    final extractors = gConfig.responseExtractors ?? _defaultExtractors;

    return _executeSocialRequest(
      url: gConfig.backendUrl,
      method: gConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate Apple credentials on backend
  Future<AuthResult<TProfile>> authenticateApple(AppleAuthData data) async {
    if (_config?.apple == null) {
      return AuthResult<TProfile>.failure(
        message: 'Apple auth is not configured',
      );
    }

    final aConfig = _config!.apple!;
    final body = aConfig.bodyBuilder(data);
    final extractors = aConfig.responseExtractors ?? _defaultExtractors;

    return _executeSocialRequest(
      url: aConfig.backendUrl,
      method: aConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate Facebook credentials on backend
  Future<AuthResult<TProfile>> authenticateFacebook(
    FacebookAuthData data,
  ) async {
    if (_config?.facebook == null) {
      return AuthResult<TProfile>.failure(
        message: 'Facebook auth is not configured',
      );
    }

    final fConfig = _config!.facebook!;
    final body = fConfig.bodyBuilder(data);
    final extractors = fConfig.responseExtractors ?? _defaultExtractors;

    return _executeSocialRequest(
      url: fConfig.backendUrl,
      method: fConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Authenticate custom OAuth credentials on backend
  Future<AuthResult<TProfile>> authenticateCustom({
    required String providerName,
    required Map<String, dynamic> authData,
  }) async {
    if (_config?.customProviders == null) {
      return AuthResult<TProfile>.failure(
        message: 'No custom social providers configured',
      );
    }

    final cConfig = _config!.customProviders!.firstWhere(
      (p) => p.providerName == providerName,
      orElse: () =>
          throw ArgumentError('Provider $providerName not configured'),
    );

    final body = cConfig.bodyBuilder(authData);
    final extractors = cConfig.responseExtractors ?? _defaultExtractors;

    return _executeSocialRequest(
      url: cConfig.backendUrl,
      method: cConfig.method,
      body: body,
      extractors: extractors,
    );
  }

  /// Helper to execute the HTTP social request, save tokens, load profile, and redirect
  Future<AuthResult<TProfile>> _executeSocialRequest({
    required String url,
    required RequestMethod method,
    required Map<String, dynamic> body,
    required AuthExtractors extractors,
  }) async {
    try {
      final response = await DioService.instance.request(
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
          return AuthResult<TProfile>.failure(
            message: 'Access token not found in social login response',
          );
        }

        await _tokenManager.saveTokens(
          accessToken: access,
          refreshToken: refresh,
        );

        final profileExtracted = extractors.profileData?.call(response.data);
        TProfile? profile;
        if (profileExtracted != null) {
          profile = _profileManager.fromJson(profileExtracted);
          await _profileManager.updateProfile(profile);
        }

        _stateController.setAuthenticated();
        await AuthStorageKeys.markNotFirstTimeUser();

        // Auto navigate to authenticated screen
        await _logoutHandler.autoNavigate();

        return AuthResult.success(
          data: profile,
          statusCode: response.statusCode,
          rawResponse: response.data,
        );
      }

      return AuthResult<TProfile>.failure(
        message: response.message,
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    } catch (e) {
      return AuthResult<TProfile>.failure(message: e.toString());
    }
  }
}
