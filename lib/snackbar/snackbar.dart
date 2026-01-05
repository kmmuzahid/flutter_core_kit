/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:41:00
 * @Email: km.muzahid@gmail.com
 */
import 'package:another_flushbar/flushbar.dart';
import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum SnackBarType { success, error, warning }

void showSnackBar(String text, {required SnackBarType type}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final context = CoreKit.instance.navigatorKey.currentContext;
    if (context == null) return;

    Flushbar(
      messageText: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: _getSnackBarColor(type),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      boxShadows: const [
        BoxShadow(
          blurRadius: 4,
          color: Colors.black26, // matches SnackBar elevation ≈ 4
        ),
      ],
      animationDuration: const Duration(milliseconds: 250),
    ).show(context);
  });
}

Color _getSnackBarColor(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return CoreKit.instance.primaryColor;
    case SnackBarType.error:
      return Colors.red;
    case SnackBarType.warning:
      return Colors.yellow;
    default:
      return CoreKit.instance.primaryColor;
  }
}
