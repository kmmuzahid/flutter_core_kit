/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:39:26
 * @Email: km.muzahid@gmail.com
 */

import 'dart:async';
import 'dart:convert';

import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/utils/app_log.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'dio_utils.dart';

class DioInterceptor extends Interceptor {
  final Dio _dio;
  final DioServiceConfig _config;
  final TokenProvider _tokenProvider;
  Completer<void>? _refreshCompleter;
  bool _isServerOff = false;
  bool _isNetworkOff = false;
  bool get isNetworkOff => _isNetworkOff;
  bool _hasShownNetworkError = false;
  DateTime? _lastServerShutdown;
  final List<_QueuedRequest> _queue = [];

  DioInterceptor({
    required Dio dio,
    required DioServiceConfig config,
    required TokenProvider tokenProvider,
  }) : _dio = dio,
       _config = config,
       _tokenProvider = tokenProvider;

  bool get isServerOff => _isServerOff;

  void _processQueue() {
    while (_queue.isNotEmpty) {
      final req = _queue.removeAt(0);
      _dio
          .fetch(req.requestOptions)
          .then(req.completer.complete)
          .catchError(req.completer.completeError);
    }
  }

  Future<void> _injectToken(RequestOptions options) async {
    final accessToken = await _tokenProvider.accessToken();
    if (accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
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
          DioUtils.showMessage('No internet connection', isError: true);
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

  Future<void> _refreshTokenIfNeeded() async {
    final refreshToken = await _tokenProvider.refreshToken();

    if (refreshToken?.isEmpty == true || refreshToken == null) {
      DioUtils.log(_config, 'No refresh token available.', tag: 'DioService');
      return;
    }
    DioUtils.log(
      _config,
      '🚀 Headers: {\'refreshtoken\': $refreshToken}\n',
      tag: 'POST::${_config.refreshTokenEndpoint}',
    );
    try {
      final response = await http.post(
        Uri.parse('${_config.baseUrl}${_config.refreshTokenEndpoint}'),
        headers: {'refreshtoken': refreshToken},
      );

      if (response.body.isNotEmpty && (response.statusCode == 200 || response.statusCode == 201)) {
        final data = jsonDecode(response.body);

        await _tokenProvider.updateTokens(data['data']);
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        DioUtils.showMessage(data['message'] ?? '', isError: true);
        _config.onLogout?.call();
        return;
      } else {
        DioUtils.log(
          _config,
          'Refresh token failed with status: ${response.statusCode}',
          tag: 'Auth',
          isError: true,
        );
        throw Exception('Refresh token failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      DioUtils.log(
        _config,
        'DioException during token refresh: ${e.message}',
        tag: 'Auth',
        isError: true,
      );
      throw Exception('Refresh token failed: ${e.message}');
    } catch (e) {
      DioUtils.log(_config, 'Error during token refresh: $e', tag: 'Auth', isError: true);
      throw Exception('Refresh token failed: $e');
    }
  }

  Future<Response<dynamic>> _retryAfterRefresh(RequestOptions requestOptions) async {
    await _injectToken(requestOptions);

    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: requestOptions.extra,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onSendProgress: requestOptions.onSendProgress,
      onReceiveProgress: requestOptions.onReceiveProgress,
    );
  }

  void intercept() {
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

            DioUtils.log(
              _config,
              '🕊️ [REQ ID: $requestId]'
              '🕊️  🕊️  Headers: $headers\n'
              '🕊️  Query: ${options.queryParameters}\n'
              '🕊️  Data: ${options.data is FormData ? options.data.fields : options.data?.toString().substring(0, options.data.toString().length > 200 ? 200 : null)}',
              tag: '${options.method}::${options.path} ',
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (_config.enableDebugLogs) {
            final requestId = response.requestOptions.extra['requestId'];
            DioUtils.log(
              _config,
              '✨ [REQ ID: $requestId]\n'
              '✨ ✨  Message: ${response.statusMessage}\n'
              '✨  Data: ${response.data}',
              tag:
                  '${response.requestOptions.method}:${response.statusCode}::${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          final requestId = error.requestOptions.extra['requestId'] as int? ?? 0;
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;
          final retryCount = error.requestOptions.extra['retryCount'] as int? ?? 0;
          final maxRetry = error.requestOptions.extra['maxRetry'] as int? ?? 1;

          AppLogger.debug('Retry count: $retryCount, Max retry: $maxRetry', tag: 'DioInterceptor');
 

          if (retryCount == maxRetry &&
              !_isServerOff &&
              (_lastServerShutdown == null ||
                  _lastServerShutdown!.isBefore(
                    DateTime.now().subtract(const Duration(minutes: 1)),
                  ))) {
            _lastServerShutdown = DateTime.now();
            DioUtils.showMessage(
              'Server is currently unavailable. Please try again later.',
              isError: true,
            );
            
            _isServerOff = true;
          }

          if (_config.enableDebugLogs) {
            DioUtils.log(
              _config,
              '❌ [REQ ID: $requestId]\n'
              '☠️  ☠️  Error: ${error.message}\n'
              '☠️  Type: ${error.type}\n'
              '☠️  Response: ${error.response?.data?.toString() ?? 'No response data'}',
              tag:
                  '${error.requestOptions.method}:${error.response?.statusCode}::${error.requestOptions.path}',
              isError: true,
            );
          }

          await _checkAndHandleNetworkStatus();

          if (statusCode == 401 && path != _config.refreshTokenEndpoint) {
            if (_refreshCompleter == null) {
              _refreshCompleter = Completer<void>();
              DioUtils.log(
                _config,
                '🔄 [AUTH] Token expired. Attempting to refresh...\n'
                '🔹 Request ID: $requestId',
                tag: 'Auth',
              );

              try {
                await _refreshTokenIfNeeded();
                DioUtils.log(
                  _config,
                  '🔄 [AUTH] Token refresh successful\n'
                  '🔹 Request ID: $requestId',
                  tag: 'Auth',
                );

                final response = await _retryAfterRefresh(error.requestOptions);
                handler.resolve(response);
              } catch (e) {
                DioUtils.log(
                  _config,
                  '❌ [AUTH] Token refresh failed\n'
                  '🔹 Request ID: $requestId\n'
                  '🔹 Error: $e',
                  tag: 'Auth',
                  isError: true,
                );
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
            DioUtils.log(
              _config,
              '401 received from refresh token endpoint. Logging out.',
              tag: 'Auth',
              isError: true,
            );
            _config.onLogout?.call();
            handler.reject(error);
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
}

class _QueuedRequest {
  _QueuedRequest(this.requestOptions, this.completer);

  final RequestOptions requestOptions;
  final Completer<dio.Response> completer;
}
