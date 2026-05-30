class LogoutConfig {
  /// Logout strategy
  final LogoutStrategy strategy;
  
  /// Force local clear even if API call fails (default: true)
  final bool forceLocalClearOnApiFailure;
  
  /// Custom body for logout request
  final Map<String, dynamic> Function()? logoutBodyBuilder;
  
  /// Custom headers for logout request
  final Map<String, String> Function()? logoutHeadersBuilder;
  
  const LogoutConfig({
    this.strategy = LogoutStrategy.localOnly,
    this.forceLocalClearOnApiFailure = true,
    this.logoutBodyBuilder,
    this.logoutHeadersBuilder,
  });
}

enum LogoutStrategy {
  /// Just clear local state, no API call
  localOnly,
  
  /// Call logout API then clear local state
  apiThenLocal,
  
  /// Call API, clear local regardless of API result
  apiWithForcedLocalClear,
}
