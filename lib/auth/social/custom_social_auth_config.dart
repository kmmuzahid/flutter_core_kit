import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/auth/auth_extractors.dart';

/// For any OAuth/social provider not covered by built-in ones
class CustomSocialAuthConfig {
  final String providerName;       // e.g., 'github', 'twitter'
  final String backendUrl;
  final RequestMethod method;
  
  /// Developer handles the entire social SDK flow and returns token/data
  final Future<Map<String, dynamic>> Function() authenticate;
  
  /// Build body to send to backend
  final Map<String, dynamic> Function(Map<String, dynamic> authData) bodyBuilder;
  
  final AuthExtractors? responseExtractors;

  const CustomSocialAuthConfig({
    required this.providerName,
    required this.backendUrl,
    required this.authenticate,
    required this.bodyBuilder,
    this.method = RequestMethod.POST,
    this.responseExtractors,
  });
}
