import 'package:core_kit/network/ck_response_extractor.dart';
import 'package:core_kit/network/request_input.dart';

class CkTransportConfig {
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
  final CkResponseExtractor responseExtractor;

  CkTransportConfig({
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
    CkResponseExtractor? responseExtractor,
  }) : responseExtractor =
           responseExtractor ??
           CkResponseExtractor(
             data: (response) => response is Map ? response['data'] : response,
             message: (response) => response is Map ? response['message']?.toString() : null,
             meta: CkResponseExtractor.defaultMeta,
           );
}


