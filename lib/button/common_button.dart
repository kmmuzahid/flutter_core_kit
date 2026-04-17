import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  const CommonButton({
    required this.titleText,
    super.key,
    this.onTap,
    this.titleColor,
    this.buttonColor,
    this.titleSize,
    this.buttonRadius,
    this.alignment = MainAxisAlignment.center,
    this.titleWeight,
    this.buttonHeight,
    this.borderWidth,
    this.isLoading = false,
    this.buttonWidth,
    this.borderColor,
    this.prefix,
    this.suffix,
    this.elevation,
    this.gradient,
    this.padding,
    this.titleGradient,
    this.titleSpacing = 10,
  });
  final VoidCallback? onTap;
  final String titleText;
  final Color? titleColor;
  final Color? buttonColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? titleSize;
  final FontWeight? titleWeight;
  final double? buttonRadius;
  final double? buttonHeight;
  final double? buttonWidth;
  final bool isLoading;
  final Widget? prefix;
  final Widget? suffix;
  final MainAxisAlignment alignment;
  final double? elevation;
  final Gradient? gradient;
  final Gradient? titleGradient;
  final EdgeInsetsGeometry? padding;
  final double titleSpacing;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(CommonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  EdgeInsets toEdgeInsets(BuildContext context, EdgeInsetsGeometry padding) {
    return padding.resolve(Directionality.of(context));
  }

@override
  Widget build(BuildContext context) {
    final elevatedButtonTheme = Theme.of(context).elevatedButtonTheme;

    // Extract theme values
    final themeShape = elevatedButtonTheme.style?.shape?.resolve({});
    final resolvedShape = themeShape is RoundedRectangleBorder ? themeShape : null;

    final themeBorderRadius = resolvedShape?.borderRadius.resolve(TextDirection.ltr).topLeft.x;

    final themeBorderWidth = resolvedShape?.side.width;
    final themeBorderColor = resolvedShape?.side.color;

    final themeMinSize = elevatedButtonTheme.style?.minimumSize?.resolve({});
    final themePadding = elevatedButtonTheme.style?.padding?.resolve({});

    final themeBackgroundColor = elevatedButtonTheme.style?.backgroundColor?.resolve({});

    final titleColor = elevatedButtonTheme.style?.textStyle?.resolve({})?.color;

    final themeDisabledBackgroundColor = elevatedButtonTheme.style?.backgroundColor?.resolve({
      WidgetState.disabled,
    });

    final themeDisabledForegroundColor = elevatedButtonTheme.style?.foregroundColor?.resolve({
      WidgetState.disabled,
    });

    final themeElevation = elevatedButtonTheme.style?.elevation?.resolve({});

    final themeTextStyle = elevatedButtonTheme.style?.textStyle?.resolve({});

    // Resolve final values
    final borderRadius = widget.buttonRadius?.r ?? themeBorderRadius ?? 8.0;

    final borderWidth = widget.borderWidth?.w ?? themeBorderWidth ?? 1.5;

    final borderColor = widget.borderColor ?? themeBorderColor ?? Colors.transparent;

    final minHeight = widget.buttonHeight?.h ?? themeMinSize?.height ?? 48.0;

    final backgroundColor =
        widget.buttonColor ?? themeBackgroundColor ?? coreKitInstance.primaryColor;

    final foregroundColor =
      widget.titleColor ?? titleColor ?? coreKitInstance.onPrimaryColor;

    final loaderColor =
        elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? coreKitInstance.secondaryColor;

    final disabledBackgroundColor =
        widget.buttonColor ?? themeDisabledBackgroundColor ?? backgroundColor;

    final disabledForegroundColor =
        widget.titleColor ?? themeDisabledForegroundColor ?? foregroundColor;

    final buttonElevation = widget.elevation ?? themeElevation ?? 2.0;

    final padding = toEdgeInsets(
      context,
      widget.padding ?? themePadding ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.maxWidth.isFinite;
        final maxAvailableWidth = hasBoundedWidth ? constraints.maxWidth : 0.0;

        final textStyle = (themeTextStyle ?? const TextStyle()).copyWith(
          fontFamily: coreKitInstance.fontFamily,
          fontSize: fontSize(elevatedButtonTheme),
          fontWeight: widget.titleWeight ?? themeTextStyle?.fontWeight ?? FontWeight.w600,
        );

        final minRequiredWidth = _measureMinWidth(
          context: context,
          textStyle: textStyle,
          padding: padding,
        );

        // FIX START
        final themeMinWidthRaw = themeMinSize?.width;
        final isThemeFullWidth = themeMinWidthRaw == double.infinity;

        final themeMinWidth = isThemeFullWidth ? 0.0 : (themeMinWidthRaw ?? 88.0);
        // FIX END

        final requestedWidth = widget.buttonWidth ?? double.nan;

        double? calculatedWidth;

        // CASE 1: buttonWidth == infinity
        if (requestedWidth == double.infinity) {
          calculatedWidth = hasBoundedWidth ? maxAvailableWidth : null;
        }

        // CASE 2: explicit width
        else if (!requestedWidth.isNaN) {
          if (requestedWidth == double.infinity) {
            calculatedWidth = hasBoundedWidth ? maxAvailableWidth : null;
          } else if (hasBoundedWidth) {
            calculatedWidth = requestedWidth.clamp(minRequiredWidth, maxAvailableWidth);
          } else {
            calculatedWidth = requestedWidth;
          }
        }

        // CASE 3: auto
        else {
          if (hasBoundedWidth) {
            if (isThemeFullWidth) {
              calculatedWidth = maxAvailableWidth;
            } else {
            calculatedWidth = minRequiredWidth.clamp(
              themeMinWidth,
              maxAvailableWidth,
            );
            }
          } else {
            calculatedWidth = isThemeFullWidth ? null : minRequiredWidth;
          }
        }

        return SizedBox(
          width: calculatedWidth,
          height: minHeight,
          child: _buildButton(
            textStyle: textStyle,
            elevatedButtonThemeData: elevatedButtonTheme,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledForegroundColor: disabledForegroundColor,
            borderRadius: borderRadius,
            borderColor: borderColor,
            loaderColor: loaderColor,
            borderWidth: borderWidth,
            buttonElevation: buttonElevation,
            padding: padding,
          ),
        );
      },
    );
  }

