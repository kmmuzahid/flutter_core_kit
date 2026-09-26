import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:material_ui/material_ui.dart';

class CkText extends StatelessWidget {
  const CkText({
    required this.text,
    super.key,
    this.maxLines,
    this.textAlign = TextAlign.center,

    /// Responsive left padding applied to the text container via ScreenUtil (`left.w`).
    ///
    /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
    ///   [CkText] embeds responsive padding directly.
    /// - Default: `0`.
    this.left = 0,

    /// Responsive right padding applied to the text container via ScreenUtil (`right.w`).
    ///
    /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
    ///   [CkText] embeds responsive padding directly.
    /// - Default: `0`.
    this.right = 0,

    /// Responsive top padding applied to the text container via ScreenUtil (`top.h`).
    ///
    /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
    ///   [CkText] embeds responsive padding directly.
    /// - Default: `0`.
    this.top = 0,

    /// Responsive bottom padding applied to the text container via ScreenUtil (`bottom.h`).
    ///
    /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
    ///   [CkText] embeds responsive padding directly.
    /// - Default: `0`.
    this.bottom = 0,

    /// Direct convenience shortcut for font size in logical pixels without creating a [TextStyle].
    ///
    /// - Overrides `style?.fontSize`.
    /// - Falls back to `12.0` if both [fontSize] and `style?.fontSize` are `null`.
    this.fontSize,

    /// Direct convenience shortcut for font weight without creating a [TextStyle].
    ///
    /// - Overrides `style?.fontWeight`.
    /// - Falls back to `FontWeight.w400` if both [fontWeight] and `style?.fontWeight` are `null`.
    this.fontWeight,

    /// Direct convenience shortcut for text color without creating a [TextStyle].
    ///
    /// - Overrides `style?.color`.
    /// - In HTML mode, falls back to `effectiveTextStyle.color` or [Colors.black].
    this.textColor,
    this.style,
    this.overflow,

    /// Whether to wrap the text inside a bordered container card.
    ///
    /// - `true`: Renders a decorated [Container] with border, border radius, margin, and padding.
    /// - `false` (Default): Renders the text without an outer border container.
    /// - Note: If [backgroundColor] is provided, container rendering is automatically enabled.
    this.enableBorder = false,

    /// Border color for the surrounding container when [enableBorder] is `true`.
    ///
    /// - Falls back to `Theme.of(context).dividerColor` if `null`.
    this.borderColor,

    /// Uniform border radius in logical pixels (scaled via ScreenUtil `.r`) for the container.
    ///
    /// - Defaults to `4.r` if `null`.
    this.borderRadious,

    /// Background color for the text container.
    ///
    /// - When specified, automatically enables container rendering even if [enableBorder] is `false`.
    /// - Falls back to `coreKitInstance.backgroundColor` when container is active.
    this.backgroundColor,

    /// Alignment for the inner row/content layout.
    this.alignment,

    /// Directional [BorderRadius] for custom corner rounding (e.g., [BorderRadius.only]).
    ///
    /// - Overrides [borderRadious] when provided.
    this.borderRadiusOnly,

    /// A trailing widget (e.g., [Icon], checkmark, or badge) placed immediately after the text.
    ///
    /// - Spaced from the text by [textSpacing].
    /// - Rendered alongside the text in a horizontal [Row].
    this.suffix,

    /// A leading widget (e.g., [Icon], avatar, or badge) placed immediately before the text.
    ///
    /// - Spaced from the text by [textSpacing].
    /// - Rendered alongside the text in a horizontal [Row].
    this.preffix,

    /// Whether to render the text as an unscaled paragraph or description.
    ///
    /// - `true`: Disables auto-shrink fitting ([FittedBox] / adaptive binary scaling) and renders standard text.
    /// - `false` (Default): Uses auto-scaling based on [preventScaling] and [autoResize].
    this.isDescription = false,

    /// Absolute line height in logical pixels.
    ///
    /// - Unlike Flutter's [TextStyle.height] which takes a multiplier, [textHeight] accepts
    ///   pixels and converts it automatically: `(textHeight / effectiveFontSize)`.
    this.textHeight,

    /// Whether to automatically resize the text to fit within available space.
    ///
    /// - `true` (Default): Scales down using [FittedBox] or binary search adaptive sizing to prevent truncation.
    /// - `false`: Uses standard fixed text sizing.
    this.autoResize = true,

    /// Minimum font size threshold in logical pixels when auto-scaling multiline text.
    ///
    /// - Used in adaptive multiline mode when [maxLines] > 1 and [preventScaling] is `false`.
    /// - Default: `10`.
    this.minFontSize = 10,

    /// Maximum font size ceiling in logical pixels when auto-scaling multiline text.
    ///
    /// - Defaults to `style?.fontSize` or `24.0` if `null`.
    this.maxAutoFontSize,

    /// Font size step granularity resolution during binary search in adaptive multiline mode.
    ///
    /// - Default: `0.5`.
    this.stepGranularity = 0.5,
    this.softWrap,

    /// Direct convenience shortcut for text decoration line color without creating a [TextStyle].
    ///
    /// - Corresponds to [TextStyle.decorationColor].
    /// - Overrides `style?.decorationColor`.
    this.decorationColor,

    /// Direct convenience shortcut for text decoration (e.g. underline, line-through) without creating a [TextStyle].
    ///
    /// - Corresponds to [TextStyle.decoration].
    /// - Overrides `style?.decoration`.
    this.decoration,
    this.textDirection,

    /// Direct convenience shortcut for line height multiplier without creating a [TextStyle].
    ///
    /// - Corresponds to [TextStyle.height].
    /// - Overrides `style?.height`.
    this.height,

    /// Horizontal gap spacing in logical pixels between the text and [preffix] or [suffix] widgets.
    ///
    /// - Default: `10`.
    this.textSpacing = 10,

    /// Text scale factor multiplier applied to the text widget.
    ///
    /// - Default: `.9`.
    this.textScaleFactor = .9,

    /// Whether to prevent automatic text scaling down.
    ///
    /// - `true`: Disables [FittedBox] and adaptive multiline sizing, rendering standard unscaled Flutter [Text].
    /// - `false` (Default): Enables auto-scaling down to fit available bounds.
    this.preventScaling = false,

    /// Gradient shader applied across the text glyphs via [ShaderMask].
    ///
    /// - Uses [BlendMode.srcIn] to paint smooth gradient colors onto the text.
    this.gradient,

    /// The number of decimal places to format floating-point numbers found in [text].
    ///
    /// Configurable behaviors:
    /// - `2` (Default): Standard currency/price rounding (e.g., `12.345` -> `12.35`).
    /// - `1`: Precision metrics or ratings (e.g., `4.89` -> `4.9`).
    /// - `0`: Rounds to the nearest integer (e.g., `12.345` -> `12`).
    /// - `null`: Completely disables automatic number formatting (useful for versions like `v1.0.4`, GPS coordinates, or codes).
    this.decimalPlaces = 2,
  });

