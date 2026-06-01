/// Developer provides callbacks — CoreKit triggers them automatically.
/// Completely avoids forcing any navigation system on the developer.
class CkAuthFlowHandlers {
  /// Custom callback to trigger when user is authenticated (e.g. show home screen or main UI)
  final void Function() onAuthenticated;

  /// Custom callback to show login screen / dialog
  final void Function() showLogin;

  /// Custom callback to show onboarding screen / dialog (optional)
  final void Function()? showOnboarding;

  /// Custom callback to show OTP verification screen / dialog (optional)
  final void Function()? showOtpVerification;

  /// Custom callback to show reset password screen / dialog (optional)
  final void Function()? showResetPassword;

  /// When true (default), showOnboarding is only called for first-time users.
  /// When false, showOnboarding is called for all unauthenticated users.
  final bool firstTimeOnly;

  const CkAuthFlowHandlers({
    required this.onAuthenticated,
    required this.showLogin,
    this.showOtpVerification,
    this.showOnboarding,
    this.showResetPassword,
    this.firstTimeOnly = true,
  });
}
