// import 'package:core_kit/network/request_input.dart';

import 'package:core_kit/network/request_input.dart';

class DioServiceConfig {
  final String baseUrl;
  final String refreshTokenEndpoint;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Function()? onLogout;
  final String tokenHeaderKey;
  final String refreshTokenHeaderKey;
  final bool isBearerToken;
  final RequestMethod refreshTokenRequestMethod;
  final bool enableDebugLogs;

  DioServiceConfig({
    required this.baseUrl,
    this.tokenHeaderKey = 'Authorization',
    this.refreshTokenHeaderKey = 'refreshToken',
    this.isBearerToken = true,
    this.refreshTokenRequestMethod = RequestMethod.POST,
    required this.refreshTokenEndpoint,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.onLogout,
    this.enableDebugLogs = false,
  });
}
