/// Developer provides callbacks — CoreKit triggers them automatically.
/// Completely avoids forcing any navigation system on the developer.
class AuthRoutes {
  /// Custom callback to navigate when user is authenticated (direct routing)
  final void Function() routeOnSuccess;
  
  /// Custom callback to navigate to login screen (direct routing)
  final void Function() routeToLogin;
  
  /// Custom callback to navigate to onboarding screen (direct routing, optional)
  final void Function()? routeToOnboarding;

  const AuthRoutes({
    required this.routeOnSuccess,
    required this.routeToLogin,
    this.routeToOnboarding,
  });
}
