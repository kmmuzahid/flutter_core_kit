/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:39:59
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/core_kit.dart';
import 'package:core_kit/core_kit_internal.dart';
import 'package:flutter/material.dart';

class CoreScreenUtils {
  CoreScreenUtils._();

  static Size? _deviceSize;
  static double? _designWidth;
  static double? _designHeight;

  static Size get deviceSize => _deviceSize ?? coreKitInstance.designSize;

  static void init(BuildContext context, VoidCallback onComplete) {
    _deviceSize = MediaQuery.of(context).size;
    _designWidth = coreKitInstance.designSize.width;
    _designHeight = coreKitInstance.designSize.height;
    onComplete();
  }

  static double _scale() {
    final width = _designWidth;
    final height = _designHeight;
    final device = _deviceSize;
    if (width == null || height == null || device == null || width == 0 || height == 0) {
      return 1.0;
    }
    return device.width / width < device.height / height
        ? device.width / width
        : device.height / height;
  }

  static double width({required num value}) => value * _scale();
  static double height({required num value}) => value * _scale();
  static double radius({required num value}) => value * _scale();
  static double sp({required num value}) => value * _scale();
}

// ---------------------------------------------------------------------------
// Gap helpers
// ---------------------------------------------------------------------------

extension GapExtesntion on int {
  Widget get width => SizedBox(width: toDouble());
  Widget get height => SizedBox(height: toDouble());
}

// ---------------------------------------------------------------------------
// Responsive extensions – int
// ---------------------------------------------------------------------------

extension responsive on int {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

// ---------------------------------------------------------------------------
// Responsive extensions – double
// ---------------------------------------------------------------------------

extension responsiveDouble on double {
  double get w => CoreScreenUtils.width(value: this);
  double get h => CoreScreenUtils.height(value: this);
  double get r => CoreScreenUtils.radius(value: this);
  double get sp => CoreScreenUtils.sp(value: this);
}

// ---------------------------------------------------------------------------
// Aspect ratio extension – Size
// ---------------------------------------------------------------------------

extension AspectRatioRecord on (num width, num height) {
  double get ar => Size($1.toDouble(), $2.toDouble()).ar;
}

extension AspectRatioExtension on Size {
  /// Returns the aspect ratio of this [Size] treated as Figma widget
  /// dimensions, scaled to fit the actual device screen.
  ///
  /// The design frame dimensions come from [CoreScreenUtils.init] — no extra
  /// arguments needed.
  ///
  /// Falls back to the raw Figma ratio (width / height) if called before
  /// [CoreScreenUtils.init].
  ///
  /// Usage:
  /// ```dart
  /// AspectRatio(
  ///   aspectRatio: Size(358, 200).ar,
  ///   child: MyCard(),
  /// )
  /// ```
  double get ar {
    assert(height != 0, 'Size.height must not be zero');

    final designW = CoreScreenUtils._designWidth;
    final designH = CoreScreenUtils._designHeight;
    final device = CoreScreenUtils._deviceSize;

    if (designW == null ||
        designH == null ||
        device == null ||
        designW == 0 ||
        designH == 0 ||
        height == 0) {
      return width / height;
    }

    final scaledWidth = width * (device.width / designW);
    final scaledHeight = height * (device.height / designH);

    return scaledWidth / scaledHeight;
  }
}
