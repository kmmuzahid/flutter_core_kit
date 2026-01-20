// lib/services/dio_service.dart
// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:async';

import 'package:core_kit/core_kit.dart';
import 'package:core_kit/network/dio_interceptor.dart';
import 'package:core_kit/network/dio_request_builder.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

import 'dio_utils.dart';
import 'request_input.dart';

// Callback for request state changes
typedef OnRequestStateChange<T> = void Function(ResponseState<T> state);

// Configuration class for initializing DioService
class DioServiceConfig {
  final String baseUrl;
  final String refreshTokenEndpoint;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Function()? onLogout;

  final bool enableDebugLogs;

  DioServiceConfig({
    required this.baseUrl,
    ///Refresh token endpoint must be post method
    required this.refreshTokenEndpoint,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.onLogout,
    this.enableDebugLogs = false,
  });
}

// Token provider interface - implement this in your app
class TokenProvider {
  Future<String>? Function() accessToken;
  Future<String>? Function() refreshToken;
  Future<void> Function(dynamic data) updateTokens; 

  TokenProvider({
    required this.accessToken,
    required this.refreshToken,
    required this.updateTokens, 
  });
}

class DioService {
  DioService._(this._dio, this._config);
  static late DioService instance;
  static bool _isInitialized = false;

  final Dio _dio;
  final DioServiceConfig _config;
  

  /// Create and initialize DioService
  static Future<DioService> init({
    required DioServiceConfig config,
    required TokenProvider tokenProvider,
  }) async {
    if (_isInitialized) {
      return DioService.instance;
    }
    _isInitialized = true;

    final dioInstance = Dio(
      dio.BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );

    final instance = DioService._(dioInstance, config);
    //inteceptor added
    DioInterceptor(
      dio: instance._dio,
      config: instance._config,
      tokenProvider: tokenProvider,
    ).intercept();
    //request builder initialized
    DioRequestBuilder.instance.init(tokenProvider: tokenProvider, dio: dioInstance);
    //instance created for DioService
    DioService.instance = instance;
    //logging
    DioUtils.log(config, 'DioService has been created', tag: 'dio');
    return instance;
  }





  Future<ResponseState<T?>> request<T>({
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
        DioUtils.log(_config, 'Request cancelled: ${e.message}', tag: input.endpoint);
        if (showMessage) {
          DioUtils.showMessage(e.message ?? '', isError: true);
        }
        return ResponseState(
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

      if (e.response?.data != null) {
        try {
          final parsed = e.response?.data['data'] != null
              ? responseBuilder(e.response?.data['data'])
              : null;
          final bool isSuccess = e.response?.data['success'] ?? false;
          final message = e.response!.data is Map && e.response!.data['message'] != null
              ? e.response!.data['message'].toString()
              : e.response!.statusMessage;
          if (showMessage) {
            DioUtils.showMessage(message ?? '', isError: true);
          }
          return ResponseState(
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
      //  else if (retryCount == maxRetry &&
      //     !_isServerOff &&
      //     (_lastServerShutdown == null ||
      //         _lastServerShutdown!.isBefore(DateTime.now().subtract(const Duration(minutes: 1))))) {
      //   _lastServerShutdown = DateTime.now();
      //   DioUtils.showMessage('Server is currently unavailable. Please try again later.', isError: true);
      //   _isServerOff = true;
      // }

      final err = _parseError(e);
      DioUtils.log(_config, 'Request failed: $err', tag: input.endpoint, isError: true);
      return ResponseState(
        data: null,
        message: e.message,
        isSuccess: false,
        cancelToken: cancelToken,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      final err = e.toString();
      DioUtils.log(_config, 'Unknown error occurred: $err', tag: input.endpoint, isError: true);
      return ResponseState(
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