double fontSize(ElevatedButtonThemeData elevatedButtonTheme) {
    final themeTextStyle = elevatedButtonTheme.style?.textStyle?.resolve({});
    return widget.titleSize?.sp ?? themeTextStyle?.fontSize?.sp ?? 16.sp;
  }

  Widget _buildButton({
    required TextStyle textStyle,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color disabledBackgroundColor,
    required Color disabledForegroundColor,
    required double borderRadius,
    required Color loaderColor,
    required Color borderColor,
    required double borderWidth,
    required double buttonElevation,
    required EdgeInsets padding,
    required ElevatedButtonThemeData elevatedButtonThemeData,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onTap,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? disabledBackgroundColor
                    : backgroundColor,
              ),

              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? disabledForegroundColor
                    : foregroundColor,
              ),
              textStyle: WidgetStateProperty.all(textStyle),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  side: BorderSide(color: borderColor, width: borderWidth),
                ),
              ),
              padding: WidgetStateProperty.all(padding),
              elevation: WidgetStateProperty.all(buttonElevation),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              backgroundBuilder: (context, state, child) {
                if (widget.buttonColor != null || widget.gradient != null) {
                  return Container(
                    decoration: BoxDecoration(
                      // Use null for color when gradient is provided,
                      // since BoxDecoration does not allow both simultaneously.
                      color: widget.gradient != null ? null : widget.buttonColor,
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    child: child,
                  );
                }

                return coreKitInstance
                        .theme
                        .elevatedButtonTheme
                        .style
                        ?.backgroundBuilder
                        ?.call(context, state, child) ??
                    child ??
                    const SizedBox.shrink();
              },
            ),
            child: CommonText(
              text: widget.titleText,
              textSpacing: widget.titleSpacing,
              preffix: widget.prefix,
              suffix: widget.suffix,
              gradient: widget.titleGradient,
              maxLines: 1,
              overflow: TextOverflow.visible,
              fontSize: fontSize(elevatedButtonThemeData),
              textColor: foregroundColor,
              fontWeight: textStyle.fontWeight,
            ),
          ),
        ),

        if (widget.isLoading)
          Positioned.fill(
            child: Positioned(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (_, _) => CustomPaint(
                    painter: _BorderLoaderPainter(
                      _animation.value,
                      loaderColor,
                      borderRadius,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _measureMinWidth({
    required BuildContext context,
    required TextStyle textStyle,
    required EdgeInsets padding,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.titleText, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final prefixWidth = widget.prefix != null ? 24.0 : 0.0;
    final suffixWidth = widget.suffix != null ? 24.0 : 0.0;

    return textPainter.width +
        prefixWidth +
        suffixWidth +
        padding.left +
        padding.right;
  }
}

class _BorderLoaderPainter extends CustomPainter {
  _BorderLoaderPainter(this.progress, this.color, this.radius);
  final double progress;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 50.0;
    const dashSpace = 1.0;
    const totalLength = (dashWidth + dashSpace);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      var distance = progress * metric.length;

      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += totalLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
