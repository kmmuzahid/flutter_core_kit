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

void showSnackBar(
  String text, {
  required SnackBarType type,
  Duration? customDuration, // Added option for manual control
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final navigator = CoreKit.instance.navigatorKey.currentState;
    if (navigator == null) return;

    // 2. Use the overlay context so it stays visible during pushes/pops
    final context = navigator.overlay?.context;
    if (context == null) return;

    final (backgroundColor, foregroundColor, iconData) = _getSnackBarTheme(type);

    // SMART LOGIC: Auto-calculate duration based on text length
    // Base 3 seconds + 1 second for every 20 characters
    final int calculatedSeconds = 3 + (text.length ~/ 60);
    final Duration displayDuration = customDuration ?? Duration(seconds: calculatedSeconds);

    Flushbar(
      messageText: Text(
        text,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.BOTTOM,
      
      // Progress Indicator helps users see how much time is left
      // showProgressIndicator: true,
      progressIndicatorBackgroundColor: foregroundColor.withOpacity(0.1),
      // progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
      
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

      // --- Time Settings ---
      duration: displayDuration,
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
    ).show(context);
  });
}

(Color, Color, IconData) _getSnackBarTheme(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return (const Color(0xFFF0FDF4), const Color(0xFF166534), Icons.check_circle_rounded);
    case SnackBarType.error:
      return (const Color(0xFFFEF2F2), const Color(0xFF991B1B), Icons.error_rounded);
    case SnackBarType.warning:
      return (const Color(0xFFFFFBEB), const Color(0xFF92400E), Icons.warning_rounded);
    default:
      return (const Color(0xFFEFF6FF), const Color(0xFF1E40AF), Icons.info_rounded);
  }
}
