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
    this.buttonRadius = 8,
    this.alignment = MainAxisAlignment.center,
    this.titleWeight = FontWeight.w600,
    this.buttonHeight = 45,
    this.borderWidth = 1.5,
    this.isLoading = false,
    this.buttonWidth = 80,
    this.borderColor,
    this.prefix,
    this.suffix,
  });
  final VoidCallback? onTap;
  final String titleText;
  final Color? titleColor;
  final Color? buttonColor;
  final Color? borderColor;
  final double borderWidth;
  final double titleSize;
  final FontWeight titleWeight;
  final double buttonRadius;
  final double buttonHeight;
  final double buttonWidth;
  final bool isLoading;
  final Widget? prefix;
  final Widget? suffix;

  final MainAxisAlignment alignment;

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
    final scale = 1 - _animationController.value;

    // Measure the title text to dynamically adjust width
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.titleText,

        // Match CommonText: GoogleFonts.dmSans with scaled size and weight
        style: (CoreKit.instance.defaultTextStyle ?? TextStyle()).copyWith(
          fontFamily: CoreKit.instance.fontFamily,
          fontSize: widget.titleSize.sp,
          fontWeight: widget.titleWeight,
          color: widget.titleColor ?? CoreKit.instance.onPrimaryColor,
        ),
      ),

      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.localeOf(context),
    )..layout();

    // Calculate width based on the content width (text or loader),
    // including horizontal padding and icon width + spacing when applicable.
    final double horizontalPadding = 24.0.w; // from EdgeInsets.symmetric(horizontal: 12.0)
    final double contentWidth = widget.isLoading
        ? textPainter
              .size
              .width // Keep text width for layout consistency
        : textPainter.size.width;

    // Border is painted inside the container; include its stroke on both sides
    final double borderStroke = (widget.borderWidth.w * 2);
    double buttonWidth =
        contentWidth + horizontalPadding + borderStroke + 8.w;
    buttonWidth = buttonWidth < widget.buttonWidth.w ? widget.buttonWidth.w : buttonWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Clamp to available width to avoid overflow from tight parents
        final double maxAllowedWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : buttonWidth;
        final double finalWidth = buttonWidth > maxAllowedWidth ? maxAllowedWidth : buttonWidth;

        return Transform.scale(
          scale: scale,
          child: Stack(
            children: [
              Container(
                width: finalWidth + 3.w, // Clamped width
                height: widget.buttonHeight.h,
                decoration: BoxDecoration(
                  color: widget.buttonColor ?? CoreKit.instance.primaryColor,
                  borderRadius: BorderRadius.circular(widget.buttonRadius.r),
                  border: Border.all(
                    color:
                        widget.borderColor ??
                        widget.buttonColor ??
                        Theme.of(context).scaffoldBackgroundColor,
                    width: widget.borderWidth.w,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.transparency,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(widget.buttonRadius.r),
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 6.0.h),
                        child: 
                            CommonText(
                              text: widget.titleText,
                          preffix: widget.prefix,
                          suffix: widget.suffix,
                          textAlign: widget.alignment == MainAxisAlignment.center
                              ? TextAlign.center
                              : widget.alignment == MainAxisAlignment.start
                              ? TextAlign.start
                              : TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              fontSize: widget.titleSize.sp,
                              textColor: widget.titleColor ?? CoreKit.instance.onPrimaryColor,
                          fontWeight: widget.titleWeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Animated border line
              if (widget.isLoading)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _BorderLoaderPainter(_animation.value, Colors.lightBlueAccent),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BorderLoaderPainter extends CustomPainter {
  _BorderLoaderPainter(this.progress, this.color);
  final double progress; // 0.0 to 1.0
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));

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
