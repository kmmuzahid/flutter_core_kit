/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:41:00
 * @Email: km.muzahid@gmail.com
 */
import 'package:another_flushbar/flushbar.dart';
import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum SnackBarType { success, error, warning, info }

void showSnackBar(String text, {required SnackBarType type}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final context = CoreKit.instance.navigatorKey.currentContext;
    if (context == null) return;

    final (backgroundColor, foregroundColor, iconData) = _getSnackBarTheme(type);

    Flushbar(
      messageText: Text(
        text,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      backgroundColor: backgroundColor,

      flushbarPosition: FlushbarPosition.TOP,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: foregroundColor.withOpacity(0.1),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(foregroundColor),

      leftBarIndicatorColor: foregroundColor,
      icon: Icon(iconData, color: foregroundColor, size: 28),

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      borderRadius: BorderRadius.circular(16),
      boxShadows: [
        BoxShadow(
          color: foregroundColor.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
      
      borderColor: foregroundColor.withOpacity(0.15),
      borderWidth: 1,

      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
    ).show(context);
  });
}
 
(Color, Color, IconData) _getSnackBarTheme(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return (
        const Color(0xFFF0FDF4), // Ultra-light mint
        const Color(0xFF166534), // Forest green
        Icons.check_circle_rounded,
      );

    case SnackBarType.error:
      return (
        const Color(0xFFFEF2F2), // Ultra-light rose
        const Color(0xFF991B1B), // Deep crimson
        Icons.error_rounded,
      );

    case SnackBarType.warning:
      return (
        const Color(0xFFFFFBEB), // Ultra-light amber
        const Color(0xFF92400E), // Deep ochre
        Icons.warning_rounded,
      );

    default: // Info
      return (
        const Color(0xFFEFF6FF), // Ultra-light sky
        const Color(0xFF1E40AF), // Modern blue
        Icons.info_rounded,
      );
  }
}