  /// Responsive left padding applied to the text container via ScreenUtil (`left.w`).
  ///
  /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
  ///   [CkText] embeds responsive padding directly.
  /// - Default: `0`.
  final double left;

  /// Responsive right padding applied to the text container via ScreenUtil (`right.w`).
  ///
  /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
  ///   [CkText] embeds responsive padding directly.
  /// - Default: `0`.
  final double right;

  /// Responsive top padding applied to the text container via ScreenUtil (`top.h`).
  ///
  /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
  ///   [CkText] embeds responsive padding directly.
  /// - Default: `0`.
  final double top;

  /// Responsive bottom padding applied to the text container via ScreenUtil (`bottom.h`).
  ///
  /// - Unlike standard Flutter [Text], which requires an external [Padding] widget,
  ///   [CkText] embeds responsive padding directly.
  /// - Default: `0`.
  final double bottom;

  /// Direct convenience shortcut for font size in logical pixels without creating a [TextStyle].
  ///
  /// - Overrides `style?.fontSize`.
  /// - Falls back to `12.0` if both [fontSize] and `style?.fontSize` are `null`.
  final double? fontSize;

  /// Direct convenience shortcut for font weight without creating a [TextStyle].
  ///
  /// - Overrides `style?.fontWeight`.
  /// - Falls back to `FontWeight.w400` if both [fontWeight] and `style?.fontWeight` are `null`.
  final FontWeight? fontWeight;

