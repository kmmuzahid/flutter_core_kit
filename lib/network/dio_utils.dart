/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:39:26
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/network/ck_transport_config.dart';
import 'package:core_kit/snackbar/ck_snackbar.dart';
import 'package:core_kit/utils/ck_logger.dart';

class DioUtils {
  static void log(
    CkTransportConfig config,
    String message, {
    String? tag,
    bool isError = false,
  }) {
    if (!config.enableDebugLogs) return;

    if (isError) {
      CkLogger.apiError(message, tag: tag);
    } else {
      CkLogger.apiDebug(message, tag: tag);
    }
  }

  static void showMessage(String message, {bool isError = false}) {
    if (isError) {
      CkSnackBar(message, type: CkSnackBarType.error);
    } else {
      CkSnackBar(message, type: CkSnackBarType.success);
    }
  }
}
