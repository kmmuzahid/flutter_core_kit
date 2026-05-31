/// Configuration for optional logout API integration.
class CkLogoutConfig {
  /// Custom body for logout request
  final Map<String, dynamic> Function()? logoutBodyBuilder;
  
  /// Custom headers for logout request
  final Map<String, String> Function()? logoutHeadersBuilder;
  
  /// Custom callback for app-specific cleanup (e.g., clear custom storage)
  /// Called after logout API (if configured) and before CoreKit clears tokens/profile
  final Future<void> Function()? onLogout;
  
  const CkLogoutConfig({
    this.logoutBodyBuilder,
    this.logoutHeadersBuilder,
    this.onLogout,
  });
}
