// ignore_for_file: prefer_initializing_formals
import 'package:core_kit/auth/ck_auth_endpoints.dart';
import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/ck_auth_flow_handlers.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/social/social_login_config.dart';

/// Request configuration payload returned by [loginRequestBuilder].
///
/// Supports all HTTP transport parameters (JSON body, form fields, files, path/query params).
class CkLoginRequest {
  final Map<String, dynamic>? body;
  final List<String>? pathParams;
  final Map<String, dynamic>? queryParams;
  final Map<String, dynamic>? formFields;
  final List<Map<String, dynamic>>? listBody;
  final Map<String, dynamic>? files;
  final Map<String, String>? headers;

  const CkLoginRequest({
    this.body,
    this.pathParams,
    this.queryParams,
    this.formFields,
    this.listBody,
    this.files,
    this.headers,
  });

  /// Wrap a simple body map into [CkLoginRequest] for backward compatibility.
  factory CkLoginRequest.fromBody(Map<String, dynamic> body) =>
      CkLoginRequest(body: body);

  /// Creates a copy of this [CkLoginRequest] with updated fields.
  CkLoginRequest copyWith({
    Map<String, dynamic>? body,
    List<String>? pathParams,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? formFields,
    List<Map<String, dynamic>>? listBody,
    Map<String, dynamic>? files,
    Map<String, String>? headers,
  }) {
    return CkLoginRequest(
      body: body ?? this.body,
      pathParams: pathParams ?? this.pathParams,
      queryParams: queryParams ?? this.queryParams,
      formFields: formFields ?? this.formFields,
      listBody: listBody ?? this.listBody,
      files: files ?? this.files,
      headers: headers ?? this.headers,
    );
  }
}

/// Main auth configuration for [CkAuthService].
///
/// Set on [CoreKitConfig.authConfig]. When non-null, CoreKit initializes
/// [CkAuthService], wires [CkTransport] token refresh, and restores session on launch.
///
/// Profile parsing is handled entirely through [extractors] — use
/// [CkAuthExtractors.profile] for API responses and cold-start restore.
class CkAuthConfig<TProfile> {
  // ─── Endpoints ───
  final CkAuthEndpoints endpoints;

  // ─── Response Extractors (flexible backend mapping) ───
  /// Non-generic extractors for tokens, profile, verification tokens, and messages.
  /// Profile parsing is handled here via [CkAuthExtractors.profile].
  final CkAuthExtractors extractors;

  /// Canonical login request builder returning [CkLoginRequest].
  final CkLoginRequest Function(LoginCallback loginCallBack)?
  loginRequestBuilder;

  /// Deprecated — use [loginRequestBuilder] instead.
  @Deprecated('Use loginRequestBuilder instead. Will be removed in v2.0.0.')
  final Map<String, dynamic> Function(LoginCallback loginCallBack)?
  loginBodyBuilder;

  /// Optional header builder called during signUp() with the active verification token.
  final Map<String, String>? Function(String? verificationToken)?
  signupHeadersBuilder;

  // ─── Flow Handlers ───
  final CkAuthFlowHandlers? handlers;

  // ─── OTP Configuration (optional — null means no OTP flow) ───
  final CkOtpConfig otpConfig;

  // ─── Social Login (optional — null providers are ignored) ───
  final CkSocialLoginConfig? socialLoginConfig;

  // ─── Lifecycle Hooks (optional) ───
  final Future<void> Function()? onTokenRestored;
  final Future<bool> Function()? customAuthValidator;

  final bool? _mockAuth;

  /// When true, all auth API calls are bypassed and mocked internally.
  /// Use this to design and test UI flows without a real backend.
  bool get mockAuth => _mockAuth ?? false;

  CkAuthConfig({
    required this.endpoints,
    this.loginRequestBuilder,

    @Deprecated('Use loginRequestBuilder instead. Will be removed in v2.0.0.')
    this.loginBodyBuilder,
    this.signupHeadersBuilder,
    CkAuthExtractors? extractors,
    this.handlers,
    required this.otpConfig,
    this.socialLoginConfig,
    this.onTokenRestored,
    this.customAuthValidator,
    bool? mockAuth,
  }) : _mockAuth = mockAuth,
       extractors = extractors ?? CkAuthExtractors.standard(),
       assert(
         loginRequestBuilder != null || loginBodyBuilder != null,
         'Either loginRequestBuilder or loginBodyBuilder must be provided.',
       );

  /// Resolves a [CkLoginRequest] from a [LoginCallback] using [loginRequestBuilder]
  /// or legacy [loginBodyBuilder], merging optional extra [headers] if provided.
  CkLoginRequest resolveLoginRequest(
    LoginCallback callback, {
    Map<String, String>? headers,
  }) {
    CkLoginRequest request;
    if (loginRequestBuilder != null) {
      request = loginRequestBuilder!(callback);
    } else if (loginBodyBuilder != null) {
      request = CkLoginRequest.fromBody(loginBodyBuilder!(callback));
    } else {
      throw StateError(
        'Neither loginRequestBuilder nor loginBodyBuilder is configured.',
      );
    }

    if (headers != null && headers.isNotEmpty) {
      final mergedHeaders = {...?request.headers, ...headers};
      return request.copyWith(headers: mergedHeaders);
    }
    return request;
  }
}

class LoginCallback {
  final String account;
  final String? password;
  final Map<String, dynamic>? args;
  final CkOtpTrigger? trigger;

  LoginCallback({
    String? account,
    @Deprecated('Use account instead. Will be removed in v2.0.0.')
    String? username,
    this.password,
    this.args,
    this.trigger,
  }) : assert(
         account != null || username != null,
         'Provide either account or username.',
       ),
       account = account ?? username!;

  /// Deprecated getter for backward compatibility.
  @Deprecated('Use account instead. Will be removed in v2.0.0.')
  String get username => account;
}
