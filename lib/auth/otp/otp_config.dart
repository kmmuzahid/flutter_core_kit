/// OTP configuration — null means no OTP flow
class CkOtpConfig {
  /// Which flows auto-trigger OTP after the initial API call
  final Set<CkOtpTrigger> autoTriggers; // e.g., {signup, forgetPassword}

  /// How the backend verifies OTP identity
  final CkOtpVerificationStrategy verificationStrategy;

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
  Map<String, dynamic> Function(VerifyOtpCallBack otpCallBack)
  verifyBodyBuilder;

  Map<String, dynamic> Function(ResendOtpCallBack resendOtpCallBack)
  resendBodyBuilder;

  CkOtpConfig({
    this.autoTriggers = const {},
    this.verificationStrategy = CkOtpVerificationStrategy.tokenBased,
    this.resendCooldown = const Duration(seconds: 120),
    this.maxResendAttempts = 0,
    this.otpLength = 6,
    this.verificationTokenHeaderKey = 'token',
    this.sendVerificationTokenInHeader = true,
    required this.verifyBodyBuilder,
    required this.resendBodyBuilder,
  });
}

enum CkOtpTrigger { signup, login, forgetPassword }

enum CkOtpVerificationStrategy {
  /// Token returned from signup/login/forgotPassword, sent back during verify
  /// (BetterHelp pattern: createUserToken, forgetToken)
  tokenBased,

  /// Session maintained server-side, just send OTP code
  sessionBased,

  /// Send identifier (email/phone) along with OTP
  identifierBased,
}

class VerifyOtpCallBack {
  final String otp;
  final String token;
  VerifyOtpCallBack({required this.otp, required this.token});
}

class ResendOtpCallBack {
  final String identifier;
  final String token;
  ResendOtpCallBack({required this.identifier, required this.token});
}
