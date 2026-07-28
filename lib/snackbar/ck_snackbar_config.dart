import 'package:flutter/material.dart';

/// Defines the screen position where the [CkSnackBar] is displayed.
enum CkSnackBarPosition { top, bottom }

/// Global configuration for the [CkSnackBar] custom overlay widget.
///
/// Allows configuring styles, borders, shadows, layout metrics,
/// semantic colors, and icons globally.
class CkSnackBarConfig {
  const CkSnackBarConfig({
    this.position,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.margin,
    this.padding,
    this.textStyle,
    this.borderWidthLeft,
    this.borderWidthOthers,
    this.iconSize,
    this.successColor,
    this.errorColor,
    this.warningColor,
    this.infoColor,
    this.successIcon,
    this.errorIcon,
    this.warningIcon,
    this.infoIcon,
  });

  /// The screen position of the snackbar (top or bottom). Defaults to [CkSnackBarPosition.bottom].
  final CkSnackBarPosition? position;

  /// The corner radius for the snackbar container.
  final double? borderRadius;

  /// The fill/background color of the snackbar container.
  final Color? backgroundColor;

  /// Custom shadow effect applied to the snackbar.
  final List<BoxShadow>? boxShadow;

  /// Outer padding/margin surrounding the snackbar.
  final EdgeInsetsGeometry? margin;

  /// Inner padding inside the snackbar borders.
  final EdgeInsetsGeometry? padding;

  /// Text style applied to the snackbar text description.
  final TextStyle? textStyle;

  /// Left-side accent indicator border width.
  final double? borderWidthLeft;

  /// Border width for top, right, and bottom sides.
  final double? borderWidthOthers;

  /// Size of the semantic status icon.
  final double? iconSize;

  /// Color override when type is [CkSnackBarType.success].
  final Color? successColor;

  /// Color override when type is [CkSnackBarType.error].
  final Color? errorColor;

  /// Color override when type is [CkSnackBarType.warning].
  final Color? warningColor;

  /// Color override when type is [CkSnackBarType.info].
  final Color? infoColor;

  /// Icon override when type is [CkSnackBarType.success].
  final IconData? successIcon;

  /// Icon override when type is [CkSnackBarType.error].
  final IconData? errorIcon;

  /// Icon override when type is [CkSnackBarType.warning].
  final IconData? warningIcon;

  /// Icon override when type is [CkSnackBarType.info].
  final IconData? infoIcon;

  CkSnackBarConfig copyWith({
    CkSnackBarPosition? position,
    double? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    double? borderWidthLeft,
    double? borderWidthOthers,
    double? iconSize,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
    IconData? successIcon,
    IconData? errorIcon,
    IconData? warningIcon,
    IconData? infoIcon,
  }) {
    return CkSnackBarConfig(
      position: position ?? this.position,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShadow: boxShadow ?? this.boxShadow,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      borderWidthLeft: borderWidthLeft ?? this.borderWidthLeft,
      borderWidthOthers: borderWidthOthers ?? this.borderWidthOthers,
      iconSize: iconSize ?? this.iconSize,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      successIcon: successIcon ?? this.successIcon,
      errorIcon: errorIcon ?? this.errorIcon,
      warningIcon: warningIcon ?? this.warningIcon,
      infoIcon: infoIcon ?? this.infoIcon,
    );
  }
}
