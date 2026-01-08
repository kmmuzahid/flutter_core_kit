/*
 * @Author: Km Muzahid
 * @Date: 2026-01-08 15:22:55
 * @Email: km.muzahid@gmail.com
 */
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CoreSpotlight extends StatelessWidget {
  final Offset center;
  final double radius;
  final Color color;

  const CoreSpotlight({super.key, required this.center, required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SpotlightPainter(center: center, radius: radius, color: color),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _SpotlightPainter({required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Create smooth radial gradient with many steps to avoid rings
    final colors = <Color>[];
    final stops = <double>[];

    const steps = 30; // More steps = smoother spotlight

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;

      // Exponential falloff for smooth spotlight effect
      final falloff = _calculateFalloff(t);

      colors.add(color.withOpacity(color.opacity * falloff));
      stops.add(t);
    }

    final gradient = ui.Gradient.radial(center, radius, colors, stops, TileMode.clamp);

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
    double result = 1.0 + x;
    double term = x;

    for (int i = 2; i < 8; i++) {
      term *= x / i;
      result += term;
    }

    return result.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color;
  }
}

// BONUS: More accurate exponential falloff version
class CoreSpotlightAdvanced extends StatelessWidget {
  final Offset center;
  final double radius;
  final Color color;
  final int gradientSteps; // More steps = smoother gradient

  const CoreSpotlightAdvanced({
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
      painter: _SpotlightAdvancedPainter(
        center: center,
        radius: radius,
        color: color,
        gradientSteps: gradientSteps,
      ),
    );
  }
}

class _SpotlightAdvancedPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final int gradientSteps;

  _SpotlightAdvancedPainter({
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

    for (int i = 0; i <= gradientSteps; i++) {
      final t = i / gradientSteps;

      // Match shader's exponential falloff: exp(-d * d * 6.0)
      final falloff = _exponentialFalloff(t);

      colors.add(color.withOpacity(color.opacity * falloff));
      stops.add(t);
    }

    final gradient = ui.Gradient.radial(center, radius, colors, stops, TileMode.clamp);

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
    double result = 1.0;
    double term = 1.0;

    for (int i = 1; i < 10; i++) {
      term *= x / i;
      result += term;
    }

    return result.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _SpotlightAdvancedPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.gradientSteps != gradientSteps;
  }
}
