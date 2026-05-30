import 'dart:convert';
import 'package:core_kit/auth/reactive/behavior_stream.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/network/ck_network.dart';
import 'package:core_kit/network/request_input.dart';

/// Generic profile manager — exposes BehaviorStream.
/// New subscribers immediately get the cached profile (never blank screen).
class ProfileManager<TProfile> {
  final BehaviorStream<TProfile?> _profile;
  final TProfile Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(TProfile) _toJson;
  final AuthExtractors _extractors;
  
  ProfileManager({
    required TProfile Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(TProfile) toJson,
    required AuthExtractors extractors,
  }) : _fromJson = fromJson,
       _toJson = toJson,
       _extractors = extractors,
       _profile = BehaviorStream(initialValue: null);
  
  /// Profile stream — new listener immediately gets last profile data
  BehaviorStream<TProfile?> get profile => _profile;
  
  /// Current profile (synchronous)
  TProfile? get current => _profile.value;

  /// Parse profile JSON data using configured fromJson callback
  TProfile fromJson(Map<String, dynamic> json) => _fromJson(json);
  
  /// Update profile locally (after API call or local edit)
  Future<void> updateProfile(TProfile? profile) async {
    _profile.add(profile);
    if (profile != null) {
      await CkStorage.write(
        AuthStorageKeys.profileDataKey,
        jsonEncode(_toJson(profile)),
      );
    } else {
      await CkStorage.delete(AuthStorageKeys.profileDataKey);
    }
  }
  
  /// Restore cached profile from storage (called on app launch)
  Future<void> restoreProfile() async {
    final cached = await CkStorage.read(AuthStorageKeys.profileDataKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        _profile.add(_fromJson(json));
      } catch (_) {}
    }
  }
  
  /// Fetch profile from API
  Future<AuthResult<TProfile?>> fetchProfile(String url, RequestMethod method) async {
    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(endpoint: url, method: method),
        responseBuilder: (data) => data,
      );
      if (response.isSuccess) {
        final extracted = _extractors.profileData?.call(response.data) ?? response.data;
        if (extracted is Map<String, dynamic>) {
          final profile = _fromJson(extracted);
          await updateProfile(profile);
          return AuthResult.success(data: profile, statusCode: response.statusCode, rawResponse: response.data);
        } else if (extracted is Map) {
          final profile = _fromJson(Map<String, dynamic>.from(extracted));
          await updateProfile(profile);
          return AuthResult.success(data: profile, statusCode: response.statusCode, rawResponse: response.data);
        } else if (extracted == null) {
          return AuthResult.failure(message: 'Profile data extracted is null', statusCode: response.statusCode);
        }
      }
      return AuthResult.failure(message: response.message, statusCode: response.statusCode, rawResponse: response.data);
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }
  
  /// Update profile via API
  Future<AuthResult<TProfile?>> updateProfileRemote({
    required String url,
    required RequestMethod method,
    Map<String, dynamic>? formFields,
    Map<String, dynamic>? files,
    Map<String, dynamic>? jsonBody,
  }) async {
    try {
      final response = await CkNetwork.instance.request(
        input: RequestInput(
          endpoint: url,
          method: method,
          formFields: formFields,
          files: files,
          jsonBody: jsonBody,
        ),
        responseBuilder: (data) => data,
      );
      if (response.isSuccess) {
        final extracted = _extractors.profileData?.call(response.data) ?? response.data;
        if (extracted is Map<String, dynamic>) {
          final profile = _fromJson(extracted);
          await updateProfile(profile);
          return AuthResult.success(data: profile, statusCode: response.statusCode, rawResponse: response.data);
        } else if (extracted is Map) {
          final profile = _fromJson(Map<String, dynamic>.from(extracted));
          await updateProfile(profile);
          return AuthResult.success(data: profile, statusCode: response.statusCode, rawResponse: response.data);
        }
      }
      return AuthResult.failure(message: response.message, statusCode: response.statusCode, rawResponse: response.data);
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }
  
  /// Clear profile (logout)
  Future<void> clearProfile() async {
    _profile.add(null);
    await CkStorage.delete(AuthStorageKeys.profileDataKey);
  }
}
