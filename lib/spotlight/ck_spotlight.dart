/*
 * @Author: Km Muzahid
 * @Date: 2026-01-08 15:22:55
 * @Email: km.muzahid@gmail.com
 */
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CkSpotlight extends StatelessWidget {
  final Offset center;
  final double radius;
  final Color color;

  const CkSpotlight({
    super.key,
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _CkSpotlightPainter(center: center, radius: radius, color: color),
    );
  }
}

class _CkSpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _CkSpotlightPainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create smooth radial gradient with many steps to avoid rings
    final colors = <Color>[];
    final stops = <double>[];

    const steps = 30; // More steps = smoother spotlight

    for (var i = 0; i <= steps; i++) {
      final t = i / steps;

      // Exponential falloff for smooth spotlight effect
      final falloff = _calculateFalloff(t);

      colors.add(color.withValues(alpha: color.a * falloff));
      stops.add(t);
    }

    final gradient = ui.Gradient.radial(
      center,
      radius,
      colors,
      stops,
      TileMode.clamp,
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    // Draw the spotlight
    canvas.drawCircle(center, radius, paint);
  }

  // Smooth exponential falloff
  double _calculateFalloff(double distance) {
    // exp(-d^2 * 6.0) creates smooth spotlight effect
    return _fastExp(-distance * distance * 6.0);
  }

  // Fast exp approximation
  double _fastExp(double x) {
    if (x < -10) return 0.0;
    if (x > 0) return 1.0;

    // Using exp approximation for smooth falloff
    var result = 1.0 + x;
    var term = x;

    for (var i = 2; i < 8; i++) {
      term *= x / i;
      result += term;
    }

    return result.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _CkSpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color;
  }
}

// BONUS: More accurate exponential falloff version
class CkSpotlightAdvanced extends StatelessWidget {
  final Offset center;
  final double radius;
  final Color color;
  final int gradientSteps; // More steps = smoother gradient

  const CkSpotlightAdvanced({
    super.key,
    required this.center,
    required this.radius,
    required this.color,
    this.gradientSteps = 100,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _CkSpotlightAdvancedPainter(
        center: center,
        radius: radius,
        color: color,
        gradientSteps: gradientSteps,
      ),
    );
  }
}

class _CkSpotlightAdvancedPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final int gradientSteps;

  _CkSpotlightAdvancedPainter({
    required this.center,
    required this.radius,
    required this.color,
    required this.gradientSteps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Generate colors with exponential falloff matching the shader
    final colors = <Color>[];
    final stops = <double>[];

    for (var i = 0; i <= gradientSteps; i++) {
      final t = i / gradientSteps;

      // Match shader's exponential falloff: exp(-d * d * 6.0)
      final falloff = _exponentialFalloff(t);

      colors.add(color.withValues(alpha: color.a * falloff));
      stops.add(t);
    }

    final gradient = ui.Gradient.radial(
      center,
      radius,
      colors,
      stops,
      TileMode.clamp,
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  // Exponential falloff matching shader: exp(-d * d * 6.0)
  double _exponentialFalloff(double distance) {
    return _exp(-distance * distance * 6.0);
  }

  // Fast approximation of exp() for performance
  double _exp(double x) {
    if (x < -10) return 0.0;
    if (x > 10) return 1.0;

    // Taylor series approximation (good enough for visuals)
    var result = 1.0;
    var term = 1.0;

    for (var i = 1; i < 10; i++) {
      term *= x / i;
      result += term;
    }

    return result.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _CkSpotlightAdvancedPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.gradientSteps != gradientSteps;
  }
}



