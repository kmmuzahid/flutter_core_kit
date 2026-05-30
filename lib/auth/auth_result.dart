import 'package:core_kit/auth/otp/otp_config.dart';

/// Result wrapper for all auth operations
class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;
  final bool requiresOtp;        // true if OTP step is needed next
  final OtpTrigger? otpTrigger;  // which flow triggered OTP
  final dynamic rawResponse;     // escape hatch for unusual needs
  
  const AuthResult({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
    this.requiresOtp = false,
    this.otpTrigger,
    this.rawResponse,
  });

  const AuthResult.success({
    this.data,
    this.message,
    this.statusCode,
    this.rawResponse,
  })  : isSuccess = true,
        requiresOtp = false,
        otpTrigger = null;

  const AuthResult.failure({
    this.message,
    this.statusCode,
    this.rawResponse,
  })  : isSuccess = false,
        data = null,
        requiresOtp = false,
        otpTrigger = null;
}
