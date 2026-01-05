// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'dio_service.dart';
// import 'response_state.dart';

// class DioUtils {
//   static void handleNetworkError(DioException e) {
//     if (e.type == DioExceptionType.connectionError) {
//       // Handle network error
//     }
//   }

//   static Future<void> refreshToken(DioService service) async {
//     final refresh = service.authCubit?.state.userLoginInfoModel.refreshToken;
//     if (refresh?.isEmpty == true) return;

//     try {
//       final res = await service.dio.post(
//         '/refresh',
//         options: Options(headers: {'refreshtoken': refresh}),
//       );
//       final data = jsonDecode(res.data);

//       await service.authCubit?.updateToken(
//         accessToken: data['data']['access_token'],
//         refreshToken: data['data']['refresh_token'],
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static ResponseState<T?> parseError<T>(dynamic e, String tag) {
//     return ResponseState(
//       data: null,
//       isSuccess: false,
//       message: e.toString(),
//       statusCode: e is DioException ? (e.response?.statusCode ?? 0) : 0,
//     );
//   }
// }
