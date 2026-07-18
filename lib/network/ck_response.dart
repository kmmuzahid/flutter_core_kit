import 'package:dio/dio.dart';

/// A generic typed response wrapper returned by [CkTransport.request].
///
/// Wraps both success and failure states, giving you [data], [isSuccess],
/// [message], and the optional [meta] block in a single object.
///
/// Example:
/// ```dart
/// final res = await CkTransport.request<User>(
///   input: RequestInput(endpoint: '/me', method: RequestMethod.GET),
///   responseBuilder: (json) => User.fromJson(json),
/// );
/// if (res.isSuccess) {
///   print(res.data?.name);
/// } else {
///   print(res.message);
/// }
/// ```

class CkResponse<T> {
  CkResponse({
    required this.data,
    required this.statusCode,
    required this.isSuccess,
    this.raw,
    this.isRequesting = false,
    this.message,
    this.meta,
    this.cancelToken,
  });

  /// The parsed response data. May be `null` on failure.
  final T data;

  /// Full decoded HTTP body before [CkResponseExtractor] `data` extraction.
  final dynamic raw;

  /// Whether this response is currently awaiting a network response.
  final bool isRequesting;

  /// `true` when the server returned a successful status.
  final bool isSuccess;

  /// Human-readable message from the server (e.g. validation error text).
  final String? message;

  /// Optional API `meta` block (dynamic). `null` when not returned.
  final dynamic meta;

  /// A [CancelToken] that can be used to abort the in-flight request.
  final CancelToken? cancelToken;

  /// HTTP status code returned by the server, e.g. `200`, `401`, `500`.
  final int? statusCode;

  CkResponse<T> copyWith({
    T? data,
    bool? isSuccess,
    bool? isRequesting,
    String? error,
    meta,
    raw,
    CancelToken? cancelToken,
    int? responseCode,
  }) {
    return CkResponse<T>(
      data: data ?? this.data,
      raw: raw ?? this.raw,
      isRequesting: isRequesting ?? this.isRequesting,
      message: error ?? message,
      meta: meta ?? this.meta,
      cancelToken: cancelToken ?? this.cancelToken,
      isSuccess: isSuccess ?? this.isSuccess,
      statusCode: responseCode ?? statusCode,
    );
  }
}
