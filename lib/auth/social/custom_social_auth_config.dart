import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/network/request_input.dart';

/// For any OAuth/social provider not covered by built-in ones
class CkCustomSocialAuthConfig {
  final String providerName; // e.g., 'github', 'twitter'
  final String backendUrl;
  final RequestMethod method;

  /// Developer handles the entire social SDK flow and returns token/data
  final Future<Map<String, dynamic>> Function() authenticate;

  /// Build body to send to backend
  final Map<String, dynamic> Function(Map<String, dynamic> authData)
  bodyBuilder;

  final CkAuthExtractors? responseExtractors;

  const CkCustomSocialAuthConfig({
    required this.providerName,
    required this.backendUrl,
    required this.authenticate,
    required this.bodyBuilder,
    this.method = RequestMethod.POST,
    this.responseExtractors,
  });
}
