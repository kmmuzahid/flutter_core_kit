// test/auth/helpers/test_auth_config.dart
import 'package:core_kit/auth/ck_auth_config.dart';
import 'package:core_kit/auth/ck_auth_endpoints.dart';
import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/ck_auth_flow_handlers.dart';
import 'package:core_kit/auth/otp/otp_config.dart';

/// Minimal endpoints for tests — all strings, no real server.
const kTestEndpoints = CkAuthEndpoints(
  signup: '/api/signup',
  signin: '/api/signin',
  forgotPassword: '/api/forgot',
  sendOtp: '/api/otp/send',
  verifyOtp: '/api/otp/verify',
  verifyForgetOtp: '/api/otp/verify-forget',
  getProfile: '/api/profile',
  updateProfile: '/api/profile',
  logout: '/api/logout',
  changePassword: '/api/reset-password',
);

/// Standard extractors using default keys
CkAuthExtractors get kTestExtractors => CkAuthExtractors.standard();

/// OTP config with signup + forgetPassword as auto-triggers
CkOtpConfig buildOtpConfig({
  Set<CkOtpTrigger> autoTriggers = const {
    CkOtpTrigger.signup,
    CkOtpTrigger.forgetPassword,
  },
  int? otpNotVerifiedStatusCode = 403,
  Duration resendCooldown = const Duration(seconds: 5),
  int maxResendAttempts = 0,
}) {
  return CkOtpConfig(
    autoTriggers: autoTriggers,
    otpNotVerifiedStatusCode: otpNotVerifiedStatusCode,
    resendCooldown: resendCooldown,
    maxResendAttempts: maxResendAttempts,
    verifyBodyBuilder: (cb) => {'otp': cb.otp, 'token': cb.token},
    resendBodyBuilder: (cb) => {'email': cb.recipient, 'token': cb.token},
  );
}

/// Capture which handlers were called
class TestFlowHandlers {
  bool onAuthenticatedCalled = false;
  bool showLoginCalled = false;
  bool showOtpVerificationCalled = false;
  bool showResetPasswordCalled = false;
  bool showOnboardingCalled = false;

  void reset() {
    onAuthenticatedCalled = false;
    showLoginCalled = false;
    showOtpVerificationCalled = false;
    showResetPasswordCalled = false;
    showOnboardingCalled = false;
  }

  CkAuthFlowHandlers build() {
    return CkAuthFlowHandlers(
      onAuthenticated: () => onAuthenticatedCalled = true,
      showLogin: () => showLoginCalled = true,
      showOtpVerification: () => showOtpVerificationCalled = true,
      showResetPassword: () => showResetPasswordCalled = true,
      showOnboarding: () => showOnboardingCalled = true,
    );
  }
}

/// Build a full CkAuthConfig for tests with mock mode enabled
CkAuthConfig<dynamic> buildMockConfig({
  TestFlowHandlers? handlers,
  Set<CkOtpTrigger> autoTriggers = const {
    CkOtpTrigger.signup,
    CkOtpTrigger.forgetPassword,
  },
  bool mockAuth = true,
}) {
  return CkAuthConfig(
    endpoints: kTestEndpoints,
    extractors: kTestExtractors,
    otpConfig: buildOtpConfig(autoTriggers: autoTriggers),
    handlers: handlers?.build(),
    loginRequestBuilder: (cb) =>
        CkLoginRequest(body: {'email': cb.account, 'password': cb.password}),
    mockAuth: mockAuth,
  );
}
