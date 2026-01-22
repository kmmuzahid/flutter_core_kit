/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 16:41:00
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

void showSnackBar(
  String text, {
  required SnackBarType type,
  Duration? customDuration,
}) {
  final navigator = CoreKit.instance.scaffoldMessangerKey.currentState;
    if (navigator == null) return;

    final context = navigator.context; 

    // 1. Extract Global Theme Properties
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snackBarTheme = theme.snackBarTheme;
    
    // 2. Map semantic colors from the ColorScheme
    final (accentColor, iconData) = _getSemanticColors(type, colorScheme);

    // Dynamic duration logic
    final int calculatedMs = 2000 + (text.length * 25);
    final Duration displayDuration = customDuration ?? Duration(milliseconds: calculatedMs);

    final snackBar = SnackBar(
    dismissDirection: DismissDirection.vertical,
    behavior: SnackBarBehavior.floating,
    content: Container(
      padding:
          snackBarTheme.insetPadding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accentColor, width: 10),
          right: BorderSide(color: accentColor, width: 1),
          top: BorderSide(color: accentColor, width: 1),
          bottom: BorderSide(color: accentColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(iconData, color: accentColor, size: 24),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style:
                  theme.snackBarTheme.contentTextStyle ??
                  TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
      ),
      backgroundColor: snackBarTheme.backgroundColor ?? colorScheme.surface,
    padding: EdgeInsets.zero,
      margin: snackBarTheme.insetPadding ?? const EdgeInsets.all(16),
      shape: snackBarTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      
      duration: displayDuration,
    );
  CoreKit.instance.scaffoldMessangerKey.currentState?.showSnackBar(snackBar); 

}

/// Extracts semantic colors strictly from the App's ColorScheme
(Color, IconData) _getSemanticColors(SnackBarType type, ColorScheme colorScheme) {
  switch (type) {
    case SnackBarType.success:
      // In Material 3, Success is usually handled by a custom 'tertiary' or a 'primary' shade
      // If you haven't defined a success color, emerald is the professional standard.
      return (const Color(0xFF10B981), Icons.check_circle_outline_rounded);
      
    case SnackBarType.error:
      // Standard Material Error color
      return (colorScheme.error, Icons.error_outline_rounded);
      
    case SnackBarType.warning:
      // 'outlineVariant' or 'tertiary' is often used for warnings in clean designs
      return (colorScheme.tertiary, Icons.info_outline_rounded);

    case SnackBarType.info:
    default:
      // Standard brand Primary color
      return (colorScheme.primary, Icons.info_outline_rounded);
  }
}
