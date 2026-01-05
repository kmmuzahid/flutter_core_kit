// lib/services/dio_service.dart
// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:async';
import 'dart:convert';

import 'package:core_kit/utils/app_log.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dio_request_builder.dart';
import 'request_input.dart';
import 'response_state.dart';

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
    required this.refreshTokenEndpoint,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.onLogout,
    this.enableDebugLogs = false,
  });
}

// Token provider interface - implement this in your app
class TokenProvider {
  String? Function() accessToken;
  String? Function() refreshToken;
  Future<void> Function(String accessToken, String refreshToken) updateTokens;
  Future<void> Function() clearTokens;

  TokenProvider({
    required this.accessToken,
    required this.refreshToken,
    required this.updateTokens,
    required this.clearTokens,
  });
}

class DioService {
  DioService._(this._dio, this._config, this._tokenProvider);
  static late DioService instance;

  final Dio _dio;
  final DioServiceConfig _config;
  final TokenProvider _tokenProvider;
  Completer<void>? _refreshCompleter;
  final List<_QueuedRequest> _queue = [];
  bool _isServerOff = false;
  bool _isNetworkOff = false;
  bool _hasShownNetworkError = false;
  DateTime? _lastServerShutdown;

  bool get isServerOff => _isServerOff;
  bool get isNetworkOff => _isNetworkOff;

  String? getAccessToken() => _tokenProvider.accessToken();
  String? getRefreshToken() => _tokenProvider.refreshToken();

  /// Create and initialize DioService
  Future<DioService> init({
    required DioServiceConfig config,
    required TokenProvider tokenProvider,
  }) async {
    final dioInstance = Dio(
      dio.BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );

    final instance = DioService._(dioInstance, config, tokenProvider);
    instance._addInterceptors();

    DioService.instance = instance;
    _log(config, 'DioService has been created', tag: 'dio');
    return instance;
  }

  static void _log(DioServiceConfig config, String message, {String? tag, bool isError = false}) {
    if (!config.enableDebugLogs) return;

    if (isError) {
      AppLogger.apiError(message, tag: tag);
    } else {
      AppLogger.apiDebug(message, tag: tag);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) {
      AppLogger.apiError(message, tag: 'dio');
    } else {
      AppLogger.apiDebug(message, tag: 'dio');
    }
  }

