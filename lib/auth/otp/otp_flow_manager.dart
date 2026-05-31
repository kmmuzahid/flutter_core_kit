import 'dart:async';
import 'package:core_kit/auth/reactive/behavior_stream.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/auth_extractors.dart';
import 'package:core_kit/auth/auth_result.dart';
import 'package:core_kit/storage/ck_storage.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';

/// Manages complete OTP lifecycle with stream-based timer
class CkOtpFlowManager {
  final CkOtpConfig _config;
  final CkAuthExtractors<dynamic> _extractors;
  final String? _sendUrl;
  final String? _verifyUrl;
  final RequestMethod _sendMethod;
  final RequestMethod _verifyMethod;

  Timer? _timer;
  int _resendAttempts = 0;
  
  // Stores verification tokens per flow in-memory
  final Map<CkOtpTrigger, String?> _verificationTokens = {};
  
  /// Resend countdown — CkBehaviorStream so UI gets current value immediately
  /// Emits remaining seconds. When 0, resend is allowed.
  late final CkBehaviorStream<int> resendCountdown;
  
  CkOtpFlowManager({
    required CkOtpConfig config,
    required CkAuthExtractors<dynamic> extractors,
    String? sendUrl,
    String? verifyUrl,
    RequestMethod sendMethod = RequestMethod.POST,
    RequestMethod verifyMethod = RequestMethod.POST,
  })  : _config = config,
        _extractors = extractors,
        _sendUrl = sendUrl,
        _verifyUrl = verifyUrl,
        _sendMethod = sendMethod,
        _verifyMethod = verifyMethod {
    resendCountdown = CkBehaviorStream(initialValue: 0);
  }

  /// Whether resend is currently allowed
  bool get canResend => resendCountdown.value == 0 && 
    (_config.maxResendAttempts == 0 || _resendAttempts < _config.maxResendAttempts);
  
  /// Store verification token from a response
  Future<void> storeVerificationToken(CkOtpTrigger trigger, String? token) async {
    _verificationTokens[trigger] = token;
    if (token != null) {
      await CkStorage.write('${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}', token);
    } else {
      await CkStorage.delete('${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}');
    }
  }
  
  /// Get stored verification token
  String? getVerificationToken(CkOtpTrigger trigger) => _verificationTokens[trigger];

  /// Restore verification tokens from secure storage
  Future<void> restoreTokens() async {
    for (final trigger in CkOtpTrigger.values) {
      final token = await CkStorage.read('${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}');
      if (token != null) {
        _verificationTokens[trigger] = token;
      }
    }
  }
  
  /// Start/restart the resend countdown timer
  void startResendTimer() {
    _timer?.cancel();
    resendCountdown.add(_config.resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = resendCountdown.value - 1;
      if (remaining <= 0) {
        resendCountdown.add(0);
        timer.cancel();
      } else {
        resendCountdown.add(remaining);
      }
    });
  }
  
  /// Send/Resend OTP via API
  Future<CkAuthResult<void>> sendOtp({
    required CkOtpTrigger trigger,
    String? identifier,
  }) async {
    if (_sendUrl == null) {
      return const CkAuthResult<void>.failure(message: 'OTP send URL is not configured');
    }
    
    if (!canResend) {
      return const CkAuthResult<void>.failure(
        message: 'Resend is locked. Please wait for the cooldown timer.',
      );
    }

    final vToken = getVerificationToken(trigger);
    
    Map<String, dynamic> body = {};
    if (_config.resendBodyBuilder != null) {
      body = _config.resendBodyBuilder!(identifier, vToken);
    } else {
      if (identifier != null) body['identifier'] = identifier;
      if (vToken != null) body['token'] = vToken;
    }

    final response = await CkTransport.request(
      input: RequestInput(
        endpoint: _sendUrl!,
        method: _sendMethod,
        jsonBody: body,
        requiresToken: false,
      ),
      responseBuilder: (data) => data,
      showMessage: true,
    );

    if (response.isSuccess) {
      _resendAttempts++;
      startResendTimer();
      final newToken = _extractors.verificationTokens?[trigger]?.call(response.data);
      if (newToken != null) {
        await storeVerificationToken(trigger, newToken);
      }
      return CkAuthResult<void>.success(
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    }

    return CkAuthResult<void>.failure(
      message: response.message,
      statusCode: response.statusCode,
      rawResponse: response.data,
    );
  }

  /// Verify OTP via API
  Future<CkAuthResult<void>> verifyOtp({
    required String otp,
    required CkOtpTrigger trigger,
    Map<String, dynamic>? additionalBody,
  }) async {
    if (_verifyUrl == null) {
      return const CkAuthResult<void>.failure(message: 'OTP verify URL is not configured');
    }

    final vToken = getVerificationToken(trigger);
    
    Map<String, dynamic> body = {};
    if (_config.verifyBodyBuilder != null) {
      body = _config.verifyBodyBuilder!(otp, vToken);
    } else {
      body['otp'] = otp;
      if (_config.verificationStrategy == CkOtpVerificationStrategy.tokenBased &&
          !_config.sendVerificationTokenInHeader &&
          vToken != null) {
        body[_config.verificationTokenHeaderKey] = vToken;
      }
    }

    if (additionalBody != null) {
      body.addAll(additionalBody);
    }

    Map<String, String> headers = {};
    if (_config.verificationStrategy == CkOtpVerificationStrategy.tokenBased &&
        _config.sendVerificationTokenInHeader &&
        vToken != null) {
      headers[_config.verificationTokenHeaderKey] = vToken;
    }

    final response = await CkTransport.request(
      input: RequestInput(
        endpoint: _verifyUrl!,
        method: _verifyMethod,
        jsonBody: body,
        headers: headers,
        requiresToken: false,
      ),
      responseBuilder: (data) => data,
      showMessage: true,
    );

    if (response.isSuccess) {
      await storeVerificationToken(trigger, null);
      return CkAuthResult<void>.success(
        statusCode: response.statusCode,
        rawResponse: response.data,
      );
    }

    return CkAuthResult<void>.failure(
      message: response.message,
      statusCode: response.statusCode,
      rawResponse: response.data,
    );
  }
  
  /// Clear all OTP state
  Future<void> clearOtpState() async {
    _timer?.cancel();
    _verificationTokens.clear();
    _resendAttempts = 0;
    resendCountdown.add(0);
    for (final trigger in CkOtpTrigger.values) {
      await CkStorage.delete('${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}');
    }
  }
  
  void dispose() {
    _timer?.cancel();
    resendCountdown.dispose();
  }
}
