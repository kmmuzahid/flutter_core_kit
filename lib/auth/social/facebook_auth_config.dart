import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/network/request_input.dart';

/// Facebook Sign-In configuration
class CkFacebookAuthConfig {
  final String backendUrl;
  final RequestMethod method;
  final List<String> permissions; // default: ['email', 'public_profile']
  final Map<String, dynamic> Function(CkFacebookAuthData data) bodyBuilder;
  final CkAuthExtractors? responseExtractors;

  const CkFacebookAuthConfig({
    required this.backendUrl,
    this.method = RequestMethod.POST,
    this.permissions = const ['email', 'public_profile'],
    required this.bodyBuilder,
    this.responseExtractors,
  });
}

class CkFacebookAuthData {
  final String? accessToken;
  final String? userId;
  final String? email;
  final String? name;

  const CkFacebookAuthData({
    this.accessToken,
    this.userId,
    this.email,
    this.name,
  });
}
