import 'dart:async';

import 'package:core_kit/auth/ck_auth_extractors.dart';
import 'package:core_kit/auth/ck_auth_result.dart';
import 'package:core_kit/auth/ck_auth.dart';
import 'package:core_kit/auth/otp/otp_config.dart';
import 'package:core_kit/auth/reactive/behavior_stream.dart';
import 'package:core_kit/auth/token/auth_storage_keys.dart';
import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:core_kit/storage/ck_storage.dart';

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
  CkOtpTrigger? lastTrigger;

  // Stores verification tokens per flow in-memory
  final Map<CkOtpTrigger, String?> _verificationTokens = {};

  /// Resend countdown — CkBehaviorStream so UI gets current value immediately
  /// Emits remaining seconds. When 0, resend is allowed.
  late final CkBehaviorStream<int> resendCountdown;

  CkOtpFlowManager({
    required this._config,
    required this._extractors,
    this._sendUrl,
    this._verifyUrl,
    this._sendMethod = RequestMethod.POST,
    this._verifyMethod = RequestMethod.POST,
  }) {
    resendCountdown = CkBehaviorStream(initialValue: 0);
  }

  /// Whether resend is currently allowed
  bool get canResend =>
      resendCountdown.value == 0 &&
      (_config.maxResendAttempts == 0 ||
          _resendAttempts < _config.maxResendAttempts);

  /// Store verification token from a response
  Future<void> storeVerificationToken(
    CkOtpTrigger trigger,
    String? token,
  ) async {
    _verificationTokens[trigger] = token;
    if (token != null) {
      lastTrigger = trigger;
      await CkStorage.write(
        '${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}',
        token,
      );
      await CkStorage.write('core_kit_last_otp_trigger', trigger.name);
    } else {
      await CkStorage.delete(
        '${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}',
      );
    }
  }

  /// Get stored verification token
  String? getVerificationToken(CkOtpTrigger trigger) =>
      _verificationTokens[trigger];

  /// Restore verification tokens from secure storage
  Future<void> restoreTokens() async {
    for (final trigger in CkOtpTrigger.values) {
      final token = await CkStorage.read(
        '${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}',
      );
      if (token != null) {
        _verificationTokens[trigger] = token;
      }
    }
    final lastTriggerName = await CkStorage.read('core_kit_last_otp_trigger');
    if (lastTriggerName != null) {
      lastTrigger = CkOtpTrigger.values.firstWhere(
        (t) => t.name == lastTriggerName,
        orElse: () => CkOtpTrigger.signup,
      );
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
  Future<CkAuthResult<void>> sendOtp({CkOtpTrigger? trigger}) async {
    final activeTrigger = trigger ?? lastTrigger;
    if (activeTrigger == null) {
      return const CkAuthResult<void>.failure(
        message: 'No active OTP trigger found',
      );
    }

    if (trigger != null) {
      lastTrigger = trigger;
      await CkStorage.write('core_kit_last_otp_trigger', trigger.name);
    }

    if (_sendUrl == null) {
      return const CkAuthResult<void>.failure(
        message: 'OTP send URL is not configured',
      );
    }

    if (!canResend) {
      return const CkAuthResult<void>.failure(
        message: 'Resend is locked. Please wait for the cooldown timer.',
      );
    }

    final vToken = getVerificationToken(activeTrigger);

    var body = <String, dynamic>{};
    body = _config.resendBodyBuilder(
      ResendOtpCallBack(identifier: CkAuth.username ?? '', token: vToken ?? ''),
    );

    final response = await CkTransport.request(
      input: RequestInput(
        endpoint: _sendUrl,
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
      final newToken = _extractors.verificationTokens?[activeTrigger]?.call(
        response.data,
      );
      if (newToken != null) {
        await storeVerificationToken(activeTrigger, newToken);
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
    Map<String, dynamic>? additionalBody,
  }) async {
    final activeTrigger = lastTrigger;
    if (activeTrigger == null) {
      return const CkAuthResult<void>.failure(
        message: 'No active OTP verification trigger found',
      );
    }

    if (_verifyUrl == null) {
      return const CkAuthResult<void>.failure(
        message: 'OTP verify URL is not configured',
      );
    }

    final vToken = getVerificationToken(activeTrigger);

    var body = <String, dynamic>{};
    body = _config.verifyBodyBuilder(
      VerifyOtpCallBack(otp: otp, token: vToken ?? ''),
    );

    if (additionalBody != null) {
      body.addAll(additionalBody);
    }

    final headers = <String, String>{};
    if (_config.verificationStrategy == CkOtpVerificationStrategy.tokenBased &&
        _config.sendVerificationTokenInHeader &&
        vToken != null) {
      headers[_config.verificationTokenHeaderKey] = vToken;
    }

    final response = await CkTransport.request(
      input: RequestInput(
        endpoint: _verifyUrl,
        method: _verifyMethod,
        jsonBody: body,
        headers: headers,
        requiresToken: false,
      ),
      responseBuilder: (data) => data,
      showMessage: true,
    );

    if (response.isSuccess) {
      await storeVerificationToken(activeTrigger, null);
      if (lastTrigger == activeTrigger) {
        lastTrigger = null;
        await CkStorage.delete('core_kit_last_otp_trigger');
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

  /// Clear all OTP state
  Future<void> clearOtpState() async {
    _timer?.cancel();
    _verificationTokens.clear();
    _resendAttempts = 0;
    resendCountdown.add(0);
    for (final trigger in CkOtpTrigger.values) {
      await CkStorage.delete(
        '${CkAuthStorageKeys.verificationTokenPrefix}${trigger.name}',
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    resendCountdown.dispose();
  }
}
