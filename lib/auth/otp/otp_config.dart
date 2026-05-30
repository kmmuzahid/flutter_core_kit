/// OTP configuration — null means no OTP flow
class OtpConfig {
  /// Which flows auto-trigger OTP after the initial API call
  final Set<OtpTrigger> autoTriggers; // e.g., {signup, forgetPassword}
  
  /// How the backend verifies OTP identity
  final OtpVerificationStrategy verificationStrategy;
  
  /// Resend cooldown duration (default: 120 seconds)
  final Duration resendCooldown;
  
  /// Max resend attempts per session (0 = unlimited)
  final int maxResendAttempts;
  
  /// OTP digit length for UI hints (default: 6)
  final int otpLength;
  
  /// Header key for verification token (default: 'token')
  final String verificationTokenHeaderKey;
  
  /// Whether to send verification token in header (true) or body (false)
  final bool sendVerificationTokenInHeader; // default: true
  
  /// Custom body builder for OTP verify request
  final Map<String, dynamic> Function(String otp, String? verificationToken)?
      verifyBodyBuilder;
  
  /// Custom body builder for OTP resend request
  final Map<String, dynamic> Function(String? identifier, String? verificationToken)?
      resendBodyBuilder;
  
  const OtpConfig({
    this.autoTriggers = const {},
    this.verificationStrategy = OtpVerificationStrategy.tokenBased,
    this.resendCooldown = const Duration(seconds: 120),
    this.maxResendAttempts = 0,
    this.otpLength = 6,
    this.verificationTokenHeaderKey = 'token',
    this.sendVerificationTokenInHeader = true,
    this.verifyBodyBuilder,
    this.resendBodyBuilder,
  });
}

enum OtpTrigger { signup, login, forgetPassword }

enum OtpVerificationStrategy {
  /// Token returned from signup/login/forgotPassword, sent back during verify
  /// (BetterHelp pattern: createUserToken, forgetToken)
  tokenBased,
  
  /// Session maintained server-side, just send OTP code
  sessionBased,
  
  /// Send identifier (email/phone) along with OTP
  identifierBased,
}
