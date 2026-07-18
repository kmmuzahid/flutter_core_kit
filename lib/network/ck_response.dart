// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

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

  final T data;

  /// Full decoded HTTP body before [CkResponseExtractor] `data` extraction.
  final dynamic raw;
  final bool isRequesting;
  final bool isSuccess;
  final String? message;

  /// Optional API `meta` block (dynamic). `null` when not returned.
  final dynamic meta;

  final CancelToken? cancelToken;
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
