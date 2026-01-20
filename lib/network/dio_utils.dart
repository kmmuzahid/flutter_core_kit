/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:39:26
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/snackbar/snackbar.dart';
import 'package:core_kit/utils/app_log.dart';

import 'dio_service.dart';

class DioUtils {
  
  static void log(DioServiceConfig config, String message, {String? tag, bool isError = false}) {
    if (!config.enableDebugLogs) return;

    if (isError) {
      AppLogger.apiError(message, tag: tag);
    } else {
      AppLogger.apiDebug(message, tag: tag);
    }
  }

  static void showMessage(String message, {bool isError = false}) {
    if (isError) {
      showSnackBar(message, type: SnackBarType.error);
    } else {
      showSnackBar(message, type: SnackBarType.success);
    }
  }

}
