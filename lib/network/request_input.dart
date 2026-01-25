// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';

enum RequestMethod { GET, POST, PUT, DELETE, PATCH }

class RequestInput {

  RequestInput({
    required this.endpoint,
    required this.method, 
    this.pathParams,
    this.queryParams,
    this.headers,
    this.formFields,
    this.jsonBody,
    this.files,
    this.timeout,
    this.onSendProgress,
    this.onReceiveProgress,
    this.requiresToken = true,
    this.cancelToken,
    this.listBody
  });
  final String endpoint; 
  final RequestMethod method;
  final List<String>? pathParams;
  final Map<String, dynamic>? queryParams;
  final Map<String, String>? headers;
  final Map<String, dynamic>? formFields;
  final Map<String, dynamic>? jsonBody;
  final List<Map<String, dynamic>>? listBody;
  final Map<String, dynamic>? files; 
  final Duration? timeout;
  final Function(int, int)? onSendProgress;
  final Function(int, int)? onReceiveProgress;
  final bool requiresToken;
  final CancelToken? cancelToken;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'endpoint': endpoint,
      'method': method.name,
      'pathParams': pathParams,
      'queryParams': queryParams,
      'headers': headers,
      'formFields': formFields,
      'jsonBody': jsonEncode(jsonBody),
      'listBody': listBody,
      'files': files?.map((key, value) => MapEntry(key, value.name)),
      'timeout': timeout.toString(),
      'requiresToken': requiresToken,
    };
  }

  String toJson() => json.encode(toMap());

}
