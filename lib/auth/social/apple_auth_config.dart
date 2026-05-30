import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/auth/auth_extractors.dart';

/// Apple Sign-In configuration
class AppleAuthConfig {
  final String backendUrl;
  final RequestMethod method;
  final List<String> scopes; // default: [email, fullName]
  final Map<String, dynamic> Function(AppleAuthData data) bodyBuilder;
  final AuthExtractors? responseExtractors;
  
  const AppleAuthConfig({
    required this.backendUrl,
    this.method = RequestMethod.POST,
    this.scopes = const ['email', 'fullName'],
    required this.bodyBuilder,
    this.responseExtractors,
  });
}

class AppleAuthData {
  final String? identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;

  const AppleAuthData({
    this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
  });
}
