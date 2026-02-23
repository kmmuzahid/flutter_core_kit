

import 'package:core_kit/initializer.dart';
import 'package:flutter/material.dart';

import '../text/common_text.dart';
import '../utils/core_screen_utils.dart';

class CommonButton extends StatefulWidget {
  const CommonButton({
    required this.titleText,
    super.key,
    this.onTap,
    this.titleColor,
    this.buttonColor,
    this.titleSize = 16,
    this.buttonRadius,
    this.alignment = MainAxisAlignment.center,
    this.titleWeight = FontWeight.w600,
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
  });
  final VoidCallback? onTap;
  final String titleText;
  final Color? titleColor;
  final Color? buttonColor;
  final Color? borderColor;
  final double? borderWidth;
  final double titleSize;
  final FontWeight titleWeight;
  final double? buttonRadius;
  final double? buttonHeight;
  final double? buttonWidth;
  final bool isLoading;
  final Widget? prefix;
  final Widget? suffix;
  final MainAxisAlignment alignment;
  final double? elevation;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));

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

    // Resolve final values: widget param > theme > default
    final borderRadius = widget.buttonRadius?.r ?? themeBorderRadius ?? 8.0;
    final borderWidth = widget.borderWidth?.w ?? themeBorderWidth ?? 1.5;
    final borderColor = widget.borderColor ?? themeBorderColor ?? Colors.transparent;
    final minHeight = widget.buttonHeight?.h ?? themeMinSize?.height ?? 48.0;
    final horizontalPadding = themePadding?.horizontal ?? widget.padding?.horizontal ?? 24.0;
    final verticalPadding = themePadding?.vertical ?? widget.padding?.vertical ?? 12.0;
    final backgroundColor =
        widget.buttonColor ?? themeBackgroundColor ?? CoreKit.instance.primaryColor;
    final foregroundColor = widget.titleColor ?? titleColor ?? CoreKit.instance.onPrimaryColor;
    final loaderColor =
        elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? CoreKit.instance.secondaryColor;
    final disabledBackgroundColor =
        widget.buttonColor ?? themeDisabledBackgroundColor ?? backgroundColor;
    final disabledForegroundColor =
        widget.titleColor ?? themeDisabledForegroundColor ?? foregroundColor;
    final buttonElevation = widget.elevation ?? themeElevation ?? 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasBoundedWidth = constraints.maxWidth.isFinite;
        final double maxAvailableWidth = hasBoundedWidth ? constraints.maxWidth : 0;

        final textStyle = (themeTextStyle ?? const TextStyle()).copyWith(
          fontFamily: CoreKit.instance.fontFamily,
          fontSize: widget.titleSize.sp,
          fontWeight: widget.titleWeight,
        );

        final double minRequiredWidth = _measureMinWidth(
          context: context,
          textStyle: textStyle,
          horizontalPadding: horizontalPadding,
        );

        final double themeMinWidth = themeMinSize?.width ?? 88.0;
        final double requestedWidth = widget.buttonWidth ?? double.nan;

        double? calculatedWidth;

        // CASE 1: buttonWidth == double.infinity
        if (requestedWidth == double.infinity) {
          calculatedWidth = hasBoundedWidth ? maxAvailableWidth : null;
        }
        // CASE 2: explicit width provided
        else if (!requestedWidth.isNaN) {
          if (hasBoundedWidth) {
            calculatedWidth = requestedWidth.clamp(minRequiredWidth, maxAvailableWidth);
          } else {
            calculatedWidth = requestedWidth;
          }
        }
        // CASE 3: auto size
        else {
          if (hasBoundedWidth) {
            calculatedWidth = minRequiredWidth.clamp(themeMinWidth, maxAvailableWidth);
          } else {
            calculatedWidth = minRequiredWidth;
          }
        }

        return SizedBox(
          width: calculatedWidth, // may be null — this is correct
          height: minHeight,
          child: _buildButton(
            textStyle: textStyle,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledForegroundColor: disabledForegroundColor,
            borderRadius: borderRadius,
            borderColor: borderColor,
            loaderColor: loaderColor,
            borderWidth: borderWidth,
            buttonElevation: buttonElevation,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
          ),
        );
      },
    );

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
    required double horizontalPadding,
    required double verticalPadding,
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
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              ),
              elevation: WidgetStateProperty.all(buttonElevation),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              backgroundBuilder: (context, state, child) {
                if (widget.gradient != null) {
                  return Container(
                  decoration: BoxDecoration(gradient: widget.gradient),
                  child: child,
                );
                }
                return CoreKit.instance.theme.elevatedButtonTheme.style?.backgroundBuilder?.call(
                      context,
                      state,
                      child,
                    ) ??
                    child ??
                    SizedBox.shrink();
                
              },
            ),
            child: CommonText(
              text: widget.titleText,
              preffix: widget.prefix,
              suffix: widget.suffix,
              maxLines: 1,
              overflow: TextOverflow.visible,
              fontSize: widget.titleSize.sp,
              textColor: foregroundColor,
              fontWeight: widget.titleWeight,
            ),
          ),
        ),

        if (widget.isLoading)
          Positioned.fill(
            child: Positioned(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (_, __) => CustomPaint(
                    painter: _BorderLoaderPainter(_animation.value, loaderColor, borderRadius),
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
    required double horizontalPadding,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.titleText, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final prefixWidth = widget.prefix != null ? 24.0 : 0.0;
    final suffixWidth = widget.suffix != null ? 24.0 : 0.0;

    return textPainter.width + prefixWidth + suffixWidth + horizontalPadding * 2;
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
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 50.0;
    final dashSpace = 1.0;
    final totalLength = (dashWidth + dashSpace);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = progress * metric.length;

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
