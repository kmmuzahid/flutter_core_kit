/// Configuration for optional logout API integration.
class CkLogoutConfig {
  /// Custom body for logout request
  final Map<String, dynamic> Function()? logoutBodyBuilder;
  
  /// Custom headers for logout request
  final Map<String, String> Function()? logoutHeadersBuilder;
  
  const CkLogoutConfig({
    this.logoutBodyBuilder,
    this.logoutHeadersBuilder,
  });
}
