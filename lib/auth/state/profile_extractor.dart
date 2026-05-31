import 'dart:convert';

import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/auth/reactive/behavior_stream.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/ck_response.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/storage/ck_storage.dart';

/// Profile cache and [CkBehaviorStream] for [CkAuthService].
///
/// - [profileExtractor] — parse [TProfile] from [CkResponse.data]
/// - [applyFromResponse] — extract, persist `jsonEncode(data)`, skip work if unchanged
/// - [restoreProfile] — `jsonDecode` stored payload, then [profileExtractor]
class CkProfileExtractor<TProfile> {
  CkProfileExtractor({
    required TProfile Function(Map<String, dynamic> json) profileExtractor,
    required CkAuthExtractors<TProfile> extractors,
  }) : _profileExtractor = profileExtractor,
       _extractors = extractors,
       _profile = CkBehaviorStream(initialValue: null);

  final TProfile Function(Map<String, dynamic> json) _profileExtractor;
  final CkAuthExtractors<TProfile> _extractors;
  final CkBehaviorStream<TProfile?> _profile;

  String? _storedPayload;
  TProfile? _cachedProfile;

  CkBehaviorStream<TProfile?> get profile => _profile;

  TProfile? get current => _cachedProfile ?? _profile.value;

  /// Extracts [TProfile] from [CkResponse.data] via [CkAuthExtractors].
  TProfile? profileExtractor(CkResponse<dynamic> response) {
    return _parseProfile(response.data);
  }

  /// Caches profile and persists to storage if changed
  void _cacheProfile(TProfile profile, String fingerprint) {
    if (fingerprint == _storedPayload && _cachedProfile != null) return;
    
    _storedPayload = fingerprint;
    _cachedProfile = profile;
    _profile.add(profile);
    CkStorage.write(CkAuthStorageKeys.profileDataKey, fingerprint);
  }

  /// Extracts profile, persists [CkResponse.data] when changed, returns cached model.
  Future<TProfile?> applyFromResponse(CkResponse<dynamic> response) async {
    final data = response.data;
    final profile = profileExtractor(response);
    if (profile == null) return null;

    final fingerprint = jsonEncode(data);
    _cacheProfile(profile, fingerprint);
    return profile;
  }

  Future<void> restoreProfile() async {
    final cached = await CkStorage.read(CkAuthStorageKeys.profileDataKey);
    if (cached == null) return;
    if (cached == _storedPayload && _cachedProfile != null) return;

    final decoded = jsonDecode(cached);
    _storedPayload = cached;
    _cachedProfile = profileExtractor(
      CkResponse<dynamic>(
        data: decoded,
        isSuccess: true,
        statusCode: null,
      ),
    );
    _profile.add(_cachedProfile);
  }

  Future<CkAuthResult<TProfile?>> fetchProfile(
    String url,
    RequestMethod method,
  ) async {
    final response = await CkTransport.request<TProfile>(
      input: RequestInput(endpoint: url, method: method),
      responseBuilder: (data) => _parseProfile(data),
    );
    if (response.isSuccess && response.data != null) {
      final profile = response.data;
      final fingerprint = jsonEncode(response.raw);
      _cacheProfile(profile, fingerprint);
      
      return CkAuthResult.success(
        data: profile,
        statusCode: response.statusCode,
        rawResponse: response.raw,
      );
    }
    return CkAuthResult.failure(
      message: response.message ?? 'Profile could not be extracted from response',
      statusCode: response.statusCode,
      rawResponse: response.raw,
    );
  }

  Future<CkAuthResult<TProfile?>> updateProfileRemote({
    required String url,
    required RequestMethod method,
    Map<String, dynamic>? formFields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? jsonBody,
  }) async {
    final response = await CkTransport.request<TProfile>(
      input: RequestInput(
        endpoint: url,
        method: method,
        formFields: formFields,
        files: files,
        jsonBody: jsonBody,
      ),
      responseBuilder: (data) => _parseProfile(data),
    );
    if (response.isSuccess && response.data != null) {
      final profile = response.data;
      final fingerprint = jsonEncode(response.raw);
      _cacheProfile(profile, fingerprint);
      
      return CkAuthResult.success(
        data: profile,
        statusCode: response.statusCode,
        rawResponse: response.raw,
      );
    }
    return CkAuthResult.failure(
      message: response.message ?? 'Profile could not be extracted from response',
      statusCode: response.statusCode,
      rawResponse: response.raw,
    );
  }

  Future<void> clearProfile() async {
    _cachedProfile = null;
    _storedPayload = null;
    _profile.add(null);
    await CkStorage.delete(CkAuthStorageKeys.profileDataKey);
  }

  TProfile? _parseProfile(dynamic data) {
    if (data == null) return null;

    // Use custom profile extractor if provided
    final custom = _extractors.profile;
    if (custom != null) return custom(data);

    // Extract profile data using profileData extractor
    final json = _extractors.profileData?.call(data);
    if (json == null) return null;

    // If already the correct type (not a Map), return as-is
    if (json is TProfile && json is! Map) return json;

    // Convert to Map<String, dynamic> for profileExtractor
    final map = json is Map<String, dynamic>
        ? json
        : json is Map
        ? Map<String, dynamic>.from(json)
        : null;
    if (map == null) return null;
    return _profileExtractor(map);
  }
}
