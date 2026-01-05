// import 'package:dio/dio.dart';
// import 'package:mainland/core/utils/log/app_log.dart';
// import 'dio_queue.dart';
// import 'dio_service.dart';
// import 'dio_utils.dart';

// class DioInterceptor extends Interceptor {
//   DioInterceptor({required this.service, required this.isDebug});

//   final DioService service;
//   final DioQueue _queue = DioQueue();
//   final bool isDebug;

//   @override
//   Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     try {
//       // Add service to extra for use in other interceptor methods
//       options.extra['service'] = service;

//       // Get auth cubit from service or context
//       final authCubit = service.authCubit;

//       // Add authorization header if needed
//       if (options.extra['requiresToken'] ?? true) {
//         final accessToken = authCubit?.state.userLoginInfoModel.accessToken;
//         if (accessToken?.isNotEmpty == true) {
//           options.headers['Authorization'] = 'Bearer $accessToken';
//         }
//       }

//       // Log request if in debug mode
//       if (isDebug) {
//         final headers = Map<String, dynamic>.from(options.headers)
//           ..removeWhere((key, _) => key == 'authorization');

//         AppLogger.apiDebug(
//           '🚀 [REQ:${options.method} ${options.path}]\n'
//           '🔹 Headers: $headers\n'
//           '🔹 Query: ${options.queryParameters}\n'
//           '🔹 Data: ${options.data is FormData ? options.data.fields : options.data}',
//           tag: options.path,
//         );
//       }

//       handler.next(options);
//     } catch (e) {
//       handler.reject(
//         DioException(requestOptions: options, error: e, stackTrace: StackTrace.current),
//       );
//     }
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     if (isDebug) {
//       AppLogger.apiDebug(
//         '✅ [RES:${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}]\n'
//         '🔹 Status: ${response.statusCode} ${response.statusMessage}\n'
//         '🔹 Data: ${response.data}',
//         tag: response.requestOptions.path,
//       );
//     }
//     handler.next(response);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       await _queue.handle401(err, service, handler);
//       return;
//     }

//     // Log error if in debug mode
//     if (isDebug) {
//       AppLogger.apiError(
//         '❌ [ERR:${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.path}]\n'
//         '🔹 Error: ${err.message}\n'
//         '🔹 Type: ${err.type}\n'
//         '🔹 Response: ${err.response?.data}',
//         tag: err.requestOptions.path,
//       );
//     }

//     handler.next(err);
//   }
// }
