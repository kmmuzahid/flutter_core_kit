import 'package:core_kit/initializer.dart' show CoreKit;
import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_html/flutter_html.dart';

class CommonText extends StatelessWidget {
  const CommonText({
    required this.text,
    super.key,
    this.maxLines,
    this.textAlign = TextAlign.center,
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.style,
    this.overflow,
    this.enableBorder = false,
    this.borderColor,
    this.borderRadious,
    this.backgroundColor,
    this.alignment,
    this.borderRadiusOnly,
    this.suffix,
    this.preffix,
    this.isDescription = false,
    this.textHeight,
    this.autoResize = true,
    this.minFontSize = 10,
    this.maxAutoFontSize,
    this.stepGranularity = 0.5,
    this.softWrap,
    this.decorationColor,
    this.decoration,
    this.textDirection,
    this.height,
    this.textScaleFactor = .9,
    this.preventScaling = false,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final bool? enableBorder;
  final Color? borderColor;
  final double? borderRadious;
  final BorderRadius? borderRadiusOnly;
  final Color? backgroundColor;
  final MainAxisAlignment? alignment;
  final Widget? suffix;
  final Widget? preffix;
  final bool isDescription;
  final double? textHeight;
  final bool autoResize;
  final double minFontSize;
  final double? maxAutoFontSize;
  final double stepGranularity;
  final bool? softWrap;
  final Color? decorationColor;
  final TextDecoration? decoration;
  final TextDirection? textDirection;
  final double? height;
  final double textScaleFactor;
  final bool preventScaling;

  @override
  Widget build(BuildContext context) {
    return enableBorder == true || backgroundColor != null
        ? _withBorder(context)
        : _withoutBorder(context);
  }

  EdgeInsets _edgeInsetsBuilder() =>
      EdgeInsets.only(left: left.w, right: right.w, top: top.h, bottom: bottom.h);

  Widget _withBorder(BuildContext context) => Container(
    padding: _edgeInsetsBuilder(),
    margin: EdgeInsets.all(5.w),
    decoration: BoxDecoration(
      color: backgroundColor ?? CoreKit.instance.backgroundColor,
      border: Border.all(color: borderColor ?? Theme.of(context).dividerColor, width: 1.2.w),
      borderRadius: BorderRadius.circular(borderRadious?.r ?? 4.r),
    ),
    child: _textField(context),
  );

  Widget _withoutBorder(BuildContext context) =>
      Padding(padding: _edgeInsetsBuilder(), child: _textField(context));

  WrapAlignment _convertAlignment() {
    switch (alignment) {
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.start:
      default:
        return WrapAlignment.start;
    }
  }

  String _formatNumbersInText(String text) {
    // This regex matches decimal numbers with one or more digits before and after the decimal point
    return text.replaceAllMapped(RegExp(r'\d+\.\d+'), (match) {
      final number = double.tryParse(match.group(0) ?? '0') ?? 0;
      // Always format to exactly 2 decimal places for decimal numbers
      return number.toStringAsFixed(2);
    });
  }

  Widget _textField(BuildContext context) {
    final effectiveTextStyle = getStyle();
    final double step = stepGranularity > 0 ? stepGranularity : 1.0;
    final double baseMin = preventScaling
        ? (effectiveTextStyle.fontSize ?? 12.0)
        : (minFontSize > 0 ? minFontSize : 8.0);
    final double baseMax = preventScaling
        ? (effectiveTextStyle.fontSize ?? 24.0)
        : (maxAutoFontSize ?? effectiveTextStyle.fontSize ?? 24.0);

    // Helper functions for quantizing font sizes
    double qFloor(double value, double step) => (value / step).floor() * step;
    double qCeil(double value, double step) => (value / step).ceil() * step;

    final double adjustedMin = qFloor(baseMin, step);
    double adjustedMax = qCeil(baseMax, step);
    if (adjustedMax < adjustedMin) {
      adjustedMax = adjustedMin;
    }

    final effectiveOverflow = overflow ?? TextOverflow.clip;
    final formattedData = _formatNumbersInText(text);

    Widget buildText() {
      // For HTML content
      if (_isHtml(text)) {
        return Html(
          data: formattedData,
          style: {
            'body': Style(
              fontFamily: CoreKit.instance.fontFamily,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              textOverflow: effectiveOverflow,
              textAlign: textAlign,
              fontSize: FontSize(effectiveTextStyle.fontSize ?? 16.0),
              color: textColor,
              fontWeight: fontWeight,
            ),
            'p': Style(
              fontFamily: CoreKit.instance.fontFamily,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              textAlign: textAlign,
              textOverflow: effectiveOverflow,
              fontSize: FontSize(effectiveTextStyle.fontSize ?? 20),
              color: textColor,
              fontWeight: fontWeight,
            ),
            'h1,h2,h3,h4,h5,h6': Style(
              fontFamily: CoreKit.instance.fontFamily,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              textAlign: textAlign,
              textOverflow: effectiveOverflow,
              fontSize: FontSize(effectiveTextStyle.fontSize ?? 25),
              color: textColor,
              fontWeight: fontWeight,
            ),
          },
        );
      }

      if (isDescription) {
        return Text(
          formattedData,
          textAlign: textAlign,
          textDirection: textDirection ?? TextDirection.ltr,
          style: effectiveTextStyle,
        );
      }

      // For multiline text
      if (maxLines != null && maxLines! > 1) {
        if (preventScaling) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Colors.black, Colors.transparent],
                stops: [0.8, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Text(
              formattedData,
              maxLines: maxLines,
              overflow: effectiveOverflow,
              textAlign: textAlign,
              softWrap: softWrap ?? true,
              textDirection: textDirection ?? TextDirection.ltr,
              style: effectiveTextStyle,
            ),
          );
        } else {
          return AutoSizeText(
            formattedData,
            maxLines: maxLines,
            overflow: effectiveOverflow,
            textAlign: textAlign,
            softWrap: softWrap ?? true,
            textDirection: textDirection ?? TextDirection.ltr,
            style: effectiveTextStyle,
            minFontSize: adjustedMin,
            maxFontSize: adjustedMax,
            stepGranularity: step,
            wrapWords: true,
          );
        }
      }

      // For single line text
      if (preventScaling) {
        return Text(
          formattedData,
          maxLines: 1,
          overflow: effectiveOverflow,
          textAlign: textAlign,
          textDirection: textDirection ?? TextDirection.ltr,
          style: effectiveTextStyle,
        );
      } else {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: AutoSizeText(
            formattedData,
            maxLines: 1,
            overflow: effectiveOverflow,
            textAlign: textAlign,
            textDirection: textDirection ?? TextDirection.ltr,
            style: effectiveTextStyle,
            minFontSize: adjustedMin,
            maxFontSize: adjustedMax,
            stepGranularity: step,
            wrapWords: false,
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (preffix != null) preffix!,
        if (preffix != null) 10.width,
        Flexible(child: buildText()),
        if (suffix != null) 10.width,
        if (suffix != null) suffix!,
      ],
    );
  }

  bool _isHtml(String input) {
    final htmlRegex = RegExp(r'<[^>]+>', multiLine: true, caseSensitive: false);
    return htmlRegex.hasMatch(input);
  }

  TextStyle getStyle() {
    final double effectiveFontSize = fontSize ?? style?.fontSize ?? 12.0;

    // Base style — either provided or default to theme.bodyMedium
    TextStyle baseStyle = style ?? const TextStyle();

    // Apply style overrides while keeping fontFamily from theme
    baseStyle = baseStyle.copyWith(
      fontFamily: CoreKit.instance.fontFamily,
      fontSize: effectiveFontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight ?? FontWeight.w400,
      color: textColor ?? baseStyle.color,
      height: height ?? baseStyle.height,
      decoration: decoration ?? baseStyle.decoration,
      decorationColor: decorationColor ?? baseStyle.decorationColor,
    );

    // Optional: recalc line height if textHeight is provided
    final double? fontHeight = textHeight != null
        ? (textHeight! / effectiveFontSize)
        : baseStyle.height;

    return baseStyle.copyWith(height: fontHeight);
  }
}
