import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/auth/auth_extractors.dart';

/// Facebook Sign-In configuration
class FacebookAuthConfig {
  final String backendUrl;
  final RequestMethod method;
  final List<String> permissions; // default: ['email', 'public_profile']
  final Map<String, dynamic> Function(FacebookAuthData data) bodyBuilder;
  final AuthExtractors? responseExtractors;
  
  const FacebookAuthConfig({
    required this.backendUrl,
    this.method = RequestMethod.POST,
    this.permissions = const ['email', 'public_profile'],
    required this.bodyBuilder,
    this.responseExtractors,
  });
}

class FacebookAuthData {
  final String? accessToken;
  final String? userId;
  final String? email;
  final String? name;

  const FacebookAuthData({
    this.accessToken,
    this.userId,
    this.email,
    this.name,
  });
}
