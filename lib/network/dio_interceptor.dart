/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:39:26
 * @Email: km.muzahid@gmail.com
 */

import 'dart:async';

import 'package:core_kit/network/ck_transport.dart';
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:core_kit/network/dio_utils.dart';
import 'package:core_kit/utils/ck_logger.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:core_kit/auth/ck_auth_service.dart';

class DioInterceptor extends Interceptor {
  final Dio _dio;
  final CkTransportConfig _config;
  final CkTokenProvider _tokenProvider;
  Completer<void>? _refreshCompleter;
  bool _isServerOff = false;
  bool _isNetworkOff = false;
  bool get isNetworkOff => _isNetworkOff;
  bool _hasShownNetworkError = false;
  DateTime? _lastServerShutdown;

  DioInterceptor({
    required this._dio,
    required this._config,
    required this._tokenProvider,
  });

  bool get isServerOff => _isServerOff;

  Future<void> _triggerLogout() async {
    if (CkAuthService.isInitialized) {
      await CkAuthService.instance.logout();
    } else {
      _config.onLogout?.call();
    }
  }

  Future<void> _injectToken(RequestOptions options) async {
    final accessToken = await _tokenProvider.accessToken();
    if (accessToken?.isNotEmpty == true) {
      options.headers[_config.tokenHeaderKey] =
          '${_config.isBearerToken ? 'Bearer ' : ''}$accessToken';
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
      DioUtils.log(_config, 'No refresh token available.', tag: 'CkTransport');
      await _triggerLogout();
      throw Exception('No refresh token available');
    }
    DioUtils.log(
      _config,
      '🚀 Headers: {\'${_config.refreshTokenHeaderKey}\': $refreshToken}\n',
      tag: 'POST::${_config.refreshTokenEndpoint}',
    );
    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.request(
        _config.refreshTokenEndpoint,
        options: Options(
          method: _config.refreshTokenRequestMethod.name,
          headers: {_config.refreshTokenHeaderKey: refreshToken},
          validateStatus: (status) => true, // Handle status codes manually
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final extractedData = _config.responseExtractor.data(response.data);
          await _tokenProvider.updateTokens(extractedData);
        }
      } else if (response.statusCode == 401) {
        final extractedMessage = _config.responseExtractor.message(
          response.data,
        );
        if (extractedMessage != null && extractedMessage.isNotEmpty) {
          DioUtils.showMessage(extractedMessage, isError: true);
        }
        await _triggerLogout();
        throw Exception('Refresh token unauthorized');
      } else {
        DioUtils.log(
          _config,
          'Refresh token failed with status: ${response.statusCode}',
          tag: 'Auth',
          isError: true,
        );
        await _triggerLogout();
        throw Exception(
          'Refresh token failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      DioUtils.log(
        _config,
        'DioException during token refresh: ${e.message}',
        tag: 'Auth',
        isError: true,
      );
      await _triggerLogout();
      throw Exception('Refresh token failed: ${e.message}');
    } catch (e) {
      DioUtils.log(
        _config,
        'Error during token refresh: $e',
        tag: 'Auth',
        isError: true,
      );
      await _triggerLogout();
      throw Exception('Refresh token failed: $e');
    }
  }

  Future<Response<dynamic>> _retryAfterRefresh(
    RequestOptions requestOptions,
  ) async {
    await _injectToken(requestOptions);

    if (requestOptions.data is FormData) {
      requestOptions.data = (requestOptions.data as FormData).clone();
    }

    return _dio.fetch(requestOptions);
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
          final requestId =
              error.requestOptions.extra['requestId'] as int? ?? 0;
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;
          final retryCount =
              error.requestOptions.extra['retryCount'] as int? ?? 0;
          final maxRetry = error.requestOptions.extra['maxRetry'] as int? ?? 1;

          CkLogger.debug(
            'Retry count: $retryCount, Max retry: $maxRetry',
            tag: 'DioInterceptor',
          );

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
            final currentToken = await _tokenProvider.accessToken();
            final requestHeader =
                error.requestOptions.headers[_config.tokenHeaderKey]
                    ?.toString() ??
                '';
            final requestToken = _config.isBearerToken
                ? requestHeader.replaceFirst('Bearer ', '')
                : requestHeader;

            // If token has already been refreshed by a previous queued request, just retry.
            if (currentToken != null &&
                currentToken.isNotEmpty &&
                requestToken != currentToken) {
              try {
                final response = await _retryAfterRefresh(error.requestOptions);
                handler.resolve(response);
              } catch (e) {
                handler.reject(error);
              }
              return;
            }

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
                // _triggerLogout is already called in _refreshTokenIfNeeded, but safe to call again
                await _triggerLogout();
                handler.reject(error);
              } finally {
                _refreshCompleter?.complete();
                _refreshCompleter = null;
              }
            } else {
              try {
                await _refreshCompleter!.future;
                final response = await _retryAfterRefresh(error.requestOptions);
                handler.resolve(response);
              } catch (e) {
                handler.reject(error);
              }
            }
          } else if (statusCode == 401 &&
              path == _config.refreshTokenEndpoint) {
            DioUtils.log(
              _config,
              '401 received from refresh token endpoint. Logging out.',
              tag: 'Auth',
              isError: true,
            );
            await _triggerLogout();
            handler.reject(error);
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
}
