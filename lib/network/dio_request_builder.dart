import 'dart:convert';

import 'package:core_kit/network/dio_service.dart';
import 'package:core_kit/network/response_state.dart' show ResponseState;
import 'package:core_kit/utils/extension.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'dio_utils.dart';
import 'request_input.dart';

class DioRequestBuilder {
  DioRequestBuilder._();
  static final instance = DioRequestBuilder._();
  late TokenProvider _tokenProvider;

  late Dio _dio;
  void init({required TokenProvider tokenProvider, required Dio dio}) {
    _tokenProvider = tokenProvider;
    _dio = dio;
  }

  Future<ResponseState<T?>> build<T>({
    required RequestInput input,
    required T? Function(dynamic data) responseBuilder,
    required CancelToken cancelToken,
    required bool showMessage,
    required int retryCount,
    required int maxRetry,
  }) async {
    final requestOptions = await _buildOptions(
      input: input,
      accessToken: await _tokenProvider.accessToken(),
      retryCount: retryCount,
      maxRetry: maxRetry,
    );

    dio.Response response;
    response = await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      // queryParameters: requestOptions.queryParameters,
      options: requestOptions.options,
      cancelToken: cancelToken,
      onSendProgress: input.onSendProgress,
      onReceiveProgress: input.onReceiveProgress,
    );

    // if (kDebugMode) {
    //   DioUtils.log(_config, response.data.toString(), tag: input.endpoint);
    // }

    final parsed = response.data['data'] != null ? responseBuilder(response.data['data']) : null;

    final message = response.data is Map && response.data['message'] != null
        ? response.data['message'].toString()
        : response.statusMessage;

    if (showMessage && (response.statusCode == 200 || response.statusCode == 201)) {
      DioUtils.showMessage(message ?? '', isError: false);
    }

    return ResponseState(
      data: parsed,
      message: message,
      isSuccess: response.data['success'],
      cancelToken: cancelToken,
      statusCode: response.statusCode,
    );
  }

  // ignore: library_private_types_in_public_api
  Future<_RequestOptionsData> _buildOptions({
    required RequestInput input,
    required String? accessToken,
    required int retryCount,
    required int maxRetry,
  }) async {
    String url = input.endpoint;
    if (input.pathParams?.isNotEmpty ?? false) {
      for (int i = 0; i < input.pathParams!.length; i++) {
        if (i == 0 && url.endsWith('/')) {
          url = "$url${input.pathParams![i]}";
        } else {
          url = "$url/${input.pathParams![i]}";
        }
      }
    }
    if (input.queryParams?.isNotEmpty ?? false) {
      url = "$url?${input.queryParams!.entries.map((e) => "${e.key}=${e.value}").join("&")}";
    }

    final headers = {
      if (input.requiresToken && accessToken?.isNotEmpty == true)
        'Authorization': 'Bearer $accessToken',
      ...?input.headers,
    };

    dynamic body;
    String contentType = 'application/json';

    final hasFiles = input.files != null && input.files!.isNotEmpty;
    final hasFields = input.formFields != null;
    final hasJson = input.jsonBody != null;
    final hasList = input.listBody != null;

    final needsMultipart = hasFiles || hasFields || (hasFiles && (hasJson || hasList));

    if (needsMultipart) {
      dio.FormData formData = dio.FormData();
      final Map<String, dynamic> form = {};

      if (input.formFields != null) {
        form.addAll(input.formFields!);
        // _form.add(input.formFields!.entries.map((e) => MapEntry(e.key, e.value)))
        // formData.fields.addAll(input.formFields!.entries.map((e) => MapEntry(e.key, e.value)));
      }
      if (hasJson) {
        form['data'] = jsonEncode(input.jsonBody);
        // formData.fields.add(MapEntry('data', jsonEncode(input.jsonBody)));
      }
      if (hasList) {
        form['data'] = jsonEncode(input.listBody);
        // formData.fields.add(MapEntry('data', jsonEncode(input.listBody)));
      }

      if (hasFiles) {
        for (final entry in input.files!.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is XFile) {
            final multipartFile = await value.toMultipart();
            // formData.files.add(MapEntry(key, multipartFile));
            form[key] = multipartFile;
          } else if (value is List<XFile>) {
            final imageFileList = await Future.wait(
              value.map((e) async {
                return await e.toMultipart();
              }).toList(),
            );
            form[key] = imageFileList;
            // for (final file in value) {
            //   final multipartFile = await file.toMultipart();
            //   formData.files.add(MapEntry(key, multipartFile));
            // }
          }
        }
      } 
      contentType = 'multipart/form-data';
      formData = dio.FormData.fromMap(form);
      body = formData;
    } else if (hasJson) {
      body = input.jsonBody;
      contentType = 'application/json';
    } else if (hasList) {
      body = jsonEncode(input.listBody);
      contentType = 'application/json';
    }

    return _RequestOptionsData(
      path: url,
      data: body, 
      options: dio.Options(
        extra: {'retryCount': retryCount, 'maxRetry': maxRetry},
        method: input.method.name,
        headers: headers,
        contentType: contentType,
      ),
    );
  }
}

class _RequestOptionsData {
  _RequestOptionsData({
    required this.path,
    required this.data, 
    required this.options,
  });

  final String path;
  final dynamic data; 
  final dio.Options options;
}
