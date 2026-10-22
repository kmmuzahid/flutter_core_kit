import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Defines how the loading indicator is displayed when a share action is in progress.
enum CkShareLoaderStyle {
  /// Automatically traces and animates along the outer edge of the child.
  /// Seamlessly adapts to circles, icons, and rounded rectangles.
  adaptiveEdge,

  /// Temporarily replaces the child with a progress indicator while loading.
  replace,

  /// Overlays a semi-transparent layer with a progress indicator over the child.
  overlay,
}

/// A fully adaptive share button and builder widget that provides immediate visual
/// feedback while downloading network/CDN images and presenting the native share sheet.
///
/// Supports two usage modes:
/// 1. **Direct Child Mode**: Wrap any widget (Icon, CircleAvatar, custom Button).
///    Automatically manages tap events and animates a loader along its edge or overlay.
/// 2. **Builder Mode**: Uses `builder: (context, share, isLoading)` for complete custom UI control.
///
/// Example with an Icon or circular button:
/// ```dart
/// CkShareButton(
///   title: 'Explore this post',
///   imageUrl: 'https://cdn.example.com/photo.jpg',
///   deepLinkUrl: 'https://myapp.com/post/123',
///   child: const Icon(Icons.share),
/// )
/// ```
///
/// Example with a rounded rectangle button:
/// ```dart
/// CkShareButton(
///   title: 'Explore this post',
///   imageUrl: 'https://cdn.example.com/photo.jpg',
///   deepLinkUrl: 'https://myapp.com/post/123',
///   borderRadius: BorderRadius.circular(12),
///   child: Container(
///     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
///     decoration: BoxDecoration(
///       color: Colors.blue,
///       borderRadius: BorderRadius.circular(12),
///     ),
///     child: const Text('Share Post', style: TextStyle(color: Colors.white)),
///   ),
/// )
/// ```
class CkShareButton extends StatefulWidget {
  const CkShareButton({
    super.key,
    required this.title,
    required this.deepLinkUrl,
    this.imageUrl,
    this.byteImage,
    this.child,
    this.builder,
    this.loaderStyle = CkShareLoaderStyle.adaptiveEdge,
    this.shape,
    this.borderRadius,
    this.strokeWidth = 2.5,
    this.strokeLengthFactor = 0.3,
    this.loaderColor,
    this.trackColor,
    this.paddingOffset = 0.0,
    this.animationDuration = const Duration(milliseconds: 1100),
    this.customLoader,
    this.onTap,
    this.onShareStart,
    this.onShareReady,
    this.onShareSuccess,
    this.onShareError,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided to CkShareButton.',
       ),
       assert(
         imageUrl != null || byteImage != null,
         'Either imageUrl or byteImage must be provided to CkShareButton.',
       );

  /// Convenient constructor for builder mode.
  const CkShareButton.builder({
    super.key,
    required this.title,
    required this.deepLinkUrl,
    required this.builder,
    this.imageUrl,
    this.byteImage,
    this.onShareStart,
    this.onShareReady,
    this.onShareSuccess,
    this.onShareError,
  }) : child = null,
       loaderStyle = CkShareLoaderStyle.adaptiveEdge,
       shape = null,
       borderRadius = null,
       strokeWidth = 2.5,
       strokeLengthFactor = 0.3,
       loaderColor = null,
       trackColor = null,
       paddingOffset = 0.0,
       animationDuration = const Duration(milliseconds: 1100),
       customLoader = null,
       onTap = null,
       assert(
         imageUrl != null || byteImage != null,
         'Either imageUrl or byteImage must be provided to CkShareButton.',
       );

  /// Title / subject to be shared.
  final String title;

  /// Deep link URL appended to the shared message.
  final String deepLinkUrl;

  /// Network or CDN image URL to fetch and share.
  final String? imageUrl;

  /// Raw byte image data to share instead of network URL.
  final ByteData? byteImage;

  /// The child widget (e.g. Icon, CircleAvatar, Container, Button).
  final Widget? child;

  /// Builder for full custom UI control: `(context, share, isLoading)`.
  final Widget Function(
    BuildContext context,
    Future<void> Function() share,
    bool isLoading,
  )? builder;

  /// How the loader is rendered during network image download.
  final CkShareLoaderStyle loaderStyle;

  /// Explicit shape override (`BoxShape.circle` or `BoxShape.rectangle`).
  /// If null, automatically infers circle if width == height.
  final BoxShape? shape;

  /// Border radius for rounded rectangular children.
  /// If null and rectangular, defaults to `BorderRadius.circular(8.0)`.
  final BorderRadius? borderRadius;

  /// Thickness of the animated edge stroke.
  final double strokeWidth;

  /// Proportion of the perimeter occupied by the traveling beam (0.1 to 0.8).
  final double strokeLengthFactor;

  /// Color of the active loader or traveling stroke. Defaults to theme primary color.
  final Color? loaderColor;

  /// Background track color underneath the traveling stroke.
  final Color? trackColor;

  /// Outward or inward offset from the child's bounds.
  /// Positive values expand outward (like a halo); negative values inset inward.
  final double paddingOffset;

  /// Duration for one complete 360° perimeter loop.
  final Duration animationDuration;

  /// Custom loader widget for `replace` or `overlay` styles.
  final Widget? customLoader;

  /// Called when the widget is tapped before the share process begins.
  final VoidCallback? onTap;

  /// Called when image download and share processing starts.
  final VoidCallback? onShareStart;

  /// Called when the native share dialog/bottomsheet is presented by the OS.
  final VoidCallback? onShareReady;

  /// Called when the share sheet has been presented / completed.
  final VoidCallback? onShareSuccess;

  /// Called if an error occurs during downloading or sharing.
  final void Function(Object error)? onShareError;

  @override
  State<CkShareButton> createState() => _CkShareButtonState();
}

class _CkShareButtonState extends State<CkShareButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void didUpdateWidget(covariant CkShareButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    if (_isLoading) return;

    widget.onTap?.call();
    widget.onShareStart?.call();

    setState(() {
      _isLoading = true;
    });
    _controller.repeat();

    void stopLoading() {
      if (mounted && _isLoading) {
        _controller.stop();
        _controller.reset();
        setState(() {
          _isLoading = false;
        });
      }
    }

    try {
      if (widget.byteImage != null) {
        await CkShare.instance.byteContent(
          title: widget.title,
          imageUrl: widget.byteImage!,
          deepLinkUrl: widget.deepLinkUrl,
          onReady: () {
            stopLoading();
            widget.onShareReady?.call();
          },
        );
      } else if (widget.imageUrl != null) {
        await CkShare.instance.content(
          title: widget.title,
          imageUrl: widget.imageUrl!,
          deepLinkUrl: widget.deepLinkUrl,
          onReady: () {
            stopLoading();
            widget.onShareReady?.call();
          },
        );
      }
      widget.onShareSuccess?.call();
    } catch (e) {
      widget.onShareError?.call(e);
    } finally {
      stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _handleShare, _isLoading);
    }

