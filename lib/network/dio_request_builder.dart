import 'dart:convert';

import 'package:core_kit/utils/extension.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';

import 'request_input.dart';

class DioRequestBuilder {
  DioRequestBuilder._();
  static final instance = DioRequestBuilder._();
  // ignore: library_private_types_in_public_api
  Future<_RequestOptionsData> build({
    required RequestInput input,
    required String? accessToken,
  }) async {
    String url = input.endpoint;
    input.pathParams?.forEach(
      (k, v) => url = url.replaceAll('{$k}', Uri.encodeComponent(v.toString())),
    );

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
      print(form.toString());
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
      queryParameters: input.queryParams,
      options: dio.Options(method: input.method.name, headers: headers, contentType: contentType),
    );
  }
}

class _RequestOptionsData {
  _RequestOptionsData({
    required this.path,
    required this.data,
    required this.queryParameters,
    required this.options,
  });

  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final dio.Options options;
}
