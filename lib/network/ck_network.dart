// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:async';

import 'package:core_kit/network/ck_response.dart';
import 'package:core_kit/network/dio_interceptor.dart';
import 'package:core_kit/network/dio_request_builder.dart';
import 'package:core_kit/network/dio_service_config.dart';
import 'package:core_kit/network/dio_utils.dart';
import 'package:core_kit/network/request_input.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

// Callback for request state changes
typedef OnRequestStateChange<T> = void Function(CkResponse<T> state);

/// Token provider interface - implement this in your app.
class CkTokenProvider {
  Future<String>? Function() accessToken;
  Future<String>? Function() refreshToken;
  Future<void> Function(dynamic data) updateTokens;

  CkTokenProvider({
    required this.accessToken,
    required this.refreshToken,
    required this.updateTokens,
  });
}

/// @deprecated Use [CkTokenProvider] instead.
@Deprecated('Use CkTokenProvider instead')
typedef TokenProvider = CkTokenProvider;

class CkNetwork {
  CkNetwork._(this._dio, this._config);
  static CkNetwork? _instance;
  static bool _isInitialized = false;

  static CkNetwork get instance {
    assert(
      _instance != null,
      'CkNetwork not initialized. Call CkNetwork.init() first.',
    );
    return _instance!;
  }

  final Dio _dio;
  final DioServiceConfig _config;

  /// Create and initialize CkNetwork
  static Future<CkNetwork> init({
    required DioServiceConfig config,
    required CkTokenProvider tokenProvider,
  }) async {
    if (_isInitialized) {
      return CkNetwork.instance;
    }
    _isInitialized = true;

    final dioInstance = Dio(
      dio.BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
      ),
    );

    final instance = CkNetwork._(dioInstance, config);
    DioInterceptor(
      dio: instance._dio,
      config: instance._config,
      tokenProvider: tokenProvider,
    ).intercept();
    DioRequestBuilder.instance.init(
      tokenProvider: tokenProvider,
      dio: dioInstance,
    );
    CkNetwork._instance = instance;
    DioUtils.log(config, 'CkNetwork has been created', tag: 'dio');
    return instance;
  }

  Future<CkResponse<T?>> request<T>({
    required RequestInput input,
    required T? Function(dynamic data) responseBuilder,
    int retryCount = 0,
    int maxRetry = 2,
    bool showMessage = false,
    bool debug = false,
    bool isRetry = false,
  }) async {
    final cancelToken = CancelToken();

    if (debug) {
      return await DioRequestBuilder.instance.build(
        input: input,
        responseBuilder: responseBuilder,
        cancelToken: cancelToken,
        showMessage: showMessage,
        retryCount: retryCount,
        maxRetry: maxRetry,
      );
    }

    try {
      return await DioRequestBuilder.instance.build(
        showMessage: showMessage,
        input: input,
        responseBuilder: responseBuilder,
        cancelToken: cancelToken,
        retryCount: retryCount,
        maxRetry: maxRetry,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        DioUtils.log(
          _config,
          'Request cancelled: ${e.message}',
          tag: input.endpoint,
        );
        if (showMessage) {
          DioUtils.showMessage(e.message ?? '', isError: true);
        }
        return CkResponse(
          data: null,
          message: e.message,
          isSuccess: false,
          cancelToken: cancelToken,
          statusCode: e.response?.statusCode,
        );
      }

      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        if (retryCount < maxRetry) {
          await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));

          return request<T>(
            input: input,
            responseBuilder: responseBuilder,
            retryCount: retryCount + 1,
            maxRetry: maxRetry,
            showMessage: showMessage,
            isRetry: true,
          );
        }
      }

      if (e.response?.data != null && e.response?.data is Map) {
        try {
          final dataMap = e.response?.data as Map<String, dynamic>;
          final parsed = dataMap['data'] != null
              ? responseBuilder(dataMap['data'])
              : null;
          final bool isSuccess = dataMap['success'] ?? false;
          final message = dataMap['message'] != null
              ? dataMap['message'].toString()
              : e.response!.statusMessage;
          if (showMessage) {
            DioUtils.showMessage(message ?? '', isError: true);
          }
          return CkResponse(
            data: parsed,
            isSuccess: isSuccess,
            message: message,
            cancelToken: cancelToken,
            statusCode: e.response!.statusCode,
          );
        } catch (parseError) {
          DioUtils.log(
            _config,
            'Failed to parse error response: $parseError',
            tag: input.endpoint,
            isError: true,
          );
        }
      }

      if (_shouldRetry(e) && retryCount < maxRetry) {
        DioUtils.log(
          _config,
          'Retrying request (attempt ${retryCount + 1})...',
          tag: input.endpoint,
        );
        await Future.delayed(const Duration(milliseconds: 300));
        return request(
          input: input,
          responseBuilder: responseBuilder,
          retryCount: retryCount + 1,
          maxRetry: maxRetry,
        );
      }

      final err = _parseError(e);
      DioUtils.log(
        _config,
        'Request failed: $err',
        tag: input.endpoint,
        isError: true,
      );
      return CkResponse(
        data: null,
        message: e.message,
        isSuccess: false,
        cancelToken: cancelToken,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      final err = e.toString();
      DioUtils.log(
        _config,
        'Unknown error occurred: $err',
        tag: input.endpoint,
        isError: true,
      );
      return CkResponse(
        data: null,
        isSuccess: false,
        message: e.toString(),
        cancelToken: cancelToken,
        statusCode: 0,
      );
    }
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.unknown;

  String _parseError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'].toString();
      } else if (data.containsKey('error')) {
        return data['error'].toString();
      } else if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
    }
    return e.message ?? 'An unknown error occurred.';
  }
}

/// @deprecated Use [CkNetwork] instead.
@Deprecated('Use CkNetwork instead')
typedef DioService = CkNetwork;