  /// Direct convenience shortcut for text color without creating a [TextStyle].
  ///
  /// - Overrides `style?.color`.
  /// - In HTML mode, falls back to `effectiveTextStyle.color` or [Colors.black].
  final Color? textColor;

  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  /// Whether to wrap the text inside a bordered container card.
  ///
  /// - `true`: Renders a decorated [Container] with border, border radius, margin, and padding.
  /// - `false` (Default): Renders the text without an outer border container.
  /// - Note: If [backgroundColor] is provided, container rendering is automatically enabled.
  final bool? enableBorder;

  /// Border color for the surrounding container when [enableBorder] is `true`.
  ///
  /// - Falls back to `Theme.of(context).dividerColor` if `null`.
  final Color? borderColor;

  /// Uniform border radius in logical pixels (scaled via ScreenUtil `.r`) for the container.
  ///
  /// - Defaults to `4.r` if `null`.
  final double? borderRadious;

  /// Directional [BorderRadius] for custom corner rounding (e.g., [BorderRadius.only]).
  ///
  /// - Overrides [borderRadious] when provided.
  final BorderRadius? borderRadiusOnly;

  /// Background color for the text container.
  ///
  /// - When specified, automatically enables container rendering even if [enableBorder] is `false`.
  /// - Falls back to `coreKitInstance.backgroundColor` when container is active.
  final Color? backgroundColor;

  /// Alignment for the inner row/content layout.
  final MainAxisAlignment? alignment;

  /// A trailing widget (e.g., [Icon], checkmark, or badge) placed immediately after the text.
  ///
  /// - Spaced from the text by [textSpacing].
  /// - Rendered alongside the text in a horizontal [Row].
  final Widget? suffix;

  /// A leading widget (e.g., [Icon], avatar, or badge) placed immediately before the text.
  ///
  /// - Spaced from the text by [textSpacing].
  /// - Rendered alongside the text in a horizontal [Row].
  final Widget? preffix;

  /// Whether to render the text as an unscaled paragraph or description.
  ///
  /// - `true`: Disables auto-shrink fitting ([FittedBox] / adaptive binary scaling) and renders standard text.
  /// - `false` (Default): Uses auto-scaling based on [preventScaling] and [autoResize].
  final bool isDescription;

  /// Absolute line height in logical pixels.
  ///
  /// - Unlike Flutter's [TextStyle.height] which takes a multiplier, [textHeight] accepts
  ///   pixels and converts it automatically: `(textHeight / effectiveFontSize)`.
  final double? textHeight;

  /// Whether to automatically resize the text to fit within available space.
  ///
  /// - `true` (Default): Scales down using [FittedBox] or binary search adaptive sizing to prevent truncation.
  /// - `false`: Uses standard fixed text sizing.
  final bool autoResize;

  /// Minimum font size threshold in logical pixels when auto-scaling multiline text.
  ///
  /// - Used in adaptive multiline mode when [maxLines] > 1 and [preventScaling] is `false`.
  /// - Default: `10`.
  final double minFontSize;

  /// Maximum font size ceiling in logical pixels when auto-scaling multiline text.
  ///
  /// - Defaults to `style?.fontSize` or `24.0` if `null`.
  final double? maxAutoFontSize;

  /// Font size step granularity resolution during binary search in adaptive multiline mode.
  ///
  /// - Default: `0.5`.
  final double stepGranularity;

  final bool? softWrap;

