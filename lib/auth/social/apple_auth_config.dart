import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/network/request_input.dart';

/// Apple Sign-In configuration
class CkAppleAuthConfig {
  final String backendUrl;
  final RequestMethod method;
  final List<String> scopes; // default: [email, fullName]
  final Map<String, dynamic> Function(CkAppleAuthData data) bodyBuilder;
  final CkAuthExtractors? responseExtractors;

  const CkAppleAuthConfig({
    required this.backendUrl,
    this.method = RequestMethod.POST,
    this.scopes = const ['email', 'fullName'],
    required this.bodyBuilder,
    this.responseExtractors,
  });
}

class CkAppleAuthData {
  final String? identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;

  const CkAppleAuthData({
    this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
  });
}
