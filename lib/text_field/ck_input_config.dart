import 'package:material_ui/material_ui.dart';

/// Global design configuration shared by [CkTextField] and [CkMultilineTextField].
///
/// All parameters are optional. When a parameter is null the individual widget
/// falls back to its own default or the active [ThemeData].
class CkInputConfig {
  const CkInputConfig({
    this.hintStyle,
    this.textStyle,
    this.fontSize,
    this.textAlign,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 1.2,
    this.backgroundColor,
    this.enableCapitalization,
  });

  /// Style applied to hint text across all text fields.
  final TextStyle? hintStyle;

  /// Base text style for user input across all text fields.
  final TextStyle? textStyle;

  /// Font size for user input. Overridden per widget if the widget
  /// specifies its own [fontSize].
  final double? fontSize;

  /// Horizontal alignment of the input text.
  final TextAlign? textAlign;

  /// Border/outline colour when the field is not focused or in error.
  final Color? borderColor;

  /// Corner radius of the input border.
  final double? borderRadius;

  /// Width of the input border stroke. Defaults to 1.2.
  /// Used as the global default; widgets can override per-instance via their own borderWidth.
  final double borderWidth;

  /// Fill/background colour of the text field.
  final Color? backgroundColor;

  /// Whether to auto-capitalise the first letter of sentences.
  /// Set to `false` to disable sentence capitalisation globally.
  final bool? enableCapitalization;

  CkInputConfig copyWith({
    TextStyle? hintStyle,
    TextStyle? textStyle,
    double? fontSize,
    TextAlign? textAlign,
    Color? borderColor,
    double? borderRadius,
    double? borderWidth,
    Color? backgroundColor,
    bool? enableCapitalization,
  }) {
    return CkInputConfig(
      hintStyle: hintStyle ?? this.hintStyle,
      textStyle: textStyle ?? this.textStyle,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      enableCapitalization: enableCapitalization ?? this.enableCapitalization,
    );
  }
}
