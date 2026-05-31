/// Developer provides callbacks — CoreKit triggers them automatically.
/// Completely avoids forcing any navigation system on the developer.
class CkAuthRoutes {
  /// Custom callback to navigate when user is authenticated (direct routing)
  final void Function() routeOnSuccess;
  
  /// Custom callback to navigate to login screen (direct routing)
  final void Function() routeToLogin;
  
  /// Custom callback to navigate to onboarding screen (direct routing, optional)
  final void Function()? routeToOnboarding;

  /// Custom callback to navigate to the splash screen (direct routing)
  final void Function() routeToSplash;

  /// When true (default), routeToOnboarding is only called for first-time users.
  /// When false, routeToOnboarding is called for all unauthenticated users.
  final bool firstTimeOnly;

  const CkAuthRoutes({
    required this.routeOnSuccess,
    required this.routeToLogin,
    required this.routeToSplash,
    this.routeToOnboarding,
    this.firstTimeOnly = true,
  });
}
