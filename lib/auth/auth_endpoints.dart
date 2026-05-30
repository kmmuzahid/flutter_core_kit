import 'package:core_kit/network/request_input.dart';

class CkAuthEndpoints {
  final String signupUrl;
  final String signinUrl;
  final String? forgetPasswordUrl;
  final String? otpSendUrl;
  final String? otpVerifyUrl;
  final String? profileGetUrl;
  final String? profileUpdateUrl;
  final String? logoutUrl;            // optional — null = local-only logout
  final String? changePasswordUrl;
  
  // ─── Method Overrides ───
  // Defaults: POST for mutations, GET for reads, PATCH for updates
  final RequestMethod signupMethod;          // default: POST
  final RequestMethod signinMethod;          // default: POST
  final RequestMethod forgetPasswordMethod;  // default: POST
  final RequestMethod otpSendMethod;         // default: POST
  final RequestMethod otpVerifyMethod;       // default: POST
  final RequestMethod profileGetMethod;      // default: GET
  final RequestMethod profileUpdateMethod;   // default: PATCH
  final RequestMethod logoutMethod;          // default: POST
  final RequestMethod changePasswordMethod;  // default: PATCH

  const CkAuthEndpoints({
    required this.signupUrl,
    required this.signinUrl,
    this.forgetPasswordUrl,
    this.otpSendUrl,
    this.otpVerifyUrl,
    this.profileGetUrl,
    this.profileUpdateUrl,
    this.logoutUrl,
    this.changePasswordUrl,
    this.signupMethod = RequestMethod.POST,
    this.signinMethod = RequestMethod.POST,
    this.forgetPasswordMethod = RequestMethod.POST,
    this.otpSendMethod = RequestMethod.POST,
    this.otpVerifyMethod = RequestMethod.POST,
    this.profileGetMethod = RequestMethod.GET,
    this.profileUpdateMethod = RequestMethod.PATCH,
    this.logoutMethod = RequestMethod.POST,
    this.changePasswordMethod = RequestMethod.PATCH,
  });
}
