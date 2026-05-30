// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class CkResponse<T> {
  CkResponse({
    required this.data,
    required this.statusCode,
    required this.isSuccess,
    this.isRequesting = false,
    this.message,
    this.cancelToken,
  });

  final T data;
  final bool isRequesting;
  final bool isSuccess;
  final String? message;
  final CancelToken? cancelToken;
  final int? statusCode;

  CkResponse<T> copyWith({
    T? data,
    bool? isSuccess,
    bool? isRequesting,
    String? error,
    CancelToken? cancelToken,
    int? responseCode,
  }) {
    return CkResponse<T>(
      data: data ?? this.data,
      isRequesting: isRequesting ?? this.isRequesting,
      message: error ?? message,
      cancelToken: cancelToken ?? this.cancelToken,
      isSuccess: isSuccess ?? this.isSuccess,
      statusCode: responseCode ?? statusCode,
    );
  }
}

/// @deprecated Use [CkResponse] instead.
@Deprecated('Use CkResponse instead')
typedef ResponseState<T> = CkResponse<T>;
