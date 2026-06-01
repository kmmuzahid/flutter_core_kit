import 'package:core_kit/auth/otp/otp_config.dart';

/// Result wrapper for [CkAuthService] operations (sign-in, OTP, profile, social).
class CkAuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;
  final bool requiresOtp;        // true if OTP step is needed next
  final CkOtpTrigger? otpTrigger;  // which flow triggered OTP
  final dynamic rawResponse;     // escape hatch for unusual needs
  
  const CkAuthResult({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
    this.requiresOtp = false,
    this.otpTrigger,
    this.rawResponse,
  });

  const CkAuthResult.success({
    this.data,
    this.message,
    this.statusCode,
    this.rawResponse,
  })  : isSuccess = true,
        requiresOtp = false,
        otpTrigger = null;

  const CkAuthResult.failure({
    this.message,
    this.statusCode,
    this.rawResponse,
  })  : isSuccess = false,
        data = null,
        requiresOtp = false,
        otpTrigger = null;
}
