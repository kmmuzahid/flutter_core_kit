// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'dio_service.dart';
// import 'dio_utils.dart';

// class DioQueue {
//   Completer<void>? _refreshCompleter;
//   final List<_QueuedRequest> _queue = [];

//   Future<void> handle401(
//     DioException err,
//     DioService service,
//     ErrorInterceptorHandler handler,
//   ) async {
//     if (_refreshCompleter == null) {
//       _refreshCompleter = Completer();
//       try {
//         await DioUtils.refreshToken(service);
//         final res = await service.dio.fetch(err.requestOptions);
//         handler.resolve(res);
//       } catch (e) {
//         handler.next(err);
//       } finally {
//         _refreshCompleter?.complete();
//         _refreshCompleter = null;
//         _processQueue(service);
//       }
//     } else {
//       final completer = Completer<Response>();
//       _queue.add(_QueuedRequest(err.requestOptions, completer));
//       return completer.future.then(handler.resolve);
//     }
//   }

//   void _processQueue(DioService service) {
//     while (_queue.isNotEmpty) {
//       final req = _queue.removeAt(0);
//       service.dio.fetch(req.options).then(req.completer.complete);
//     }
//   }
// }

// class _QueuedRequest {
//   final RequestOptions options;
//   final Completer<Response> completer;
//   _QueuedRequest(this.options, this.completer);
// }
