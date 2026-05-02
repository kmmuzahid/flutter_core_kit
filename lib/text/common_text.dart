import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';
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
    this.textSpacing = 10,
    this.textScaleFactor = .9,
    this.preventScaling = false,
    this.gradient,
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
  final Gradient? gradient;
  final double textSpacing;

  @override
  Widget build(BuildContext context) {
    return enableBorder == true || backgroundColor != null
        ? _withBorder(context)
        : _withoutBorder(context);
  }

  EdgeInsets _edgeInsetsBuilder() => EdgeInsets.only(
    left: left.w,
    right: right.w,
    top: top.h,
    bottom: bottom.h,
  );

  Widget _withBorder(BuildContext context) => Container(
    padding: _edgeInsetsBuilder(),
    margin: EdgeInsets.all(5.w),
    decoration: BoxDecoration(
      color: backgroundColor ?? coreKitInstance.backgroundColor,
      border: Border.all(
        color: borderColor ?? Theme.of(context).dividerColor,
        width: 1.2.w,
      ),
      borderRadius: BorderRadius.circular(borderRadious?.r ?? 4.r),
    ),
    child: _textField(context),
  );

  Widget _withoutBorder(BuildContext context) =>
      Padding(padding: _edgeInsetsBuilder(), child: _textField(context));

  String _formatNumbersInText(String text) {
    return text.replaceAllMapped(RegExp(r'\d+\.\d+'), (match) {
      final number = double.tryParse(match.group(0) ?? '0') ?? 0;
      return number.toStringAsFixed(2);
    });
  }

  Widget _textField(BuildContext context) {
    final effectiveTextStyle = getStyle();
    final effectiveOverflow = overflow ?? TextOverflow.ellipsis;
    final formattedData = _formatNumbersInText(text);
    final isHtml = _isHtml(text);
    if (isHtml) {
      return Html(
        data: formattedData,
        style: {
          'body': Style(
            fontFamily: coreKitInstance.fontFamily,
            maxLines: isDescription ? null : maxLines,
            textOverflow: isDescription ? null : effectiveOverflow,
            textAlign: textAlign,
            fontSize: FontSize(effectiveTextStyle.fontSize ?? 16.0),
            color: textColor,
            fontWeight: fontWeight,
          ),
          'p': Style(
            fontFamily: coreKitInstance.fontFamily,
            maxLines: isDescription ? null : maxLines,
            textOverflow: isDescription ? null : effectiveOverflow,
            textAlign: textAlign,
            fontSize: FontSize(effectiveTextStyle.fontSize ?? 20),
            color: textColor,
            fontWeight: fontWeight,
          ),
          'h1,h2,h3,h4,h5,h6': Style(
            fontFamily: coreKitInstance.fontFamily,
            maxLines: isDescription ? null : maxLines,
            textOverflow: isDescription ? null : effectiveOverflow,
            textAlign: textAlign,
            fontSize: FontSize(effectiveTextStyle.fontSize ?? 25),
            color: textColor,
            fontWeight: fontWeight,
          ),
        },
      );
    }

    Widget buildText() {
      // For HTML content

      // For description text - no resizing
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
          return Text(
            formattedData,
            maxLines: maxLines,
            overflow: effectiveOverflow,
            textAlign: textAlign,
            softWrap: softWrap ?? true,
            textDirection: textDirection ?? TextDirection.ltr,
            style: effectiveTextStyle,
          );
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              return _AdaptiveText(
                text: formattedData,
                style: effectiveTextStyle,
                maxLines: maxLines!,
                textAlign: textAlign,
                overflow: effectiveOverflow,
                softWrap: softWrap ?? true,
                textDirection: textDirection ?? TextDirection.ltr,
                minFontSize: minFontSize,
                maxFontSize:
                    maxAutoFontSize ?? effectiveTextStyle.fontSize ?? 24.0,
                availableWidth: constraints.maxWidth,
              );
            },
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
          alignment: _getAlignment(),
          child: Text(
            formattedData,
            maxLines: 1,
            overflow: TextOverflow.visible,
            textAlign: textAlign,
            textDirection: textDirection ?? TextDirection.ltr,
            style: effectiveTextStyle,
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?preffix,
        if (preffix != null) textSpacing.width,
        Flexible(
          child: gradient != null
              ? ShaderMask(
                  shaderCallback: (bounds) => gradient!.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  blendMode: BlendMode.srcIn,
                  child: buildText(),
                )
              : buildText(),
        ),
        if (suffix != null) textSpacing.width,
        ?suffix,
      ],
    );
  }

  Alignment _getAlignment() {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
      default:
        return Alignment.center;
    }
  }

  bool _isHtml(String input) {
    final htmlRegex = RegExp(r'<[^>]+>', multiLine: true, caseSensitive: false);
    return htmlRegex.hasMatch(input);
  }

  TextStyle getStyle() {
    final effectiveFontSize = fontSize ?? style?.fontSize ?? 12.0;

    var baseStyle = style ?? const TextStyle();

    baseStyle = baseStyle.copyWith(
      fontFamily: coreKitInstance.fontFamily,
      fontSize: effectiveFontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight ?? FontWeight.w400,
      color: textColor ?? baseStyle.color,
      height: height ?? baseStyle.height,
      decoration: decoration ?? baseStyle.decoration,
      decorationColor: decorationColor ?? baseStyle.decorationColor,
    );

    final fontHeight = textHeight != null
        ? (textHeight! / effectiveFontSize)
        : baseStyle.height;

    return baseStyle.copyWith(height: fontHeight);
  }
}

class _AdaptiveText extends StatelessWidget {
  const _AdaptiveText({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.textAlign,
    required this.overflow,
    required this.softWrap,
    required this.textDirection,
    required this.minFontSize,
    required this.maxFontSize,
    required this.availableWidth,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final bool softWrap;
  final TextDirection textDirection;
  final double minFontSize;
  final double maxFontSize;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    if (availableWidth == double.infinity || availableWidth <= 0) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
        softWrap: softWrap,
        textDirection: textDirection,
      );
    }

    var fontSize = maxFontSize;

    // Binary search for optimal font size
    var low = minFontSize;
    var high = maxFontSize;

    while (high - low > 0.5) {
      final mid = (low + high) / 2;
      final testStyle = style.copyWith(fontSize: mid);

      final span = TextSpan(text: text, style: testStyle);
      final tp = TextPainter(
        text: span,
        maxLines: maxLines,
        textAlign: textAlign,
        textDirection: textDirection,
      );

      tp.layout(maxWidth: availableWidth);

      if (tp.didExceedMaxLines || tp.width > availableWidth) {
        high = mid;
      } else {
        low = mid;
        fontSize = mid;
      }
    }

    return Text(
      text,
      style: style.copyWith(fontSize: fontSize),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }
}