    final effectiveChild = widget.child!;
    final effectiveLoaderColor =
        widget.loaderColor ?? Theme.of(context).colorScheme.primary;

    Widget content;
    switch (widget.loaderStyle) {
      case CkShareLoaderStyle.adaptiveEdge:
        content = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              foregroundPainter: _isLoading
                  ? _AdaptiveEdgePainter(
                      progress: _controller.value,
                      color: effectiveLoaderColor,
                      trackColor: widget.trackColor ??
                          effectiveLoaderColor.withValues(alpha: 0.15),
                      strokeWidth: widget.strokeWidth,
                      strokeLengthFactor: widget.strokeLengthFactor,
                      borderRadius: widget.borderRadius,
                      shape: widget.shape,
                      paddingOffset: widget.paddingOffset,
                    )
                  : null,
              child: child,
            );
          },
          child: effectiveChild,
        );
        break;

      case CkShareLoaderStyle.replace:
        content = _isLoading
            ? (widget.customLoader ??
                SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: widget.strokeWidth,
                    valueColor: AlwaysStoppedAnimation(effectiveLoaderColor),
                  ),
                ))
            : effectiveChild;
        break;

      case CkShareLoaderStyle.overlay:
        content = Stack(
          alignment: Alignment.center,
          children: [
            effectiveChild,
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: widget.customLoader ??
                      SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: widget.strokeWidth,
                          valueColor: AlwaysStoppedAnimation(
                            effectiveLoaderColor,
                          ),
                        ),
                      ),
                ),
              ),
          ],
        );
        break;
    }

    return MouseRegion(
      cursor: _isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isLoading ? null : _handleShare,
        child: content,
      ),
    );
  }
}

/// Custom painter that draws an animated traveling stroke along the exact perimeter
/// of any shape (circle, oval, rounded rectangle, or pill).
class _AdaptiveEdgePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color? trackColor;
  final double strokeWidth;
  final double strokeLengthFactor;
  final BorderRadius? borderRadius;
  final BoxShape? shape;
  final double paddingOffset;

  _AdaptiveEdgePainter({
    required this.progress,
    required this.color,
    this.trackColor,
    required this.strokeWidth,
    required this.strokeLengthFactor,
    this.borderRadius,
    this.shape,
    this.paddingOffset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Rect.fromLTWH(
      -paddingOffset,
      -paddingOffset,
      size.width + (paddingOffset * 2),
      size.height + (paddingOffset * 2),
    );

    final path = Path();
    final isSquare = (size.width - size.height).abs() < 2.5;

    // Detect circle if explicitly requested, or if square with no rounded radius specified
    if (shape == BoxShape.circle ||
        (shape == null && isSquare && borderRadius == null)) {
      path.addOval(rect);
    } else {
      final r = borderRadius ?? BorderRadius.circular(8.0);
      path.addRRect(r.toRRect(rect));
    }

    // 1. Draw background track if track color has opacity
    if (trackColor != null && trackColor!.a > 0) {
      final trackPaint = Paint()
        ..color = trackColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, trackPaint);
    }

    // 2. Compute metrics and extract the traveling beam
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final totalLength = metric.length;
    if (totalLength <= 0) return;

    final segmentLength = totalLength * strokeLengthFactor.clamp(0.05, 0.95);
    final start = (progress * totalLength) % totalLength;
    final end = start + segmentLength;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (end <= totalLength) {
      final extract = metric.extractPath(start, end);
      canvas.drawPath(extract, strokePaint);
    } else {
      final extract1 = metric.extractPath(start, totalLength);
      final extract2 = metric.extractPath(0, end - totalLength);
      canvas.drawPath(extract1, strokePaint);
      canvas.drawPath(extract2, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_AdaptiveEdgePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shape != shape ||
        oldDelegate.paddingOffset != paddingOffset;
  }
}