  /// Direct convenience shortcut for text decoration line color without creating a [TextStyle].
  ///
  /// - Corresponds to [TextStyle.decorationColor].
  /// - Overrides `style?.decorationColor`.
  final Color? decorationColor;

  /// Direct convenience shortcut for text decoration (e.g. underline, line-through) without creating a [TextStyle].
  ///
  /// - Corresponds to [TextStyle.decoration].
  /// - Overrides `style?.decoration`.
  final TextDecoration? decoration;

  final TextDirection? textDirection;

  /// Direct convenience shortcut for line height multiplier without creating a [TextStyle].
  ///
  /// - Corresponds to [TextStyle.height].
  /// - Overrides `style?.height`.
  final double? height;

  /// Text scale factor multiplier applied to the text widget.
  ///
  /// - Default: `.9`.
  final double textScaleFactor;

  /// Whether to prevent automatic text scaling down.
  ///
  /// - `true`: Disables [FittedBox] and adaptive multiline sizing, rendering standard unscaled Flutter [Text].
  /// - `false` (Default): Enables auto-scaling down to fit available bounds.
  final bool preventScaling;

  /// Gradient shader applied across the text glyphs via [ShaderMask].
  ///
  /// - Uses [BlendMode.srcIn] to paint smooth gradient colors onto the text.
  final Gradient? gradient;

  /// Horizontal gap spacing in logical pixels between the text and [preffix] or [suffix] widgets.
  ///
  /// - Default: `10`.
  final double textSpacing;

  /// The number of decimal places to format floating-point numbers found in [text].
  ///
  /// Configurable behaviors:
  /// - `2` (Default): Standard currency/price rounding (e.g., `12.345` -> `12.35`).
  /// - `1`: Precision metrics or ratings (e.g., `4.89` -> `4.9`).
  /// - `0`: Rounds to the nearest integer (e.g., `12.345` -> `12`).
  /// - `null`: Completely disables automatic number formatting (useful for versions like `v1.0.4`, GPS coordinates, or codes).
  final int? decimalPlaces;

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

  String _formatNumbersInText(String text, int fractionDigits) {
    return text.replaceAllMapped(RegExp(r'\d+\.\d+'), (match) {
      final number = double.tryParse(match.group(0) ?? '0') ?? 0;
      return number.toStringAsFixed(fractionDigits);
    });
  }

  Widget _textField(BuildContext context) {
    final effectiveTextStyle = getStyle();
    final effectiveOverflow = overflow ?? TextOverflow.ellipsis;
    final formattedData = decimalPlaces != null
        ? _formatNumbersInText(text, decimalPlaces!)
        : text;
    final isHtml = _isHtml(text);
    Widget buildText() {
      if (isHtml) {
        final effectiveFontSize = effectiveTextStyle.fontSize ?? 16.0;
        final effectiveColor =
            textColor ?? effectiveTextStyle.color ?? Colors.black;
        final effectiveFontWeight =
            fontWeight ?? effectiveTextStyle.fontWeight ?? FontWeight.w400;
        final effectiveFontFamily = coreKitInstance.fontFamily ?? 'sans-serif';

        return HtmlWidget(
          formattedData,
          textStyle: effectiveTextStyle.copyWith(
            fontFamily: coreKitInstance.fontFamily,
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
            color: effectiveColor,
          ),
          customStylesBuilder: (element) {
            if (element.localName == 'body' || element.localName == 'html') {
              return {
                'margin': '0',
                'padding': '0',
                'font-family': effectiveFontFamily,
                'font-size': '${effectiveFontSize}px',
                'font-weight': '${effectiveFontWeight.value}',
              };
            }
            if (element.localName == 'p') {
              return {'display': 'inline', 'margin': '0', 'padding': '0'};
            }
            if ([
              'h1',
              'h2',
              'h3',
              'h4',
              'h5',
              'h6',
            ].contains(element.localName)) {
              return {
                'display': 'inline',
                'margin': '0',
                'padding': '0',
                'font-weight': 'bold',
              };
            }
            return null;
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
