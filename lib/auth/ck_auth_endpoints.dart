import 'package:core_kit/network/request_input.dart';

class CkAuthEndpoints {
  final String signup;
  final String signin;
  final String forgotPassword;
  final String sendOtp;
  final String verifyOtp;
  final String? verifyForgetOtp;
  final String getProfile;
  final String updateProfile;
  final String logout;
  final String resetPassword;

  // ─── Method Overrides ───
  // Defaults: POST for mutations, GET for reads, PATCH for updates
  final RequestMethod signupMethod; // default: POST
  final RequestMethod signinMethod; // default: POST
  final RequestMethod forgotPasswordMethod; // default: POST
  final RequestMethod sendOtpMethod; // default: POST
  final RequestMethod verifyOtpMethod; // default: POST
  final RequestMethod getProfileMethod; // default: GET
  final RequestMethod updateProfileMethod; // default: PATCH
  final RequestMethod logoutMethod; // default: POST
  final RequestMethod resetPasswordMethod; // default: PATCH

  const CkAuthEndpoints({
    required this.signup,
    required this.signin,
    required this.forgotPassword,
    required this.sendOtp,
    required this.verifyOtp,
    this.verifyForgetOtp,
    required this.getProfile,
    required this.updateProfile,
    required this.logout,
    required this.resetPassword,
    this.signupMethod = RequestMethod.POST,
    this.signinMethod = RequestMethod.POST,
    this.forgotPasswordMethod = RequestMethod.POST,
    this.sendOtpMethod = RequestMethod.POST,
    this.verifyOtpMethod = RequestMethod.POST,
    this.getProfileMethod = RequestMethod.GET,
    this.updateProfileMethod = RequestMethod.PATCH,
    this.logoutMethod = RequestMethod.POST,
    this.resetPasswordMethod = RequestMethod.POST,
  });
}