  Future<bool> _isNetworkAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkAndHandleNetworkStatus() async {
    final hasNetwork = await _isNetworkAvailable();

    if (!hasNetwork) {
      if (!_isNetworkOff) {
        _isNetworkOff = true;
        if (!_hasShownNetworkError) {
          _hasShownNetworkError = true;
          _showMessage('No internet connection', isError: true);
        }
      }
      return;
    }

    if (_isServerOff) {
      _isServerOff = false;
    }
    if (_isNetworkOff) {
      _isNetworkOff = false;
      _hasShownNetworkError = false;
    }
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final requestId = DateTime.now().millisecondsSinceEpoch;
          options.extra['requestId'] = requestId;

          if (options.extra['requiresToken'] ?? true) {
            await _injectToken(options);
          }

          if (_config.enableDebugLogs) {
            final headers = Map<String, dynamic>.from(options.headers)
              ..removeWhere((key, _) => key == 'authorization');

            _log(
              _config,
              '🚀 [REQ:${options.method} ${options.path}] ID: $requestId\n'
              '🔹 Headers: $headers\n'
              '🔹 Query: ${options.queryParameters}\n'
              '🔹 Data: ${options.data is FormData ? options.data.fields : options.data?.toString().substring(0, options.data.toString().length > 200 ? 200 : null)}',
              tag: options.path,
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (_config.enableDebugLogs) {
            final requestId = response.requestOptions.extra['requestId'];
            _log(
              _config,
              '✅ [RES:${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}] ID: $requestId\n'
              '🔹 Status: ${response.statusCode} ${response.statusMessage}\n'
              '🔹 Data: ${response.data.toString().substring(0, response.data.toString().length > 200 ? 200 : null)}'
              '${response.data.toString().length > 200 ? '...' : ''}',
              tag: response.requestOptions.path,
            );
          }
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          final requestId = error.requestOptions.extra['requestId'] as int? ?? 0;
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;

          if (_config.enableDebugLogs) {
            _log(
              _config,
              '❌ [ERR:$statusCode ${error.requestOptions.method} $path] ID: $requestId\n'
              '🔹 Error: ${error.message}\n'
              '🔹 Type: ${error.type}\n'
              '🔹 Response: ${error.response?.data?.toString() ?? 'No response data'}',
              tag: path,
              isError: true,
            );
          }

          await _checkAndHandleNetworkStatus();

          if (statusCode == 401 && path != _config.refreshTokenEndpoint) {
            if (_refreshCompleter == null) {
              _refreshCompleter = Completer<void>();
              _log(
                _config,
                '🔄 [AUTH] Token expired. Attempting to refresh...\n'
                '🔹 Request ID: $requestId',
                tag: 'Auth',
              );

              try {
                await _refreshTokenIfNeeded();
                _log(
                  _config,
                  '🔄 [AUTH] Token refresh successful\n'
                  '🔹 Request ID: $requestId',
                  tag: 'Auth',
                );
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
              } catch (e) {
                _log(
                  _config,
                  '❌ [AUTH] Token refresh failed\n'
                  '🔹 Request ID: $requestId\n'
                  '🔹 Error: $e',
                  tag: 'Auth',
                  isError: true,
                );
                await _tokenProvider.clearTokens();
                _config.onLogout?.call();
                handler.reject(error);
              } finally {
                _refreshCompleter?.complete();
                _refreshCompleter = null;
                _processQueue();
              }
            } else {
              final responseCompleter = Completer<dio.Response>();
              _queue.add(_QueuedRequest(error.requestOptions, responseCompleter));
              return responseCompleter.future.then(handler.resolve).catchError((
                Object err,
                StackTrace stackTrace,
              ) {
                if (err is DioException) {
                  handler.reject(err);
                } else {
                  handler.reject(
                    DioException(
                      requestOptions: error.requestOptions,
                      error: err,
                      stackTrace: stackTrace,
                      message: err.toString(),
                    ),
                  );
                }
              });
            }
          } else if (statusCode == 401 && path == _config.refreshTokenEndpoint) {
            _log(
              _config,
              '401 received from refresh token endpoint. Logging out.',
              tag: 'Auth',
              isError: true,
            );
            await _tokenProvider.clearTokens();
            _config.onLogout?.call();
            handler.reject(error);
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _injectToken(RequestOptions options) async {
    final accessToken = _tokenProvider.accessToken();
    if (accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
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
      return await _requestBuilder(
        input: input,
        responseBuilder: responseBuilder,
        cancelToken: cancelToken,
        showMessage: showMessage,
      );
    }

    try {
      return await _requestBuilder(
        showMessage: showMessage,
        input: input,
        responseBuilder: responseBuilder,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _log(_config, 'Request cancelled: ${e.message}', tag: input.endpoint);
        if (showMessage) {
          _showMessage(e.message ?? '', isError: true);
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
            _showMessage(message ?? '', isError: true);
          }
          return ResponseState(
            data: parsed,
            isSuccess: isSuccess,
            message: message,
            cancelToken: cancelToken,
            statusCode: e.response!.statusCode,
          );
        } catch (parseError) {
          _log(
            _config,
            'Failed to parse error response: $parseError',
            tag: input.endpoint,
            isError: true,
          );
        }
      }

      if (_shouldRetry(e) && retryCount < maxRetry) {
        _log(_config, 'Retrying request (attempt ${retryCount + 1})...', tag: input.endpoint);
        await Future.delayed(const Duration(milliseconds: 300));
        return request(
          input: input,
          responseBuilder: responseBuilder,
          retryCount: retryCount + 1,
          maxRetry: maxRetry,
        );
      } else if (retryCount == maxRetry &&
          !_isServerOff &&
          (_lastServerShutdown == null ||
              _lastServerShutdown!.isBefore(DateTime.now().subtract(const Duration(minutes: 1))))) {
        _lastServerShutdown = DateTime.now();
        _showMessage('Server is currently unavailable. Please try again later.', isError: true);
        _isServerOff = true;
      }

      final err = _parseError(e);
      _log(_config, 'Request failed: $err', tag: input.endpoint, isError: true);
      return ResponseState(
        data: null,
        message: e.message,
        isSuccess: false,
        cancelToken: cancelToken,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      final err = e.toString();
      _log(_config, 'Unknown error occurred: $err', tag: input.endpoint, isError: true);
      return ResponseState(
        data: null,
        isSuccess: false,
        message: e.toString(),
        cancelToken: cancelToken,
        statusCode: 0,
      );
    }
  }

  Future<ResponseState<T?>> _requestBuilder<T>({
    required RequestInput input,
    required T? Function(dynamic data) responseBuilder,
    required CancelToken cancelToken,
    required bool showMessage,
  }) async {
    final requestOptions = await DioRequestBuilder.instance.build(
      input: input,
      accessToken: getAccessToken(),
    );

    dio.Response response;
    response = await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: requestOptions.options,
      cancelToken: cancelToken,
      onSendProgress: input.onSendProgress,
      onReceiveProgress: input.onReceiveProgress,
    );

    if (kDebugMode) {
      _log(_config, response.data.toString(), tag: input.endpoint);
    }

    final parsed = response.data['data'] != null ? responseBuilder(response.data['data']) : null;

    final message = response.data is Map && response.data['message'] != null
        ? response.data['message'].toString()
        : response.statusMessage;

    if (showMessage && (response.statusCode == 200 || response.statusCode == 201)) {
      _showMessage(message ?? '', isError: false);
    }

    return ResponseState(
      data: parsed,
      message: message,
      isSuccess: response.data['success'],
      cancelToken: cancelToken,
      statusCode: response.statusCode,
    );
  }

  Future<void> _refreshTokenIfNeeded() async {
    final refreshToken = _tokenProvider.refreshToken();

    if (refreshToken?.isEmpty == true || refreshToken == null) {
      _log(_config, 'No refresh token available.', tag: 'DioService');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${_config.baseUrl}${_config.refreshTokenEndpoint}'),
        headers: {'refreshtoken': refreshToken},
      );

      if (response.body.isNotEmpty && (response.statusCode == 200 || response.statusCode == 201)) {
        final data = jsonDecode(response.body);
        final access = data['data']['access_token'];
        final refresh = data['data']['refresh_token'];
        await _tokenProvider.updateTokens(access, refresh);
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        _showMessage(data['message'] ?? '', isError: true);
        await _tokenProvider.clearTokens();
        _config.onLogout?.call();
        return;
      } else {
        throw Exception('Refresh token failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _log(_config, 'DioException during token refresh: ${e.message}', tag: 'Auth', isError: true);
      throw Exception('Refresh token failed: ${e.message}');
    } catch (e) {
      _log(_config, 'Error during token refresh: $e', tag: 'Auth', isError: true);
      throw Exception('Refresh token failed: $e');
    }
  }

  void _processQueue() {
    while (_queue.isNotEmpty) {
      final req = _queue.removeAt(0);
      _dio
          .fetch(req.requestOptions)
          .then(req.completer.complete)
          .catchError(req.completer.completeError);
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

class _QueuedRequest {
  _QueuedRequest(this.requestOptions, this.completer);

  final RequestOptions requestOptions;
  final Completer<dio.Response> completer;
}
